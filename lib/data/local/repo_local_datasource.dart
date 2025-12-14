import 'dart:convert';

import 'package:hive/hive.dart';

import '../../core/errors/exceptions.dart';
import '../../storage/hive_boxes.dart';
import '../models/repo_model.dart';

enum SortOption { stars, updated }

enum SortDirection { desc, asc }

class RepoLocalDataSource {
  Box get _reposBox => Hive.box(HiveBoxes.reposBox);
  Box get _settingsBox => Hive.box(HiveBoxes.settingsBox);

  static const String _reposKey = 'cached_flutter_repos_v1';
  static const String _sortKey = 'selected_sort_option_v1';
  static const String _sortDirectionKey = 'selected_sort_direction_v1';

  Future<void> cacheRepos(List<RepoModel> repos) async {
    try {
      final payload = repos.map((e) => e.toJson()).toList(growable: false);
      await _reposBox.put(_reposKey, jsonEncode(payload));
    } catch (e) {
      throw CacheException('Failed to cache repos');
    }
  }

  Future<List<RepoModel>> getCachedRepos() async {
    try {
      final raw = _reposBox.get(_reposKey);
      if (raw is! String || raw.isEmpty) return <RepoModel>[];

      final decoded = jsonDecode(raw);
      if (decoded is! List) return <RepoModel>[];

      return decoded
          .whereType<Map>()
          .map((e) => RepoModel.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    } catch (e) {
      throw CacheException('Failed to read cached repos');
    }
  }

  Future<void> saveSortOption(SortOption option) async {
    await _settingsBox.put(_sortKey, option.name);
  }

  Future<void> saveSortDirection(SortDirection direction) async {
    await _settingsBox.put(_sortDirectionKey, direction.name);
  }

  SortOption getSavedSortOption() {
    final raw = _settingsBox.get(_sortKey);
    if (raw == 'updated') return SortOption.updated;
    return SortOption.stars;
  }

  SortDirection getSavedSortDirection() {
    final raw = _settingsBox.get(_sortDirectionKey);
    if (raw == 'asc') return SortDirection.asc;
    return SortDirection.desc;
  }
}
