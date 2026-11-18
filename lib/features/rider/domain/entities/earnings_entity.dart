import 'package:equatable/equatable.dart';

class EarningsEntity extends Equatable {
  final double todayEarningsPkr;
  final double weekEarningsPkr;
  final double monthEarningsPkr;
  final double cashCollectedPkr;
  final double cashDepositedPkr;
  final double cashInHandPkr;
  final double cashLimitPkr;
  final int deliveriesToday;
  final int deliveriesTotal;

  const EarningsEntity({
    required this.todayEarningsPkr,
    required this.weekEarningsPkr,
    required this.monthEarningsPkr,
    required this.cashCollectedPkr,
    required this.cashDepositedPkr,
    required this.cashInHandPkr,
    required this.cashLimitPkr,
    required this.deliveriesToday,
    required this.deliveriesTotal,
  });

  double get cashLimitRatio =>
      cashLimitPkr <= 0 ? 0 : (cashInHandPkr / cashLimitPkr).clamp(0.0, 1.0);

  @override
  List<Object?> get props => [
        todayEarningsPkr,
        weekEarningsPkr,
        monthEarningsPkr,
        cashCollectedPkr,
        cashDepositedPkr,
        cashInHandPkr,
        cashLimitPkr,
        deliveriesToday,
        deliveriesTotal,
      ];
}
