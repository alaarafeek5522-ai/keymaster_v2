import 'package:flutter/material.dart';

class KeyModel {
  final String key;
  bool active;
  final int duration;
  final String unit;
  String? registeredAt;
  String? expiresAt;
  String? deviceId;

  KeyModel({
    required this.key,
    this.active = true,
    required this.duration,
    this.unit = 'days',
    this.registeredAt,
    this.expiresAt,
    this.deviceId,
  });

  factory KeyModel.fromJson(String key, Map<String, dynamic> json) {
    return KeyModel(
      key: key,
      active: json['active'] ?? true,
      duration: json['duration'] ?? 30,
      unit: json['unit'] ?? 'days',
      registeredAt: json['registered_at'],
      expiresAt: json['expires_at'],
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() => {
    'active': active,
    'duration': duration,
    'unit': unit,
    'registered_at': registeredAt,
    'expires_at': expiresAt,
    'device_id': deviceId,
  };

  bool get isUsed => registeredAt != null;
  
  bool get isExpired {
    if (expiresAt == null) return false;
    try {
      final exp = DateTime.parse(expiresAt!);
      return DateTime.now().isAfter(exp);
    } catch (_) {
      return false;
    }
  }

  int? get daysLeft {
    if (expiresAt == null) return null;
    try {
      final exp = DateTime.parse(expiresAt!);
      final diff = exp.difference(DateTime.now()).inDays;
      return diff > 0 ? diff : 0;
    } catch (_) {
      return null;
    }
  }

  String get status {
    if (!active) return 'معطل';
    if (isExpired) return 'منتهي';
    if (isUsed) return 'مفعل';
    return 'جديد';
  }

  Color get statusColor {
    if (!active) return const Color(0xFFFF1744);
    if (isExpired) return const Color(0xFFFF9100);
    if (isUsed) return const Color(0xFF00E676);
    return const Color(0xFF00E5FF);
  }
}
