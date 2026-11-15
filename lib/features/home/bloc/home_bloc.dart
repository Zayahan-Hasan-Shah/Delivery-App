import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/home/bloc/home_event.dart';
import 'package:delivery_app/features/home/bloc/home_state.dart';
import 'package:delivery_app/features/home/service/home_service.dart';
import 'package:delivery_app/core/utils/app_logger.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService homeService;

  HomeBloc({required this.homeService}) : super(const HomeState()) {
    on<LoadHomeDashboardEvent>(_onLoadDashboard);
    on<RefreshHomeDashboardEvent>(_onRefreshDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadHomeDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final summary = await homeService.getDashboardSummary();
      final orders = await homeService.getRecentOrders();

      emit(state.copyWith(
        status: HomeStatus.success,
        summary: summary,
        orders: orders,
        errorMessage: null,
      ));
    } catch (e, st) {
      AppLogger.error('Failed to load home dashboard', error: e, stackTrace: st, tag: 'HomeBloc');
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: 'Unable to load dashboard data. Please try again.',
      ));
    }
  }

  Future<void> _onRefreshDashboard(
    RefreshHomeDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final summary = await homeService.getDashboardSummary();
      final orders = await homeService.getRecentOrders();
      emit(state.copyWith(
        status: HomeStatus.success,
        summary: summary,
        orders: orders,
        errorMessage: null,
      ));
    } catch (e) {
      // Keep existing data on silent refresh error
    }
  }
}
