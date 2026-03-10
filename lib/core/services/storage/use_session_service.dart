import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Shared preff provider
final SharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("shared preferences not initialized");
});

//provider
final userSessionServiceProvider = Provider<UserSessionService>((ref){
  return UserSessionService(
    prefs: ref.read(SharedPreferencesProvider),
  );


});
class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs})
      : _prefs = prefs;

  //keys for storing data
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserEmail = 'user_email';
  static 
  static const String _keyUserFullName = 'user_full_name';
  static const String _keyUserPhoneNumber = 'phone_number';
  static const String _keyUserBatchId = 'user_batch_id';
  static const String _keyUserProfileImage = 'user_profile_image';


}