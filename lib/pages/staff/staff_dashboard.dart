import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_page.dart';

import '../../theme/app_colors.dart';
import '../../models/car_model.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import '../../widgets/car_picture.dart';

import 'staff_vehicle_management_page.dart';
import 'staff_booking_management_page.dart';
import 'staff_booking_details_page.dart';

class StaffDashboard extends StatefulWidget {
const StaffDashboard({super.key});

@override
State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
int selectedTab = 0;
String selectedTaskFilter = 'All';

@override
void initState() {
super.initState();
loadStaffBookings();
}

Future<void> loadStaffBookings() async {
try {
await BookingStore.startStaffListening();
} catch (error) {
debugPrint('Unable to load staff bookings: $error');

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Unable to load bookings. Please try again.',
),
backgroundColor: Colors.redAccent,
),
);
}
}


final String staffName = 'Staff Account';
final String staffId = 'STF001';
final String staffBranch = 'Muar';

bool isLoggingOut = false;

Future<void> logoutStaff() async {
if (isLoggingOut) return;

setState(() {
isLoggingOut = true;
});

try {
// End the staff Firebase session.
await FirebaseAuth.instance.signOut();

// Clear any customer-specific booking data
// still held in the shared booking store.
BookingStore.stopListening();

if (!mounted) return;

Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(
builder: (_) => const LoginScreen(),
),
(route) => false,
);
} catch (e) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Unable to log out. Please try again.',
),
backgroundColor: Colors.redAccent,
behavior: SnackBarBehavior.floating,
),
);

setState(() {
isLoggingOut = false;
});
}
}


// ------------------------------------
// DATE HELPERS
// ------------------------------------

DateTime get today {
final now = DateTime.now();
return DateTime(now.year, now.month, now.day);
}

DateTime dateOnly(DateTime date) {
return DateTime(date.year, date.month, date.day);
}

bool isToday(DateTime date) {
return dateOnly(date) == today;
}

String formatDate(DateTime date) {
final day = date.day.toString().padLeft(2, '0');
final month = date.month.toString().padLeft(2, '0');
return '$day/$month/${date.year}';
}

String bookingStatus(RentalBooking booking) {
if (booking.status == BookingStatus.cancelled) {
return 'Cancelled';
}

if (booking.hasReturned) {
return 'Returned';
}

if (booking.hasPickedUp) {
return 'On Rent';
}

if (dateOnly(booking.pickupDate).isAfter(today)) {
return 'Upcoming';
}

if (dateOnly(booking.returnDate).isBefore(today)) {
return 'Pickup Pending';
}

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
return const Color(0xFF0EAA78);

case 'Cancelled':
return const Color(0xFFE54266);

default:
return darkPurple;
}
}

// ------------------------------------
// STAFF BOOKING DATA
// ------------------------------------

List<RentalBooking> branchBookings(
List<RentalBooking> allBookings,
) {
return allBookings.where((booking) {
return booking.car.branch.toLowerCase() ==
staffBranch.toLowerCase();
}).toList();
}

List<RentalBooking> pickupTasks(
List<RentalBooking> bookings,
) {
return bookings.where((booking) {
return booking.status != BookingStatus.cancelled &&
!booking.hasPickedUp &&
!booking.hasReturned &&
isToday(booking.pickupDate);
}).toList();
}

List<RentalBooking> returnTasks(
List<RentalBooking> bookings,
) {
return bookings.where((booking) {
return booking.status != BookingStatus.cancelled &&
booking.hasPickedUp &&
!booking.hasReturned &&
isToday(booking.returnDate);
}).toList();
}

List<RentalBooking> overdueTasks(
List<RentalBooking> bookings,
) {
// Only vehicles actually collected by customers
// can be considered overdue for return.
return bookings.where((booking) {
return booking.status != BookingStatus.cancelled &&
booking.hasPickedUp &&
!booking.hasReturned &&
dateOnly(booking.returnDate).isBefore(today);
}).toList();
}

// ------------------------------------
// NAVIGATION
// ------------------------------------

void openBookings() {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => StaffBookingManagementPage(
branch: staffBranch,
),
),
);
}

void openBookingDetails(RentalBooking booking) {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => StaffBookingDetailsPage(
bookingId: booking.id,
),
),
);
}

void openTab(int index) {
if (index == 1) {
openBookings();
return;
}

if (index == 2) {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) => StaffVehicleManagementPage(
branch: staffBranch,
),
),
);
return;
}

setState(() {
selectedTab = index;
});
}

void showInfo(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
backgroundColor: darkPurple,
behavior: SnackBarBehavior.floating,
),
);
}

