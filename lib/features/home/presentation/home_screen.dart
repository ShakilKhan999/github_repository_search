import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/common_background.dart';
import '../../../core/utils/constants/sizer.dart';
import '../../../data/local/repo_local_datasource.dart';
import '../../../themes/theme_controller.dart';
import '../controller/home_controller.dart';
import 'widgets/repo_list_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tablet = Sizer.isTablet(context);
    return CommonBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Top Flutter Repos'),
          actions: [
            GetBuilder<ThemeController>(
              builder: (themeController) => IconButton(
                tooltip: themeController.isDark
                    ? 'Theme: Dark'
                    : 'Theme: Light',
                onPressed: themeController.toggleLightDark,
                icon: Icon(
                  themeController.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
            ),
            Obx(
              () => IconButton(
                tooltip: controller.sortDirection.value == SortDirection.desc
                    ? 'Sort: Descending'
                    : 'Sort: Ascending',
                onPressed: controller.toggleSortDirection,
                icon: Icon(
                  controller.sortDirection.value == SortDirection.desc
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                ),
              ),
            ),
            Obx(
              () => PopupMenuButton<SortOption>(
                initialValue: controller.sortOption.value,
                onSelected: controller.changeSort,
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: SortOption.stars,
                    child: Text('Sort: Stars'),
                  ),
                  PopupMenuItem(
                    value: SortOption.updated,
                    child: Text('Sort: Updated'),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Obx(() {
          final status = controller.status.value;
          if (status == HomeStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (status == HomeStatus.error && controller.repos.isEmpty) {
            return _MessageView(
              message: controller.errorMessage.value.isEmpty
                  ? 'Something went wrong.'
                  : controller.errorMessage.value,
            );
          }

          if (controller.repos.isEmpty) {
            return _MessageView(
              message: controller.errorMessage.value.isEmpty
                  ? 'No data yet.'
                  : controller.errorMessage.value,
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadRepos(forceRefresh: true),
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Trigger pagination when close to the bottom.
                if (notification.metrics.extentAfter < 300) {
                  controller.loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tablet
                          ? Sizer.w(context, 6)
                          : Sizer.w(context, 4),
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Obx(() {
                        if (!controller.isShowingCachedData.value) {
                          return const SizedBox.shrink();
                        }
                        final text = controller.isOffline.value
                            ? 'Offline: showing cached results'
                            : 'Showing cached results (refresh failed)';
                        return Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tablet
                          ? Sizer.w(context, 6)
                          : Sizer.w(context, 4),
                    ),
                    sliver: SliverList.separated(
                      itemBuilder: (_, index) {
                        final repo = controller.repos[index];
                        return RepoListTile(
                          repo: repo,
                          compact: tablet,
                          onTap: () => controller.openDetails(repo),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: controller.repos.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      if (controller.isOffline.value) {
                        return const SizedBox(height: 16);
                      }

                      if (controller.isLoadingMore.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (!controller.hasMore.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: Text('No more results')),
                        );
                      }

                      return const SizedBox(height: 16);
                    }),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
