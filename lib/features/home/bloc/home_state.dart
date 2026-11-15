import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/home/model/dashboard_summary.dart';
import 'package:delivery_app/features/orders/model/order_model.dart';

enum HomeStatus { initial, loading, success, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final DashboardSummary? summary;
  final List<OrderModel> orders;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.summary,
    this.orders = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    DashboardSummary? summary,
    List<OrderModel>? orders,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, summary, orders, errorMessage];
}
