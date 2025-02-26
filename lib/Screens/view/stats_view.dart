import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense.dart';

// Déplacé en dehors de la classe StatsView
class Stats {
  final double averageExpense;
  final double maxExpense;
  final String maxExpenseTitle;
  final int activeDays;
  final int categoryCount;

  Stats({
    required this.averageExpense,
    required this.maxExpense,
    required this.maxExpenseTitle,
    required this.activeDays,
    required this.categoryCount,
  });
}

// Déplacé en dehors de la classe StatsView
class MonthlyData {
  final String month;
  final double amount;

  MonthlyData(this.month, this.amount);
}

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final expenses = expenseProvider.expenses;

    if (expenses.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalCard(context, expenseProvider),
            const SizedBox(height: 24),
            _buildSectionTitle('Tendances mensuelles'),
            _buildEnhancedMonthlyTrendsChart(context, expenses),
            const SizedBox(height: 24),
            _buildSectionTitle('Répartition par catégorie'),
            _buildCategoryPieChart(context, expenseProvider, expenses),
            const SizedBox(height: 24),
            _buildSectionTitle('Statistiques générales'),
            _buildEnhancedStatisticCards(context, expenseProvider, expenses),
          ],
        ),
      ),
    );
  }

  // Graphique de tendances mensuelles amélioré et corrigé
  Widget _buildEnhancedMonthlyTrendsChart(BuildContext context, List<Expense> expenses) {
    final monthlyData = _prepareMonthlyData(expenses);
    final maxAmount = monthlyData.fold<double>(0, (max, data) => data.amount > max ? data.amount : max);

    // Calculer la croissance d'un mois à l'autre
    final growthPercentages = <double>[];
    for (int i = 1; i < monthlyData.length; i++) {
      final previousMonth = monthlyData[i - 1].amount;
      final currentMonth = monthlyData[i].amount;
      if (previousMonth > 0) {
        final growthPercent = ((currentMonth - previousMonth) / previousMonth) * 100;
        growthPercentages.add(growthPercent);
      } else {
        growthPercentages.add(0);
      }
    }

    // Créer une palette de couleurs plus raffinée
    const primaryColor = Color(0xFF5E35B1);
    const gradientStart = Color(0xFF5E35B1);
    const gradientEnd = Color(0xFF7B1FA2);

    return Card(
      elevation: 8,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // En-tête du graphique avec légende et titre amélioré
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Évolution des dépenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aperçu des 6 derniers mois',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [gradientStart, gradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Dépenses',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Graphique principal amélioré
            Container(
              height: 250,
              padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: primaryColor.withOpacity(0.8), // CORRECTION ICI: remplacé getTooltipColor
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(10),
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final index = barSpot.x.toInt();
                          final month = monthlyData[index].month;
                          return LineTooltipItem(
                            '$month\n',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: '${barSpot.y.toStringAsFixed(2)}€',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              // Afficher la croissance si disponible
                              if (index > 0)
                                TextSpan(
                                  text: '\n${growthPercentages[index - 1].toStringAsFixed(1)}% vs mois précédent',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    touchSpotThreshold: 20,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    drawHorizontalLine: true,
                    horizontalInterval: maxAmount / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.15),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              '${value.toInt()}€',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= monthlyData.length) return const Text('');

                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              monthlyData[value.toInt()].month.substring(0, 3),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: (monthlyData.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxAmount * 1.2, // Ajouter de l'espace au-dessus du graphique
                  lineBarsData: [
                    LineChartBarData(
                      spots: monthlyData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.amount);
                      }).toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [
                          gradientStart,
                          gradientEnd,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 3.5,
                            strokeColor: primaryColor,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            gradientStart.withOpacity(0.35),
                            gradientEnd.withOpacity(0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      // Ajouter des effets de shadow pour un look plus premium
                      shadow: const Shadow(
                        blurRadius: 8,
                        color: gradientStart,
                        offset: Offset(0, 4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Ajout d'un séparateur décoratif
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.withOpacity(0.1),
                      primaryColor.withOpacity(0.3),
                      Colors.grey.withOpacity(0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Statistiques mensuelles améliorées
            if (monthlyData.length >= 2)
              _buildEnhancedMonthlyStatsRow(monthlyData, growthPercentages),
          ],
        ),
      ),
    );
  }

  // Nouvelle version améliorée de la ligne de statistiques mensuelles
  Widget _buildEnhancedMonthlyStatsRow(List<MonthlyData> monthlyData, List<double> growthPercentages) {
    // Calculer le changement global
    final firstMonth = monthlyData.first.amount;
    final lastMonth = monthlyData.last.amount;
    final totalChangePercent = firstMonth > 0
        ? ((lastMonth - firstMonth) / firstMonth) * 100
        : 0.0;

    // Trouver le meilleur et le pire mois
    int bestMonthIndex = 0;
    int worstMonthIndex = 0;

    for (int i = 1; i < growthPercentages.length; i++) {
      if (growthPercentages[i] > growthPercentages[bestMonthIndex]) {
        bestMonthIndex = i;
      }
      if (growthPercentages[i] < growthPercentages[worstMonthIndex]) {
        worstMonthIndex = i;
      }
    }

    // Couleurs thématiques
    const positiveColor = Color(0xFF4CAF50);
    const negativeColor = Color(0xFFF44336);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildEnhancedMonthlyStatItem(
            "Évolution totale",
            "${totalChangePercent.toStringAsFixed(1)}%",
            totalChangePercent >= 0 ? negativeColor : positiveColor,
            totalChangePercent >= 0 ? Icons.trending_up : Icons.trending_down,
            "Depuis ${monthlyData.first.month}",
          ),
          if (growthPercentages.isNotEmpty) ...[
            _buildEnhancedMonthlyStatItem(
              "Meilleure baisse",
              "${growthPercentages[bestMonthIndex].toStringAsFixed(1)}%",
              positiveColor,
              Icons.arrow_downward,
              "Performance max",
            ),
            _buildEnhancedMonthlyStatItem(
              "Pire hausse",
              "${growthPercentages[worstMonthIndex].toStringAsFixed(1)}%",
              negativeColor,
              Icons.arrow_upward,
              "Attention",
            ),
          ],
        ],
      ),
    );
  }

  // Élément de statistique mensuelle amélioré
  Widget _buildEnhancedMonthlyStatItem(String label, String value, Color color, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context, ExpenseProvider provider, List<Expense> expenses) {
    final categories = _calculateCategoryTotals(expenses);
    final totalExpenses = provider.totalExpenses;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: categories.entries.map((entry) {
                    final percentage = (entry.value / totalExpenses) * 100;
                    return PieChartSectionData(
                      color: _getCategoryColor(entry.key.name),
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categories.entries.map((entry) {
                return _buildCategoryLegendItem(
                  entry.key.name,
                  _getCategoryColor(entry.key.name),
                  ((entry.value / totalExpenses) * 100).toStringAsFixed(0),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryLegendItem(String category, Color color, String percentage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStatisticCards(BuildContext context, ExpenseProvider provider, List<Expense> expenses) {
    final stats = _calculateStats(provider, expenses);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildEnhancedStatCard(
          title: 'Moyenne par dépense',
          value: '${stats.averageExpense.toStringAsFixed(2)}€',
          icon: Icons.analytics_outlined,
          gradientColors: const [Colors.blue, Colors.lightBlueAccent],
        ),
        _buildEnhancedStatCard(
          title: 'Dépense max',
          value: '${stats.maxExpense.toStringAsFixed(2)}€',
          subtitle: stats.maxExpenseTitle,
          icon: Icons.arrow_upward_rounded,
          gradientColors: const [Colors.purple, Colors.purpleAccent],
        ),
        _buildEnhancedStatCard(
          title: 'Jours actifs',
          value: stats.activeDays.toString(),
          icon: Icons.calendar_today_rounded,
          gradientColors: const [Colors.orange, Colors.amber],
        ),
        _buildEnhancedStatCard(
          title: 'Catégories',
          value: stats.categoryCount.toString(),
          icon: Icons.category_rounded,
          gradientColors: const [Colors.green, Colors.lightGreen],
        ),
      ],
    );
  }

  Widget _buildEnhancedStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              gradientColors[0].withOpacity(0.1),
              gradientColors[1].withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      color: gradientColors[0],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: gradientColors[0],
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: gradientColors[0].withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }

  Stats _calculateStats(ExpenseProvider provider, List<Expense> expenses) {
    final averageExpense = provider.totalExpenses / expenses.length;
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    final highestExpense = expenses.first;
    final uniqueDays = expenses
        .map((e) => DateFormat('yyyy-MM-dd').format(e.date))
        .toSet()
        .length;
    final categoryCount = _calculateCategoryTotals(expenses).length;

    return Stats(
      averageExpense: averageExpense,
      maxExpense: highestExpense.amount,
      maxExpenseTitle: highestExpense.title,
      activeDays: uniqueDays,
      categoryCount: categoryCount,
    );
  }

  List<MonthlyData> _prepareMonthlyData(List<Expense> expenses) {
    final monthlyExpenses = <String, double>{};
    for (var expense in expenses) {
      final monthKey = DateFormat('MMM yyyy').format(expense.date);
      monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0) + expense.amount;
    }

    final sortedMonths = monthlyExpenses.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMM yyyy').parse(a);
        final dateB = DateFormat('MMM yyyy').parse(b);
        return dateA.compareTo(dateB);
      });

    if (sortedMonths.length > 6) {
      sortedMonths.removeRange(0, sortedMonths.length - 6);
    }

    return sortedMonths
        .map((month) => MonthlyData(month, monthlyExpenses[month]!))
        .toList();
  }

  Map<ExpenseCategory, double> _calculateCategoryTotals(List<Expense> expenses) {
    final categoryTotals = <ExpenseCategory, double>{};

    for (var expense in expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bar_chart,
              size: 80,
              color: Colors.deepPurple.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune statistique disponible',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Ajoutez des dépenses pour voir vos statistiques et suivre votre budget',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              // Navigation vers l'ajout de dépense
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une dépense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context, ExpenseProvider provider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6A1B9A),
              Color(0xFF4A148C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total des dépenses',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.euro_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${provider.totalExpenses.toStringAsFixed(2)} €',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${provider.expenses.length} dépenses enregistrées',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'alimentation': const Color(0xFF4CAF50),
      'transport': const Color(0xFF2196F3),
      'logement': const Color(0xFFF44336),
      'loisirs': const Color(0xFFFF9800),
      'shopping': const Color(0xFF9C27B0),
      'santé': const Color(0xFF009688),
      'education': const Color(0xFF3F51B5),
      'autres': const Color(0xFF757575),
    };

    return colors[categoryName.toLowerCase()] ?? const Color(0xFF757575);
  }
}