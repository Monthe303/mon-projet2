// lib/screens/view/add_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';

// Définir l'énumération ici pour éviter des conflits
enum DefaultExpenseCategory {
  food,
  transport,
  housing,
  entertainment,
  health,
  education
}

extension ExpenseCategoryExtension on DefaultExpenseCategory {
  String get name {
    switch (this) {
      case DefaultExpenseCategory.food:
        return 'Alimentation';
      case DefaultExpenseCategory.transport:
        return 'Transport';
      case DefaultExpenseCategory.housing:
        return 'Logement';
      case DefaultExpenseCategory.entertainment:
        return 'Divertissement';
      case DefaultExpenseCategory.health:
        return 'Santé';
      case DefaultExpenseCategory.education:
        return 'Éducation';
    }
  }

  IconData get icon {
    switch (this) {
      case DefaultExpenseCategory.food:
        return Icons.fastfood;
      case DefaultExpenseCategory.transport:
        return Icons.directions_car;
      case DefaultExpenseCategory.housing:
        return Icons.home;
      case DefaultExpenseCategory.entertainment:
        return Icons.movie;
      case DefaultExpenseCategory.health:
        return Icons.medical_services;
      case DefaultExpenseCategory.education:
        return Icons.school;
    }
  }

  Color get color {
    switch (this) {
      case DefaultExpenseCategory.food:
        return Colors.orange;
      case DefaultExpenseCategory.transport:
        return Colors.blue;
      case DefaultExpenseCategory.housing:
        return Colors.brown;
      case DefaultExpenseCategory.entertainment:
        return Colors.red;
      case DefaultExpenseCategory.health:
        return Colors.green;
      case DefaultExpenseCategory.education:
        return Colors.purple;
    }
  }
}

class AddView extends StatefulWidget {
  final Expense? expense;

  const AddView({super.key, this.expense});

  @override
  State<AddView> createState() => _AddViewState();
}

