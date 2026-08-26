import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golazy_app/core/network/api_exceptions.dart';
import 'package:golazy_app/features/auth/models/auth_user.dart';
import 'package:golazy_app/features/auth/providers/auth_providers.dart';
import 'package:golazy_app/features/auth/providers/auth_state.dart';

import 'fakes/fake_auth_repository.dart';

const _user = AuthUser(
  id: 'user-1',
  phone: '9876543210',
  name: 'Test User',
  renterEnabled: true,
  ownerEnabled: false,
  renterVerificationStatus: 'NOT_STARTED',
);

void main() {
  group('AuthController', () {
    test('starts unknown, then unauthenticated when no session was stored', () async {
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(FakeAuthRepository())],
      );
      addTearDown(container.dispose);

      expect(container.read(authControllerProvider).status, AuthStatus.unknown);

      await pumpEventQueue();

      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
    });

    test('restores an authenticated session on start', () async {
      final fake = FakeAuthRepository()..sessionToRestore = _user;
      final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
      addTearDown(container.dispose);
      container.read(authControllerProvider); // trigger build() before pumping

      await pumpEventQueue();

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.id, 'user-1');
    });

    test('login transitions state to authenticated even while a restore is still pending', () async {
      final fake = FakeAuthRepository()..loginResult = _user;
      final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
      addTearDown(container.dispose);

      // Deliberately do NOT await the pending restore first: login must win
      // even if it resolves before the fire-and-forget restore does.
      await container.read(authControllerProvider.notifier).login(phone: _user.phone, password: 'secret123');
      await pumpEventQueue();

      final state = container.read(authControllerProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user?.id, _user.id);
    });

    test('a failed login rethrows and leaves state unauthenticated', () async {
      final fake = FakeAuthRepository()
        ..loginError = const ApiRequestException('Invalid phone number or password.', statusCode: 401);
      final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await pumpEventQueue();

      await expectLater(
        container.read(authControllerProvider.notifier).login(phone: _user.phone, password: 'wrong'),
        throwsA(isA<ApiRequestException>()),
      );
      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
    });

    test('register transitions state to authenticated', () async {
      final fake = FakeAuthRepository()
        ..registerResult = _user
        ..otpToReturn = '123456';
      final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await pumpEventQueue();

      final otp = await container.read(authControllerProvider.notifier).sendOtp(_user.phone);
      expect(otp, '123456');

      await container
          .read(authControllerProvider.notifier)
          .register(phone: _user.phone, otp: otp!, password: 'secret123');

      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);
    });

    test('logout returns state to unauthenticated', () async {
      final fake = FakeAuthRepository()..sessionToRestore = _user;
      final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
      addTearDown(container.dispose);
      container.read(authControllerProvider);
      await pumpEventQueue();
      expect(container.read(authControllerProvider).status, AuthStatus.authenticated);

      await container.read(authControllerProvider.notifier).logout();

      expect(container.read(authControllerProvider).status, AuthStatus.unauthenticated);
      expect(fake.loggedOut, isTrue);
    });
  });
}
