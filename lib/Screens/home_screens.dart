import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/expense_provider.dart';
import 'package:expense_management/screens/view/add_view.dart';  // Notez 'screens' en minuscule
import 'package:expense_management/screens/view/home_view.dart';
import 'package:expense_management/screens/view/list_hashtags_view.dart';
import 'package:expense_management/screens/view/stats_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  late PageController pageController;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar(
      ExpenseProvider expenseProvider,
      LocaleProvider localeProvider,
      AppLocalizations l10n,
      ) {
    return AppBar(
      backgroundColor: Colors.deepPurple[900],
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'EXM',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const Spacer(),
          _buildLanguageSelector(localeProvider),
          const SizedBox(width: 8),
          _buildThemeToggle(expenseProvider),
        ],
      ),
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(LocaleProvider localeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: localeProvider.locale.languageCode,
          dropdownColor: Colors.deepPurple[900],
          icon: const Icon(Icons.language, color: Colors.white),
          items: [
            _buildLanguageItem('fr', '🇫🇷', 'Français'),
            _buildLanguageItem('en', '🇬🇧', 'English'),
          ],
          onChanged: (value) {
            if (value != null) {
              localeProvider.setLocale(Locale(value));
            }
          },
        ),
      ),
    );
  }

  Widget _buildThemeToggle(ExpenseProvider expenseProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          expenseProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
          color: Colors.white,
        ),
        onPressed: () => expenseProvider.toggleDarkMode(),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: l10n.searchExpenseHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => searchController.clear(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.deepPurple[900]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.deepPurple[900]!,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.deepPurple[50],
        ),
        onChanged: (value) {
          // Implement search logic
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: _buildAppBar(expenseProvider, localeProvider, l10n),
      body: Column(
        children: [
          _buildSearchBar(l10n),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              children:  const [
               HomeView(),
               AddView(),
               ListHashtagsView(),
               StatsView(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(l10n),
    );
  }

  Widget _buildBottomNavBar(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.deepPurple[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.homeTab ,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: l10n.addTab ,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            label: l10n.listTab ,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.pie_chart),
            label: l10n.statsTab ,
          ),
        ],
        onTap: (index) {
          pageController.jumpToPage(index);
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }

  DropdownMenuItem<String> _buildLanguageItem(
      String value,
      String flag,
      String label,
      ) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}