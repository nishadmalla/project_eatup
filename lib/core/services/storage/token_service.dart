import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Changed from FutureProvider to a normal Provider.
// It throws an error ONLY if we forgot to initialize it in main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

// 2. No more .when() or loading states! We just grab the ready instance directly.
final tokenServiceProvider = Provider<TokenService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TokenService(prefs);
});

class TokenService {
  static const _tokenKey = 'auth_token';
  final SharedPreferences _prefs;

  TokenService(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }
}