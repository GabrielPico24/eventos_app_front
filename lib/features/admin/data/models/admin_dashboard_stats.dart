class AdminDashboardStats {
  final int totalUsers;
  final int totalEvents;
  final int pendingNotifications;

  const AdminDashboardStats({
    required this.totalUsers,
    required this.totalEvents,
    required this.pendingNotifications,
  });

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      totalUsers: int.tryParse('${json['totalUsers'] ?? 0}') ?? 0,
      totalEvents: int.tryParse('${json['totalEvents'] ?? 0}') ?? 0,
      pendingNotifications:
          int.tryParse('${json['pendingNotifications'] ?? 0}') ?? 0,
    );
  }
}