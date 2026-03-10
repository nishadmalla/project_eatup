import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_eatup/core/api/api_config.dart';
import 'package:project_eatup/core/services/storage/token_service.dart';
import 'package:project_eatup/screens/restaurant_details_screen.dart';

// ✅ IMPORT YOUR NEW CONFIG FILE


// ---------------------------------
// 1. Models
// ---------------------------------
class Restaurant {
  final String id;
  final String name;
  final String address;
  final String imageUrl;

  Restaurant({required this.id, required this.name, required this.address, required this.imageUrl});

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Restaurant',
      address: json['address']?.toString() ?? 'No address provided',
      // ✅ Uses the Global Base URL for images
      imageUrl: json['restaurantImage'] != null 
          ? '${ApiConfig.baseUrl}${json['restaurantImage']}' 
          : '',
    );
  }
}

class MenuItem {
  final String id;
  final String name; 
  final String restaurantId; 
  final String category;

  MenuItem({required this.id, required this.name, required this.restaurantId, required this.category});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    var rId = json['restaurantId'] ?? json['restaurant']; 
    String parsedRestaurantId = '';
    
    if (rId is Map) {
      parsedRestaurantId = rId['_id']?.toString() ?? '';
    } else if (rId != null) {
      parsedRestaurantId = rId.toString();
    }

    return MenuItem(
      id: json['_id']?.toString() ?? '',
      name: json['itemName']?.toString() ?? '', 
      restaurantId: parsedRestaurantId,
      category: json['category']?.toString() ?? 'Other', 
    );
  }
}

// ---------------------------------
// 2. Home Screen UI
// ---------------------------------
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Restaurant> _restaurants = [];
  List<MenuItem> _menuItems = []; 
  
  bool _isLoading = true;
  String _selectedCategory = "All";
  
  String _userName = "Foodie";
  String? _profileImageUrl;

  final List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.restaurant_menu},
    {"name": "Burgers", "icon": Icons.lunch_dining},
    {"name": "Pizza", "icon": Icons.local_pizza},
    {"name": "Asian", "icon": Icons.ramen_dining},
    {"name": "Dessert", "icon": Icons.cake},
    {"name": "Drinks", "icon": Icons.local_cafe},
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _fetchAllData(); 
  }

  List<Restaurant> get _filteredRestaurants {
    if (_selectedCategory == "All") return _restaurants;

    final searchWord = _selectedCategory.toLowerCase().replaceAll(RegExp(r's$'), '');

    final matchingMenus = _menuItems.where((item) {
      final matchesCategory = item.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase();
      final matchesName = item.name.toLowerCase().contains(searchWord);
      return matchesCategory || matchesName;
    }).toList();

    final Set<String> validRestaurantIds = matchingMenus
        .map((m) => m.restaurantId)
        .where((id) => id.isNotEmpty)
        .toSet();

    return _restaurants.where((r) => validRestaurantIds.contains(r.id)).toList();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final tokenService = ref.read(tokenServiceProvider);
      final token = tokenService.getToken();
      if (token == null) return;

      final response = await Dio().get(
        // ✅ Uses Global Base URL
        '${ApiConfig.baseUrl}/api/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200 && mounted) {
        final userData = response.data['data'] ?? response.data['user'];
        setState(() {
          _userName = userData['fullName'] ?? userData['username'] ?? "Foodie";
          _profileImageUrl = userData['profileImage'];
        });
      }
    } catch (e) {
      debugPrint("Header fetch error: $e");
    }
  }

  Future<void> _fetchAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final dio = Dio();

    // 1. Fetch Restaurants
    try {
      // ✅ Uses Global Base URL
      final res = await dio.get('${ApiConfig.baseUrl}/api/restaurants');
      if (res.statusCode == 200 && res.data['success'] == true) {
        final List data = res.data['data'] ?? [];
        _restaurants = data.map((j) => Restaurant.fromJson(j)).toList();
      }
    } catch (e) {
      debugPrint("Restaurant fetch error: $e");
    }

    // 2. Fetch Individual Menus
    List<MenuItem> fetchedMenus = [];
    for (var restaurant in _restaurants) {
      try {
        // ✅ Uses Global Base URL
        final res = await dio.get('${ApiConfig.baseUrl}/api/menu/${restaurant.id}');
        if (res.statusCode == 200 && res.data['success'] == true) {
          final List data = res.data['data'] ?? [];
          fetchedMenus.addAll(data.map((j) => MenuItem.fromJson(j)));
        }
      } catch (e) {
        debugPrint("Menu fetch error for ${restaurant.name}: $e");
      }
    }
    
    _menuItems = fetchedMenus;

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _fetchUserProfile();
            await _fetchAllData();
          },
          color: Colors.orange,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildCategories(), 
                      const SizedBox(height: 24),
                      Text(
                        _selectedCategory == "All" ? "Popular Restaurants" : "Restaurants serving $_selectedCategory",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: Colors.orange)),
                )
              else if (_filteredRestaurants.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCategory == "All" 
                              ? "No restaurants found." 
                              : "No restaurants found serving $_selectedCategory.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final restaurant = _filteredRestaurants[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetailsScreen(
                                  restaurant: {
                                    'id': restaurant.id,
                                    'name': restaurant.name,
                                    'address': restaurant.address,
                                    // Strip the base URL before passing to the details screen
                                    'restaurantImage': restaurant.imageUrl.replaceAll(ApiConfig.baseUrl, ''),
                                  },
                                ),
                              ),
                            );
                          },
                          child: _buildRestaurantCard(restaurant),
                        );
                      },
                      childCount: _filteredRestaurants.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Hey there,", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                _userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: -0.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.orange,
          backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
              // ✅ Uses Global Base URL
              ? NetworkImage('${ApiConfig.baseUrl}$_profileImageUrl')
              : null,
          child: _profileImageUrl == null || _profileImageUrl!.isEmpty
              ? Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "What are you craving?",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          icon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.tune, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category["name"];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category["name"];
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Icon(
                      category["icon"], 
                      color: isSelected ? Colors.white : Colors.orange, 
                      size: 30
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category["name"], 
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, 
                      fontSize: 13,
                      color: isSelected ? Colors.orange : Colors.black,
                    )
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              clipBehavior: Clip.antiAlias,
              child: restaurant.imageUrl.isNotEmpty
                  ? Image.network(restaurant.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.storefront, color: Colors.grey))
                  : const Icon(Icons.storefront, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Expanded(child: Text(restaurant.address, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    const Text("4.8", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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