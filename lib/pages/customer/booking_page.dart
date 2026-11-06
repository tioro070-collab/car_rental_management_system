

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/car_model.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../widgets/car_picture.dart';
import '../../widgets/app_bottom_bar.dart';
import 'payment_page.dart';

class BookingScreen extends StatefulWidget {
final Car car;

const BookingScreen({
super.key,
required this.car,
});

@override
State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
DateTimeRange? rentalDates;
String paymentMethod = 'Touch n Go';

int get rentalDays {
if (rentalDates == null) return 0;

final start = rentalDates!.start;
final end = rentalDates!.end;

final days = DateTime(
end.year,
end.month,
end.day,
).difference(
DateTime(start.year, start.month, start.day),
).inDays;

return days < 1 ? 1 : days;
}

int get totalPrice => rentalDays * widget.car.price;

String formatDate(DateTime date) {
return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}

void showMessage(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(message)),
);
}

Future<void> chooseRentalDates() async {
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);

final pickedDates = await showDateRangePicker(
context: context,
firstDate: today,
lastDate: DateTime(now.year + 3),
initialDateRange: rentalDates,
helpText: 'SELECT RENTAL DATES',
saveText: 'CONFIRM DATES',
);

if (pickedDates != null && mounted) {
setState(() => rentalDates = pickedDates);
}
}

Widget sectionTitle(String title) {
return Text(
title,
style: const TextStyle(
color: darkPurple,
fontSize: 20,
fontWeight: FontWeight.w900,
),
);
}

Widget detailRow(
String label,
String value, {
bool highlight = false,
}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8),
child: Row(
children: [
Expanded(
child: Text(
label,
style: TextStyle(
color: highlight ? darkPurple : Colors.black54,
fontSize: highlight ? 15 : 13,
fontWeight: highlight
? FontWeight.bold
    : FontWeight.normal,
),
),
),
Text(
value,
style: TextStyle(
color: highlight ? orange : darkPurple,
fontSize: highlight ? 22 : 14,
fontWeight: FontWeight.w900,
),
),
],
),
);
}

Widget paymentOption({
required String title,
required String subtitle,
required IconData icon,
}) {
final selected = paymentMethod == title;

return InkWell(
onTap: () => setState(() => paymentMethod = title),
borderRadius: BorderRadius.circular(15),
child: Container(
margin: const EdgeInsets.only(bottom: 11),
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: selected
? orange.withOpacity(0.08)
    : Colors.white,
borderRadius: BorderRadius.circular(15),
border: Border.all(
color: selected
? orange
    : darkPurple.withOpacity(0.10),
width: selected ? 1.8 : 1,
),
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: selected
? orange.withOpacity(0.13)
    : lightGrey.withOpacity(0.45),
borderRadius: BorderRadius.circular(11),
),
child: Icon(
icon,
color: selected ? orange : darkPurple,
size: 24,
),
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.w900,
fontSize: 14,
),
),
const SizedBox(height: 4),
Text(
subtitle,
style: const TextStyle(
color: Colors.black54,
fontSize: 11,
),
),
],
),
),
Icon(
selected
? Icons.radio_button_checked_rounded
    : Icons.radio_button_unchecked_rounded,
color: selected ? orange : Colors.grey,
),
],
),
),
);
}

// ---------------------------------------
// NAVIGATE TO PAYMENT (NO BOOKING SAVED HERE)
// ---------------------------------------

void confirmBooking() {
if (!widget.car.available) {
showMessage('This car is currently unavailable.');
return;
}

if (rentalDates == null) {
showMessage('Please select rental dates first.');
return;
}

final booking = RentalBooking(
id: BookingStore.generateBookingId(),
car: widget.car,
pickupDate: rentalDates!.start,
returnDate: rentalDates!.end,
rentalDays: rentalDays,
totalPrice: totalPrice,
paymentMethod: paymentMethod,
paymentStatus: PaymentStatus.pending,
bookedAt: DateTime.now(),
);

Navigator.push(
context,
MaterialPageRoute(
builder: (_) => PaymentScreen(booking: booking),
),
);
}

// ---------------------------------------
// MAIN BOOKING SCREEN
// ---------------------------------------

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: lightGrey,
bottomNavigationBar: const AppBottomBar(
selectedIndex: 1,
),
body: SafeArea(
child: Column(
children: [
// PURPLE HEADER
Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(
16, 18, 20, 23,
),
decoration: const BoxDecoration(
color: darkPurple,
borderRadius: BorderRadius.vertical(
bottom: Radius.circular(25),
),
),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 900,
),
child: Row(
children: [
IconButton(
onPressed: () {
Navigator.maybePop(context);
},
icon: const Icon(
Icons.arrow_back_rounded,
color: Colors.white,
),
),
const SizedBox(width: 8),
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Book Your Ride',
style: TextStyle(
color: Colors.white,
fontSize: 25,
fontWeight: FontWeight.w900,
),
),
SizedBox(height: 5),
Text(
'Complete your rental details',
style: TextStyle(
color: Color(0xFFCEC5DC),
fontSize: 12,
),
),
],
),
),
],
),
),
),
),

