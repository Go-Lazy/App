/// App-wide configuration values that aren't secrets and don't change
/// per-environment yet, but are kept out of feature code so they have one
/// obvious home as the app grows.
class AppConfig {
  const AppConfig._();

  /// The public GitHub repository releases are published to, used by the
  /// in-app update checker.
  static const String githubRepoOwner = 'Go-Lazy';
  static const String githubRepoName = 'App';

  /// Base URL of the GoLazy backend (Go-Lazy/backend: Node.js + Fastify).
  ///
  /// Defaults to the Android emulator's alias for the host machine's
  /// localhost. Override for a physical device or a deployed environment
  /// with `--dart-define=API_BASE_URL=http://<host>:4000`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:4000',
  );
}
