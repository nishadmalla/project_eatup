import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Import your dynamic IP config
import 'package:project_eatup/core/api/api_config.dart'; 

// ⚠️ Ensure these paths match your project structure
import 'package:project_eatup/features/auth/presentation/pages/cart_provider.dart';
import 'package:project_eatup/screens/dashboard_screen.dart'; 
import 'package:project_eatup/core/services/storage/order_storage_service.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isPlacingOrder = false;
  // ✅ Controller to capture address at checkout
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  // 💾 SAVE THE ORDER TO LOCAL STORAGE
  Future<void> _placeOrder() async {
    final cartItems = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).totalPrice;

    if (cartItems.isEmpty) return;

    // ✅ Validation: Ensure address is not empty
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery address! 📍'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      // 🛠️ Create the order object for Local History
      final localOrder = {
        "_id": "LOCAL-${DateTime.now().millisecondsSinceEpoch}",
        "totalAmount": total,
        "address": _addressController.text.trim(), 
        "status": "delivered", 
        "createdAt": DateTime.now().toIso8601String(),
        "items": cartItems.map((item) => {
          "itemName": item.name, 
          "quantity": item.quantity,
          "price": item.price,
        }).toList(),
      };

      // 💾 Save to phone storage
      await OrderStorageService().saveOrderLocally(localOrder);

      // ✅ Success! Clear the cart via Riverpod
      ref.read(cartProvider.notifier).clearCart();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order saved to local history! 🍔'), 
          backgroundColor: Colors.green
        ),
      );

      // Go back to the dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Error saving local order: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save order locally.'), 
          backgroundColor: Colors.red
        ),
      );
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final total = ref.read(cartProvider.notifier).totalPrice;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Your Cart', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Your cart is empty", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03), 
                              blurRadius: 10, 
                              offset: const Offset(0, 4)
                            )
                          ]
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                image: item.image != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          item.image!.startsWith('http') 
                                              ? item.image! 
                                              // ✅ UPDATED: Uses ApiConfig for images
                                              : '${ApiConfig.baseUrl}${item.image}'
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.image == null 
                                  ? const Icon(Icons.fastfood, color: Colors.grey) 
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Rs. ${item.price}", 
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text("Qty: ${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () {
                                    ref.read(cartProvider.notifier).removeItem(item.id);
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // --- CHECKOUT FOOTER ---
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                    ]
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ Address Input Field
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: "Delivery Address",
                            hintText: "e.g. Lalitpur, Ward 4",
                            prefixIcon: const Icon(Icons.location_on, color: Colors.orange),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text(
                              "Rs. $total", 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isPlacingOrder ? null : _placeOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isPlacingOrder
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Place Order", 
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}