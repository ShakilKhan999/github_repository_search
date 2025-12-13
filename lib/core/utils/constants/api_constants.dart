class ApiConstants {
  /// Flavor support (extra credit)
  ///
  /// Override at build/run time:
  /// `--dart-define=APP_ENV=dev --dart-define=GITHUB_API_BASE_URL=https://api.github.com`
  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'prod',
  );

  static const String baseUrl = String.fromEnvironment(
    'GITHUB_API_BASE_URL',
    defaultValue: 'https://api.github.com',
  );
  static const String searchReposPath = '/search/repositories';

  static const String defaultQuery = 'Flutter';

  /// GitHub search pagination
  ///
  /// Requirement: load results using pagination (per_page=10, page=1..).
  static const int perPage = 10;

  /// App requirement: show up to the top 50 repos.
  static const int maxResults = 50;
}
