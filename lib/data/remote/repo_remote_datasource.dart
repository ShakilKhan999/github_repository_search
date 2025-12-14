import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:github_repository_search/core/errors/exceptions.dart';
import 'package:github_repository_search/core/network/dio_clients.dart';
import '../../core/utils/constants/api_constants.dart';
import '../models/repo_model.dart';

class RepoRemoteDataSource {
  RepoRemoteDataSource({required this.dioClient});

  final DioClient dioClient;

  Future<List<RepoModel>> searchFlutterRepos({
    required int page,
    required int perPage,
    required String sort,
    required String order,
  }) async {
    try {
      final response = await dioClient.dio.get(
        ApiConstants.searchReposPath,
        queryParameters: {
          'q': ApiConstants.defaultQuery,
          'sort': sort,
          'order': order,
          'per_page': perPage,
          'page': page,
        },
      );

      debugPrint('Repo search response status: ${response.statusCode}');
      debugPrint('Repo search response data: ${response.data}');

      if (response.statusCode != 200) {
        throw ApiException('GitHub API error: ${response.statusCode}');
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ApiException('Unexpected response format');
      }

      final items = data['items'];
      if (items is! List) {
        throw ApiException('Unexpected items format');
      }

      return items
          .whereType<Map>()
          .map((e) => RepoModel.fromJson(e.cast<String, dynamic>()))
          .toList(growable: false);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map
          ? (e.response?.data['message']?.toString() ?? e.message)
          : e.message;

      if (status == 403) {
        throw ApiException('Rate limited by GitHub API. Try again later.');
      }
      throw ApiException(message ?? 'Network request failed');
    }
  }
}
