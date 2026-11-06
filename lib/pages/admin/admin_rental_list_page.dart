import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';

class AdminRentalListPage extends StatefulWidget {
const AdminRentalListPage({super.key});

@override
State<AdminRentalListPage> createState() =>
_AdminRentalListPageState();
}

class _AdminRentalListPageState extends State<AdminRentalListPage> {
final TextEditingController _searchController =
TextEditingController();

String _search = '';
String _statusFilter = 'All';

late final Stream<QuerySnapshot<Map<String, dynamic>>>
_bookingsStream =
FirebaseFirestore.instance
    .collection('bookings')
    .snapshots();

late final Stream<QuerySnapshot<Map<String, dynamic>>> _usersStream =
FirebaseFirestore.instance.collection('users').snapshots();

@override
void dispose() {
_searchController.dispose();
super.dispose();
}

String _date(dynamic value) {
if (value is! Timestamp) return 'Not available';

final date = value.toDate();
final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');

return '$day/$month/${date.year}';
}

String _statusLabel(String status) {
switch (status) {
case 'upcoming':
return 'Upcoming';
case 'ongoing':
return 'On Rent';
case 'completed':
return 'Returned';
case 'cancelled':
return 'Cancelled';
default:
return status.isEmpty ? 'Unknown' : status;
}
}

Color _statusColor(String status) {
switch (status) {
case 'upcoming':
return Colors.blue;
case 'ongoing':
return Colors.orange;
case 'completed':
return Colors.green;
case 'cancelled':
return Colors.red;
default:
return Colors.grey;
}
}

Widget _detail(String label, String value) {
return Padding(
padding: const EdgeInsets.only(bottom: 7),
child: Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(
width: 110,
child: Text(
label,
style: const TextStyle(
color: Colors.grey,
fontSize: 12,
),
),
),
Expanded(
child: SelectableText(
value,
style: const TextStyle(
fontWeight: FontWeight.w600,
fontSize: 12,
),
),
),
],
),
);
}

