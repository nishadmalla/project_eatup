import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OrderStorageService {
  static const String _storageKey = 'local_order_history';

  // 💾 SAVE A NEW ORDER LOCALLY
  Future<void> saveOrderLocally(Map<String, dynamic> newOrder) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing orders first
    List<Map<String, dynamic>> orders = await getLocalOrders();
    
    // Add the new one at the top
    orders.insert(0, newOrder);
    
    // Convert the whole list to a JSON string and save
    final String encodedData = jsonEncode(orders);
    await prefs.setString(_storageKey, encodedData);
  }

  // 📖 READ ALL SAVED ORDERS
  Future<List<Map<String, dynamic>>> getLocalOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? orderString = prefs.getString(_storageKey);
    
    if (orderString == null) return [];
    
    final List<dynamic> decodedData = jsonDecode(orderString);
    return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  // 🧹 CLEAR HISTORY (Optional)
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}