// SCROLLABLE CONTENT
Expanded(
child: SingleChildScrollView(
padding: const EdgeInsets.all(18),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 900,
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
// SELECTED CAR
Container(
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(22),
),
child: Row(
children: [
Container(
width: 112,
height: 100,
decoration: BoxDecoration(
color: lightGrey.withOpacity(0.35),
borderRadius:
BorderRadius.circular(15),
),
child: ClipRRect(
borderRadius:
BorderRadius.circular(15),
child: CarPicture(
car: widget.car,
height: 100,
),
),
),
const SizedBox(width: 14),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
widget.car.name,
style: const TextStyle(
color: darkPurple,
fontSize: 19,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 7),
Text(
'${widget.car.type}  •  ${widget.car.seats} Seats',
style: const TextStyle(
color: Colors.black54,
fontSize: 12,
),
),

const SizedBox(height: 7),

Text(
'RM ${widget.car.price} / day',
style: const TextStyle(
color: orange,
fontSize: 16,
fontWeight: FontWeight.w900,
),
),
],
),
),
],
),
),

const SizedBox(height: 25),

sectionTitle('Pickup Location'),

const SizedBox(height: 12),

// PICKUP BRANCH
Container(
width: double.infinity,
padding: const EdgeInsets.all(17),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(17),
),
child: Row(
children: [
const Icon(
Icons.location_on_outlined,
color: orange,
size: 27,
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'PICKUP BRANCH',
style: TextStyle(
color: Colors.black45,
fontSize: 10,
fontWeight: FontWeight.bold,
letterSpacing: 1,
),
),
const SizedBox(height: 6),
Text(
'${widget.car.branch} Branch',
style: const TextStyle(
color: darkPurple,
fontSize: 16,
fontWeight: FontWeight.w900,
),
),
],
),
),
],
),
),

const SizedBox(height: 26),

sectionTitle('Rental Period'),

const SizedBox(height: 12),

// DATE PICKER
InkWell(
onTap: chooseRentalDates,
borderRadius: BorderRadius.circular(17),
child: Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(17),
),
child: Row(
children: [
const Icon(
Icons.calendar_month_outlined,
color: orange,
size: 28,
),
const SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Text(
'PICKUP & RETURN DATES',
style: TextStyle(
color: Colors.black45,
fontSize: 10,
fontWeight: FontWeight.bold,
letterSpacing: 1,
),
),
const SizedBox(height: 7),
Text(
rentalDates == null
? 'Select rental dates'
    : '${formatDate(rentalDates!.start)}'
'  -  '
'${formatDate(rentalDates!.end)}',
style: const TextStyle(
color: darkPurple,
fontSize: 14,
fontWeight: FontWeight.bold,
),
),
],
),
),
const Icon(
Icons.keyboard_arrow_down_rounded,
color: darkPurple,
),
],
),
),
),

const SizedBox(height: 12),

if (rentalDates != null)
Container(
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
color: orange.withOpacity(0.10),
borderRadius:
BorderRadius.circular(13),
),
child: Row(
children: [
const Icon(
Icons.access_time_rounded,
color: orange,
),
const SizedBox(width: 10),
Expanded(
child: Text(
'Rental Duration: '
'$rentalDays day(s)',
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.bold,
),
),
),
],
),
),

const SizedBox(height: 27),

sectionTitle('Payment Method'),

const SizedBox(height: 13),

paymentOption(
title: 'Touch n Go',
subtitle: 'E-wallet payment',
icon: Icons
    .account_balance_wallet_outlined,
),

paymentOption(
title: 'Cash',
subtitle: 'Pay at pickup branch',
icon: Icons.payments_outlined,
),

const SizedBox(height: 25),

sectionTitle('Booking Summary'),

const SizedBox(height: 13),

// PRICE SUMMARY
Container(
width: double.infinity,
padding: const EdgeInsets.all(21),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
),
child: Column(
children: [
detailRow(
'Daily Rental Rate',
'RM ${widget.car.price}',
),
detailRow(
'Rental Duration',
'$rentalDays day(s)',
),
detailRow(
'Penalty Fee',
'RM 0',
),
const SizedBox(height: 11),
const Divider(),
const SizedBox(height: 11),
detailRow(
'Total Amount',
'RM $totalPrice',
highlight: true,
),
],
),
),

const SizedBox(height: 21),

// CONFIRM BOOKING BUTTON
SizedBox(
width: double.infinity,
height: 57,
child: ElevatedButton.icon(
onPressed: rentalDates != null && widget.car.available
? confirmBooking
    : null,
icon: const Icon(
Icons.check_circle_outline_rounded,
),
label: const Text(
'CONFIRM BOOKING',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w900,
letterSpacing: 1,
),
),
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
disabledBackgroundColor: Colors.grey,
disabledForegroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(16),
),
),
),
),

const SizedBox(height: 14),

const Center(
child: Text(
'Demo booking only. No real payment is processed.',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.black54,
fontSize: 11,
),
),
),

const SizedBox(height: 25),
],
),
),
),
),
),
],
),
),
);
}
}