// ------------------------------------
// REUSABLE UI
// ------------------------------------

Widget sectionHeading(
String title, {
VoidCallback? onViewAll,
}) {
return Row(
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
if (onViewAll != null)
TextButton(
onPressed: onViewAll,
child: const Row(
mainAxisSize: MainAxisSize.min,
children: [
Text(
'View All',
style: TextStyle(
color: Color(0xFF5030C9),
fontWeight: FontWeight.bold,
fontSize: 12,
),
),
SizedBox(width: 4),
Icon(
Icons.arrow_forward_ios_rounded,
color: Color(0xFF5030C9),
size: 12,
),
],
),
),
],
);
}

Widget roundedPanel(Widget child) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
border: Border.all(color: const Color(0xFFE9E1F2)),
boxShadow: [
BoxShadow(
color: darkPurple.withOpacity(0.05),
blurRadius: 16,
offset: const Offset(0, 5),
),
],
),
child: child,
);
}

// ------------------------------------
// PREMIUM HEADER
// ------------------------------------

Widget dashboardHeader() {
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
Text('CAR RENTAL', style: TextStyle(
color: Colors.white, fontSize: 16,
fontWeight: FontWeight.w900, letterSpacing: 1)),
SizedBox(height: 3),
Text('MANAGEMENT SYSTEM', style: TextStyle(
color: Color(0xFFD9CCE8), fontSize: 9,
fontWeight: FontWeight.w700, letterSpacing: 1.2)),
],
),
),
Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
decoration: BoxDecoration(
color: orange, borderRadius: BorderRadius.circular(20)),
child: const Text('STAFF', style: TextStyle(
color: Colors.white, fontSize: 10,
fontWeight: FontWeight.w900, letterSpacing: 0.8)),
),
IconButton(
tooltip: 'Notifications',
onPressed: () => showInfo('Staff notifications will be connected later.'),
icon: const Icon(Icons.notifications_none_rounded,
color: Colors.white, size: 23),
),
IconButton(
tooltip: 'Log out',
onPressed: isLoggingOut ? null : logoutStaff,
icon: isLoggingOut
? const SizedBox(width: 20, height: 20,
child: CircularProgressIndicator(
color: Colors.white, strokeWidth: 2))
    : const Icon(Icons.logout_rounded,
color: Colors.white, size: 23),
),
],
),
const SizedBox(height: 35),
const Text.rich(
TextSpan(children: [
TextSpan(text: 'Welcome, ',
style: TextStyle(color: Colors.white)),
TextSpan(text: 'Staff',
style: TextStyle(color: orange)),
]),
style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
),
const SizedBox(height: 8),
Text('$staffBranch Branch  •  Staff ID: $staffId',
style: const TextStyle(color: Color(0xFFE0D6EC), fontSize: 13)),
const SizedBox(height: 19),
Container(width: 47, height: 4,
decoration: BoxDecoration(color: orange,
borderRadius: BorderRadius.circular(10))),
],
),
);
}

// ------------------------------------
// DASHBOARD STATISTICS
// ------------------------------------

Widget statisticCard({
required IconData icon,
required String number,
required String label,
required String subtitle,
required Color color,
VoidCallback? onTap,
}) {
return Material(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(19),
child: Container(
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(19),
border: Border.all(color: const Color(0xFFE9E1F2)),
boxShadow: [BoxShadow(
color: darkPurple.withOpacity(0.05),
blurRadius: 12, offset: const Offset(0, 4))],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Container(
width: 42, height: 42,
decoration: BoxDecoration(
color: const Color(0xFFFFEBDD),
borderRadius: BorderRadius.circular(12)),
child: Icon(icon, color: orange, size: 23),
),
const Spacer(),
Text(number, style: const TextStyle(
color: darkPurple, fontSize: 26,
fontWeight: FontWeight.w900)),
const SizedBox(height: 3),
Text(label, maxLines: 2, overflow: TextOverflow.ellipsis,
style: const TextStyle(color: darkPurple,
fontSize: 13, fontWeight: FontWeight.w900)),
const SizedBox(height: 3),
Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Color(0xFF8C829B), fontSize: 10)),
],
),
),
),
);
}

