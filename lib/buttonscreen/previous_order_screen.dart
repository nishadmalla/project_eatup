import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ⚠️ Ensure these imports match your project structure
import 'package:project_eatup/core/services/storage/order_storage_service.dart';
import 'package:project_eatup/screens/order_details_screen.dart';

class PreviousOrderScreen extends ConsumerStatefulWidget {
  const PreviousOrderScreen({super.key});

  @override
  ConsumerState<PreviousOrderScreen> createState() => _PreviousOrderScreenState();
}

class _PreviousOrderScreenState extends ConsumerState<PreviousOrderScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLocalHistory();
  }

  // 📖 READ DIRECTLY FROM PHONE MEMORY
  Future<void> _loadLocalHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    // Using our new local service instead of Dio/Network
    final history = await OrderStorageService().getLocalOrders();

    if (!mounted) return;
    setState(() {
      _orders = history;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'delivered': return Colors.green;
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Previous Orders",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  // Added a refresh button just in case
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadLocalHistory,
                  )
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadLocalHistory,
                color: Colors.orange,
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  "No local history found.",
                  style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text("Orders you place will be saved here!"),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String status = order['status']?.toString() ?? 'delivered';
    final double total = double.tryParse(order['totalAmount']?.toString() ?? '0') ?? 0.0;
    
    // Formatting local ID
    final String fullId = order['_id']?.toString() ?? '';
    final String displayId = fullId.length > 6 
        ? fullId.substring(fullId.length - 6).toUpperCase() 
        : "LOCAL";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order #$displayId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Total Paid", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text("Rs. $total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderDetailsScreen(order: order)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  foregroundColor: Colors.orange,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("View Details"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}