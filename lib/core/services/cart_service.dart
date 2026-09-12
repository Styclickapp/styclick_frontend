import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItemModel {
  final String id;
  final String name;
  final String storeName;
  final double price;
  final String size;
  int quantity;
  final String image;
  bool isSelected;
  final String vendorType;
  final String? vendorId;
  final String? vendorEmail;
  final String? vendorPhone;
  final String? vendorAddress;
  final String? vendorBio;
  final String? vendorSpecialization;
  final String? vendorBanner;
  final String? vendorAvatar;
  final String? category;
  final String? description;

  CartItemModel({
    required this.id,
    required this.name,
    required this.storeName,
    required this.price,
    required this.size,
    required this.quantity,
    required this.image,
    this.isSelected = true,
    this.vendorType = 'seller',
    this.vendorId,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorAddress,
    this.vendorBio,
    this.vendorSpecialization,
    this.vendorBanner,
    this.vendorAvatar,
    this.category,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'storeName': storeName,
      'price': price,
      'size': size,
      'quantity': quantity,
      'image': image,
      'isSelected': isSelected,
      'vendorType': vendorType,
      'vendorId': vendorId,
      'vendorEmail': vendorEmail,
      'vendorPhone': vendorPhone,
      'vendorAddress': vendorAddress,
      'vendorBio': vendorBio,
      'vendorSpecialization': vendorSpecialization,
      'vendorBanner': vendorBanner,
      'vendorAvatar': vendorAvatar,
      'category': category,
      'description': description,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      storeName: json['storeName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      size: json['size'] ?? '',
      quantity: json['quantity'] as int? ?? 1,
      image: json['image'] ?? '',
      isSelected: json['isSelected'] as bool? ?? true,
      vendorType: json['vendorType'] ?? 'seller',
      vendorId: json['vendorId'],
      vendorEmail: json['vendorEmail'],
      vendorPhone: json['vendorPhone'],
      vendorAddress: json['vendorAddress'],
      vendorBio: json['vendorBio'],
      vendorSpecialization: json['vendorSpecialization'],
      vendorBanner: json['vendorBanner'],
      vendorAvatar: json['vendorAvatar'],
      category: json['category'],
      description: json['description'],
    );
  }
}

class CartService {
  static CartService? _instance;
  static CartService get instance {
    _instance ??= CartService._();
    return _instance!;
  }

  Future<void>? _loadFuture;

  CartService._() {
    _loadFuture = _loadCart();
  }

  Future<void> ensureLoaded() async {
    _loadFuture ??= _loadCart();
    await _loadFuture;
  }

  final ValueNotifier<List<CartItemModel>> _itemsNotifier = ValueNotifier<List<CartItemModel>>([]);

  ValueNotifier<List<CartItemModel>> get itemsNotifier => _itemsNotifier;

  List<CartItemModel> get items => List.unmodifiable(_itemsNotifier.value);

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartData = prefs.getString('styclick_cart_items');
      if (cartData != null) {
        final List<dynamic> decoded = jsonDecode(cartData);
        _itemsNotifier.value = decoded
            .map((item) => CartItemModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        _itemsNotifier.value = [];
      }
    } catch (e) {
      debugPrint('[CartService] Error loading cart: $e');
      _itemsNotifier.value = [];
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(
        _itemsNotifier.value.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('styclick_cart_items', encoded);
    } catch (e) {
      debugPrint('[CartService] Error saving cart: $e');
    }
  }

  Future<void> addToCart(CartItemModel newItem) async {
    await ensureLoaded();
    final currentList = List<CartItemModel>.from(_itemsNotifier.value);
    final existingIndex = currentList.indexWhere(
      (item) => item.name == newItem.name && item.size == newItem.size && item.storeName == newItem.storeName,
    );

    if (existingIndex != -1) {
      currentList[existingIndex].quantity += newItem.quantity;
    } else {
      currentList.add(newItem);
    }

    _itemsNotifier.value = currentList;
    _saveCart();
  }

  Future<void> removeFromCart(String id) async {
    await ensureLoaded();
    final currentList = List<CartItemModel>.from(_itemsNotifier.value);
    currentList.removeWhere((item) => item.id == id);
    _itemsNotifier.value = currentList;
    _saveCart();
  }

  Future<void> updateQuantity(String id, int quantity) async {
    await ensureLoaded();
    if (quantity <= 0) {
      removeFromCart(id);
      return;
    }
    final currentList = List<CartItemModel>.from(_itemsNotifier.value);
    final idx = currentList.indexWhere((item) => item.id == id);
    if (idx != -1) {
      currentList[idx].quantity = quantity;
      _itemsNotifier.value = currentList;
      _saveCart();
    }
  }

  Future<void> toggleSelect(String id) async {
    await ensureLoaded();
    final currentList = List<CartItemModel>.from(_itemsNotifier.value);
    final idx = currentList.indexWhere((item) => item.id == id);
    if (idx != -1) {
      currentList[idx].isSelected = !currentList[idx].isSelected;
      _itemsNotifier.value = currentList;
      _saveCart();
    }
  }

  Future<void> toggleSelectAll(bool selectAll) async {
    await ensureLoaded();
    final currentList = List<CartItemModel>.from(_itemsNotifier.value);
    for (var item in currentList) {
      item.isSelected = selectAll;
    }
    _itemsNotifier.value = currentList;
    _saveCart();
  }

  Future<void> clearCart() async {
    await ensureLoaded();
    _itemsNotifier.value = [];
    _saveCart();
  }
}
