
import 'package:flutter/material.dart';

import '../../services/car_import_service.dart';
import '../../theme/app_colors.dart';

class AdminCarImportPage extends StatefulWidget {
  const AdminCarImportPage({super.key});

  @override
  State<AdminCarImportPage> createState() => _AdminCarImportPageState();
}

class _AdminCarImportPageState extends State<AdminCarImportPage> {
  bool _isImporting = false;
  String? _resultMessage;

  Future<void> _importCars() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import Cars'),
        content: const Text(
          'This will import cars from the existing car list '
              'into Firebase Firestore.\n\n'
              'Cars that already exist will be skipped.\n\n'
              'Do you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isImporting = true;
      _resultMessage = null;
    });

    try {
      final result = await CarImportService.importCars();

      if (!mounted) return;

      setState(() {
        _resultMessage = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _resultMessage = 'Import failed: $error';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isImporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FA),
      appBar: AppBar(
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Import Cars',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_car_rounded,
                  size: 75,
                  color: darkPurple,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Import Vehicle Inventory',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Import the 24 cars from your existing Flutter '
                      'car list into Firebase Firestore.\n\n'
                      'Existing cars will not be overwritten.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isImporting ? null : _importCars,
                    icon: _isImporting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(
                      _isImporting
                          ? 'Importing Cars...'
                          : 'Import Cars to Firebase',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                if (_resultMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    _resultMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: darkPurple,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
