

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../widgets/car_picture.dart';
import 'available_cars_page.dart';

class MyBookingsScreen extends StatefulWidget {
const MyBookingsScreen({super.key});

@override
State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
String selectedFilter = 'All';
bool cancellingBooking = false;

@override
void initState() {
super.initState();
BookingStore.startListening();
}

String formatDate(DateTime date) {
return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}

String statusName(BookingStatus status) {
switch (status) {
case BookingStatus.upcoming:
return 'Upcoming';
case BookingStatus.ongoing:
return 'Ongoing';
case BookingStatus.completed:
return 'Completed';
case BookingStatus.cancelled:
return 'Cancelled';
}
}

Color statusColor(BookingStatus status) {
switch (status) {
case BookingStatus.upcoming:
return orange;
case BookingStatus.ongoing:
return const Color(0xFF4D35B0);
case BookingStatus.completed:
return const Color(0xFF13996B);
case BookingStatus.cancelled:
return const Color(0xFFE54266);
}
}

int countStatus(
List<RentalBooking> bookings,
BookingStatus status,
) {
return bookings
    .where((booking) => booking.currentStatus == status)
    .length;
}

String paymentStatusName(PaymentStatus status) {
return status == PaymentStatus.paid ? 'Paid' : 'Payment Pending';
}

Color paymentStatusColor(PaymentStatus status) {
return status == PaymentStatus.paid
? const Color(0xFF13996B)
    : const Color(0xFFB66A0A);
}

Widget paymentBadge(PaymentStatus status) {
final color = paymentStatusColor(status);
return Container(
padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
decoration: BoxDecoration(
color: color.withOpacity(0.10),
borderRadius: BorderRadius.circular(20),
),
child: Text(
paymentStatusName(status),
style: TextStyle(
color: color,
fontSize: 11,
fontWeight: FontWeight.bold,
),
),
);
}

Widget statCard(
IconData icon,
String value,
String label,
Color color,
) {
return Expanded(
child: Column(
children: [
CircleAvatar(
radius: 21,
backgroundColor: color.withOpacity(0.12),
child: Icon(icon, color: color, size: 21),
),
const SizedBox(height: 7),
Text(
value,
style: const TextStyle(
color: darkPurple,
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
Text(
label,
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.black54,
fontSize: 10,
),
),
],
),
);
}

Widget filterChip(String label, int count) {
final selected = selectedFilter == label;

return Padding(
padding: const EdgeInsets.only(right: 9),
child: ChoiceChip(
label: Text('$label  $count'),
selected: selected,
onSelected: (_) {
setState(() => selectedFilter = label);
},
selectedColor: orange,
backgroundColor: Colors.white,
labelStyle: TextStyle(
color: selected ? Colors.white : darkPurple,
fontWeight: FontWeight.bold,
fontSize: 12,
),
side: BorderSide.none,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
),
);
}

Widget infoLine(
IconData icon,
String text,
) {
return Padding(
padding: const EdgeInsets.only(top: 8),
child: Row(
children: [
Icon(icon, size: 17, color: darkPurple),
const SizedBox(width: 8),
Expanded(
child: Text(
text,
style: const TextStyle(
color: Colors.black54,
fontSize: 12,
),
),
),
],
),
);
}

void showBookingDetails(RentalBooking booking) {
showDialog<void>(
context: context,
builder: (dialogContext) => AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(22),
),
title: const Text(
'Booking Details',
style: TextStyle(
color: darkPurple,
fontWeight: FontWeight.w900,
),
),
content: SingleChildScrollView(
child: Text(
'Booking ID: ${booking.id}\n\n'
'Vehicle: ${booking.car.name}\n'
'Plate: ${booking.car.plate}\n'
'Branch: ${booking.car.branch}\n\n'
'Pickup: ${formatDate(booking.pickupDate)}\n'
'Return: ${formatDate(booking.returnDate)}\n'
'Duration: ${booking.rentalDays} day(s)\n\n'
'Rate: RM${booking.car.price}/day\n'
'Total: RM${booking.totalPrice}\n'
'Payment selected: ${booking.paymentMethod}\n'
'Payment status: ${paymentStatusName(booking.paymentStatus)}\n\n'
'Status: ${statusName(booking.currentStatus)}',
style: const TextStyle(height: 1.6),
),
),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext),
child: const Text(
'CLOSE',
style: TextStyle(color: orange),
),
),
],
),
);
}

