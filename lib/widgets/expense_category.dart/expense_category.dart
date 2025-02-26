// lib/models/expense.dart
import 'package:uuid/uuid.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final bool isPredefined;
  final String? icon;

  const ExpenseCategory({
    required this.id,
    required this.name,
    this.isPredefined = false,
    this.icon,
  });

  // Constructeur de copie
  ExpenseCategory copyWith({
    String? id,
    String? name,
    bool? isPredefined,
    String? icon,
  }) {
    return ExpenseCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      isPredefined: isPredefined ?? this.isPredefined,
      icon: icon ?? this.icon,
    );
  }

  // Conversion depuis JSON
  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      isPredefined: json['isPredefined'] as bool? ?? false,
      icon: json['icon'] as String?,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPredefined': isPredefined,
      if (icon != null) 'icon': icon,
    };
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final List<String> hashtags;
  final bool isPredefined;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    List<String>? hashtags,
    this.isPredefined = false,
  }) : id = id ?? const Uuid().v4(),
        hashtags = hashtags ?? [];

  // Constructeur de copie
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    List<String>? hashtags,
    bool? isPredefined,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      hashtags: hashtags ?? List.from(this.hashtags),
      isPredefined: isPredefined ?? this.isPredefined,
    );
  }

  // Génère des hashtags basés sur le titre et la catégorie
  void generateHashtags() {
    // Ignorer si déjà défini manuellement
    if (hashtags.isNotEmpty) return;

    // Ajouter la catégorie comme hashtag
    final List<String> tags = ['#${category.name.toLowerCase().replaceAll(' ', '_')}'];

    // Ajouter des mots-clés du titre comme hashtags supplémentaires
    final words = title.split(' ')
        .where((word) => word.length > 3) // Ignorer les mots trop courts
        .take(2) // Limiter à 2 mots maximum
        .map((word) => '#${word.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}');

    tags.addAll(words);
    hashtags.addAll(tags);
  }

  // Conversion depuis JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: ExpenseCategory.fromJson(json['category'] as Map<String, dynamic>),
      hashtags: (json['hashtags'] as List<dynamic>).map((e) => e as String).toList(),
      isPredefined: json['isPredefined'] as bool? ?? false,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toJson(),
      'hashtags': hashtags,
      'isPredefined': isPredefined,
    };
  }
}