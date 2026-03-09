
import 'package:project_eatup/features/auth/data/models/auth_model.dart';

abstract interface class IAuthDatasource {
  Future<bool> signUp(AuthModel user);
  Future<AuthModel> login(String email, String password);
}