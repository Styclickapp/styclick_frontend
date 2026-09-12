import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:stylclick/core/services/api_service.dart';
import 'package:stylclick/shared/endpoint.dart';

class ConversationModel {
  final String vendorName;
  final String vendorType;
  final String? productName;
  final String? productPrice;
  final String? productImage;
  final String? vendorAvatar;
  final List<Map<String, dynamic>> messages;
  final int unreadCount;
  final bool isOnline;

  ConversationModel({
    required this.vendorName,
    required this.vendorType,
    this.productName,
    this.productPrice,
    this.productImage,
    this.vendorAvatar,
    required this.messages,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  ConversationModel copyWith({
    List<Map<String, dynamic>>? messages,
    int? unreadCount,
    bool? isOnline,
    String? productName,
    String? productPrice,
    String? productImage,
  }) {
    return ConversationModel(
      vendorName: vendorName,
      vendorType: vendorType,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      vendorAvatar: vendorAvatar,
      messages: messages ?? this.messages,
      unreadCount: unreadCount ?? this.unreadCount,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorName': vendorName,
      'vendorType': vendorType,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'vendorAvatar': vendorAvatar,
      'messages': messages,
      'unreadCount': unreadCount,
      'isOnline': isOnline,
    };
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      vendorName: json['vendorName'] ?? '',
      vendorType: json['vendorType'] ?? 'seller',
      productName: json['productName'],
      productPrice: json['productPrice'],
      productImage: json['productImage'],
      vendorAvatar: json['vendorAvatar'],
      messages: List<Map<String, dynamic>>.from(
        (json['messages'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
      ),
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
    );
  }
}

class ChatService {
  static ChatService? _instance;
  static ChatService get instance {
    _instance ??= ChatService._();
    return _instance!;
  }

  ChatService._() {
    _loadFromPrefs();
  }

  static const String _prefsKey = 'styclick_chat_conversations';

  final ValueNotifier<Map<String, ConversationModel>> _conversationsNotifier =
      ValueNotifier<Map<String, ConversationModel>>({});

  ValueNotifier<Map<String, ConversationModel>> get conversationsNotifier => _conversationsNotifier;

  Map<String, ConversationModel> get conversations => _conversationsNotifier.value;

  Timer? _pollTimer;

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      syncFromBackend();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Local Cache ──────────────────────────────────────────────────────────

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dataStr = prefs.getString(_prefsKey);
      if (dataStr != null && dataStr.isNotEmpty) {
        final Map<String, dynamic> decoded = json.decode(dataStr);
        bool hasFake = false;
        final Map<String, ConversationModel> loaded = {};
        decoded.forEach((key, value) {
          final model = ConversationModel.fromJson(Map<String, dynamic>.from(value as Map));
          if (model.messages.isNotEmpty && model.messages.first['text'].toString().contains("I'm interested in")) {
            hasFake = true;
          }
          loaded[key] = model;
        });

        if (hasFake || decoded.containsKey('Adaeze Fabrics') || decoded.containsKey('Tailor Emeka')) {
          prefs.remove(_prefsKey);
          _conversationsNotifier.value = {};
        } else {
          _conversationsNotifier.value = loaded;
        }
      } else {
        _conversationsNotifier.value = {};
      }
    } catch (e) {
      log('[CHAT SERVICE] Load error: $e');
    }
    // Sync with backend API in background
    syncFromBackend();
    startPolling();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> encoded = {};
      _conversationsNotifier.value.forEach((key, model) {
        encoded[key] = model.toJson();
      });
      await prefs.setString(_prefsKey, json.encode(encoded));
    } catch (e) {
      log('[CHAT SERVICE] Save error: $e');
    }
  }

  // ── Remote Sync ──────────────────────────────────────────────────────────

