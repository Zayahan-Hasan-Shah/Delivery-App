import 'package:delivery_app/features/rider/domain/entities/earnings_entity.dart';

class EarningsModel extends EarningsEntity {
  const EarningsModel({
    required super.todayEarningsPkr,
    required super.weekEarningsPkr,
    required super.monthEarningsPkr,
    required super.cashCollectedPkr,
    required super.cashDepositedPkr,
    required super.cashInHandPkr,
    required super.cashLimitPkr,
    required super.deliveriesToday,
    required super.deliveriesTotal,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      todayEarningsPkr: (json['today_earnings_pkr'] as num?)?.toDouble() ?? 0,
      weekEarningsPkr: (json['week_earnings_pkr'] as num?)?.toDouble() ?? 0,
      monthEarningsPkr: (json['month_earnings_pkr'] as num?)?.toDouble() ?? 0,
      cashCollectedPkr: (json['cash_collected_pkr'] as num?)?.toDouble() ?? 0,
      cashDepositedPkr: (json['cash_deposited_pkr'] as num?)?.toDouble() ?? 0,
      cashInHandPkr: (json['cash_in_hand_pkr'] as num?)?.toDouble() ?? 0,
      cashLimitPkr: (json['cash_limit_pkr'] as num?)?.toDouble() ?? 25000,
      deliveriesToday: (json['deliveries_today'] as num?)?.toInt() ?? 0,
      deliveriesTotal: (json['deliveries_total'] as num?)?.toInt() ?? 0,
    );
  }
}
