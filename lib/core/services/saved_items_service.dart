import 'package:flutter/foundation.dart';

class SavedItemModel {
  final String id;
  final String name;
  final double price;
  final String storeName;
  final String imagePath;
  final String? category;
  final String? rating;
  final String? vendorId;
  final String? vendorType;
  final String? vendorEmail;
  final String? vendorPhone;
  final String? vendorAddress;
  final String? vendorBio;
  final String? vendorSpecialization;
  final String? vendorBanner;
  final String? vendorAvatar;
  final String? description;

  SavedItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.storeName,
    required this.imagePath,
    this.category,
    this.rating,
    this.vendorId,
    this.vendorType,
    this.vendorEmail,
    this.vendorPhone,
    this.vendorAddress,
    this.vendorBio,
    this.vendorSpecialization,
    this.vendorBanner,
    this.vendorAvatar,
    this.description,
  });
}

class SavedItemsService {
  static SavedItemsService? _instance;
  static SavedItemsService get instance {
    _instance ??= SavedItemsService._();
    return _instance!;
  }

  SavedItemsService._() {
    _itemsNotifier.value = [];
  }

  final ValueNotifier<List<SavedItemModel>> _itemsNotifier = ValueNotifier<List<SavedItemModel>>([]);

  ValueNotifier<List<SavedItemModel>> get itemsNotifier => _itemsNotifier;

  List<SavedItemModel> get items => List.unmodifiable(_itemsNotifier.value);

  bool isFavorited(String name) {
    return _itemsNotifier.value.any((item) => item.name.toLowerCase() == name.toLowerCase());
  }

  bool toggleFavorite(SavedItemModel item) {
    final currentList = List<SavedItemModel>.from(_itemsNotifier.value);
    final idx = currentList.indexWhere((i) => i.name.toLowerCase() == item.name.toLowerCase());
    
    bool newlyAdded = false;
    if (idx != -1) {
      currentList.removeAt(idx);
      newlyAdded = false;
    } else {
      currentList.add(item);
      newlyAdded = true;
    }

    _itemsNotifier.value = currentList;
    return newlyAdded;
  }

  void removeSavedItem(String id) {
    final currentList = List<SavedItemModel>.from(_itemsNotifier.value);
    currentList.removeWhere((item) => item.id == id);
    _itemsNotifier.value = currentList;
  }
}