// ---------------------------------------
// FIRESTORE BOOKING CANCELLATION
// ---------------------------------------

void confirmCancellation(RentalBooking booking) {
if (cancellingBooking) return;

showDialog<void>(
context: context,
barrierDismissible: false,
builder: (dialogContext) => StatefulBuilder(
builder: (dialogContext, dialogSetState) => AlertDialog(
title: const Text('Cancel Booking?'),
content: Text(
'Do you want to cancel your reservation '
'for ${booking.car.name}?',
),
actions: [
TextButton(
onPressed: cancellingBooking
? null
    : () => Navigator.pop(dialogContext),
child: const Text('KEEP BOOKING'),
),
TextButton(
onPressed: cancellingBooking
? null
    : () async {
setState(() => cancellingBooking = true);
dialogSetState(() {});

try {
final success =
await BookingStore.cancelBooking(
booking.id,
);

if (!mounted) return;

if (dialogContext.mounted) {
Navigator.pop(dialogContext);
}

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
success
? 'Booking cancelled.'
    : 'This booking cannot be cancelled.',
),
),
);
} catch (error) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
'Unable to cancel booking: $error',
),
backgroundColor: Colors.redAccent,
),
);
} finally {
if (mounted) {
setState(
() => cancellingBooking = false,
);
}

if (dialogContext.mounted) {
dialogSetState(() {});
}
}
},
child: Text(
cancellingBooking
? 'CANCELLING...'
    : 'CANCEL BOOKING',
style: const TextStyle(color: Colors.red),
),
),
],
),
),
);
}

Widget bookingCard(RentalBooking booking) {
final status = booking.currentStatus;
final color = statusColor(status);

return Container(
margin: const EdgeInsets.only(bottom: 15),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(23),
boxShadow: [
BoxShadow(
color: darkPurple.withOpacity(0.06),
blurRadius: 14,
offset: const Offset(0, 4),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 115,
height: 105,
decoration: BoxDecoration(
color: const Color(0xFFF1ECFF),
borderRadius: BorderRadius.circular(16),
),
child: ClipRRect(
borderRadius: BorderRadius.circular(16),
child: CarPicture(
car: booking.car,
height: 105,
),
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
booking.car.name,
style: const TextStyle(
color: darkPurple,
fontSize: 18,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 8),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 6,
),
decoration: BoxDecoration(
color: color.withOpacity(0.10),
borderRadius: BorderRadius.circular(20),
),
child: Text(
statusName(status),
style: TextStyle(
color: color,
fontSize: 11,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(height: 8),
Text(
'RM${booking.totalPrice}',
style: const TextStyle(
color: orange,
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
],
),
),
],
),
const SizedBox(height: 13),
Row(
children: [
const Icon(Icons.payments_outlined, size: 17, color: darkPurple),
const SizedBox(width: 8),
Expanded(
child: Text(
'Payment: ${booking.paymentMethod}',
style: const TextStyle(color: Colors.black54, fontSize: 12),
),
),
paymentBadge(booking.paymentStatus),
],
),
infoLine(
Icons.calendar_month_outlined,
'${formatDate(booking.pickupDate)} - '
'${formatDate(booking.returnDate)} '
'(${booking.rentalDays} days)',
),
infoLine(
Icons.location_on_outlined,
'${booking.car.branch} Branch',
),
infoLine(
Icons.receipt_long_outlined,
'Booking ID: ${booking.id}',
),
const SizedBox(height: 15),
const Divider(),
const SizedBox(height: 8),
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: () => showBookingDetails(booking),
style: OutlinedButton.styleFrom(
foregroundColor: darkPurple,
side: const BorderSide(color: darkPurple),
),
child: const Text('View Details'),
),
),
if (status == BookingStatus.upcoming) ...[
const SizedBox(width: 10),
Expanded(
child: ElevatedButton(
onPressed: cancellingBooking
? null
    : () => confirmCancellation(booking),
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
),
child: const Text('Cancel'),
),
),
],
],
),
],
),
);
}

