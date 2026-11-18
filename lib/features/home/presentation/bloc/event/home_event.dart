import 'package:equatable/equatable.dart';
import 'package:delivery_app/features/authentication/domain/entities/user_role.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDashboardEvent extends HomeEvent {
  final UserRole role;
  final String userId;

  const LoadHomeDashboardEvent({
    required this.role,
    required this.userId,
  });

  @override
  List<Object?> get props => [role, userId];
}