Widget dashboardStatistics(
List<RentalBooking> bookings,
) {
final todaysBookings = bookings.where(
(booking) => isToday(booking.bookedAt),
).length;

final branchCars = carList.where(
(car) =>
car.branch.toLowerCase() ==
staffBranch.toLowerCase(),
).toList();

final availableCars = branchCars.where(
(car) => car.available,
).length;

final activeRentals = bookings.where(
(booking) =>
booking.status != BookingStatus.cancelled &&
booking.hasPickedUp &&
!booking.hasReturned,
).length;

final returnsToday = returnTasks(bookings).length;

return LayoutBuilder(
builder: (context, constraints) {
final columns = constraints.maxWidth >= 700 ? 4 : 2;
final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
final cardHeight = columns == 4 ? 165.0 : 180.0;
return GridView.count(
crossAxisCount: columns,
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
mainAxisSpacing: 12,
crossAxisSpacing: 12,
childAspectRatio: cardWidth / cardHeight,
children: [
statisticCard(
icon: Icons.calendar_month_rounded,
number: '$todaysBookings',
label: "Today's Bookings",
subtitle: 'New reservations today',
color: orange,
onTap: openBookings,
),
statisticCard(
icon: Icons.directions_car_rounded,
number: '$availableCars',
label: 'Vehicles Available',
subtitle: '${branchCars.length} catalog vehicles',
color: const Color(0xFF5030C9),
onTap: () => openTab(2),
),
statisticCard(
icon: Icons.key_rounded,
number: '$activeRentals',
label: 'Active Rentals',
subtitle: 'Confirmed vehicle pickups',
color: const Color(0xFF0EAA78),
onTap: openBookings,
),
statisticCard(
icon: Icons.assignment_return_rounded,
number: '$returnsToday',
label: 'Returns Today',
subtitle: 'Awaiting vehicle return',
color: const Color(0xFFE54266),
onTap: () {
setState(() {
selectedTab = 0;
selectedTaskFilter = 'Returns';
});
},
),
],
);
},
);
}

// ------------------------------------
// QUICK ACTIONS
// ------------------------------------

Widget quickAction({
required IconData icon,
required String label,
required Color color,
required VoidCallback onTap,
}) {
return Material(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
child: InkWell(
onTap: onTap,
borderRadius: BorderRadius.circular(19),
child: Container(
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(19),
border: Border.all(color: const Color(0xFFE9E1F2)),
),
child: Row(
children: [
Container(
width: 42, height: 42,
decoration: BoxDecoration(
color: darkPurple,
borderRadius: BorderRadius.circular(12)),
child: Icon(icon, color: orange, size: 23),
),
const SizedBox(width: 10),
Expanded(child: Text(label,
maxLines: 2, overflow: TextOverflow.ellipsis,
style: const TextStyle(color: darkPurple,
fontSize: 13, fontWeight: FontWeight.w900))),
],
),
),
),
);
}

Widget quickActions() {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
sectionHeading('Quick Actions'),
const SizedBox(height: 14),
LayoutBuilder(builder: (context, constraints) {
final columns = constraints.maxWidth >= 700 ? 4 : 2;
final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
return GridView.count(
crossAxisCount: columns,
mainAxisSpacing: 12,
crossAxisSpacing: 12,
childAspectRatio: width / 94,
shrinkWrap: true,
physics: const NeverScrollableScrollPhysics(),
children: [
quickAction(icon: Icons.event_available_rounded,
label: 'Bookings', color: orange, onTap: openBookings),
quickAction(icon: Icons.directions_car_rounded,
label: 'Vehicles', color: orange, onTap: () => openTab(2)),
quickAction(icon: Icons.bar_chart_rounded,
label: 'Reports', color: orange,
onTap: () => showInfo('Staff reports will be added later.')),
],
);
}),
],
);
}

// ------------------------------------
// TASK FILTER CHIPS
// ------------------------------------

Widget taskFilter(
String label,
int count,
) {
final selected = selectedTaskFilter == label;

return Padding(
padding: const EdgeInsets.only(right: 8),
child: ChoiceChip(
selected: selected,
onSelected: (_) {
setState(() {
selectedTaskFilter = label;
});
},
label: Text('$label ($count)'),
selectedColor: orange,
backgroundColor: const Color(0xFFF1ECFF),
labelStyle: TextStyle(
color: selected ? Colors.white : darkPurple,
fontSize: 11,
fontWeight: FontWeight.bold,
),
side: BorderSide.none,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
),
);
}

// ------------------------------------
// TODAY'S TASK CARDS
// ------------------------------------

