import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/services/storage/token_service.dart';
import 'package:project_eatup/features/auth/domain/usecases/login_usecases.dart';
import 'package:project_eatup/features/auth/domain/usecases/register_usecases.dart';
import 'package:project_eatup/features/auth/presentation/state/auth_state.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecases _registerUsecases;
  late final LoginUsecases _loginUsecases;

  @override
  AuthState build() {
    _registerUsecases = ref.read(registerUsecaseProvider);
    _loginUsecases = ref.read(loginUsecasesProvider);
    return AuthState();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = RegisterUsecasesParam(
      name: name,
      email: email,
      password: password,
    );

    final result = await _registerUsecases.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          message: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.registered,
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final params = LoginUsecasesParams(
      email: email,
      password: password,
    );

    final result = await _loginUsecases.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          message: failure.message,
        );
      },
      (authEntity) async {
        // 🔐 SAVE TOKEN HERE (THIS WAS MISSING)
        final tokenService = ref.read(tokenServiceProvider);
        await tokenService.saveToken(authEntity.token);

        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}
