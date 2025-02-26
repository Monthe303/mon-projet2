// lib/models/expense.dart
import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData? icon;
  final Color? color;

  ExpenseCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  // Pour la sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Pour la désérialisation JSON
  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'],
      name: json['name'],
    );
  }

  get isPredefined => null;
}

class Expense {
  final String? id; // Peut être null lors de la création initiale
  final String title;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final bool isPredefined;
  final List<String> hashtags;

  Expense({
    this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.isPredefined,
    List<String>? hashtags,
  }) : hashtags = hashtags ?? generateHashtags(title);

  // Méthode pour générer les hashtags à partir du titre
  static List<String> generateHashtags(String title) {
    final words = title.split(' ');
    return words
        .where((word) => word.length > 3)
        .map((word) => word.toLowerCase())
        .toList();
  }

  // Pour la désérialisation JSON
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      category: ExpenseCategory.fromJson(json['category']),
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
      isPredefined: json['isPredefined'],
      hashtags: List<String>.from(json['hashtags']),
    );
  }

  get notes => null;

  // Pour la sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.toJson(),
      'amount': amount,
      'date': date.toISOString(),
      'isPredefined': isPredefined,
      'hashtags': hashtags,
    };
  }

  // Helper method pour la date au format ISO
  Expense copyWith({
    String? id,
    String? title,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    bool? isPredefined,
    List<String>? hashtags,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isPredefined: isPredefined ?? this.isPredefined,
      hashtags: hashtags ?? this.hashtags,
    );
  }
}

// Extension pour DateTime pour ajouter la méthode toISOString
extension DateTimeExtension on DateTime {
  String toISOString() {
    return toIso8601String();
  }
}