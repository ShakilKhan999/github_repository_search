import 'package:github_repository_search/data/local/repo_local_datasource.dart';

import '../../core/errors/exceptions.dart';
import '../../core/utils/connectivity_helper.dart';
import '../../core/utils/constants/api_constants.dart';
import '../models/repo_model.dart';
import '../remote/repo_remote_datasource.dart';

class RepoFetchResult {
  const RepoFetchResult({
    required this.repos,
    required this.fromCache,
    required this.offline,
  });

  final List<RepoModel> repos;
  final bool fromCache;
  final bool offline;
}

class RepoRepository {
  RepoRepository({
    required this.remote,
    required this.local,
    required this.connectivity,
  });

  final RepoRemoteDataSource remote;
  final RepoLocalDataSource local;
  final ConnectivityHelper connectivity;

  Future<RepoFetchResult> getFlutterRepos({
    required int page,
    required int perPage,
    required SortOption sortOption,
    required SortDirection sortDirection,
    bool forceRefresh = false,
  }) async {
    final hasInternet = await connectivity.hasInternet();

    if (!hasInternet) {
      final cached = await local.getCachedRepos();
      return RepoFetchResult(repos: cached, fromCache: true, offline: true);
    }

    try {
      final sort = _mapSort(sortOption);
      final order = sortDirection.name;

      final pageItems = await remote.searchFlutterRepos(
        page: page,
        perPage: perPage,
        sort: sort,
        order: order,
      );

      final existing = (page == 1 || forceRefresh)
          ? <RepoModel>[]
          : await local.getCachedRepos();

      final merged = _mergeById(
        existing,
        pageItems,
      ).take(ApiConstants.maxResults).toList(growable: false);

      await local.cacheRepos(merged);
      return RepoFetchResult(repos: merged, fromCache: false, offline: false);
    } on ApiException {
      final cached = await local.getCachedRepos();
      if (cached.isNotEmpty) {
        return RepoFetchResult(repos: cached, fromCache: true, offline: false);
      }
      rethrow;
    }
  }

  String _mapSort(SortOption option) {
    switch (option) {
      case SortOption.stars:
        return 'stars';
      case SortOption.updated:
        return 'updated';
    }
  }

  List<RepoModel> _mergeById(
    List<RepoModel> existing,
    List<RepoModel> incoming,
  ) {
    final byId = <int, RepoModel>{for (final r in existing) r.id: r};
    for (final r in incoming) {
      byId[r.id] = r;
    }
    return byId.values.toList(growable: false);
  }
}
