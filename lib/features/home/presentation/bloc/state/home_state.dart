import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/home/domain/entities/dashboard_summary_entity.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final DashboardSummaryEntity? summary;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    DashboardSummaryEntity? summary,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, summary, errorMessage];
}
