import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 1. The Cart Item Model
class CartItem {
  final String id;
  final String name;
  final double price;
  final String? image;
  final String restaurantId;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    required this.restaurantId,
    this.quantity = 1,
  });

  // Helper to copy the item with a new quantity
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      price: price,
      image: image,
      restaurantId: restaurantId,
      quantity: quantity ?? this.quantity,
    );
  }
}

// 2. The Cart Logic (StateNotifier)
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]); // Starts with an empty cart!

  void addItem(CartItem newItem) {
    // Check if the item is already in the cart
    final existingIndex = state.indexWhere((item) => item.id == newItem.id);

    if (existingIndex >= 0) {
      // If it exists, just increase the quantity
      final newState = [...state];
      newState[existingIndex] = newState[existingIndex].copyWith(
        quantity: newState[existingIndex].quantity + 1,
      );
      state = newState;
    } else {
      // If it's new, add it to the list
      state = [...state, newItem];
    }
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clearCart() {
    state = [];
  }

  // Get total price of everything in the cart
  double get totalPrice {
    return state.fold(0, (total, item) => total + (item.price * item.quantity));
  }
}

// 3. The Global Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});