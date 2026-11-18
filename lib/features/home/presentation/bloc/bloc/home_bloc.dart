import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_app/features/home/domain/usecases/get_dashboard_summary_usecase.dart';
import 'package:delivery_app/features/home/presentation/bloc/event/home_event.dart';
import 'package:delivery_app/features/home/presentation/bloc/state/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardSummaryUseCase getDashboardSummaryUseCase;

  HomeBloc({required this.getDashboardSummaryUseCase})
      : super(const HomeState()) {
    on<LoadHomeDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadHomeDashboardEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final summary = await getDashboardSummaryUseCase(
        role: event.role,
        userId: event.userId,
      );
      emit(state.copyWith(isLoading: false, summary: summary));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load dashboard: $e',
      ));
    }
  }
}