Widget taskCard(
RentalBooking booking,
String taskType,
) {
final isPickup = taskType == 'Pickup';
final isOverdue = taskType == 'Overdue';

final taskColor = isOverdue
? const Color(0xFFE54266)
    : isPickup
? orange
    : const Color(0xFF0EAA78);

return Container(
margin: const EdgeInsets.only(top: 11),
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: const Color(0xFFF8F7FC),
borderRadius: BorderRadius.circular(17),
),
child: InkWell(
onTap: () => openBookingDetails(booking),
borderRadius: BorderRadius.circular(17),
child: Row(
children: [
SizedBox(
width: 92,
height: 78,
child: CarPicture(
car: booking.car,
height: 78,
),
),
const SizedBox(width: 11),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
booking.car.name,
style: const TextStyle(
color: darkPurple,
fontSize: 14,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 5),
Text(
'Booking ${booking.id}',
overflow: TextOverflow.ellipsis,
style: const TextStyle(
color: Colors.black54,
fontSize: 10,
),
),
const SizedBox(height: 5),
Text(
'${formatDate(
isPickup
? booking.pickupDate
    : booking.returnDate,
)} • ${booking.car.branch}',
style: const TextStyle(
color: Colors.black54,
fontSize: 10,
),
),
],
),
),
const SizedBox(width: 5),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 9,
vertical: 7,
),
decoration: BoxDecoration(
color: taskColor.withOpacity(0.12),
borderRadius: BorderRadius.circular(15),
),
child: Text(
taskType,
style: TextStyle(
color: taskColor,
fontWeight: FontWeight.bold,
fontSize: 10,
),
),
),
],
),
),
);
}

Widget todayTasks(
List<RentalBooking> bookings,
) {
final pickups = pickupTasks(bookings);
final returns = returnTasks(bookings);
final overdue = overdueTasks(bookings);

final List<Widget> taskWidgets = [];

if (selectedTaskFilter == 'All' ||
selectedTaskFilter == 'Pickups') {
for (final booking in pickups) {
taskWidgets.add(taskCard(booking, 'Pickup'));
}
}

if (selectedTaskFilter == 'All' ||
selectedTaskFilter == 'Returns') {
for (final booking in returns) {
taskWidgets.add(taskCard(booking, 'Return'));
}
}

if (selectedTaskFilter == 'All' ||
selectedTaskFilter == 'Overdue') {
for (final booking in overdue) {
taskWidgets.add(taskCard(booking, 'Overdue'));
}
}

return roundedPanel(
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
sectionHeading(
"Today's Tasks",
onViewAll: openBookings,
),
const SizedBox(height: 10),
SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [
taskFilter(
'All',
pickups.length +
returns.length +
overdue.length,
),
taskFilter(
'Pickups',
pickups.length,
),
taskFilter(
'Returns',
returns.length,
),
taskFilter(
'Overdue',
overdue.length,
),
],
),
),
if (taskWidgets.isEmpty)
const Padding(
padding: EdgeInsets.symmetric(vertical: 28),
child: Center(
child: Column(
children: [
Icon(
Icons.task_alt_rounded,
color: Color(0xFF5030C9),
size: 38,
),
SizedBox(height: 9),
Text(
'No tasks in this category',
style: TextStyle(
color: Colors.black54,
fontSize: 12,
),
),
],
),
),
)
else
...taskWidgets,
],
),
);
}

// ------------------------------------
// RECENT BOOKING CARDS
// ------------------------------------

Widget bookingListCard(RentalBooking booking) {
final status = bookingStatus(booking);
final color = statusColor(status);

return InkWell(
onTap: () => openBookingDetails(booking),
borderRadius: BorderRadius.circular(15),
child: Padding(
padding: const EdgeInsets.symmetric(vertical: 11),
child: Row(
children: [
SizedBox(
width: 75,
height: 59,
child: CarPicture(
car: booking.car,
height: 59,
),
),
const SizedBox(width: 10),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
booking.car.name,
style: const TextStyle(
color: darkPurple,
fontWeight: FontWeight.w900,
fontSize: 13,
),
),
const SizedBox(height: 4),
Text(
'${formatDate(booking.pickupDate)} - '
'${formatDate(booking.returnDate)}',
style: const TextStyle(
color: Colors.black54,
fontSize: 10,
),
),
],
),
),
Container(
padding: const EdgeInsets.symmetric(
horizontal: 9,
vertical: 7,
),
decoration: BoxDecoration(
color: color.withOpacity(0.11),
borderRadius: BorderRadius.circular(18),
),
child: Text(
status,
style: TextStyle(
color: color,
fontSize: 10,
fontWeight: FontWeight.bold,
),
),
),
const SizedBox(width: 5),
const Icon(
Icons.chevron_right_rounded,
color: darkPurple,
),
],
),
),
);
}

