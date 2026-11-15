import 'dart:async';
import 'package:delivery_app/core/utils/app_logger.dart';

class PushNotificationPayload {
  final String title;
  final String body;
  final String? orderId;
  final String? eventType;
  final Map<String, dynamic> rawData;

  PushNotificationPayload({
    required this.title,
    required this.body,
    this.orderId,
    this.eventType,
    this.rawData = const {},
  });

  factory PushNotificationPayload.fromMap(Map<String, dynamic> map) {
    return PushNotificationPayload(
      title: map['title'] as String? ?? 'Delivery Update',
      body: map['body'] as String? ?? '',
      orderId: map['orderId'] as String?,
      eventType: map['eventType'] as String?,
      rawData: map,
    );
  }
}

abstract class NotificationRouter {
  void handleNotificationNavigation(PushNotificationPayload payload);
}

abstract class NotificationService {
  Future<void> initialize();
  Future<String?> getFcmToken();
  Stream<PushNotificationPayload> get onNotificationReceived;
  Stream<PushNotificationPayload> get onNotificationOpened;
  void setNotificationRouter(NotificationRouter router);
  void simulateIncomingNotification(PushNotificationPayload payload);
}

class NotificationServiceImpl implements NotificationService {
  final _receivedController = StreamController<PushNotificationPayload>.broadcast();
  final _openedController = StreamController<PushNotificationPayload>.broadcast();
  NotificationRouter? _router;
  String? _fcmToken;

  @override
  Stream<PushNotificationPayload> get onNotificationReceived => _receivedController.stream;

  @override
  Stream<PushNotificationPayload> get onNotificationOpened => _openedController.stream;

  @override
  Future<void> initialize() async {
    _fcmToken = 'mock_fcm_token_${DateTime.now().millisecondsSinceEpoch}';
    AppLogger.info('Notification service initialized with token: $_fcmToken', tag: 'NotificationService');
  }

  @override
  Future<String?> getFcmToken() async {
    return _fcmToken;
  }

  @override
  void setNotificationRouter(NotificationRouter router) {
    _router = router;
  }

  @override
  void simulateIncomingNotification(PushNotificationPayload payload) {
    AppLogger.info('Notification received: ${payload.title} - ${payload.body}', tag: 'NotificationService');
    _receivedController.add(payload);
  }

  void handleNotificationTap(PushNotificationPayload payload) {
    AppLogger.info('Notification tapped: order ${payload.orderId}', tag: 'NotificationService');
    _openedController.add(payload);
    _router?.handleNotificationNavigation(payload);
  }

  void dispose() {
    _receivedController.close();
    _openedController.close();
  }
}