  Future<void> syncFromBackend() async {
    try {
      log('[CHAT SERVICE] Syncing inbox rooms from backend...');
      final response = await ApiService.instance.get<dynamic>(chatInbox);

      if (response.status == true && response.data != null) {
        final List inboxList = response.data is List ? response.data : (response.data['data'] as List? ?? []);
        final current = Map<String, ConversationModel>.from(_conversationsNotifier.value);

        for (final item in inboxList) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(item as Map);
          final vendorName = map['vendorName'] ?? '';
          if (vendorName.isEmpty) continue;

          // Fetch latest messages for this room
          final messagesRes = await ApiService.instance.get<dynamic>(
            '$chatMessages?vendorName=${Uri.encodeComponent(vendorName)}',
          );

          List<Map<String, dynamic>> messagesList = [];
          if (messagesRes.status == true && messagesRes.data != null) {
            final List list = messagesRes.data is List ? messagesRes.data : (messagesRes.data['data'] as List? ?? []);
            messagesList = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }

          if (current.containsKey(vendorName)) {
            current[vendorName] = current[vendorName]!.copyWith(
              messages: messagesList.isNotEmpty ? messagesList : current[vendorName]!.messages,
              productName: map['productName'] ?? current[vendorName]!.productName,
              productPrice: map['productPrice'] ?? current[vendorName]!.productPrice,
              productImage: map['productImage'] ?? current[vendorName]!.productImage,
            );
          } else {
            current[vendorName] = ConversationModel(
              vendorName: vendorName,
              vendorType: map['vendorType'] ?? 'seller',
              productName: map['productName'],
              productPrice: map['productPrice'],
              productImage: map['productImage'],
              vendorAvatar: map['vendorAvatar'],
              messages: messagesList,
              unreadCount: map['unreadCount'] ?? 0,
              isOnline: map['isOnline'] ?? false,
            );
          }
        }

        _conversationsNotifier.value = current;
        await _saveToPrefs();
        log('[CHAT SERVICE] Sync complete. Active rooms: ${current.keys.length}');
      }
    } catch (e) {
      log('[CHAT SERVICE] Sync error: $e');
    }
  }

  // ── Operations ────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> getMessages(
    String vendorKey,
    String vendorType,
    String? productName, {
    String? productPrice,
    String? productImage,
    String? vendorAvatar,
  }) {
    final current = _conversationsNotifier.value;
    if (current.containsKey(vendorKey)) {
      // Clear unread count when reading
      if (current[vendorKey]!.unreadCount > 0) {
        final updated = Map<String, ConversationModel>.from(current);
        updated[vendorKey] = updated[vendorKey]!.copyWith(unreadCount: 0);
        _conversationsNotifier.value = updated;
        _saveToPrefs();
      }
      return current[vendorKey]!.messages;
    }

    // Default initial messages for new chat
    final initial = <Map<String, dynamic>>[];

    final model = ConversationModel(
      vendorName: vendorKey,
      vendorType: vendorType,
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      vendorAvatar: vendorAvatar,
      messages: initial,
      unreadCount: 0,
      isOnline: true,
    );

    final updated = Map<String, ConversationModel>.from(current);
    updated[vendorKey] = model;
    _conversationsNotifier.value = updated;
    _saveToPrefs();

    return initial;
  }

  Future<void> sendMessage(String vendorKey, Map<String, dynamic> message, String vendorType) async {
    final current = Map<String, ConversationModel>.from(_conversationsNotifier.value);
    if (!current.containsKey(vendorKey)) {
      current[vendorKey] = ConversationModel(
        vendorName: vendorKey,
        vendorType: vendorType,
        messages: [],
        isOnline: true,
      );
    }

    final model = current[vendorKey]!;
    final msgs = List<Map<String, dynamic>>.from(model.messages)..add(message);
    current[vendorKey] = model.copyWith(messages: msgs);
    _conversationsNotifier.value = current;
    await _saveToPrefs();

    // POST to backend API
    try {
      final response = await ApiService.instance.post(
        chatSendMessage,
        body: {
          'vendorName': vendorKey,
          'vendorType': vendorType,
          'text': message['text'],
          'isOffer': message['isOffer'] == true,
          'productName': model.productName,
          'productPrice': model.productPrice,
          'productImage': model.productImage,
          'vendorAvatar': model.vendorAvatar,
        },
      );
      log('[CHAT SERVICE] Message post response: ${response.status} | ${response.message}');
    } catch (e) {
      log('[CHAT SERVICE] Backend post failed: $e. Message saved locally.');
    }
  }
}
