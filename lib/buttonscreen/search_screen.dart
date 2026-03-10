import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:project_eatup/core/api/api_config.dart'; // ✅ Import your new config

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // We keep TWO lists: one for all data, one for the filtered results
  List<dynamic> _allRestaurants = [];
  List<dynamic> _filteredRestaurants = [];
  
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  // Fetch the data exactly like we did on the Home Screen
  Future<void> _fetchRestaurants() async {
    try {
      final dio = Dio();
      // ✅ UPDATED: Uses dynamic IP from ApiConfig
      final response = await dio.get('${ApiConfig.baseUrl}/api/restaurants');
      
      if (response.statusCode == 200 && response.data['success'] == true) {
        if (mounted) {
          setState(() {
            _allRestaurants = response.data['data'] ?? [];
            _filteredRestaurants = List.from(_allRestaurants); // Start by showing everything
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching restaurants for search: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // The magic function that filters the list when you type!
  void _runFilter(String enteredKeyword) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      // If the search field is empty, show all restaurants
      results = List.from(_allRestaurants);
    } else {
      // Otherwise, filter based on the restaurant name
      results = _allRestaurants.where((restaurant) {
        final name = (restaurant['name'] ?? '').toString().toLowerCase();
        return name.contains(enteredKeyword.toLowerCase());
      }).toList();
    }

    // Refresh the UI with the filtered results
    setState(() {
      _filteredRestaurants = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a Scaffold without an AppBar here because your DashboardScreen already has one!
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // 1. THE SEARCH BAR
              TextField(
                controller: _searchController,
                onChanged: (value) => _runFilter(value),
                decoration: InputDecoration(
                  hintText: 'Search for a restaurant...',
                  prefixIcon: const Icon(Icons.search, color: Colors.orange),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  // Add a clear button if there is text
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                            _runFilter('');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // 2. THE RESTAURANT GRID
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : _filteredRestaurants.isEmpty
                        ? const Center(
                            child: Text(
                              'No restaurants found 😢',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            itemCount: _filteredRestaurants.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final restaurant = _filteredRestaurants[index];
                              return foodCard(
                                restaurant['name'] ?? "Unknown",
                                restaurant['address'] ?? "No address",
                                restaurant['restaurantImage'],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusing your exact foodCard design from the Home Screen!
  Widget foodCard(String name, String subtitle, String? imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null
                    // ✅ UPDATED: Uses dynamic IP from ApiConfig for images
                    ? Image.network(
                        '${ApiConfig.baseUrl}$imageUrl',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}