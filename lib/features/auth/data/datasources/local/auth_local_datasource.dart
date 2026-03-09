

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/services/hive/hive_service.dart';
import 'package:project_eatup/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_eatup/features/auth/data/models/auth_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref){
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource( hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDatasource{
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService}): _hiveService = hiveService;

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final user =  await _hiveService.login(email, password);
      return Future.value(user);
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }

  @override
  Future<bool> signUp(AuthModel user) async {
    try {
      return _hiveService.signUp(user).then((value) => true);
    } catch (e) {
      throw Exception("Sign Up failed: $e");
    }
  }

}