Widget recentBookings(
List<RentalBooking> bookings,
) {
final recent = bookings.take(3).toList();

return roundedPanel(
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
sectionHeading(
'Recent Bookings',
onViewAll: openBookings,
),
const SizedBox(height: 8),
if (recent.isEmpty)
const Padding(
padding: EdgeInsets.symmetric(vertical: 28),
child: Center(
child: Text(
'No bookings yet.\n'
'Customer reservations will appear here.',
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.black54,
height: 1.6,
),
),
),
)
else
for (int i = 0; i < recent.length; i++) ...[
bookingListCard(recent[i]),
if (i != recent.length - 1)
const Divider(height: 1),
],
],
),
);
}

// ------------------------------------
// DASHBOARD HOME
// ------------------------------------

Widget dashboardPage(
List<RentalBooking> bookings,
) {
return ListView(
padding: EdgeInsets.zero,
children: [
dashboardHeader(),
Padding(
padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
child: Column(
children: [
dashboardStatistics(bookings),
const SizedBox(height: 17),
quickActions(),
const SizedBox(height: 17),
todayTasks(bookings),
const SizedBox(height: 17),
recentBookings(bookings),
],
),
),
],
);
}

// ------------------------------------
// VEHICLE MANAGEMENT TAB
// ------------------------------------

Widget vehiclesPage() {
final cars = carList.where(
(car) =>
car.branch.toLowerCase() ==
staffBranch.toLowerCase(),
).toList();

return ListView(
padding: const EdgeInsets.all(16),
children: [
const Text(
'Vehicle Management',
style: TextStyle(
color: darkPurple,
fontSize: 25,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 6),
Text(
'$staffBranch Branch • ${cars.length} vehicles',
style: const TextStyle(
color: Colors.black54,
),
),
const SizedBox(height: 20),
if (cars.isEmpty)
roundedPanel(
const Center(
child: Text('No vehicles assigned.'),
),
),
for (final car in cars)
Container(
margin: const EdgeInsets.only(bottom: 13),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(19),
),
child: Row(
children: [
SizedBox(
width: 108,
height: 86,
child: CarPicture(
car: car,
height: 86,
),
),
const SizedBox(width: 12),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
car.name,
style: const TextStyle(
color: darkPurple,
fontSize: 16,
fontWeight: FontWeight.w900,
),
),
const SizedBox(height: 5),
Text(
'${car.plate} • ${car.type}',
style: const TextStyle(
color: Colors.black54,
fontSize: 11,
),
),
const SizedBox(height: 8),
Text(
car.available
? 'Catalog: Available'
    : 'Catalog: Unavailable',
style: TextStyle(
color: car.available
? const Color(0xFF0EAA78)
    : Colors.red,
fontWeight: FontWeight.bold,
fontSize: 12,
),
),
],
),
),
],
),
),
],
);
}

// ------------------------------------
// MOBILE BOTTOM NAVIGATION
// ------------------------------------

Widget bottomNavItem(
int index,
IconData icon,
String label,
) {
final selected = selectedTab == index;

return Expanded(
child: InkWell(
onTap: () => openTab(index),
child: Padding(
padding: const EdgeInsets.symmetric(
vertical: 11,
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
color: selected
? orange
    : const Color(0xFFC6B5E4),
size: 25,
),
const SizedBox(height: 5),
Text(
label,
style: TextStyle(
color: selected
? orange
    : const Color(0xFFC6B5E4),
fontSize: 11,
fontWeight: selected
? FontWeight.w900
    : FontWeight.normal,
),
),
],
),
),
),
);
}

Widget staffBottomNavigation() {
return Container(
decoration: const BoxDecoration(
color: darkPurple,
borderRadius: BorderRadius.vertical(
top: Radius.circular(25),
),
),
child: SafeArea(
top: false,
child: Row(
children: [
bottomNavItem(
0,
Icons.home_rounded,
'Dashboard',
),
bottomNavItem(
1,
Icons.calendar_month_rounded,
'Bookings',
),
bottomNavItem(
2,
Icons.directions_car_rounded,
'Vehicles',
),
],
),
),
);
}

// ------------------------------------
// MAIN BUILD
// ------------------------------------

@override
Widget build(BuildContext context) {
return ValueListenableBuilder<List<RentalBooking>>(
valueListenable: BookingStore.bookings,
builder: (context, allBookings, _) {
final bookings = branchBookings(allBookings);

Widget currentPage;

switch (selectedTab) {
case 2:
currentPage = vehiclesPage();
break;

default:
currentPage = dashboardPage(bookings);
}

return Scaffold(
backgroundColor: const Color(0xFFF6F3FA),
body: SafeArea(
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 900,
),
child: currentPage,
),
),
),
bottomNavigationBar: staffBottomNavigation(),
);
},
);
}
}

