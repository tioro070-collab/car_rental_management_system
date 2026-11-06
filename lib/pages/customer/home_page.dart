

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_colors.dart';
import '../../widgets/app_bottom_bar.dart';
import 'available_cars_page.dart';
import 'my_bookings_page.dart';

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
String selectedBranch = 'All Branches';

final List<String> branches = [
'All Branches',
'Muar',
'Johor Bahru',
'Batu Pahat',
'Kluang',
'Melaka',
'Seremban',
];

void openCars() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => AvailableCarsScreen(
initialBranch: selectedBranch,
),
),
);
}

void openMyBookings() {
Navigator.push(
context,
MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
);
}

void comingSoon(String feature) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('$feature will be available soon!'),
backgroundColor: darkPurple,
behavior: SnackBarBehavior.floating,
),
);
}

BoxDecoration get cardDecoration => BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
border: Border.all(color: const Color(0xFFE9E1F2)),
boxShadow: [
BoxShadow(
color: darkPurple.withOpacity(0.05),
blurRadius: 13,
offset: const Offset(0, 5),
),
],
);

Widget sectionHeading(String title, IconData icon,
{VoidCallback? onViewAll}) {
return Row(
children: [
Container(
width: 39,
height: 39,
decoration: BoxDecoration(
color: const Color(0xFFFFEBDD),
borderRadius: BorderRadius.circular(12),
),
child: Icon(icon, color: orange, size: 22),
),
const SizedBox(width: 11),
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
if (onViewAll != null)
TextButton(
onPressed: onViewAll,
child: const Text(
'View All',
style: TextStyle(color: orange, fontWeight: FontWeight.bold),
),
),
],
);
}

Widget buildHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [darkPurple, Color(0xFF35135B), Color(0xFF49216F)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 900),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 45,
height: 45,
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.10),
borderRadius: BorderRadius.circular(13),
),
child: const Icon(Icons.directions_car_filled_rounded,
color: orange, size: 27),
),
const SizedBox(width: 11),
const Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('CAR RENTAL',
style: TextStyle(
color: Colors.white,
fontSize: 16,
fontWeight: FontWeight.w900,
letterSpacing: 1)),
SizedBox(height: 3),
Text('MANAGEMENT SYSTEM',
style: TextStyle(
color: Color(0xFFD9CCE8),
fontSize: 9,
fontWeight: FontWeight.w700,
letterSpacing: 1.2)),
],
),
),
Container(
padding:
const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
decoration: BoxDecoration(
color: orange,
borderRadius: BorderRadius.circular(20),
),
child: const Text('CUSTOMER',
style: TextStyle(
color: Colors.white,
fontSize: 10,
fontWeight: FontWeight.w900,
letterSpacing: 0.5)),
),
IconButton(
tooltip: 'Notifications',
onPressed: () => comingSoon('Notifications'),
icon: const Icon(Icons.notifications_none_rounded,
color: Colors.white),
),
],
),
const SizedBox(height: 32),
StreamBuilder<User?>(
stream: FirebaseAuth.instance.userChanges(),
builder: (context, snapshot) {
final name = (snapshot.data?.displayName ??
FirebaseAuth.instance.currentUser?.displayName ?? '')
    .trim();
return Text.rich(
TextSpan(children: [
const TextSpan(text: 'Hello', style: TextStyle(color: Colors.white)),
if (name.isNotEmpty) ...[
const TextSpan(text: ', ', style: TextStyle(color: Colors.white)),
TextSpan(text: name, style: const TextStyle(color: orange)),
],
const TextSpan(text: '!', style: TextStyle(color: Colors.white)),
]),
style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
);
},
),
const SizedBox(height: 8),
const Text('Ready for your next journey?',
style: TextStyle(color: Color(0xFFE0D6EC), fontSize: 13)),
const SizedBox(height: 19),
Container(
width: 47,
height: 4,
decoration: BoxDecoration(
color: orange,
borderRadius: BorderRadius.circular(10),
),
),
],
),
),
),
);
}

Widget featuredCard() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(19),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [darkPurple, Color(0xFF49216F)],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(19),
),
child: Row(
children: [
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('EXPLORE OUR FLEET',
style: TextStyle(
color: orange,
fontSize: 10,
fontWeight: FontWeight.w900,
letterSpacing: 1)),
const SizedBox(height: 9),
const Text('YOUR RIDE.\nYOUR WAY.',
style: TextStyle(
color: Colors.white,
fontSize: 23,
height: 1.15,
fontWeight: FontWeight.w900)),
const SizedBox(height: 15),
ElevatedButton(
onPressed: openCars,
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
elevation: 0,
padding: const EdgeInsets.symmetric(
horizontal: 14, vertical: 10),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(11)),
),
child: const Text('Explore Cars',
style: TextStyle(fontWeight: FontWeight.w800)),
),
],
),
),
const SizedBox(width: 8),
const Icon(Icons.directions_car_filled_rounded,
color: Color(0xFFE1D6ED), size: 85),
],
),
);
}

