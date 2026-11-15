import 'package:flutter/material.dart';
import 'package:delivery_app/core/theme/app_colors.dart';

enum OrderStatus {
  placed,
  accepted,
  assigned,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
  rejected,
  failed;

  static OrderStatus fromString(String? status) {
    if (status == null) return OrderStatus.placed;
    final normalized = status.toLowerCase().replaceAll('_', '');
    for (final s in OrderStatus.values) {
      if (s.name.toLowerCase() == normalized) return s;
    }
    switch (normalized) {
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'ontheway':
      case 'onroad':
        return OrderStatus.onTheWay;
      default:
        return OrderStatus.placed;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.accepted:
        return 'Order Accepted';
      case OrderStatus.assigned:
        return 'Rider Assigned';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.failed:
        return 'Failed';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.placed:
        return AppColors.statusPlaced;
      case OrderStatus.accepted:
        return AppColors.statusAccepted;
      case OrderStatus.assigned:
        return AppColors.statusAssigned;
      case OrderStatus.pickedUp:
        return AppColors.statusPickedUp;
      case OrderStatus.onTheWay:
        return AppColors.statusOnTheWay;
      case OrderStatus.delivered:
        return AppColors.statusDelivered;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
      case OrderStatus.rejected:
      case OrderStatus.failed:
        return AppColors.statusFailed;
    }
  }

  int get timelineOrder {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.accepted:
        return 1;
      case OrderStatus.assigned:
        return 2;
      case OrderStatus.pickedUp:
        return 3;
      case OrderStatus.onTheWay:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
      case OrderStatus.rejected:
      case OrderStatus.failed:
        return -1;
    }
  }

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.cancelled ||
      this == OrderStatus.rejected ||
      this == OrderStatus.failed;

  bool get isActive => !isTerminal;

  bool isCompletedBefore(OrderStatus current) {
    if (isTerminal && this != OrderStatus.delivered) return false;
    return timelineOrder < current.timelineOrder;
  }
}