Widget _bookingCard(
QueryDocumentSnapshot<Map<String, dynamic>> document,
Map<String, Map<String, dynamic>> profiles,
) {
final data = document.data();

final rawCar = data['car'];
final car = rawCar is Map
? Map<String, dynamic>.from(rawCar)
    : <String, dynamic>{};

final carName = (car['name'] ?? 'Unknown Car').toString();
final plate = (car['plate'] ?? '-').toString();
final branch = (car['branch'] ?? 'Unassigned').toString();

final userId = (data['userId'] ?? '-').toString();
final profile = profiles[userId];
final customerName = (profile?['fullName'] ?? 'Profile not available').toString();
final customerEmail = (profile?['email'] ?? 'Profile not available').toString();
final status =
(data['status'] ?? 'upcoming').toString().toLowerCase();

final paymentMethod =
(data['paymentMethod'] ?? '-').toString();

final paymentStatus =
(data['paymentStatus'] ?? 'pending').toString();

final totalPrice = data['totalPrice'];

final priceText = totalPrice is num
? 'RM ${totalPrice.toStringAsFixed(2)}'
    : 'Not available';

return Card(
color: Colors.white,
margin: const EdgeInsets.only(bottom: 12),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(17),
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
const Icon(
Icons.directions_car,
color: orange,
),
const SizedBox(width: 9),
Expanded(
child: Text(
carName,
style: const TextStyle(
color: darkPurple,
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 9,
vertical: 6,
),
decoration: BoxDecoration(
color: _statusColor(status).withOpacity(0.12),
borderRadius: BorderRadius.circular(12),
),
child: Text(
_statusLabel(status),
style: TextStyle(
color: _statusColor(status),
fontSize: 11,
fontWeight: FontWeight.bold,
),
),
),
],
),
const Divider(height: 24),
_detail('Booking ID', document.id),
_detail('Customer Name', customerName),
_detail('Customer Email', customerEmail),
_detail('Customer ID', userId),
_detail('Plate Number', plate),
_detail('Branch', branch),
_detail('Pickup Date', _date(data['pickupDate'])),
_detail('Return Date', _date(data['returnDate'])),
_detail('Payment Method', paymentMethod),
_detail('Payment Status', paymentStatus),
_detail('Total Price', priceText),
],
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF6F3FA),
appBar: AppBar(
backgroundColor: darkPurple,
foregroundColor: Colors.white,
title: const Text('All Bookings'),
),
body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
stream: _usersStream,
builder: (context, usersSnapshot) {
if (usersSnapshot.hasError) {
return const Center(
child: Text('Unable to load customer profiles. Check admin permissions.'),
);
}
if (!usersSnapshot.hasData) {
return const Center(child: CircularProgressIndicator());
}
final profiles = <String, Map<String, dynamic>>{
for (final userDoc in usersSnapshot.data!.docs)
userDoc.id: userDoc.data(),
};
return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
stream: _bookingsStream,
builder: (context, snapshot) {
if (snapshot.hasError) {
return const Center(
child: Text(
'Unable to load bookings. Check Firebase permissions.',
textAlign: TextAlign.center,
),
);
}

if (!snapshot.hasData) {
return const Center(
child: CircularProgressIndicator(),
);
}

final allBookings = snapshot.data!.docs.toList();

allBookings.sort((a, b) {
final aDate = a.data()['bookedAt'];
final bDate = b.data()['bookedAt'];

final aTime = aDate is Timestamp
? aDate.millisecondsSinceEpoch
    : 0;

final bTime = bDate is Timestamp
? bDate.millisecondsSinceEpoch
    : 0;

return bTime.compareTo(aTime);
});

final bookings = allBookings.where((document) {
final data = document.data();
final rawCar = data['car'];

final car = rawCar is Map
? Map<String, dynamic>.from(rawCar)
    : <String, dynamic>{};

final status =
(data['status'] ?? 'upcoming')
    .toString()
    .toLowerCase();

final matchesStatus =
_statusFilter == 'All' ||
status == _statusFilter.toLowerCase();

final searchable = [
document.id,
data['userId'] ?? '',
profiles[(data['userId'] ?? '').toString()]?['fullName'] ?? '',
profiles[(data['userId'] ?? '').toString()]?['email'] ?? '',
car['name'] ?? '',
car['plate'] ?? '',
car['branch'] ?? '',
].join(' ').toLowerCase();

return matchesStatus &&
searchable.contains(_search.toLowerCase());
}).toList();

return Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 850),
child: ListView(
padding: const EdgeInsets.all(18),
children: [
Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: darkPurple,
borderRadius: BorderRadius.circular(20),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Rental Management',
style: TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 7),
const Text(
'Customer bookings across all branches',
style: TextStyle(
color: Colors.white70,
),
),
const SizedBox(height: 15),
Text(
'Total Bookings: ${allBookings.length}',
style: const TextStyle(
color: orange,
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
],
),
),
const SizedBox(height: 18),
TextField(
controller: _searchController,
onChanged: (value) {
setState(() {
_search = value.trim();
});
},
decoration: InputDecoration(
hintText:
'Search booking, customer, car or branch',
prefixIcon: const Icon(Icons.search),
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
const SizedBox(height: 12),
DropdownButtonFormField<String>(
value: _statusFilter,
decoration: InputDecoration(
labelText: 'Booking Status',
filled: true,
fillColor: Colors.white,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
),
),
items: const [
DropdownMenuItem(
value: 'All',
child: Text('All Statuses'),
),
DropdownMenuItem(
value: 'upcoming',
child: Text('Upcoming'),
),
DropdownMenuItem(
value: 'ongoing',
child: Text('On Rent'),
),
DropdownMenuItem(
value: 'completed',
child: Text('Returned'),
),
DropdownMenuItem(
value: 'cancelled',
child: Text('Cancelled'),
),
],
onChanged: (value) {
if (value == null) return;
setState(() {
_statusFilter = value;
});
},
),
const SizedBox(height: 20),
Text(
'Showing ${bookings.length} bookings',
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 12),
if (bookings.isEmpty)
const Padding(
padding: EdgeInsets.all(25),
child: Center(
child: Text('No matching bookings found.'),
),
)
else
...bookings.map((booking) => _bookingCard(booking, profiles)),
],
),
),
);
},
);
},
),
);
}
}
