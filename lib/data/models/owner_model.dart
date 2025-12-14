class OwnerModel {
  const OwnerModel({required this.login, required this.avatarUrl});

  final String login;
  final String avatarUrl;

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      login: (json['login'] ?? '').toString(),
      avatarUrl: (json['avatar_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'login': login, 'avatar_url': avatarUrl};
  }
}
