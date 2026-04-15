class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String category;
  final String type;
  final bool read;
  final DateTime createdAt;
  final String userId;
  final String createdByName;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.type,
    required this.read,
    required this.createdAt,
    required this.userId,
    required this.createdByName,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      type: json['type']?.toString() ?? 'info',
      read: json['read'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      userId: json['userId']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
    );
  }
}