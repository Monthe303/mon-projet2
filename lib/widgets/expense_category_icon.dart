import 'package:flutter/material.dart';

class ExpenseCategoryIcon extends StatelessWidget {
  final String categoryName;
  final bool isPredefined;
  final double size;

  const ExpenseCategoryIcon({
    super.key,
    required this.categoryName,
    required this.isPredefined,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        _getIconData(),
        color: Theme.of(context).colorScheme.primary,
        size: size * 0.6,
      ),
    );
  }

  IconData _getIconData() {
    switch (categoryName.toLowerCase()) {
      case 'alimentation':
        return Icons.restaurant; // 🍽️
      case 'transport':
        return Icons.directions_car; // 🚗
      case 'loisirs':
        return Icons.sports_esports; // 🎮
      case 'sante':
        return Icons.local_hospital; // 🏥
      case 'education':
        return Icons.school; // 🎓
      case 'divertissement':
        return Icons.movie; // 🎬
      default:
        return Icons.category; // 📂 (fallback)
    }
  }
}
