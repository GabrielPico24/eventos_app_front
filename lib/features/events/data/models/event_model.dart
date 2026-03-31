import 'package:event_app/features/categories/data/models/category_model.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final bool isActive;
  final CategoryModel category;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.isActive,
    required this.category,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      category: CategoryModel.fromJson(
        Map<String, dynamic>.from(json['category'] ?? {}),
      ),
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    bool? isActive,
    CategoryModel? category,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }
}