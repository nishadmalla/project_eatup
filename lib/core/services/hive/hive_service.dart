
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project_eatup/core/constants/hive_table_constant.dart';
import 'package:project_eatup/features/auth/data/models/auth_model.dart';

final hiveServiceProvider = Provider<HiveService>((ref){
  return HiveService();
});


class HiveService {

  Future<void> init() async {
    // Initialization code for Hive
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName }';

    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }


  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authId)) {
      Hive.registerAdapter(AuthModelAdapter());
    }
  }


  Future<void> _openBoxes() async {
    await Hive.openBox<AuthModel>(HiveTableConstant.authTable);
  }


  Future<void> close() async {
    await Hive.close();
  }

  // Auth operations 
  Box<AuthModel> get _authBox => Hive.box<AuthModel>(HiveTableConstant.authTable);

  Future<AuthModel> signUp(AuthModel user) async {
    await _authBox.put(user.userId, user);
    return user;
  }


  Future<AuthModel?> login(String email, String password) async {
    final users = _authBox.values.where((user) => user.email == email && user.password == password);
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }
}