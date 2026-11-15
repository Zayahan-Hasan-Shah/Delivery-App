class RealtimeEventNames {
  // Conceptual events configured for easy backend mapping
  static const String orderStatusUpdated = 'ORDER_STATUS_UPDATED';
  static const String riderAssigned = 'RIDER_ASSIGNED';
  static const String riderLocationUpdated = 'RIDER_LOCATION_UPDATED';
  static const String orderUpdated = 'ORDER_UPDATED';
  static const String orderCancelled = 'ORDER_CANCELLED';
  static const String deliveryCompleted = 'DELIVERY_COMPLETED';

  // Subscriptions
  static const String subscribeOrder = 'SUBSCRIBE_ORDER';
  static const String unsubscribeOrder = 'UNSUBSCRIBE_ORDER';
}
