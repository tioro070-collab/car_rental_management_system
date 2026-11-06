

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../widgets/car_picture.dart';
import 'staff_vehicle_handover_page.dart';

class StaffBookingDetailsPage extends StatelessWidget {
final String bookingId;

const StaffBookingDetailsPage({
super.key,
required this.bookingId,
});

String formatDate(DateTime date) {
return '${date.day.toString().padLeft(2, '0')}/'
'${date.month.toString().padLeft(2, '0')}/'
'${date.year}';
}

String formatDateTime(DateTime date) {
final hour = date.hour.toString().padLeft(2, '0');
final minute = date.minute.toString().padLeft(2, '0');
return '${formatDate(date)}  $hour:$minute';
}

Widget panel({
required String title,
required Widget child,
}) {
return Container(
margin: const EdgeInsets.only(bottom: 15),
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(21),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.w900,
fontSize: 17,
),
),
const SizedBox(height: 14),
child,
],
),
);
}

Widget infoRow(
String label,
String value, {
Color? valueColor,
}) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 8),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(
width: 105,
child: Text(
label,
style: const TextStyle(
color: Colors.black54,
fontSize: 12,
),
),
),
Expanded(
child: Text(
value,
style: TextStyle(
color: valueColor ?? darkPurple,
fontWeight: FontWeight.w800,
fontSize: 12,
),
),
),
],
),
);
}

Widget progressStep(
IconData icon,
String title,
bool complete,
) {
return Expanded(
child: Column(
children: [
CircleAvatar(
radius: 19,
backgroundColor: complete
? orange
    : const Color(0xFFE8E4F1),
child: Icon(
complete ? Icons.check_rounded : icon,
color: complete ? Colors.white : Colors.grey,
size: 19,
),
),
const SizedBox(height: 7),
Text(
title,
textAlign: TextAlign.center,
style: TextStyle(
color: complete ? darkPurple : Colors.black45,
fontSize: 10,
fontWeight: FontWeight.w800,
),
),
],
),
);
}

void openHandover(
BuildContext context,
RentalBooking booking, {
required bool isPickup,
}) {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => StaffVehicleHandoverPage(
bookingId: booking.id,
isPickup: isPickup,
),
),
);
}

