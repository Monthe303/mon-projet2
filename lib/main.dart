import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:expense_management/screens/home_screens.dart';
import 'package:expense_management/providers/expense_provider.dart';
import 'package:expense_management/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final expenseProvider = ExpenseProvider();
  final localeProvider = LocaleProvider();
  await expenseProvider.loadExpenses();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: expenseProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ExpenseProvider>().isDarkMode;
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      title: 'EXM',
      debugShowCheckedModeBanner: false,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: const HomeScreen(),
    );
  }
}