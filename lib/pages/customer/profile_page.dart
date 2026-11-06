import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_page.dart';
import '../../theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../widgets/app_bottom_bar.dart';

import 'my_bookings_page.dart';

class ProfileScreen extends StatefulWidget {
const ProfileScreen({super.key});

@override
State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
bool isLoggingOut = false;
String customerName = FirebaseAuth.instance.currentUser?.displayName?.trim().isNotEmpty == true
? FirebaseAuth.instance.currentUser!.displayName!.trim()
    : 'Customer Account';
String get customerEmail => FirebaseAuth.instance.currentUser?.email ?? 'Email unavailable';
String customerPhone = 'Add your phone number';

void showMessage(String message) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
backgroundColor: darkPurple,
behavior: SnackBarBehavior.floating,
),
);
}

// ------------------------------------
// EDIT PROFILE
// ------------------------------------

Future<void> editProfile() async {
final formKey = GlobalKey<FormState>();

final nameController = TextEditingController(
text: customerName == 'Customer Account'
? ''
    : customerName,
);

final phoneController = TextEditingController(
text: customerPhone == 'Add your phone number'
? ''
    : customerPhone,
);

await showDialog<void>(
context: context,
builder: (dialogContext) {
return AlertDialog(
backgroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(24),
),
title: const Text(
'Edit Profile',
style: TextStyle(
color: darkPurple,
fontWeight: FontWeight.w900,
),
),
content: SizedBox(
width: 420,
child: SingleChildScrollView(
child: Form(
key: formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TextFormField(
controller: nameController,
decoration: inputDecoration(
'Full Name',
Icons.person_outline,
),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'Please enter your name';
}

return null;
},
),

const SizedBox(height: 14),

TextFormField(
initialValue: customerEmail,
readOnly: true,
decoration: inputDecoration(
'Registered Email (read-only)',
Icons.email_outlined,
),
),

const SizedBox(height: 14),

TextFormField(
controller: phoneController,
keyboardType: TextInputType.phone,
decoration: inputDecoration(
'Phone Number',
Icons.phone_outlined,
),
validator: (value) {
if (value == null ||
value.trim().isEmpty) {
return 'Please enter your phone number';
}

return null;
},
),
],
),
),
),
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext);
},
child: const Text(
'CANCEL',
style: TextStyle(color: darkPurple),
),
),

ElevatedButton(
onPressed: () async {
if (!formKey.currentState!.validate()) return;
final user = FirebaseAuth.instance.currentUser;
if (user == null) {
showMessage('Please log in again to update your profile.');
return;
}
try {
// Save the name to Firebase Auth so Home can display it.
await user.updateDisplayName(nameController.text.trim());
await user.reload();
if (!mounted) return;
setState(() {
customerName = nameController.text.trim();
customerPhone = phoneController.text.trim();
});
if (dialogContext.mounted) Navigator.pop(dialogContext);
showMessage('Profile updated successfully!');
} catch (error) {
if (mounted) showMessage('Unable to update profile: $error');
}
},
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
),
child: const Text('SAVE'),
),
],
);
},
);

// Allow the dialog's closing animation to finish
// before disposing its text controllers.
await Future<void>.delayed(
const Duration(milliseconds: 500),
);

nameController.dispose();
phoneController.dispose();
// nameController.dispose();
// phoneController.dispose();
}

InputDecoration inputDecoration(
String label,
IconData icon,
) {
return InputDecoration(
labelText: label,
prefixIcon: Icon(icon, color: orange),
filled: true,
fillColor: lightGrey.withOpacity(0.35),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
);
}

// ------------------------------------
// NAVIGATION
// ------------------------------------

void openMyBookings() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => const MyBookingsScreen(),
),
);
}

// ------------------------------------
// SECTION HEADING
// ------------------------------------

