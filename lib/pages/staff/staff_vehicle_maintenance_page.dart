
import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../models/vehicle_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/car_picture.dart';

class StaffVehicleMaintenancePage extends StatefulWidget {
  final Car car;

  const StaffVehicleMaintenancePage({
    super.key,
    required this.car,
  });

  @override
  State<StaffVehicleMaintenancePage> createState() =>
      _StaffVehicleMaintenancePageState();
}

class _StaffVehicleMaintenancePageState
    extends State<StaffVehicleMaintenancePage> {
  MaintenanceType selectedType = MaintenanceType.regularService;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  IconData iconFor(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.regularService:
        return Icons.build_rounded;
      case MaintenanceType.repair:
        return Icons.settings_rounded;
      case MaintenanceType.inspection:
        return Icons.fact_check_rounded;
      case MaintenanceType.cleaning:
        return Icons.water_drop_rounded;
    }
  }

  Future<void> chooseDate(bool isStart) async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);

    final selected = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : endDate,
      firstDate: first,
      lastDate: DateTime(now.year + 5),
    );

    if (selected == null) return;

    setState(() {
      if (isStart) {
        startDate = selected;
        if (endDate.isBefore(startDate)) {
          endDate = startDate;
        }
      } else {
        endDate = selected;
      }
    });
  }

  Future<void> saveMaintenance() async {
    if (endDate.isBefore(startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must not be before start date.'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Maintenance'),
        content: Text(
          'Schedule ${VehicleStore.maintenanceLabel(selectedType)} '
              'for ${widget.car.name} from '
              '${formatDate(startDate)} to ${formatDate(endDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final saved = VehicleStore.addMaintenance(
      car: widget.car,
      type: selectedType,
      startDate: startDate,
      endDate: endDate,
      notes: notesController.text,
    );

    if (saved) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot schedule maintenance: '
                'dates conflict with an existing booking.',
          ),
        ),
      );
    }
  }

  Widget dateField(String title, DateTime date, bool isStart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => chooseDate(isStart),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F6FC),
              border: Border.all(
                color: const Color(0xFFE2DCEC),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF7143DD),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    formatDate(date),
                    style: const TextStyle(
                      color: darkPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FA),
      appBar: AppBar(
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Set Maintenance',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 105,
                      height: 85,
                      child: CarPicture(
                        car: widget.car,
                        height: 85,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.car.name,
                            style: const TextStyle(
                              color: darkPurple,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            widget.car.plate,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEE8FF),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF7143DD),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Maintenance will affect the vehicle status '
                            'during its scheduled dates.',
                        style: TextStyle(
                          color: darkPurple,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Maintenance Type',
                style: TextStyle(
                  color: darkPurple,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 11),
              for (final type in MaintenanceType.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: InkWell(
                    onTap: () => setState(() => selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: selectedType == type
                            ? const Color(0xFFFFF1E7)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selectedType == type
                              ? orange
                              : const Color(0xFFE5E1ED),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            iconFor(type),
                            color: selectedType == type
                                ? orange
                                : darkPurple,
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              VehicleStore.maintenanceLabel(type),
                              style: const TextStyle(
                                color: darkPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            selectedType == type
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: selectedType == type
                                ? orange
                                : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 13),
              dateField('Start Date', startDate, true),
              const SizedBox(height: 17),
              dateField('Expected Completion Date', endDate, false),
              const SizedBox(height: 20),
              const Text(
                'Notes (Optional)',
                style: TextStyle(
                  color: darkPurple,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 9),
              TextField(
                controller: notesController,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: 'Describe the maintenance work...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: saveMaintenance,
                  icon: const Icon(Icons.build_rounded),
                  label: const Text(
                    'SET AS UNDER MAINTENANCE',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
