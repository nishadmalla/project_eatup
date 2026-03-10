import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? userId;
  final String fullName;  
  final String email;
  final String? password;
  final String? role;
  final String? token;
  final String? profileImage;

  AuthApiModel({
    this.userId,
    required this.fullName, 
    required this.email,
    this.password,
    this.role,
    this.token,
    this.profileImage,
  });

  // -------------------------------
  // From JSON (API → Model)
  // -------------------------------
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    final userData = json['data'] ?? json['user'] ?? json;
    
    return AuthApiModel(
      userId: userData['_id'] as String?,
      fullName: userData['fullName'] != null ? userData['fullName'] as String : 'Unknown', 
      email: userData['email'] != null ? userData['email'] as String : 'noemail@example.com',
      password: userData['password'] as String?,
      role: userData['role'] as String?,
      profileImage: userData['profileImage'] as String?,
      token: json['token'] as String?,
    );
  }

  // -------------------------------
  // To JSON (Model → API)
  // -------------------------------
  
// -------------------------------
  // To JSON (Model → API)
  // -------------------------------
  Map<String, dynamic> toJson() {
    return {
      "username": fullName,        // FIX 1: Map the UI's name field to what the backend wants
      "fullName": fullName,        // (Sending both just in case your DB expects fullName)
      "email": email,
      "password": password,
      "confirmPassword": password, // FIX 2: Send password again to satisfy backend validation
      "role": (role == null || role!.isEmpty) ? "user" : role, // FIX 3: Force it to say "user"
    };
  }
  // -------------------------------
  // From Entity (Domain → API)
  // -------------------------------
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      userId: entity.userId,
      fullName: entity.name.isNotEmpty ? entity.name : 'Unknown',
      email: entity.email.isNotEmpty ? entity.email : 'noemail@example.com',
      password: entity.password,
      role: entity.role ?? 'user',
      token: entity.token,
      profileImage: entity.profileImage,
    );
  }

  // -------------------------------
  // To Entity (API → Domain)
  // -------------------------------
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      name: fullName,  
      email: email,
      password: password,
      role: role ?? 'user',
      token: token ?? '',
      profileImage: profileImage, 
      authId: '',
    );
  }
  
  // -------------------------------
  // List mapping from API Models → Entities
  // -------------------------------
  static List<AuthEntity> fromEntityList(List<AuthApiModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }
}