import 'owner_model.dart';

class RepoModel {
  const RepoModel({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.stargazersCount,
    required this.updatedAt,
    required this.language,
    required this.htmlUrl,
    required this.owner,
  });

  final int id;
  final String name;
  final String fullName;
  final String? description;
  final int stargazersCount;
  final DateTime updatedAt;
  final String? language;
  final String htmlUrl;
  final OwnerModel owner;

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      fullName: (json['full_name'] ?? '').toString(),
      description: json['description']?.toString(),
      stargazersCount: (json['stargazers_count'] as num?)?.toInt() ?? 0,
      updatedAt:
          DateTime.tryParse((json['updated_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      language: json['language']?.toString(),
      htmlUrl: (json['html_url'] ?? '').toString(),
      owner: OwnerModel.fromJson(
        (json['owner'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'stargazers_count': stargazersCount,
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'language': language,
      'html_url': htmlUrl,
      'owner': owner.toJson(),
    };
  }
}