Widget sectionHeading(
String title, {
String? subtitle,
}) {
return Padding(
padding: const EdgeInsets.only(bottom: 13),
child: Row(
children: [
Expanded(
child: Text(
title,
style: const TextStyle(
color: darkPurple,
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
),

if (subtitle != null)
Text(
subtitle,
style: const TextStyle(
color: Colors.black45,
fontSize: 11,
),
),
],
),
);
}

// ------------------------------------
// MENU TILE
// ------------------------------------

Widget menuTile({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
Color iconColor = darkPurple,
}) {
return Material(
color: Colors.white,
child: InkWell(
onTap: onTap,
child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 16,
vertical: 14,
),
child: Row(
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: iconColor.withOpacity(0.09),
borderRadius: BorderRadius.circular(14),
),
child: Icon(
icon,
color: iconColor,
size: 23,
),
),

const SizedBox(width: 14),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.w800,
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

const Icon(
Icons.chevron_right_rounded,
color: Colors.black38,
),
],
),
),
),
);
}

// ------------------------------------
// ACCOUNT INFORMATION ROW
// ------------------------------------

Widget accountRow(
IconData icon,
String label,
String value,
) {
return InkWell(
onTap: editProfile,
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 13,
),
child: Row(
children: [
Container(
width: 43,
height: 43,
decoration: BoxDecoration(
color: const Color(0xFFF1ECFF),
borderRadius: BorderRadius.circular(13),
),
child: Icon(
icon,
color: darkPurple,
),
),

const SizedBox(width: 13),

SizedBox(
width: 95,
child: Text(
label,
style: const TextStyle(
color: darkPurple,
fontSize: 12,
fontWeight: FontWeight.bold,
),
),
),

Expanded(
child: Text(
value,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.black54,
fontSize: 12,
),
),
),

const Icon(
Icons.chevron_right,
color: Colors.black38,
size: 19,
),
],
),
),
);
}

// ------------------------------------
// BOOKING STATISTICS
// ------------------------------------

Widget statItem(
IconData icon,
String value,
String label,
Color color,
) {
return Expanded(
child: Column(
children: [
Container(
width: 40,
height: 40,
decoration: BoxDecoration(
color: color.withOpacity(0.12),
shape: BoxShape.circle,
),
child: Icon(
icon,
color: color,
size: 21,
),
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

const SizedBox(height: 3),

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

// ------------------------------------
// ROUNDED CARD
// ------------------------------------

Widget roundedCard(Widget child) {
return Container(
width: double.infinity,
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: darkPurple.withOpacity(0.06),
blurRadius: 16,
offset: const Offset(0, 5),
),
],
),
child: ClipRRect(
borderRadius: BorderRadius.circular(22),
child: child,
),
);
}

// ------------------------------------
// LOGOUT DIALOG
// ------------------------------------


Future<void> confirmLogout() async {
if (isLoggingOut) return;

final shouldLogout = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
title: const Text('Log Out'),
content: const Text(
'Are you sure you want to log out?',
),
actions: [
TextButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
child: const Text(
'CANCEL',
style: TextStyle(color: darkPurple),
),
),

TextButton(
onPressed: () {
Navigator.pop(dialogContext, true);
},
child: const Text(
'LOG OUT',
style: TextStyle(color: orange),
),
),
],
);
},
);

if (shouldLogout != true || !mounted) return;

setState(() {
isLoggingOut = true;
});

try {
// Sign out the current Firebase customer.
await FirebaseAuth.instance.signOut();

// Stop Firestore listening and clear booking data.
BookingStore.stopListening();

if (!mounted) return;

// Return to Login and clear previous pages.
Navigator.of(context).pushAndRemoveUntil(
MaterialPageRoute(
builder: (_) => const LoginScreen(),
),
(route) => false,
);
} catch (error) {
if (!mounted) return;

showMessage('Unable to log out: $error');
} finally {
if (mounted) {
setState(() {
isLoggingOut = false;
});
}
}
}


