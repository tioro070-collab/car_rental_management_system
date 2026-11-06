
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../widgets/car_picture.dart';
import 'staff_booking_details_page.dart';

class StaffBookingManagementPage extends StatefulWidget {
  final String branch;

  const StaffBookingManagementPage({
    super.key,
    this.branch = 'Muar',
  });

  @override
  State<StaffBookingManagementPage> createState() =>
      _StaffBookingManagementPageState();
}

class _StaffBookingManagementPageState
    extends State<StaffBookingManagementPage> {
  final searchController = TextEditingController();
  String filter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String statusLabel(RentalBooking booking) {
    if (booking.status == BookingStatus.cancelled) {
      return 'Cancelled';
    }
    if (booking.hasReturned) return 'Returned';
    if (booking.hasPickedUp) return 'On Rent';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickup = DateTime(
      booking.pickupDate.year,
      booking.pickupDate.month,
      booking.pickupDate.day,
    );
    final returning = DateTime(
      booking.returnDate.year,
      booking.returnDate.month,
      booking.returnDate.day,
    );

    if (today.isBefore(pickup)) return 'Upcoming';
    if (today.isAfter(returning)) return 'Pickup Pending';
    return 'Pickup Due';
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Upcoming':
      case 'Pickup Due':
      case 'Pickup Pending':
        return orange;
      case 'On Rent':
        return const Color(0xFF5030C9);
      case 'Returned':
        return const Color(0xFF109F70);
      default:
        return const Color(0xFFE54266);
    }
  }

  bool matchesFilter(RentalBooking booking) {
    final label = statusLabel(booking);
    switch (filter) {
      case 'Upcoming':
        return label == 'Upcoming' ||
            label == 'Pickup Due' ||
            label == 'Pickup Pending';
      case 'On Rent':
        return label == 'On Rent';
      case 'Returned':
        return label == 'Returned';
      case 'Cancelled':
        return label == 'Cancelled';
      default:
        return true;
    }
  }

  Widget filterItem(String label, int count) {
    final selected = filter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => filter = label),
        label: Text('$label ($count)'),
        selectedColor: orange,
        backgroundColor: const Color(0xFFF1ECFF),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected ? Colors.white : darkPurple,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget bookingCard(RentalBooking booking) {
    final label = statusLabel(booking);
    final color = statusColor(label);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffBookingDetailsPage(
                bookingId: booking.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 105,
                height: 108,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1ECFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CarPicture(
                    car: booking.car,
                    height: 108,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.car.name,
                      style: const TextStyle(
                        color: darkPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${booking.id}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 13,
                          color: darkPurple.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${formatDate(booking.pickupDate)}'
                                ' - ${formatDate(booking.returnDate)}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'RM ${booking.totalPrice}',
                      style: const TextStyle(
                        color: orange,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: darkPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(19, 18, 19, 22),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    darkPurple,
                    Color(0xFF47237A),
                  ],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(26),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Booking Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      '${widget.branch} Branch • Customer reservations',
                      style: const TextStyle(
                        color: Color(0xFFE0D5F0),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search booking ID or vehicle...',
                      hintStyle: const TextStyle(fontSize: 12),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF7565A0),
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<RentalBooking>>(
                valueListenable: BookingStore.bookings,
                builder: (context, allBookings, _) {
                  final branchBookings = allBookings.where(
                        (booking) =>
                    booking.car.branch.toLowerCase() ==
                        widget.branch.toLowerCase(),
                  ).toList();

                  final query = searchController.text
                      .trim()
                      .toLowerCase();

                  final filtered = branchBookings.where((booking) {
                    final matchesSearch = query.isEmpty ||
                        booking.id.toLowerCase().contains(query) ||
                        booking.car.name.toLowerCase().contains(query) ||
                        booking.car.plate.toLowerCase().contains(query);

                    return matchesSearch && matchesFilter(booking);
                  }).toList();

                  int count(String label) {
                    if (label == 'All') return branchBookings.length;
                    return branchBookings.where((booking) {
                      final status = statusLabel(booking);
                      if (label == 'Upcoming') {
                        return status == 'Upcoming' ||
                            status == 'Pickup Due' ||
                            status == 'Pickup Pending';
                      }
                      return status == label;
                    }).length;
                  }

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                filterItem('All', count('All')),
                                filterItem(
                                  'Upcoming',
                                  count('Upcoming'),
                                ),
                                filterItem('On Rent', count('On Rent')),
                                filterItem('Returned', count('Returned')),
                                filterItem(
                                  'Cancelled',
                                  count('Cancelled'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 17),
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 65,
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.event_busy_rounded,
                                    color: darkPurple,
                                    size: 58,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No bookings found',
                                    style: TextStyle(
                                      color: darkPurple,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 19,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    query.isNotEmpty
                                        ? 'Try another booking ID or vehicle.'
                                        : 'Reservations will appear here.',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            for (final booking in filtered)
                              bookingCard(booking),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
