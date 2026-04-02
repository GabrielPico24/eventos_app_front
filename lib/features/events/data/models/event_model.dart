import 'package:event_app/features/categories/data/models/category_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String location;
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
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.location,
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
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
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
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
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
    String? startDate,
    String? endDate,
    String? startTime,
    String? endTime,
    String? location,
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
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
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