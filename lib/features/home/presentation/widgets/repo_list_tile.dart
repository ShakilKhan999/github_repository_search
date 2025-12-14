import 'package:flutter/material.dart';
import 'package:github_repository_search/core/common/styles/global_text_style.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/repo_model.dart';

class RepoListTile extends StatelessWidget {
  const RepoListTile({
    super.key,
    required this.repo,
    required this.onTap,
    this.compact = false,
  });

  final RepoModel repo;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      '${repo.stargazersCount} ★',
      'Updated: ${DateFormatter.format(repo.updatedAt)}',
      if ((repo.language ?? '').isNotEmpty) repo.language!,
    ].join(' • ');

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        child: repo.owner.avatarUrl.isEmpty
            ? const Icon(Icons.person)
            : ClipOval(
                child: Image.network(
                  repo.owner.avatarUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person),
                ),
              ),
      ),
      title: Text(
        repo.fullName,
        style: GlobalTextStyle.subtitle(context),
        maxLines: compact ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        maxLines: compact ? 1 : 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
