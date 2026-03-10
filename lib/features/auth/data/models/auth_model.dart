import 'package:hive/hive.dart';
import 'package:project_eatup/core/constants/hive_table_constant.dart';
import 'package:project_eatup/features/auth/data/models/auth_api_model.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_model.g.dart';

@HiveType(typeId: HiveTableConstant.authId)
class AuthModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  AuthModel({
    String? userId,
    required this.name,
    required this.email,
    this.password,
  }) : userId = userId ?? Uuid().v4();

  // -------------------------------
  // From Entity → Local Model
  // -------------------------------
  factory AuthModel.fromEntity(AuthEntity entity) {
    return AuthModel(
      userId: entity.userId,
      name: entity.name.isNotEmpty ? entity.name : 'Unknown',
      email: entity.email.isNotEmpty ? entity.email : 'noemail@example.com',
      password: entity.password,
    );
  }

  // -------------------------------
  // From API → Local Model
  // -------------------------------
  factory AuthModel.fromApi(AuthApiModel apiModel) {
    return AuthModel(
      userId: apiModel.userId ?? Uuid().v4(),
      name: apiModel.fullName.isNotEmpty ? apiModel.fullName : 'Unknown',
      email: apiModel.email.isNotEmpty ? apiModel.email : 'noemail@example.com',
      password: apiModel.password,
    );
  }

  // -------------------------------
  // To Entity
  // -------------------------------
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      password: password, role: '', token: '', authId: '',
    );
  }

  // -------------------------------
  // List mapping from Hive Models → Entities
  // -------------------------------
  static List<AuthEntity> fromEntityList(List<AuthModel> models) {
    return models.map((e) => e.toEntity()).toList();
  }

  // -------------------------------
  // CopyWith (useful for clearing password)
  // -------------------------------
  AuthModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? password,
  }) {
    return AuthModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
