import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✅ Import your dynamic IP config
import 'package:project_eatup/core/api/api_config.dart'; 
import 'package:project_eatup/screens/cart_screen.dart'; 
import 'package:project_eatup/features/auth/presentation/pages/cart_provider.dart';

class RestaurantDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  ConsumerState<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends ConsumerState<RestaurantDetailsScreen> {
  List<dynamic> _menuItems = [];
  bool _isLoadingMenu = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    try {
      final dio = Dio();
      final restaurantId = widget.restaurant['id']; 
      // ✅ FIX 1: Use ApiConfig for the menu API
      final String apiUrl = '${ApiConfig.baseUrl}/api/menu/$restaurantId'; 
      
      final response = await dio.get(apiUrl);

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _menuItems = response.data['data'] ?? response.data['menu'] ?? [];
          _isLoadingMenu = false;
        });
      } else {
        setState(() => _isLoadingMenu = false);
      }
    } catch (e) {
      print("Error fetching menu: $e");
      setState(() => _isLoadingMenu = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.restaurant['name'] ?? 'Unknown Restaurant';
    final address = widget.restaurant['address'] ?? 'No address provided';
    
    // ✅ FIX 2: Use ApiConfig for the main restaurant banner image
    final imageUrl = widget.restaurant['restaurantImage'] != null
        ? '${ApiConfig.baseUrl}${widget.restaurant['restaurantImage']}'
        : null;

    // Watch the cart so we can show how many items are in it!
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      
      // Floating button that appears when you have items in your cart
      floatingActionButton: cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()), 
                );
              },
              backgroundColor: Colors.orange,
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              label: Text(
                "${cartItems.length} items | Rs. ${ref.read(cartProvider.notifier).totalPrice}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            pinned: true,
            backgroundColor: Colors.orange,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade200, 
                      child: const Icon(Icons.restaurant, size: 80, color: Colors.grey)
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0.0, -30.0, 0.0), 
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey.shade400, size: 18),
                        const SizedBox(width: 4),
                        Text(address, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 40),
                    const Text("Menu", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    
                    _isLoadingMenu
                        ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.orange)))
                        : _menuItems.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: [
                                      Icon(Icons.no_meals_outlined, size: 60, color: Colors.grey.shade300),
                                      const SizedBox(height: 10),
                                      Text("No items on the menu yet.", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true, 
                                physics: const NeverScrollableScrollPhysics(), 
                                padding: EdgeInsets.zero,
                                itemCount: _menuItems.length,
                                itemBuilder: (context, index) {
                                  return _buildMenuItem(_menuItems[index]);
                                },
                              ),
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    final String itemId = item['_id'] ?? 'unknown_id';
    final String itemName = item['itemName'] ?? 'Unknown Item';
    final String itemDesc = item['description'] ?? 'Delicious food from our kitchen.';
    
    // Safely parse the price
    final double itemPrice = double.tryParse((item['price'] ?? 0).toString()) ?? 0.0;
    
    final String? itemImage = item['itemImage']; 

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              image: itemImage != null && itemImage.isNotEmpty
                  ? DecorationImage(
                      // ✅ FIX 3: Use ApiConfig for individual food item images
                      image: NetworkImage(itemImage.startsWith('http') ? itemImage : '${ApiConfig.baseUrl}$itemImage'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (itemImage == null || itemImage.isEmpty) ? const Icon(Icons.fastfood, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(itemDesc, style: TextStyle(color: Colors.grey.shade500, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Rs. $itemPrice", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                    
                    InkWell(
                      onTap: () {
                        // 1. Create the cart item
                        final cartItem = CartItem(
                          id: itemId,
                          name: itemName,
                          price: itemPrice,
                          image: itemImage,
                          restaurantId: widget.restaurant['id'] ?? 'unknown',
                        );

                        // 2. Add it to Riverpod
                        ref.read(cartProvider.notifier).addItem(cartItem);

                        // 3. Show a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$itemName added to cart!'),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Add +",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}