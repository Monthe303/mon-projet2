// lib/screens/view/expense_detail_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../../models/expense.dart';

class ExpenseDetailView extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailView({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la dépense'),
        backgroundColor: Colors.deepPurple[900],
        actions: [
          _buildMoreOptionsMenu(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildExpenseDetails(context),
      ),
    );
  }

  Widget _buildMoreOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onSelected: (value) async {
        // Capturer le ScaffoldMessenger avant les opérations asynchrones
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        switch (value) {
          case 'share':
            await _shareExpense(context, scaffoldMessenger);
            break;
          case 'save':
            await _saveAsPdf(scaffoldMessenger);
            break;
          case 'print':
            await _printExpense(scaffoldMessenger);
            break;
        }
      },
      itemBuilder: (context) => [
        _buildPopupMenuItem('share', 'Partager', Icons.share),
        _buildPopupMenuItem('save', 'Enregistrer en PDF', Icons.save_alt),
        _buildPopupMenuItem('print', 'Imprimer', Icons.print),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildExpenseDetails(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec le total de la dépense
          _buildExpenseHeader(context),
          const SizedBox(height: 24),

          // Détails de la dépense
          _buildSection(
            title: 'Détails',
            children: [
              _buildDetailRow('Titre', expense.title, Icons.title),
              _buildDetailRow('Montant', '${expense.amount.toStringAsFixed(2)} €', Icons.euro),
              _buildDetailRow('Catégorie', expense.category.name, _getCategoryIcon(expense.category.name)),
              _buildDetailRow('Date', DateFormat('dd MMMM yyyy').format(expense.date), Icons.calendar_today),
            ],
          ),

          const SizedBox(height: 24),

          // Description de la dépense (si disponible)
          if (expense.notes != null && expense.notes!.isNotEmpty)
            _buildSection(
              title: 'Notes',
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    expense.notes ?? '',
                    style: textTheme.bodyLarge,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Boutons d'action
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildExpenseHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Color(0xFF6A1B9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 35,
            child: Icon(
              _getCategoryIcon(expense.category.name),
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            expense.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${expense.amount.toStringAsFixed(2)} €',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat('dd MMMM yyyy').format(expense.date),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        const Divider(color: Colors.deepPurple),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple[300], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Capturer le ScaffoldMessenger à l'avance
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          context,
          label: 'Modifier',
          icon: Icons.edit,
          onPressed: () {
            Navigator.of(context).pop();
            // Rediriger vers la page de modification (AddView)
            Navigator.of(context).pushNamed('/add', arguments: expense);
          },
        ),
        _buildActionButton(
          context,
          label: 'Partager',
          icon: Icons.share,
          onPressed: () => _shareExpense(context, scaffoldMessenger),
        ),
        _buildActionButton(
          context,
          label: 'Enregistrer',
          icon: Icons.save_alt,
          onPressed: () => _saveAsPdf(scaffoldMessenger),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // Création du document PDF
  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.nunitoSemiBold();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                color: PdfColors.deepPurple,
                width: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'DÉTAIL DE DÉPENSE',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 24,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      expense.title,
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 20,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      '${expense.amount.toStringAsFixed(2)} €',
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: 26,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Informations détaillées
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _pdfSectionTitle('Détails de la dépense', fontBold),
                    pw.Divider(color: PdfColors.deepPurple),
                    pw.SizedBox(height: 10),

                    _pdfDetailRow('Catégorie', expense.category.name, font),
                    _pdfDetailRow('Date', DateFormat('dd MMMM yyyy').format(expense.date), font),

                    if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                      pw.SizedBox(height: 20),
                      _pdfSectionTitle('Notes', fontBold),
                      pw.Divider(color: PdfColors.deepPurple),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        expense.notes ?? '',
                        style: pw.TextStyle(font: font, fontSize: 12),
                      ),
                    ],

                    pw.SizedBox(height: 40),
                    pw.Center(
                      child: pw.Text(
                        'Document généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  pw.Widget _pdfSectionTitle(String title, pw.Font font) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: font,
        fontSize: 16,
        color: PdfColors.deepPurple,
      ),
    );
  }

  pw.Widget _pdfDetailRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              '$label :',
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fonction pour partager la dépense
  Future<void> _shareExpense(BuildContext context, ScaffoldMessengerState scaffoldMessenger) async {
    try {
      // Préparer le fichier temporaire pour le partage
      final pdf = await _generatePdf();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/depense_${expense.id}.pdf');

      await file.writeAsBytes(await pdf.save());

      // Préparer le texte pour le partage
      final String shareText =
          'Dépense: ${expense.title}\n'
          'Montant: ${expense.amount.toStringAsFixed(2)} €\n'
          'Catégorie: ${expense.category.name}\n'
          'Date: ${DateFormat('dd/MM/yyyy').format(expense.date)}';

      // Utiliser le package Share Plus pour partager avec gestion d'erreur correcte
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: shareText,
        subject: 'Détails de la dépense: ${expense.title}',
      ).catchError((error) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Impossible de partager: $error'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Retourner un objet ShareResult par défaut pour éviter l'erreur
        return ShareResult('', ShareResultStatus.unavailable);
      });

      // Vérifier le résultat du partage
      if (result.status == ShareResultStatus.unavailable) {
        if (!context.mounted) return;
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Le partage n\'est pas disponible sur cet appareil'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Impossible de partager: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Fonction pour enregistrer en PDF
  Future<void> _saveAsPdf(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final pdf = await _generatePdf();

      // Obtenir le répertoire Documents sur l'appareil
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'depense_${expense.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      // Enregistrer le PDF
      await file.writeAsBytes(await pdf.save());

      // Afficher un message de confirmation en utilisant le ScaffoldMessenger capturé
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('PDF enregistré avec succès: ${file.path}'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Impossible d\'enregistrer le PDF: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Fonction pour imprimer
  Future<void> _printExpense(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      final pdf = await _generatePdf();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Dépense - ${expense.title}',
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Impossible d\'imprimer: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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