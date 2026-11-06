
import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../models/booking_store.dart';
import '../../models/vehicle_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/car_picture.dart';
import 'staff_vehicle_history_page.dart';
import 'staff_vehicle_maintenance_page.dart';

class StaffVehicleDetailsPage extends StatelessWidget {
  final Car car;

  const StaffVehicleDetailsPage({
    super.key,
    required this.car,
  });

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        BookingStore.bookings,
        VehicleStore.maintenance,
        VehicleStore.manuallyUnavailable,
      ]),
      builder: (context, _) {
        final status = VehicleStore.statusFor(car);
        final manual = VehicleStore.manuallyUnavailable.value
            .contains(VehicleStore.keyFor(car));

        final activeMaintenance = VehicleStore.recordsFor(car)
            .where((record) => record.isActiveOn(DateTime.now()))
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F3FA),
          appBar: AppBar(
            title: const Text(
              'Vehicle Details',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            backgroundColor: darkPurple,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      children: [
                        CarPicture(car: car, height: 205),
                        const SizedBox(height: 12),
                        Text(
                          car.name,
                          style: const TextStyle(
                            color: darkPurple,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${car.type} • ${car.fuel}',
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Chip(
                          label: Text(
                            VehicleStore.statusLabel(status),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          backgroundColor: const Color(0xFFFFE8D9),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehicle Information',
                          style: TextStyle(
                            color: darkPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        detailRow('Plate Number', car.plate),
                        detailRow('Vehicle Type', car.type),
                        detailRow('Branch', car.branch),
                        detailRow('Year', car.year),
                        detailRow('Colour', car.colour),
                        detailRow('Fuel', car.fuel),
                        detailRow('Origin', car.origin),
                        detailRow('Rental Rate', 'RM ${car.price}/day'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Availability Status',
                          style: TextStyle(
                            color: darkPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          status == VehicleStatus.available
                              ? 'Ready for rental today.'
                              : 'Current status: '
                              '${VehicleStore.statusLabel(status)}',
                          style: const TextStyle(
                            color: darkPurple,
                          ),
                        ),
                        if (activeMaintenance.isNotEmpty) ...[
                          const SizedBox(height: 9),
                          Text(
                            'Active maintenance: '
                                '${VehicleStore.maintenanceLabel(
                              activeMaintenance.first.type,
                            )}',
                            style: const TextStyle(
                              color: orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Manually Unavailable',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkPurple,
                            ),
                          ),
                          subtitle: const Text(
                            'Use for temporary administrative holds.',
                          ),
                          activeColor: orange,
                          value: manual,
                          onChanged: (value) {
                            VehicleStore.setUnavailable(car, value);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      actionButton(
                        icon: Icons.history_rounded,
                        label: 'Rental History',
                        color: const Color(0xFF7143DD),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StaffVehicleHistoryPage(car: car),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      actionButton(
                        icon: Icons.build_rounded,
                        label: 'Maintenance',
                        color: orange,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                StaffVehicleMaintenancePage(car: car),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vehicle specifications are read from carList. '
                        'Editing the car model is not enabled yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
