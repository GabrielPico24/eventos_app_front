import 'package:event_app/features/categories/data/models/category_model.dart';

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
    this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'];

    return EventModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      repeat: json['repeat']?.toString() ?? 'never',
      isActive: json['isActive'] ?? true,
      status: json['status']?.toString() ?? 'upcoming',
      createdBy: json['createdBy']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
      notify24hBefore: json['notify24hBefore'] ?? true,
      notify1hBefore: json['notify1hBefore'] ?? true,
      notifyAtTime: json['notifyAtTime'] ?? true,
      categoryName: json['categoryName']?.toString() ?? '',
      category: categoryJson is Map<String, dynamic>
          ? CategoryModel.fromJson(categoryJson)
          : CategoryModel.empty(),
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? repeat,
    bool? isActive,
    String? status,
    String? createdBy,
    String? createdByName,
    bool? notify24hBefore,
    bool? notify1hBefore,
    bool? notifyAtTime,
    CategoryModel? category,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      repeat: repeat ?? this.repeat,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      notify24hBefore: notify24hBefore ?? this.notify24hBefore,
      notify1hBefore: notify1hBefore ?? this.notify1hBefore,
      notifyAtTime: notifyAtTime ?? this.notifyAtTime,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}