Widget searchPanel() {
return Container(
padding: const EdgeInsets.all(16),
decoration: cardDecoration,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text('Pickup Branch',
style: TextStyle(
color: darkPurple,
fontWeight: FontWeight.w800,
fontSize: 13)),
const SizedBox(height: 9),
Container(
padding: const EdgeInsets.symmetric(horizontal: 12),
decoration: BoxDecoration(
color: const Color(0xFFF8F6FB),
border: Border.all(color: const Color(0xFFE9E1F2)),
borderRadius: BorderRadius.circular(13),
),
child: Row(
children: [
const Icon(Icons.location_on_outlined, color: orange),
const SizedBox(width: 9),
Expanded(
child: DropdownButtonHideUnderline(
child: DropdownButton<String>(
value: selectedBranch,
isExpanded: true,
items: branches
    .map((branch) => DropdownMenuItem(
value: branch,
child: Text(branch,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.w600)),
))
    .toList(),
onChanged: (value) {
if (value != null) {
setState(() => selectedBranch = value);
}
},
),
),
),
],
),
),
const SizedBox(height: 12),
SizedBox(
width: double.infinity,
height: 49,
child: ElevatedButton.icon(
onPressed: openCars,
icon: const Icon(Icons.search_rounded),
label: const Text('SEARCH AVAILABLE CARS',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w900,
letterSpacing: 0.5)),
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(13)),
),
),
),
],
),
);
}

Widget quickAction(IconData icon, String title, VoidCallback onTap) {
return Material(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(19),
child: Container(
padding: const EdgeInsets.all(14),
decoration: cardDecoration,
child: Row(
children: [
Container(
width: 43,
height: 43,
decoration: BoxDecoration(
color: const Color(0xFFFFEBDD),
borderRadius: BorderRadius.circular(12),
),
child: Icon(icon, color: orange, size: 23),
),
const SizedBox(width: 10),
Expanded(
child: Text(title,
maxLines: 2,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: darkPurple,
fontSize: 13,
fontWeight: FontWeight.w900)),
),
],
),
),
),
);
}

Widget categoryCard(String title, String subtitle, IconData icon) {
return Material(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
child: InkWell(
onTap: openCars,
borderRadius: BorderRadius.circular(19),
child: Container(
width: 155,
padding: const EdgeInsets.all(15),
decoration: cardDecoration,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: const Color(0xFFFFEBDD),
borderRadius: BorderRadius.circular(12),
),
child: Icon(icon, color: orange, size: 24),
),
const Spacer(),
Text(title,
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.w900,
fontSize: 14)),
const SizedBox(height: 4),
Text(subtitle,
maxLines: 1,
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Color(0xFF8C829B), fontSize: 11)),
],
),
),
),
);
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFF6F3FA),
bottomNavigationBar: const AppBottomBar(selectedIndex: 0),
body: SafeArea(
child: ListView(
padding: EdgeInsets.zero,
children: [
buildHeader(),
Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 900),
child: Padding(
padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
featuredCard(),
const SizedBox(height: 27),
sectionHeading('Find a Car', Icons.search_rounded),
const SizedBox(height: 14),
searchPanel(),
const SizedBox(height: 27),
sectionHeading('Quick Access', Icons.grid_view_rounded),
const SizedBox(height: 14),
LayoutBuilder(builder: (context, constraints) {
final singleColumn = constraints.maxWidth < 320;
final actions = [
quickAction(Icons.directions_car_outlined,
'Browse Cars', openCars),
quickAction(Icons.calendar_month_outlined,
'My Bookings', openMyBookings),
quickAction(Icons.payments_outlined,
'Payments', () => comingSoon('Payments')),
quickAction(Icons.notifications_none_rounded,
'Alerts', () => comingSoon('Alerts')),
];
if (singleColumn) {
return Column(
children: [
for (var i = 0; i < actions.length; i++) ...[
actions[i],
if (i < actions.length - 1)
const SizedBox(height: 12),
],
],
);
}
return Column(
children: [
Row(children: [
Expanded(child: actions[0]),
const SizedBox(width: 12),
Expanded(child: actions[1]),
]),
const SizedBox(height: 12),
Row(children: [
Expanded(child: actions[2]),
const SizedBox(width: 12),
Expanded(child: actions[3]),
]),
],
);
}),
const SizedBox(height: 27),
sectionHeading('Explore Categories',
Icons.category_outlined,
onViewAll: openCars),
const SizedBox(height: 14),
SizedBox(
height: 155,
child: ListView(
scrollDirection: Axis.horizontal,
children: [
categoryCard('Budget', 'Affordable rides',
Icons.savings_outlined),
const SizedBox(width: 12),
categoryCard('Local', 'Proton & Perodua',
Icons.flag_outlined),
const SizedBox(width: 12),
categoryCard('Sedan', 'Comfortable travel',
Icons.directions_car_outlined),
const SizedBox(width: 12),
categoryCard('Premium', 'Extra comfort',
Icons.auto_awesome_outlined),
],
),
),
const SizedBox(height: 27),
Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: darkPurple,
borderRadius: BorderRadius.circular(19),
),
child: const Row(
children: [
Icon(Icons.verified_user_outlined,
color: orange, size: 31),
SizedBox(width: 13),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Easy & Convenient',
style: TextStyle(
color: Colors.white,
fontSize: 15,
fontWeight: FontWeight.w900)),
SizedBox(height: 5),
Text(
'Choose your pickup branch, explore vehicles, and book your next ride.',
style: TextStyle(
color: Color(0xFFCEC6DB),
fontSize: 12,
height: 1.4),
),
],
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
],
),
),
);
}
}


