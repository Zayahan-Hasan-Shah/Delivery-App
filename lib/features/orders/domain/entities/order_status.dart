import 'package:flutter/material.dart';
import 'package:delivery_app/core/theme/app_colors.dart';
import 'package:delivery_app/l10n/app_localizations.dart';

enum OrderStatus {
  placed,
  accepted,
  assigned,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
  failed;

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase().replaceAll('_', '').replaceAll(' ', '')) {
      case 'placed':
        return OrderStatus.placed;
      case 'accepted':
        return OrderStatus.accepted;
      case 'assigned':
        return OrderStatus.assigned;
      case 'pickedup':
        return OrderStatus.pickedUp;
      case 'ontheway':
        return OrderStatus.onTheWay;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'failed':
        return OrderStatus.failed;
      default:
        return OrderStatus.placed;
    }
  }

  String localizedLabel(AppLocalizations l10n) {
    switch (this) {
      case OrderStatus.placed:
        return l10n.statusPlaced;
      case OrderStatus.accepted:
        return l10n.statusAccepted;
      case OrderStatus.assigned:
        return l10n.statusAssigned;
      case OrderStatus.pickedUp:
        return l10n.statusPickedUp;
      case OrderStatus.onTheWay:
        return l10n.statusOnTheWay;
      case OrderStatus.delivered:
        return l10n.statusDelivered;
      case OrderStatus.cancelled:
        return l10n.statusCancelled;
      case OrderStatus.failed:
        return l10n.statusFailed;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.assigned:
        return 'Assigned';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
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
      case OrderStatus.failed:
        return -1;
    }
  }

  bool get isActive =>
      this != OrderStatus.delivered &&
      this != OrderStatus.cancelled &&
      this != OrderStatus.failed;

  bool get isTerminal => !isActive;
}
