import 'package:flutter_test/flutter_test.dart';
import 'package:golazy_app/features/auth/data/auth_api.dart';
import 'package:golazy_app/features/auth/repositories/api_auth_repository.dart';

import 'fakes/fake_secure_key_value_store.dart';
import 'support/scripted_dio_client.dart';

void main() {
  group('ApiAuthRepository', () {
    test('restoreSession returns null when nothing has been persisted', () async {
      final repo = ApiAuthRepository(
        AuthApi(ScriptedApiClient(200, const {'success': true})),
        FakeSecureKeyValueStore(),
      );

      expect(await repo.restoreSession(), isNull);
    });

    test('login persists the user so restoreSession finds it afterwards', () async {
      final storage = FakeSecureKeyValueStore();
      final repo = ApiAuthRepository(
        AuthApi(ScriptedApiClient(200, const {
          'success': true,
          'data': {
            'id': 'user-1',
            'phone': '9876543210',
            'name': 'Test User',
            'renterEnabled': true,
            'ownerEnabled': false,
            'renterVerificationStatus': 'NOT_STARTED',
            'ownerVerificationStatus': 'NOT_STARTED',
          },
        })),
        storage,
      );

      final user = await repo.login(phone: '9876543210', password: 'secret123');
      expect(user.id, 'user-1');

      final restored = await repo.restoreSession();
      expect(restored?.id, 'user-1');
      expect(restored?.phone, '9876543210');
    });

    test('register persists the user', () async {
      final storage = FakeSecureKeyValueStore();
      final repo = ApiAuthRepository(
        AuthApi(ScriptedApiClient(201, const {
          'success': true,
          'data': {
            'id': 'user-2',
            'phone': '9990001234',
            'renterEnabled': true,
            'ownerEnabled': false,
          },
        })),
        storage,
      );

      await repo.register(phone: '9990001234', otp: '123456', password: 'secret123');

      final restored = await repo.restoreSession();
      expect(restored?.id, 'user-2');
    });

    test('logout clears the persisted session', () async {
      final storage = FakeSecureKeyValueStore();
      final repo = ApiAuthRepository(
        AuthApi(ScriptedApiClient(200, const {
          'success': true,
          'data': {
            'id': 'user-1',
            'phone': '9876543210',
            'renterEnabled': true,
            'ownerEnabled': false,
          },
        })),
        storage,
      );

      await repo.login(phone: '9876543210', password: 'secret123');
      expect(await repo.restoreSession(), isNotNull);

      await repo.logout();
      expect(await repo.restoreSession(), isNull);
    });
  });
}
