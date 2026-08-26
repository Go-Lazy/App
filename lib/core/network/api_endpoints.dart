/// Path constants for the GoLazy backend (Go-Lazy/backend: Node.js +
/// Fastify). Centralized so a path never has to be typed twice.
abstract class ApiEndpoints {
  const ApiEndpoints._();

  static const String health = '/health';

  static const String sendOtp = '/api/v1/auth/send-otp';
  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
}
