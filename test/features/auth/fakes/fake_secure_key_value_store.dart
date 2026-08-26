import 'package:golazy_app/core/storage/secure_key_value_store.dart';

/// In-memory [SecureKeyValueStore] for tests. [FlutterSecureStorage] talks
/// to platform channels that don't exist under `flutter test`.
class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
