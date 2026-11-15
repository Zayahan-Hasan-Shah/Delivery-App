import 'package:equatable/equatable.dart';

class EarningsModel extends Equatable {
  final double totalEarned;
  final double todayEarned;
  final double weekEarned;
  final int completedDeliveriesCount;
  final String currency;

  const EarningsModel({
    required this.totalEarned,
    required this.todayEarned,
    required this.weekEarned,
    required this.completedDeliveriesCount,
    this.currency = 'USD',
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      todayEarned: (json['todayEarned'] as num?)?.toDouble() ?? 0.0,
      weekEarned: (json['weekEarned'] as num?)?.toDouble() ?? 0.0,
      completedDeliveriesCount: (json['completedDeliveriesCount'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }

  Map<String, dynamic> toJson() => {
        'totalEarned': totalEarned,
        'todayEarned': todayEarned,
        'weekEarned': weekEarned,
        'completedDeliveriesCount': completedDeliveriesCount,
        'currency': currency,
      };

  @override
  List<Object?> get props => [
        totalEarned,
        todayEarned,
        weekEarned,
        completedDeliveriesCount,
        currency,
      ];
}
