import 'package:event_app/features/categories/data/models/category_model.dart';

class AssignedUserModel {
  final String user;
  final String name;
  final String email;

  AssignedUserModel({
    required this.user,
    required this.name,
    required this.email,
  });

  factory AssignedUserModel.fromJson(Map<String, dynamic> json) {
    return AssignedUserModel(
      user: (json['user'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'name': name,
      'email': email,
    };
  }
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String repeat;
  final bool isActive;
  final String status;
  final String createdBy;
  final String createdByName;
  final bool notify24hBefore;
  final bool notify1hBefore;
  final bool notifyAtTime;
  final CategoryModel category;
  final String categoryName;
  final List<AssignedUserModel> assignedUsers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.repeat,
    required this.isActive,
    required this.status,
    required this.createdBy,
    required this.createdByName,
    required this.notify24hBefore,
    required this.notify1hBefore,
    required this.notifyAtTime,
    required this.category,
    required this.categoryName,
    required this.assignedUsers,
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];
    final assignedUsersJson = json['assignedUsers'] as List? ?? [];

    String createdByValue = '';
    final createdByJson = json['createdBy'];

    if (createdByJson is Map<String, dynamic>) {
      createdByValue =
          (createdByJson['_id'] ?? createdByJson['id'] ?? '').toString();
    } else {
      createdByValue = (json['createdBy'] ?? '').toString();
    }

    return EventModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      repeat: json['repeat']?.toString() ?? 'never',
      isActive: json['isActive'] ?? true,
      status: json['status']?.toString() ?? 'upcoming',
      createdBy: createdByValue,
      createdByName: json['createdByName']?.toString() ?? '',
      notify24hBefore: json['notify24hBefore'] ?? true,
      notify1hBefore: json['notify1hBefore'] ?? true,
      notifyAtTime: json['notifyAtTime'] ?? true,
      categoryName: json['categoryName']?.toString() ?? '',
      category: categoryJson is Map<String, dynamic>
          ? CategoryModel.fromJson(categoryJson)
          : CategoryModel.empty(),
      assignedUsers: assignedUsersJson
          .map((e) => AssignedUserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'repeat': repeat,
      'isActive': isActive,
      'status': status,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'notify24hBefore': notify24hBefore,
      'notify1hBefore': notify1hBefore,
      'notifyAtTime': notifyAtTime,
      'categoryName': categoryName,
      'category': category.toJson(),
      'assignedUsers': assignedUsers.map((e) => e.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
