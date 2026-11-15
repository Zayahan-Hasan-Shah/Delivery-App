import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final int onRoadCount;
  final int waitingCount;
  final int deliveredCount;

  const DashboardSummary({
    required this.onRoadCount,
    required this.waitingCount,
    required this.deliveredCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      onRoadCount: (json['onRoadCount'] as num?)?.toInt() ?? 0,
      waitingCount: (json['waitingCount'] as num?)?.toInt() ?? 0,
      deliveredCount: (json['deliveredCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'onRoadCount': onRoadCount,
        'waitingCount': waitingCount,
        'deliveredCount': deliveredCount,
      };

  @override
  List<Object?> get props => [onRoadCount, waitingCount, deliveredCount];
}