// ------------------------------------
// REDESIGNED PROFILE INTERFACE
// ------------------------------------

Widget profileHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [darkPurple, Color(0xFF35135B), Color(0xFF49216F)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(children: [
Container(
width: 45, height: 45,
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.10),
borderRadius: BorderRadius.circular(13),
),
child: const Icon(Icons.directions_car_filled_rounded,
color: orange, size: 27),
),
const SizedBox(width: 11),
const Expanded(child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('CAR RENTAL', style: TextStyle(color: Colors.white,
fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
SizedBox(height: 3),
Text('MANAGEMENT SYSTEM', style: TextStyle(
color: Color(0xFFD9CCE8), fontSize: 9,
fontWeight: FontWeight.w700, letterSpacing: 1.2)),
],
)),
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
decoration: BoxDecoration(color: orange,
borderRadius: BorderRadius.circular(20)),
child: const Text('CUSTOMER', style: TextStyle(
color: Colors.white, fontSize: 10,
fontWeight: FontWeight.w900, letterSpacing: 0.5)),
),
IconButton(
tooltip: 'Notifications',
onPressed: () => showMessage('Notifications are not connected yet.'),
icon: const Icon(Icons.notifications_none_rounded,
color: Colors.white),
),
]),
const SizedBox(height: 30),
const Text('My Profile', style: TextStyle(color: Colors.white,
fontSize: 28, fontWeight: FontWeight.w900)),
const SizedBox(height: 7),
const Text('View and manage your personal information.',
style: TextStyle(color: Color(0xFFE0D6EC), fontSize: 13)),
const SizedBox(height: 18),
Container(width: 47, height: 4,
decoration: BoxDecoration(color: orange,
borderRadius: BorderRadius.circular(10))),
],
),
);
}

Widget profileOverview() {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
border: Border.all(color: const Color(0xFFE9E1F2)),
boxShadow: [BoxShadow(color: darkPurple.withOpacity(0.06),
blurRadius: 13, offset: const Offset(0, 5))],
),
child: Column(children: [
Row(children: [
const SizedBox(
width: 88, height: 88,
child: CircleAvatar(
radius: 41,
backgroundColor: Color(0xFFE9DEFF),
child: Icon(Icons.person_rounded, size: 48, color: darkPurple),
),
),
const SizedBox(width: 14),
Expanded(child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(customerName, maxLines: 2, overflow: TextOverflow.ellipsis,
style: const TextStyle(color: darkPurple,
fontSize: 19, fontWeight: FontWeight.w900)),
const SizedBox(height: 5),
Text(customerEmail, maxLines: 2, overflow: TextOverflow.ellipsis,
style: const TextStyle(color: Color(0xFF8C829B), fontSize: 12)),
const SizedBox(height: 8),
const Text('CUSTOMER ACCOUNT', style: TextStyle(
color: orange, fontSize: 10, fontWeight: FontWeight.w900,
letterSpacing: 0.5)),
],
)),
]),
const SizedBox(height: 14),
SizedBox(width: double.infinity,
child: OutlinedButton.icon(
onPressed: editProfile,
icon: const Icon(Icons.edit_outlined, size: 18),
label: const Text('Edit Profile'),
style: OutlinedButton.styleFrom(
foregroundColor: darkPurple,
side: const BorderSide(color: Color(0xFFE9E1F2)),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
),
),
),
const Divider(height: 25),
ValueListenableBuilder<List<RentalBooking>>(
valueListenable: BookingStore.bookings,
builder: (context, bookings, child) {
final total = bookings.length;
final ongoing = bookings.where((b) =>
b.currentStatus == BookingStatus.ongoing).length;
final completed = bookings.where((b) =>
b.currentStatus == BookingStatus.completed).length;
final cancelled = bookings.where((b) =>
b.currentStatus == BookingStatus.cancelled).length;
return Row(children: [
statItem(Icons.directions_car_rounded, '$total', 'Total', orange),
statItem(Icons.calendar_month_rounded, '$ongoing', 'Ongoing', darkPurple),
statItem(Icons.check_circle_rounded, '$completed', 'Completed',
const Color(0xFF21A779)),
statItem(Icons.cancel_rounded, '$cancelled', 'Cancelled',
const Color(0xFFE34C72)),
]);
},
),
]),
);
}

