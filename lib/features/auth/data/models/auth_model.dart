


import 'package:hive/hive.dart';
import 'package:project_eatup/core/constants/hive_table_constant.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';
import 'package:uuid/uuid.dart';

part 'auth_model.g.dart';

@HiveType(typeId: HiveTableConstant.authId)

class AuthModel extends HiveObject{
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  AuthModel({
    String?  userId,
    required this.name,
    required this.email,
    this.password,
  }): userId = userId ?? Uuid().v4()  ;


  // from entity 
  factory AuthModel.fromEntity(AuthEntity entity) {
    return AuthModel(
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      password: entity.password,
    );
  }

  // to entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      name: name,
      email: email,
      password: password,
    );
  }

  // list model from list entity
  static List<AuthEntity> fromEntityList(List<AuthModel> model) {
    return model.map((e) => e.toEntity()).toList();
  }
}