class _AddViewState extends State<AddView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();

  DefaultExpenseCategory _selectedDefaultCategory = DefaultExpenseCategory.food;
  bool _isPredefined = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      // Mode édition: pré-remplir le formulaire
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();

      // Détermine si c'est une catégorie prédéfinie ou personnalisée
      _isPredefined = widget.expense!.isPredefined;

      if (_isPredefined) {
        // Essaie de trouver la catégorie prédéfinie correspondante
        try {
          _selectedDefaultCategory = DefaultExpenseCategory.values.firstWhere(
                  (cat) => cat.name == widget.expense!.category.name,
              orElse: () => DefaultExpenseCategory.food
          );
        } catch (_) {
          _selectedDefaultCategory = DefaultExpenseCategory.food;
        }
      } else {
        // Pour une catégorie personnalisée, utilisez le nom de la catégorie
        _customCategoryController.text = widget.expense!.category.name;
      }

      _selectedDate = widget.expense!.date;
      _selectedTime = TimeOfDay.fromDateTime(widget.expense!.date);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // Sélectionner une date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Couleur d'en-tête
              onPrimary: Colors.white, // Texte d'en-tête
              onSurface: Colors.black, // Texte du calendrier
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Sélectionner une heure
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple, // Couleur d'en-tête
              onPrimary: Colors.white, // Texte d'en-tête
              onSurface: Colors.black, // Texte de l'horloge
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Enregistrer la dépense
  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final DateTime dateTimeWithTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Créer la catégorie
      final ExpenseCategory category;
      if (_isPredefined) {
        category = ExpenseCategory(
          id: _selectedDefaultCategory.toString(),
          name: _selectedDefaultCategory.name,
          icon: _selectedDefaultCategory.icon,
          color: _selectedDefaultCategory.color,
        );
      } else {
        category = ExpenseCategory(
          id: 'custom_${_customCategoryController.text.trim().toLowerCase().replaceAll(' ', '_')}',
          name: _customCategoryController.text.trim(),
        );
      }

      // Créer ou mettre à jour la dépense
      final List<String> generatedHashtags = Expense.generateHashtags(_titleController.text.trim());

      final Expense newExpense = Expense(
        id: widget.expense?.id,
        title: _titleController.text.trim(),
        category: category,
        amount: double.parse(_amountController.text.trim()),
        date: dateTimeWithTime,
        isPredefined: _isPredefined,
        hashtags: generatedHashtags,
      );

      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

      if (widget.expense == null) {
        // Mode ajout
        expenseProvider.addExpense(newExpense);
        _showSuccessSnackbar('Dépense ajoutée avec succès');
        _resetForm();
      } else {
        // Mode modification
        _showConfirmDialog(
          title: 'Confirmer la modification',
          content: 'Voulez-vous vraiment modifier cette dépense?',
          onConfirm: () {
            expenseProvider.updateExpense(newExpense);
            _showSuccessSnackbar('Dépense modifiée avec succès');
            Navigator.pop(context); // Retour à la vue précédente
          },
        );
      }
    }
  }

  // Réinitialiser le formulaire
  void _resetForm() {
    _formKey.currentState!.reset();
    _titleController.clear();
    _amountController.clear();
    _customCategoryController.clear();
    setState(() {
      _selectedDefaultCategory = DefaultExpenseCategory.food;
      _isPredefined = true;
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    });
  }

  // Afficher une confirmation
  void _showConfirmDialog({
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            child: const Text('Oui', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  // Afficher un message de succès
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Construction du formulaire
  @override
  Widget build(BuildContext context) {
    // Obtenir le mode sombre pour l'utiliser dans l'interface
    final darkMode = Provider.of<ExpenseProvider>(context).isDarkMode;
    final textColor = darkMode ? Colors.white : Colors.deepPurple;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la page
              const SizedBox(height: 20),
              Text(
                widget.expense == null ? 'Ajouter une dépense' : 'Modifier la dépense',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 30),

              // Nom de la dépense
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la dépense',
                  prefixIcon: Icon(Icons.title, color: Colors.deepPurple),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Type de catégorie
              Row(
                children: [
                  const Text('Type de catégorie:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        // Option prédéfinie
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Prédéfinie'),
                            value: true,
                            groupValue: _isPredefined,
                            onChanged: (value) {
                              setState(() {
                                _isPredefined = value!;
                              });
                            },
                            activeColor: Colors.deepPurple,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        // Option personnalisée
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Personnalisée'),
                            value: false,
                            groupValue: _isPredefined,
                            onChanged: (value) {
                              setState(() {
                                _isPredefined = value!;
                              });
                            },
                            activeColor: Colors.deepPurple,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Catégorie (selon le type choisi)
              if (_isPredefined)
              // Catégories prédéfinies
                DropdownButtonFormField<DefaultExpenseCategory>(
                  value: _selectedDefaultCategory,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category, color: Colors.deepPurple),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                    ),
                  ),
                  items: DefaultExpenseCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Row(
                        children: [
                          Icon(category.icon, color: category.color),
                          const SizedBox(width: 10),
                          Text(category.name),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDefaultCategory = value!;
                    });
                  },
                )
              else
              // Catégorie personnalisée
                TextFormField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie personnalisée',
                    prefixIcon: Icon(Icons.edit, color: Colors.deepPurple),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                    ),
                  ),
                  validator: (value) {
                    if (!_isPredefined && (value == null || value.trim().isEmpty)) {
                      return 'Veuillez entrer une catégorie';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),

              // Montant
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant (€)',
                  prefixIcon: Icon(Icons.euro, color: Colors.deepPurple),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date et heure
              Row(
                children: [
                  // Sélecteur de date
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          prefixIcon: Icon(Icons.calendar_today, color: Colors.deepPurple),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sélecteur d'heure
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Heure',
                          prefixIcon: Icon(Icons.access_time, color: Colors.deepPurple),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _selectedTime.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Bouton d'action (Ajouter ou Modifier)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    widget.expense == null ? 'AJOUTER' : 'MODIFIER',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}