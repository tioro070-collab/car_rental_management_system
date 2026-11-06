
import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../models/vehicle_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/car_picture.dart';
import 'staff_booking_details_page.dart';

class StaffVehicleHistoryPage extends StatefulWidget {
  final Car car;

  const StaffVehicleHistoryPage({
    super.key,
    required this.car,
  });

  @override
  State<StaffVehicleHistoryPage> createState() =>
      _StaffVehicleHistoryPageState();
}

class _StaffVehicleHistoryPageState
    extends State<StaffVehicleHistoryPage> {
  String filter = 'All';

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String labelFor(RentalBooking booking) {
    if (booking.status == BookingStatus.cancelled) {
      return 'Cancelled';
    }
    if (booking.hasReturned) return 'Completed';
    if (booking.hasPickedUp) return 'Ongoing';
    return 'Upcoming';
  }

  Color colorFor(String label) {
    switch (label) {
      case 'Completed':
        return const Color(0xFF0EAA78);
      case 'Ongoing':
        return const Color(0xFF7143DD);
      case 'Cancelled':
        return Colors.red;
      default:
        return orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RentalBooking>>(
      valueListenable: BookingStore.bookings,
      builder: (context, _, __) {
        final bookings = VehicleStore.bookingsFor(widget.car);

        final filtered = bookings.where((booking) {
          return filter == 'All' || labelFor(booking) == filter;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F3FA),
          appBar: AppBar(
            title: const Text(
              'Rental History',
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
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          height: 90,
                          child: CarPicture(
                            car: widget.car,
                            height: 90,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.car.name,
                                style: const TextStyle(
                                  color: darkPurple,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                widget.car.plate,
                                style: const TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${bookings.length} recorded bookings',
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final item in [
                          'All',
                          'Upcoming',
                          'Ongoing',
                          'Completed',
                          'Cancelled',
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(item),
                              selected: filter == item,
                              onSelected: (_) {
                                setState(() => filter = item);
                              },
                              selectedColor: orange,
                              backgroundColor:
                              const Color(0xFFECE7F6),
                              side: BorderSide.none,
                              labelStyle: TextStyle(
                                color: filter == item
                                    ? Colors.white
                                    : darkPurple,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(45),
                      child: Center(
                        child: Text(
                          'No rental records in this category.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                  for (final booking in filtered)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StaffBookingDetailsPage(
                              bookingId: booking.id,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorFor(
                                      labelFor(booking),
                                    ).withOpacity(0.12),
                                    borderRadius:
                                    BorderRadius.circular(13),
                                  ),
                                  child: Text(
                                    labelFor(booking),
                                    style: TextStyle(
                                      color: colorFor(
                                        labelFor(booking),
                                      ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.chevron_right,
                                  color: darkPurple,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${formatDate(booking.pickupDate)}'
                                  ' - ${formatDate(booking.returnDate)}',
                              style: const TextStyle(
                                color: darkPurple,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'Booking ID: ${booking.id}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              '${booking.rentalDays} day(s) • '
                                  'RM ${booking.totalPrice}',
                              style: const TextStyle(
                                color: orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (booking.hasPickedUp) ...[
                              const SizedBox(height: 7),
                              const Text(
                                'Pickup confirmed by staff',
                                style: TextStyle(
                                  color: Color(0xFF0EAA78),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (booking.hasReturned)
                              const Text(
                                'Return confirmed by staff',
                                style: TextStyle(
                                  color: Color(0xFF0EAA78),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
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
