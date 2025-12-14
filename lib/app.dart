import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:github_repository_search/features/home/presentation/home_screen.dart';
import 'core/bindings/initial_binding.dart';
import 'themes/app_theme.dart';
import 'themes/theme_controller.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (themeController) {
        return GetMaterialApp(
          title: 'Flutter GitHub Explorer',
          debugShowCheckedModeBanner: false,
          initialBinding: InitialBinding(),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeController.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
