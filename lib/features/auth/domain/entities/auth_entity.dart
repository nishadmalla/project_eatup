import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? password;
  final String? confirmPassword;

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.password,
    this.confirmPassword,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        password,
        confirmPassword,
      ];
}
