

import 'package:equatable/equatable.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registered,
  error,
}


class AuthState extends Equatable{
  final AuthStatus status;
  final String? errorMessage; 
  final AuthEntity? authEntity;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.authEntity,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? message,
    AuthEntity? authEntity,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: message ?? errorMessage,
      authEntity: authEntity ?? this.authEntity,
    );
  }

  
  @override
  // TODO: implement props
  List<Object?> get props => [status, errorMessage, authEntity];
}