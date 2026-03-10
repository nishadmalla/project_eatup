import 'package:flutter_test/flutter_test.dart';
import 'package:project_eatup/features/auth/data/models/auth_api_model.dart';
import 'package:project_eatup/features/auth/domain/entities/auth_entity.dart';

void main() {
  const tJson = {
    'data': {
      '_id': '1',
      'fullName': 'John Doe',
      'email': 'john@email.com',
      'role': 'user',
      'profileImage': 'image.png',
    },
    'token': 'abc123',
  };

  test('fromJson should create AuthApiModel correctly', () {
    final model = AuthApiModel.fromJson(tJson);

    expect(model.userId, '1');
    expect(model.fullName, 'John Doe');
    expect(model.email, 'john@email.com');
    expect(model.role, 'user');
    expect(model.token, 'abc123');
  });

  test('toJson should return correct map', () {
    final model = AuthApiModel(
      fullName: 'John Doe',
      email: 'john@email.com',
      password: '123456',
    );

    final json = model.toJson();

    // ✅ Updated to match the new Zod backend fields!
    expect(json['username'], 'John Doe');
    expect(json['fullName'], 'John Doe');
    expect(json['email'], 'john@email.com');
    expect(json['password'], '123456');
    expect(json['confirmPassword'], '123456');
    expect(json['role'], 'user');
  });

  test('fromEntity should create model from entity', () {
    // ✅ Changed 'const' to 'final' to prevent constructor compile errors
    final entity = AuthEntity(
      authId: '',
      userId: '1',
      name: 'John Doe',
      email: 'john@email.com',
      password: '123456',
      role: 'user',
      token: 'abc123',
      profileImage: 'image.png',
    );

    final model = AuthApiModel.fromEntity(entity);

    expect(model.userId, '1');
    expect(model.fullName, 'John Doe');
    expect(model.email, 'john@email.com');
    expect(model.token, 'abc123');
  });

  test('toEntity should convert model to entity', () {
    final model = AuthApiModel(
      userId: '1',
      fullName: 'John Doe',
      email: 'john@email.com',
      role: 'user',
      token: 'abc123',
    );

    final entity = model.toEntity();

    expect(entity.userId, '1');
    expect(entity.name, 'John Doe');
    expect(entity.email, 'john@email.com');
    expect(entity.role, 'user');
    expect(entity.token, 'abc123');
  });

  test('fromEntityList should convert list of models to entities', () {
    final models = [
      AuthApiModel(fullName: 'User 1', email: 'u1@mail.com'),
      AuthApiModel(fullName: 'User 2', email: 'u2@mail.com'),
    ];

    // ✅ Renamed from toEntityList to fromEntityList to match your actual model
    final entities = AuthApiModel.fromEntityList(models);

    expect(entities.length, 2);
    expect(entities.first.name, 'User 1');
    expect(entities.last.email, 'u2@mail.com');
  });
}