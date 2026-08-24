/// App-wide configuration values that aren't secrets and don't change
/// per-environment yet, but are kept out of feature code so they have one
/// obvious home as the app grows.
class AppConfig {
  const AppConfig._();

  /// The public GitHub repository releases are published to, used by the
  /// in-app update checker.
  static const String githubRepoOwner = 'Go-Lazy';
  static const String githubRepoName = 'App';
}
