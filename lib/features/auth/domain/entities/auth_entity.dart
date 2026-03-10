import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String name;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String token;  // ✅ Required for authentication
  final String? role;
  final String? profileImage; // ✅ For storing profile image URL

  const AuthEntity({
    this.userId,
    required this.name,
    required this.email,
    this.password,
    this.confirmPassword,
    required this.token,  // ✅ Made required
    this.role,
    this.profileImage, required String authId,
  });

  @override
  List<Object?> get props => [
        userId,
        name,
        email,
        password,
        confirmPassword,
        token,
        role,
        profileImage,
      ];

  // ✅ Added copyWith for easier updates
  AuthEntity copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? token,
    String? role,
    String? profileImage,
  }) {
    return AuthEntity(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      token: token ?? this.token,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage, authId: '',
    );
  }
}