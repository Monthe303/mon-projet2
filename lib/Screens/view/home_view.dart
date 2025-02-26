// lib/screens/view/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../view/add_view.dart';
import 'expense_details_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisez .watch pour que le widget se reconstruise quand le provider change
    final expenseProvider = context.watch<ExpenseProvider>();
    final expenses = expenseProvider.expenses;
    final totalExpenses = expenseProvider.totalExpenses;

    return Scaffold(
      body: expenses.isEmpty
          ? _buildEmptyState()
          : _buildExpensesList(context, expenses, totalExpenses),
    );
  }

  // Affiche un état vide quand il n'y a pas de dépenses
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Aucune dépense enregistrée',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ajoutez votre première dépense en cliquant sur +',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Construit la liste des dépenses avec l'en-tête de total
  Widget _buildExpensesList(BuildContext context, List<Expense> expenses, double totalExpenses) {
    return Column(
      children: [
        // En-tête avec le total des dépenses
        _buildTotalExpensesHeader(context, totalExpenses),
        // Liste des dépenses
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return _buildExpenseItem(context, expenses[index]);
            },
          ),
        ),
      ],
    );
  }

  // En-tête avec total des dépenses
  Widget _buildTotalExpensesHeader(BuildContext context, double totalExpenses) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16), // Bordure plus arrondie
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 12, // Ombre plus douce
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total des dépenses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500, // Un peu plus visible
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${totalExpenses.toStringAsFixed(2)} €',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32, // Légèrement plus grand
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5, // Améliore la lisibilité des chiffres
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Élément de dépense individuel
  Widget _buildExpenseItem(BuildContext context, Expense expense) {
    // S'assurer que categoryName est non-null en utilisant ?? pour fournir une valeur par défaut
    final categoryName = expense.category.name;

    return Dismissible(
      key: Key(expense.id ?? ''),
      background: Container(
        color: Colors.red.shade700, // Rouge plus profond
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline, // Icône plus moderne
          color: Colors.white,
          size: 30,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Supprimer la dépense'),
            content: const Text('Voulez-vous vraiment supprimer cette dépense ?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // Dialog plus arrondi
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Supprimer', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(expense.id ?? '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Dépense supprimée'),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating, // Flottant pour un look plus moderne
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'Annuler',
              textColor: Colors.white,
              onPressed: () {
                Provider.of<ExpenseProvider>(context, listen: false).addExpense(expense);
              },
            ),
          ),
        );
      },
      child: Card(
        elevation: 3, // Ombre légèrement plus prononcée
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Plus arrondi
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Naviguer vers l'écran de détail de la dépense
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ExpenseDetailView(expense: expense),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Plus d'espace
            child: Row(
              children: [
                // Avatar avec l'icône de catégorie
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.9), // Plus visible
                  radius: 26, // Légèrement plus grand
                  child: Icon(
                    // Utiliser categoryName qui est maintenant une String non-nullable
                    _getCategoryIcon(categoryName),
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Informations sur la dépense
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 17, // Légèrement plus grand
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        categoryName, // Utilisation de la variable sécurisée
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500, // Un peu plus lisible
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('dd MMM yyyy').format(expense.date),
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Montant de la dépense
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1), // Fond subtil
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${expense.amount.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Icône d'édition
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_outlined, // Version outline pour plus de modernité
                      color: Colors.deepPurple,
                    ),
                    tooltip: 'Modifier',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddView(
                            expense: expense,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Obtenir l'icône en fonction de la catégorie
  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'alimentation':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'logement':
        return Icons.home;
      case 'loisirs':
        return Icons.sports_esports;
      case 'shopping':
        return Icons.shopping_bag;
      case 'santé':
        return Icons.healing;
      default:
        return Icons.category;
    }
  }
}