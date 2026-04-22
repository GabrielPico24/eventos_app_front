import 'package:event_app/features/admin/data/models/admin_dashboard_stats.dart';

class AdminDashboardState {
  final bool isLoading;
  final String? errorMessage;
  final AdminDashboardStats? stats;

  const AdminDashboardState({
    this.isLoading = false,
    this.errorMessage,
    this.stats,
  });

  AdminDashboardState copyWith({
    bool? isLoading,
    String? errorMessage,
    AdminDashboardStats? stats,
    bool clearError = false,
  }) {
    return AdminDashboardState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      stats: stats ?? this.stats,
    );
  }
}