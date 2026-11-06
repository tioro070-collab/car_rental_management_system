import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/booking_store.dart';
import '../../widgets/car_picture.dart';

class StaffVehicleHandoverPage extends StatefulWidget {
  final String bookingId;
  final bool isPickup;

  const StaffVehicleHandoverPage({
    super.key,
    required this.bookingId,
    required this.isPickup,
  });

  @override
  State<StaffVehicleHandoverPage> createState() =>
      _StaffVehicleHandoverPageState();
}

class _StaffVehicleHandoverPageState
    extends State<StaffVehicleHandoverPage> {
  final notesController = TextEditingController();

  final Map<String, bool> inspection = {
    'Exterior': true,
    'Interior': true,
    'Fuel Level': true,
    'Tyres': true,
  };

  bool submitting = false;

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  IconData inspectionIcon(String label) {
    switch (label) {
      case 'Exterior':
        return Icons.directions_car_rounded;
      case 'Interior':
        return Icons.airline_seat_recline_normal;
      case 'Fuel Level':
        return Icons.local_gas_station_rounded;
      default:
        return Icons.tire_repair_rounded;
    }
  }

  Widget inspectionTile(String label) {
    final good = inspection[label] ?? true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: good
              ? const Color(0xFFE5DEF3)
              : const Color(0xFFF4A7B2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            inspectionIcon(label),
            color: darkPurple,
            size: 27,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 9),
          Switch(
            value: good,
            activeThumbColor: const Color(0xFF0EAA78),
            onChanged: submitting
                ? null
                : (value) {
              setState(() => inspection[label] = value);
            },
          ),
          Text(
            good ? 'Good' : 'Issue',
            style: TextStyle(
              color: good
                  ? const Color(0xFF0EAA78)
                  : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submit() async {
    if (submitting) return;

    final hasIssue = inspection.values.any(
          (good) => !good,
    );

    if (hasIssue && notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe the vehicle condition issue in Notes.',
          ),
        ),
      );
      return;
    }

    final booking = BookingStore.findBooking(
      widget.bookingId,
    );

    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking not found.'),
        ),
      );
      return;
    }

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          widget.isPickup
              ? 'Confirm Vehicle Pickup?'
              : 'Confirm Vehicle Return?',
        ),
        content: Text(
          widget.isPickup
              ? 'Record that the customer collected '
              '${booking.car.name}?'
              : 'Record that ${booking.car.name} '
              'was returned?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('BACK'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (approved != true || !mounted) return;

    setState(() => submitting = true);

    try {
      final success = await (widget.isPickup
          ? BookingStore.confirmPickup(
        bookingId: widget.bookingId,
        inspection: Map<String, bool>.from(inspection),
        notes: notesController.text,
      )
          : BookingStore.confirmReturn(
        bookingId: widget.bookingId,
        inspection: Map<String, bool>.from(inspection),
        notes: notesController.text,
      ));

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to confirm this handover. '
                  'Check its dates, status, or active vehicle rentals.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save handover: $error',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = BookingStore.findBooking(
      widget.bookingId,
    );

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vehicle Inspection'),
        ),
        body: const Center(
          child: Text('Booking not found.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FA),
      appBar: AppBar(
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        title: Text(
          widget.isPickup
              ? 'Record Vehicle Pickup'
              : 'Record Vehicle Return',
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: ListView(
            padding: const EdgeInsets.all(17),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 110,
                      child: CarPicture(
                        car: booking.car,
                        height: 110,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.car.name,
                            style: const TextStyle(
                              color: darkPurple,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            booking.car.plate,
                            style: const TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            booking.car.type,
                            style: const TextStyle(
                              color: orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEE9FF),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF5030C9),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        widget.isPickup
                            ? 'Inspect the vehicle together with '
                            'the customer before confirming pickup.'
                            : 'Inspect the returned vehicle and '
                            'record any condition issues.',
                        style: const TextStyle(
                          color: darkPurple,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Vehicle Condition',
                style: TextStyle(
                  color: darkPurple,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                mainAxisExtent: 180,
                children: [
                  for (final label in inspection.keys)
                    inspectionTile(label),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Inspection Notes',
                style: TextStyle(
                  color: darkPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: notesController,
                enabled: !submitting,
                maxLines: 4,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText:
                  'Add any notes about the vehicle condition...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: submitting ? null : submit,
                  icon: submitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.check_circle_outline,
                  ),
                  label: Text(
                    submitting
                        ? 'SAVING...'
                        : widget.isPickup
                        ? 'CONFIRM PICKUP'
                        : 'CONFIRM RETURN',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Vehicle handover records are saved '
                    'to Cloud Firestore when authorized.',
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
  }
}
