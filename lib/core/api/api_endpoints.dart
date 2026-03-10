import 'package:project_eatup/core/api/api_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "${ApiConfig.baseUrl}";

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==========Auth endpoints ======
  // ✅ ADDED the /api/auth path to match your Node.js backend
  static const String register = "/api/auth/register"; 
  static const String login = "/api/auth/login";       
}