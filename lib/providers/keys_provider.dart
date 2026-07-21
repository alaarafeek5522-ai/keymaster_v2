import 'dart:math';
import 'package:flutter/material.dart';
import '../models/key_model.dart';
import '../models/offer_model.dart';
import '../services/gist_service.dart';

class KeysProvider extends ChangeNotifier {
  Map<String, KeyModel> _keys = {};
  Map<String, dynamic> _appControl = {};
  List<OfferModel> _offers = [];
  bool _isLoading = false;
  String? _error;

  Map<String, KeyModel> get keys => _keys;
  Map<String, dynamic> get appControl => _appControl;
  List<OfferModel> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get activeCount => _keys.values.where((k) => k.active && !k.isExpired).length;
  int get expiredCount => _keys.values.where((k) => k.isExpired).length;
  int get unusedCount => _keys.values.where((k) => !k.isUsed).length;
  int get totalCount => _keys.length;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final data = await GistService.fetchData();
    if (data == null) {
      _error = 'فشل الاتصال بالسيرفر';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final keysData = data['keys'] as Map<String, dynamic>? ?? {};
    _keys = {};
    keysData.forEach((key, value) {
      _keys[key] = KeyModel.fromJson(key, value);
    });

    final offersData = data['offers'] as List? ?? [];
    _offers = offersData.map((o) => OfferModel.fromJson(o)).toList();

    _appControl = data['app_control'] as Map<String, dynamic>? ?? {};
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addKeys(int count, int duration, String unit) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    final keysData = data['keys'] as Map<String, dynamic>? ?? {};
    
    for (int i = 0; i < count; i++) {
      final key = _generateKey();
      while (keysData.containsKey(key)) {
        key == _generateKey();
      }
      keysData[key] = {
        'active': true,
        'duration': duration,
        'unit': unit,
        'registered_at': null,
        'expires_at': null,
        'device_id': null,
      };
    }

    data['keys'] = keysData;
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  Future<bool> toggleKey(String key) async {
    if (!_keys.containsKey(key)) return false;
    
    final data = await GistService.fetchData();
    if (data == null) return false;

    final keysData = data['keys'] as Map<String, dynamic>;
    keysData[key]['active'] = !keysData[key]['active'];
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  Future<bool> deleteKey(String key) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    final keysData = data['keys'] as Map<String, dynamic>;
    keysData.remove(key);
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  Future<bool> resetDevice(String key) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    final keysData = data['keys'] as Map<String, dynamic>;
    if (keysData.containsKey(key)) {
      keysData[key]['device_id'] = null;
      keysData[key]['registered_at'] = null;
      keysData[key]['expires_at'] = null;
    }
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  Future<bool> updateAppControl(Map<String, dynamic> control) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    data['app_control'] = {...data['app_control'] ?? {}, ...control};
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  // ─── OFFERS ─────────────────────────────────────────────────────

  Future<bool> addOffer(OfferModel offer) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    final offers = (data['offers'] as List? ?? []).map((o) => OfferModel.fromJson(o)).toList();
    
    // Update if exists, else add
    final index = offers.indexWhere((o) => o.id == offer.id);
    if (index >= 0) {
      offers[index] = offer;
    } else {
      offers.add(offer);
    }

    data['offers'] = offers.map((o) => o.toJson()).toList();
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  Future<bool> deleteOffer(String offerId) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    final offers = (data['offers'] as List? ?? [])
        .map((o) => OfferModel.fromJson(o))
        .where((o) => o.id != offerId)
        .toList();

    data['offers'] = offers.map((o) => o.toJson()).toList();
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  Future<bool> toggleOffer(String offerId, bool active) async {
    final data = await GistService.fetchData();
    if (data == null) return false;

    final offers = (data['offers'] as List? ?? []).map((o) => OfferModel.fromJson(o)).toList();
    final index = offers.indexWhere((o) => o.id == offerId);
    if (index >= 0) {
      offers[index] = offers[index].copyWith(active: active);
    }

    data['offers'] = offers.map((o) => o.toJson()).toList();
    
    final success = await GistService.updateData(data);
    if (success) await loadData();
    return success;
  }

  String _generateKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    String key;
    do {
      final parts = List.generate(3, (_) {
        return List.generate(4, (_) => chars[rand.nextInt(chars.length)]).join();
      });
      key = parts.join('-');
    } while (_keys.containsKey(key));
    return key;
  }
}
