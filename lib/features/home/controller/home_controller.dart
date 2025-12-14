import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:github_repository_search/data/repository/repo_repository.dart';

import '../../../core/utils/constants/api_constants.dart';
import '../../../data/local/repo_local_datasource.dart';
import '../../../data/models/repo_model.dart';

enum HomeStatus { idle, loading, loaded, error }

class HomeController extends GetxController {
  HomeController({required this.repoRepository, required this.localDataSource});

  final RepoRepository repoRepository;
  final RepoLocalDataSource localDataSource;

  final repos = <RepoModel>[].obs;
  final status = HomeStatus.idle.obs;
  final errorMessage = ''.obs;
  final sortOption = SortOption.stars.obs;
  final sortDirection = SortDirection.desc.obs;
  final isOffline = false.obs;
  final isShowingCachedData = false.obs;

  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  int _currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    sortOption.value = localDataSource.getSavedSortOption();
    sortDirection.value = localDataSource.getSavedSortDirection();
    loadRepos();
  }

  Future<void> loadRepos({bool forceRefresh = false}) async {
    _currentPage = 1;
    hasMore.value = true;
    isLoadingMore.value = false;

    status.value = HomeStatus.loading;
    errorMessage.value = '';
    isOffline.value = false;
    isShowingCachedData.value = false;
    try {
      final result = await repoRepository.getFlutterRepos(
        page: _currentPage,
        perPage: ApiConstants.perPage,
        sortOption: sortOption.value,
        sortDirection: sortDirection.value,
        forceRefresh: forceRefresh,
      );
      isOffline.value = result.offline;
      isShowingCachedData.value = result.fromCache;
      final items = (result.fromCache || result.offline)
          ? _sorted(result.repos, sortOption.value, sortDirection.value)
          : result.repos;
      repos.assignAll(items);
      status.value = HomeStatus.loaded;

      hasMore.value =
          !isOffline.value && repos.length < ApiConstants.maxResults;
      if (repos.isEmpty) {
        errorMessage.value = 'No cached data available offline.';
      }
    } catch (e) {
      status.value = HomeStatus.error;
      errorMessage.value = e.toString();
    }
  }

  Future<void> loadMore() async {
    debugPrint(
        'HomeController.loadMore called — currentPage=$_currentPage, status=${status.value}, isOffline=${isOffline.value}, repos=${repos.length}');
    if (status.value != HomeStatus.loaded) return;
    if (isOffline.value) return;
    if (!hasMore.value) return;
    if (isLoadingMore.value) return;

    isLoadingMore.value = true;
    errorMessage.value = '';

    final before = repos.length;
    final nextPage = _currentPage + 1;
    try {
      final result = await repoRepository.getFlutterRepos(
        page: nextPage,
        perPage: ApiConstants.perPage,
        sortOption: sortOption.value,
        sortDirection: sortDirection.value,
      );

      isOffline.value = result.offline;
      isShowingCachedData.value = result.fromCache;
      // Keep server ordering for paginated online results to avoid visual jumps.
      final items = (result.fromCache || result.offline)
          ? _sorted(result.repos, sortOption.value, sortDirection.value)
          : result.repos;
      repos.assignAll(items);

      final after = repos.length;
      if (after > before) {
        _currentPage = nextPage;
      }

      hasMore.value =
          !isOffline.value && after < ApiConstants.maxResults && after > before;
    } catch (e) {
      // Keep the current list and surface a lightweight message.
      errorMessage.value = e.toString();
      hasMore.value = false;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> changeSort(SortOption option) async {
    sortOption.value = option;
    await localDataSource.saveSortOption(option);
    if (isOffline.value) {
      repos.assignAll(
        _sorted(repos.toList(growable: false), option, sortDirection.value),
      );
      return;
    }
    await loadRepos(forceRefresh: true);
  }

  Future<void> toggleSortDirection() async {
    final next = sortDirection.value == SortDirection.desc
        ? SortDirection.asc
        : SortDirection.desc;
    sortDirection.value = next;
    await localDataSource.saveSortDirection(next);
    if (isOffline.value) {
      repos.assignAll(
        _sorted(repos.toList(growable: false), sortOption.value, next),
      );
      return;
    }
    await loadRepos(forceRefresh: true);
  }

  void openDetails(RepoModel repo) {}

  List<RepoModel> _sorted(
    List<RepoModel> list,
    SortOption option,
    SortDirection direction,
  ) {
    final copy = [...list];
    int compareNum(int a, int b) =>
        direction == SortDirection.desc ? b.compareTo(a) : a.compareTo(b);
    int compareDate(DateTime a, DateTime b) =>
        direction == SortDirection.desc ? b.compareTo(a) : a.compareTo(b);
    switch (option) {
      case SortOption.stars:
        copy.sort((a, b) {
          final primary = compareNum(a.stargazersCount, b.stargazersCount);
          if (primary != 0) return primary;
          // Tie-breaker for deterministic ordering (avoids list re-shuffling).
          return a.id.compareTo(b.id);
        });
        break;
      case SortOption.updated:
        copy.sort((a, b) {
          final primary = compareDate(a.updatedAt, b.updatedAt);
          if (primary != 0) return primary;
          return a.id.compareTo(b.id);
        });
        break;
    }
    return copy;
  }
}
