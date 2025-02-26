// lib/providers/expense_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isDarkMode = false;

  // Constructeur qui charge les dépenses au démarrage
  ExpenseProvider() {
    loadExpenses();
  }

  // Getters
  List<Expense> get expenses => _expenses;
  bool get isDarkMode => _isDarkMode;

  // Récupère toutes les dépenses
  Future<void> loadExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = prefs.getStringList('expenses') ?? [];

      _expenses = expensesJson
          .map((expenseJson) => Expense.fromJson(jsonDecode(expenseJson)))
          .toList();

      // Charger le mode thème
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;

      notifyListeners();
    } catch (e) {
      debugPrint('Erreur de chargement des dépenses: $e');
      _expenses = []; // Initialise avec une liste vide en cas d'erreur
      notifyListeners();
    }
  }

  // Sauvegarde toutes les dépenses
  Future<void> saveExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expensesJson = _expenses
          .map((expense) => jsonEncode(expense.toJson()))
          .toList();

      await prefs.setStringList('expenses', expensesJson);
    } catch (e) {
      debugPrint('Erreur de sauvegarde des dépenses: $e');
    }
  }

  // Ajoute une nouvelle dépense
  Future<void> addExpense(Expense expense) async {
    Expense.generateHashtags(expense as String);  // Correction: ajout de l'argument expense
    _expenses.add(expense);
    await saveExpenses();
    notifyListeners();
  }

  // Met à jour une dépense existante
  Future<void> updateExpense(Expense updatedExpense) async {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index != -1) {
      Expense.generateHashtags(updatedExpense as String);  // Correction: ajout de l'argument updatedExpense
      _expenses[index] = updatedExpense;
      await saveExpenses();
      notifyListeners();
    }
  }

  // Supprime une dépense
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((expense) => expense.id == id);
    await saveExpenses();
    notifyListeners();
  }

  // Filtre les dépenses par texte de recherche
  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) {
      return _expenses;
    }
    return _expenses.where((expense) =>
    expense.title.toLowerCase().contains(query.toLowerCase()) ||
        expense.hashtags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // Filtre les dépenses par hashtag
  List<Expense> filterByHashtag(String hashtag) {
    return _expenses.where((expense) =>
        expense.hashtags.any((tag) => tag.toLowerCase() == hashtag.toLowerCase())
    ).toList();
  }

  // Bascule le mode jour/nuit
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Obtient les dépenses prédéfinies
  List<Expense> get predefinedExpenses =>
      _expenses.where((expense) => expense.isPredefined).toList();

  // Obtient les dépenses personnalisées
  List<Expense> get customExpenses =>
      _expenses.where((expense) => !expense.isPredefined).toList();

  // Calcule le total des dépenses
  double get totalExpenses =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);

  // Récupère les hashtags populaires
  List<String> getPopularHashtags() {
    final allHashtags = _expenses.expand((expense) => expense.hashtags).toList();
    final Map<String, int> tagCounts = {};

    for (final tag in allHashtags) {
      tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
    }

    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(10).map((e) => e.key).toList();
  }
}