Widget emptyBookings() {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 50),
child: Column(
children: [
const Icon(
Icons.car_rental_outlined,
size: 68,
color: darkPurple,
),
const SizedBox(height: 15),
const Text(
'No bookings found',
style: TextStyle(
color: darkPurple,
fontSize: 21,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 8),
const Text(
'Your reservations will appear here.',
style: TextStyle(color: Colors.black54),
),
const SizedBox(height: 16),
ElevatedButton(
onPressed: openCars,
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
),
child: const Text('Browse Cars'),
),
],
),
);
}

void openCars() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const AvailableCarsScreen(),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF4F2F9),
appBar: AppBar(
backgroundColor: darkPurple,
foregroundColor: Colors.white,
title: const Text(
'My Bookings',
style: TextStyle(fontWeight: FontWeight.w900),
),
),
body: ValueListenableBuilder<List<RentalBooking>>(
valueListenable: BookingStore.bookings,
builder: (context, allBookings, _) {
final bookings = allBookings.where((booking) {
return selectedFilter == 'All' ||
statusName(booking.currentStatus) ==
selectedFilter;
}).toList();

return Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 900),
child: ListView(
padding: const EdgeInsets.all(17),
children: [
const Text(
'Your rental journey',
style: TextStyle(
color: darkPurple,
fontSize: 23,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 5),
const Text(
'View and manage your reservations',
style: TextStyle(color: Colors.black54),
),
const SizedBox(height: 19),
Container(
padding: const EdgeInsets.symmetric(
vertical: 20,
horizontal: 8,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
),
child: Row(
children: [
statCard(
Icons.directions_car,
'${allBookings.length}',
'Total',
orange,
),
statCard(
Icons.calendar_month,
'${countStatus(
allBookings,
BookingStatus.upcoming,
)}',
'Upcoming',
darkPurple,
),
statCard(
Icons.check_circle,
'${countStatus(
allBookings,
BookingStatus.completed,
)}',
'Completed',
const Color(0xFF13996B),
),
statCard(
Icons.cancel,
'${countStatus(
allBookings,
BookingStatus.cancelled,
)}',
'Cancelled',
const Color(0xFFE54266),
),
],
),
),
const SizedBox(height: 22),
SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [
filterChip(
'All',
allBookings.length,
),
filterChip(
'Upcoming',
countStatus(
allBookings,
BookingStatus.upcoming,
),
),
filterChip(
'Ongoing',
countStatus(
allBookings,
BookingStatus.ongoing,
),
),
filterChip(
'Completed',
countStatus(
allBookings,
BookingStatus.completed,
),
),
filterChip(
'Cancelled',
countStatus(
allBookings,
BookingStatus.cancelled,
),
),
],
),
),
const SizedBox(height: 20),
if (bookings.isEmpty)
emptyBookings()
else
for (final booking in bookings)
bookingCard(booking),
const SizedBox(height: 10),
Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
Color(0xFF75449D),
darkPurple,
],
),
borderRadius: BorderRadius.circular(22),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Plan another trip?',
style: TextStyle(
color: Colors.white,
fontSize: 21,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 6),
const Text(
'Find your next favourite ride.',
style: TextStyle(
color: Colors.white70,
),
),
const SizedBox(height: 13),
ElevatedButton.icon(
onPressed: openCars,
icon: const Icon(Icons.arrow_forward),
label: const Text('Browse Cars'),
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
),
),
],
),
),
],
),
),
);
},
),
);
}
}