Widget profileSection(String title, IconData icon, Widget content) {
return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
Row(children: [
Container(width: 39, height: 39,
decoration: BoxDecoration(color: const Color(0xFFFFEBDD),
borderRadius: BorderRadius.circular(12)),
child: Icon(icon, color: orange, size: 22),
),
const SizedBox(width: 11),
Expanded(child: Text(title, style: const TextStyle(
color: darkPurple, fontSize: 20, fontWeight: FontWeight.w900))),
]),
const SizedBox(height: 15),
content,
]);
}

Widget profileAction({
required IconData icon,
required String title,
required String subtitle,
required VoidCallback onTap,
}) {
return Container(
margin: const EdgeInsets.only(bottom: 11),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
border: Border.all(color: const Color(0xFFE9E1F2)),
boxShadow: [BoxShadow(color: darkPurple.withOpacity(0.05),
blurRadius: 12, offset: const Offset(0, 4))],
),
child: Material(color: Colors.transparent,
child: InkWell(
borderRadius: BorderRadius.circular(19),
onTap: onTap,
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
child: Row(children: [
Container(width: 49, height: 49,
decoration: BoxDecoration(color: darkPurple,
borderRadius: BorderRadius.circular(14)),
child: Icon(icon, color: orange, size: 24)),
const SizedBox(width: 14),
Expanded(child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title, style: const TextStyle(color: darkPurple,
fontSize: 14, fontWeight: FontWeight.w900)),
const SizedBox(height: 4),
Text(subtitle, style: const TextStyle(
color: Color(0xFF8C829B), fontSize: 11)),
],
)),
const Icon(Icons.chevron_right_rounded, color: orange, size: 26),
]),
),
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF6F3FA),
bottomNavigationBar: const AppBottomBar(selectedIndex: 2),
body: SafeArea(
child: SingleChildScrollView(
child: Column(children: [
profileHeader(),
Center(child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 900),
child: Padding(
padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
profileOverview(),
const SizedBox(height: 28),
profileSection('Account Information', Icons.person_outline_rounded,
roundedCard(Padding(
padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
child: Column(children: [
accountRow(Icons.person_outline_rounded, 'Full Name', customerName),
const Divider(height: 1),
accountRow(Icons.email_outlined, 'Email', customerEmail),
const Divider(height: 1),
accountRow(Icons.phone_outlined, 'Phone', customerPhone),
]),
)),
),
const SizedBox(height: 27),
profileSection('My Rentals', Icons.car_rental_rounded,
Column(children: [
profileAction(icon: Icons.car_rental_rounded,
title: 'My Bookings',
subtitle: 'Upcoming and ongoing reservations',
onTap: openMyBookings),
]),
),
const SizedBox(height: 17),
const SizedBox(height: 18),
SizedBox(width: double.infinity, height: 52,
child: OutlinedButton.icon(
onPressed: isLoggingOut ? null : confirmLogout,
icon: const Icon(Icons.logout_rounded),
label: const Text('LOG OUT', style: TextStyle(
fontWeight: FontWeight.w900)),
style: OutlinedButton.styleFrom(
foregroundColor: orange,
side: const BorderSide(color: orange, width: 1.5),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16)),
),
),
),
const SizedBox(height: 22),
const Center(child: Text('CAR RENTAL MANAGEMENT SYSTEM\nVersion 1.0',
textAlign: TextAlign.center,
style: TextStyle(color: Color(0xFFAAA1B5),
fontSize: 10, height: 1.6))),
],
),
),
)),
]),
),
),
);
}
}
