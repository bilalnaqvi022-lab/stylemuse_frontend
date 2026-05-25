import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/closet_item_model.dart';
import '../models/outfit_model.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import '../services/outfit_service.dart';

class ClosetProvider extends ChangeNotifier {
  static const String _localClosetKey = 'closet_items_local';

  List<ClosetItemModel> _items = [];
  List<OutfitModel> _savedOutfits = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;

  List<ClosetItemModel> get items => _selectedCategory == 'All'
      ? _items : _items.where((i) => i.category == _selectedCategory).toList();
  List<ClosetItemModel> get allItems => _items;
  List<OutfitModel> get savedOutfits => _savedOutfits;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;

  Future<void> loadItems() async {
    _isLoading = true; notifyListeners();
    await Future.wait([_loadClosetItems(), _loadSavedOutfits()]);
    _isLoading = false; notifyListeners();
  }

  Future<void> _loadClosetItems() async {
    try {
      final data = await ApiService.get(ApiConfig.closet);
      print("data from api: $data");
      _items = (data['items'] as List).map((i) => ClosetItemModel.fromApiMap(i)).toList();
    } catch (_) {
      // Fallback to local cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getStringList(_localClosetKey) ?? [];
      _items = cached.map((j) => ClosetItemModel.fromMap(jsonDecode(j))).toList();
    }
  }

  Future<void> _loadSavedOutfits() async {
    try {
      _savedOutfits = await OutfitService().getSavedOutfits();
    } catch (_) {}
  }

  Future<void> addItem(ClosetItemModel item) async {
    try {
      final data = await ApiService.post(ApiConfig.closet, {
        'name': item.name, 'category': item.category, 'imagePath': item.imagePath,
        'brand': item.brand, 'color': item.color, 'notes': item.notes,
      });
      final newItem = ClosetItemModel.fromApiMap(data['item']);
      _items.insert(0, newItem);
    } catch (_) {
      // Add locally if backend fails
      _items.insert(0, item);
      _cacheLocally();
    }
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    try { await ApiService.delete(ApiConfig.closetItem(id)); } catch (_) {}
    _items.removeWhere((i) => i.id == id);
    _cacheLocally();
    notifyListeners();
  }

  Future<void> saveOutfit(OutfitModel outfit) async {
    if (_savedOutfits.any((o) => o.id == outfit.id)) return;
    await OutfitService().saveOutfit(outfit.id);
    _savedOutfits.insert(0, outfit.copyWith(isSaved: true));
    notifyListeners();
  }

  Future<void> removeOutfit(String outfitId) async {
    await OutfitService().unsaveOutfit(outfitId);
    _savedOutfits.removeWhere((o) => o.id == outfitId);
    notifyListeners();
  }

  bool isOutfitSaved(String id) => _savedOutfits.any((o) => o.id == id);

  Future<void> _cacheLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_localClosetKey, _items.map((i) => jsonEncode(i.toMap())).toList());
  }

  void setCategory(String cat) { _selectedCategory = cat; notifyListeners(); }
}