@override
Widget build(BuildContext context) {
return ValueListenableBuilder<List<RentalBooking>>(
valueListenable: BookingStore.bookings,
builder: (context, _, __) {
final booking = BookingStore.findBooking(bookingId);

if (booking == null) {
return Scaffold(
appBar: AppBar(title: const Text('Booking Details')),
body: const Center(
child: Text('Booking no longer exists.'),
),
);
}

final cancelled =
booking.status == BookingStatus.cancelled;

final canPickup = !cancelled &&
!booking.hasPickedUp &&
!booking.hasReturned;

final canReturn = !cancelled &&
booking.hasPickedUp &&
!booking.hasReturned;

return Scaffold(
backgroundColor: const Color(0xFFF5F3FA),
appBar: AppBar(
title: const Text(
'Booking Details',
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
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
),
child: Row(
children: [
SizedBox(
width: 125,
height: 115,
child: CarPicture(
car: booking.car,
height: 115,
),
),
const SizedBox(width: 13),
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
const SizedBox(height: 7),
Text(
booking.car.plate,
style: const TextStyle(
color: Colors.black54,
fontSize: 12,
),
),
const SizedBox(height: 8),
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
const SizedBox(height: 15),
panel(
title: 'Booking Information',
child: Column(
children: [
infoRow('Booking ID', booking.id),
infoRow(
'Booked On',
formatDateTime(booking.bookedAt),
),
infoRow(
'Pickup',
formatDate(booking.pickupDate),
),
infoRow(
'Return',
formatDate(booking.returnDate),
),
infoRow(
'Duration',
'${booking.rentalDays} day(s)',
),
infoRow(
'Branch',
'${booking.car.branch} Branch',
),
infoRow(
'Status',
booking.handoverStatus,
valueColor: orange,
),
],
),
),
panel(
title: 'Payment Information',
child: Column(
children: [
infoRow(
'Method',
booking.paymentMethod,
),
infoRow(
'Total Price',
'RM ${booking.totalPrice}',
valueColor: orange,
),
infoRow(
'Payment',
booking.paymentStatus == PaymentStatus.paid ? 'Paid' : 'Pending',
valueColor: booking.paymentStatus == PaymentStatus.paid
? const Color(0xFF109F70) : orange,
),
if (!cancelled &&
booking.paymentMethod.trim().toLowerCase() == 'cash' &&
booking.paymentStatus == PaymentStatus.pending) ...[
const SizedBox(height: 14),
SizedBox(
width: double.infinity,
child: ElevatedButton.icon(
icon: const Icon(Icons.payments_outlined),
label: const Text('Confirm Cash Received'),
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
),
onPressed: () async {
final approved = await showDialog<bool>(
context: context,
builder: (dialogContext) => AlertDialog(
title: const Text('Confirm cash received?'),
content: Text(
'Confirm you have received RM ${booking.totalPrice} '
'in cash for booking ${booking.id}.',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(dialogContext, false),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () => Navigator.pop(dialogContext, true),
child: const Text('Confirm'),
),
],
),
);
if (approved != true || !context.mounted) return;
try {
final success = await BookingStore.confirmCashPayment(booking.id);
if (!context.mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(success
? 'Cash payment confirmed successfully.'
    : 'Unable to confirm: booking is no longer eligible.')),
);
} catch (error) {
if (!context.mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Payment confirmation failed: $error')),
);
}
},
),
),
],
],
),
),
panel(
title: 'Rental Progress',
child: Column(
children: [
Row(
children: [
progressStep(
Icons.receipt_long,
'Booked',
true,
),
progressStep(
Icons.key_rounded,
'Pickup',
booking.hasPickedUp,
),
progressStep(
Icons.directions_car,
'On Rent',
booking.hasPickedUp &&
!booking.hasReturned,
),
progressStep(
Icons.assignment_turned_in,
'Returned',
booking.hasReturned,
),
],
),
if (cancelled) ...[
const SizedBox(height: 15),
const Text(
'This booking was cancelled.',
style: TextStyle(color: Colors.red),
),
],
const SizedBox(height: 19),
Row(
children: [
Expanded(
child: OutlinedButton.icon(
onPressed: canPickup
? () => openHandover(
context,
booking,
isPickup: true,
)
    : null,
icon: const Icon(Icons.key_rounded),
label: const Text('Record Pickup'),
style: OutlinedButton.styleFrom(
foregroundColor: darkPurple,
),
),
),
const SizedBox(width: 9),
Expanded(
child: ElevatedButton.icon(
onPressed: canReturn
? () => openHandover(
context,
booking,
isPickup: false,
)
    : null,
icon: const Icon(
Icons.assignment_return,
),
label: const Text('Record Return'),
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
),
),
),
],
),
],
),
),
if (booking.hasPickedUp)
panel(
title: 'Pickup Record',
child: Column(
children: [
infoRow(
'Confirmed',
formatDateTime(booking.actualPickupAt!),
),
infoRow(
'Notes',
booking.pickupNotes.isEmpty
? 'No notes'
    : booking.pickupNotes,
),
for (final item
in booking.pickupInspection.entries)
infoRow(
item.key,
item.value ? 'Good' : 'Needs attention',
),
],
),
),
if (booking.hasReturned)
panel(
title: 'Return Record',
child: Column(
children: [
infoRow(
'Confirmed',
formatDateTime(booking.actualReturnAt!),
),
infoRow(
'Notes',
booking.returnNotes.isEmpty
? 'No notes'
    : booking.returnNotes,
),
for (final item
in booking.returnInspection.entries)
infoRow(
item.key,
item.value ? 'Good' : 'Needs attention',
),
],
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


