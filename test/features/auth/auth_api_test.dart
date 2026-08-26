import 'package:flutter_test/flutter_test.dart';
import 'package:golazy_app/core/network/api_exceptions.dart';
import 'package:golazy_app/features/auth/data/auth_api.dart';

import 'support/scripted_dio_client.dart';

void main() {
  group('AuthApi', () {
    test('sendOtp returns the debugOtp from a successful response', () async {
      final api = AuthApi(ScriptedApiClient(200, const {
        'success': true,
        'message': 'OTP sent successfully (Mocked in server console).',
        'debugOtp': '123456',
      }));

      expect(await api.sendOtp('9876543210'), '123456');
    });

    test('register parses the returned user', () async {
      final api = AuthApi(ScriptedApiClient(201, const {
        'success': true,
        'data': {
          'id': 'abc-123',
          'phone': '9876543210',
          'name': 'Test User',
          'renterEnabled': true,
          'ownerEnabled': false,
          'renterVerificationStatus': 'NOT_STARTED',
          'ownerVerificationStatus': 'NOT_STARTED',
        },
      }));

      final user = await api.register(
        phone: '9876543210',
        otp: '123456',
        password: 'secret123',
        name: 'Test User',
      );

      expect(user.id, 'abc-123');
      expect(user.phone, '9876543210');
      expect(user.name, 'Test User');
      expect(user.renterEnabled, isTrue);
      expect(user.ownerEnabled, isFalse);
      expect(user.renterVerificationStatus, 'NOT_STARTED');
    });

    test('login parses the returned user', () async {
      final api = AuthApi(ScriptedApiClient(200, const {
        'success': true,
        'data': {
          'id': 'abc-123',
          'phone': '9876543210',
          'renterEnabled': true,
          'ownerEnabled': false,
        },
      }));

      final user = await api.login(phone: '9876543210', password: 'secret123');
      expect(user.id, 'abc-123');
    });

    test('login throws ApiRequestException with the backend message on 401', () async {
      final api = AuthApi(ScriptedApiClient(401, const {
        'success': false,
        'error': 'Invalid phone number or password.',
      }));

      await expectLater(
        api.login(phone: '9876543210', password: 'wrong'),
        throwsA(
          isA<ApiRequestException>()
              .having((e) => e.message, 'message', 'Invalid phone number or password.')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test('register throws with the backend message on an invalid OTP', () async {
      final api = AuthApi(ScriptedApiClient(400, const {
        'success': false,
        'error': 'Invalid or expired OTP.',
      }));

      await expectLater(
        api.register(phone: '9876543210', otp: '000000', password: 'secret123'),
        throwsA(isA<ApiRequestException>().having((e) => e.message, 'message', 'Invalid or expired OTP.')),
      );
    });
  });
}
