import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/api/api_config.dart'; // ✅ Import your new config

// ⚠️ Ensure these paths match your actual project folders!
import 'package:project_eatup/core/services/storage/token_service.dart';
import 'package:project_eatup/screens/order_details_screen.dart'; 

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMyOrders();
  }

  // 📡 FETCH ORDERS FROM BACKEND
  Future<void> _fetchMyOrders() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tokenService = ref.read(tokenServiceProvider);
      final token = tokenService.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _errorMessage = "You need to be logged in to see orders.";
          _isLoading = false;
        });
        return;
      }

      final dio = Dio();
      // ✅ UPDATED: Uses dynamic IP from ApiConfig instead of 10.0.2.2
      final String apiUrl = '${ApiConfig.baseUrl}/api/orders/my-orders'; 

      final response = await dio.get(
        apiUrl,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _orders = List.from(response.data['data'] ?? []).reversed.toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load orders.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Network error. Check your laptop connection.";
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'processing': case 'preparing': return Colors.blue;
      case 'delivered': case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text("My Orders", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchMyOrders,
                color: Colors.orange,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Colors.orange));
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchMyOrders,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text("Try Again", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("No orders yet!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                Text("Looks like you haven't ordered anything.", style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(_orders[index]);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String orderId = order['_id'] ?? 'Unknown ID';
    final String shortId = orderId.length > 6 ? orderId.substring(orderId.length - 6).toUpperCase() : orderId;
    final String status = order['status'] ?? 'Pending';
    final double totalAmount = double.tryParse((order['totalAmount'] ?? 0).toString()) ?? 0.0;
    
    String dateStr = "Recently";
    if (order['createdAt'] != null) {
      try {
        final date = DateTime.parse(order['createdAt']);
        dateStr = "${date.day}/${date.month}/${date.year}";
      } catch (e) {}
    }

    final List items = order['items'] ?? [];
    int totalItemsQuantity = 0;
    for (var item in items) {
      totalItemsQuantity += (item['quantity'] as int?) ?? 1;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Order #$shortId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(status.toUpperCase(), style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text(dateStr, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.fastfood_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Text("$totalItemsQuantity item(s)", style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Amount", style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    Text("Rs. $totalAmount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                    );
                  },
                  child: const Text("View Details", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}