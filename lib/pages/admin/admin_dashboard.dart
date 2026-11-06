
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../auth/login_page.dart';
import 'admin_management_pages.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool isLoggingOut = false;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _carsStream =
  _db.collection('cars').snapshots();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _bookingsStream =
  _db.collection('bookings').snapshots();

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _employeesStream =
  _db.collection('employees').snapshots();

  // ----------------------------------------
  // ADMIN LOGOUT
  // ----------------------------------------

  Future<void> logout() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();

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

  // ----------------------------------------
  // HEADER
  // ----------------------------------------

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkPurple,
            Color(0xFF35135B),
            Color(0xFF49216F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
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
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: orange,
                  size: 27,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAR RENTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'MANAGEMENT SYSTEM',
                      style: TextStyle(
                        color: Color(0xFFD9CCE8),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              IconButton(
                tooltip: 'Log out',
                onPressed: isLoggingOut ? null : logout,
                icon: isLoggingOut
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome, ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: 'Admin',
                  style: TextStyle(color: orange),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage your rental operations here.',
            style: TextStyle(
              color: Color(0xFFE0D6EC),
              fontSize: 13,
            ),
          ),
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
    );
  }

  // ----------------------------------------
  // SECTION HEADING
  // ----------------------------------------

  Widget sectionHeading({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBDD),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: orange,
            size: 22,
          ),
        ),
        const SizedBox(width: 11),
        Text(
          title,
          style: const TextStyle(
            color: darkPurple,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------
  // OVERVIEW CARD WITH FIREBASE
  // ----------------------------------------

  Widget overviewCard({
    required String title,
    required IconData icon,
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    bool activeOnly = false,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        String value;

        if (snapshot.hasError) {
          value = 'Error';
        } else if (!snapshot.hasData) {
          value = '...';
        } else if (activeOnly) {
          final activeRentals = snapshot.data!.docs.where((doc) {
            final status = doc.data()['status']
                ?.toString()
                .trim()
                .toLowerCase();

            return status == 'ongoing';
          }).length;

          value = activeRentals.toString();
        } else {
          value = snapshot.data!.docs.length.toString();
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFE9E1F2),
            ),
            boxShadow: [
              BoxShadow(
                color: darkPurple.withOpacity(0.06),
                blurRadius: 13,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBDD),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: orange,
                  size: 23,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: darkPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  color: snapshot.hasError
                      ? Colors.redAccent
                      : darkPurple,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ----------------------------------------
  // MANAGEMENT TILE
  // ----------------------------------------

  Widget managementTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE9E1F2),
        ),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(19),
        child: InkWell(
          borderRadius: BorderRadius.circular(19),
          onTap: () {
            Widget page;

            switch (title) {
              case 'Manage Cars':
                page = const AdminManageCarsPage();
                break;

              case 'Manage Rentals':
                page = const AdminManageRentalsPage();
                break;

              case 'Reports':
                page = const AdminReportsPage();
                break;

              case 'Manage Employees':
                page = const AdminManageEmployeesPage();
                break;

              default:
                return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => page,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 51,
                  height: 51,
                  decoration: BoxDecoration(
                    color: darkPurple,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: orange,
                    size: 26,
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
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF8C829B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: orange,
                  size: 27,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------
  // OVERVIEW GRID WITH LIVE DATA
  // ----------------------------------------

  Widget buildOverviewGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        final columns = availableWidth >= 700 ? 4 : 2;

        final cardWidth =
            (availableWidth - (columns - 1) * 12) / columns;

        final cardHeight = columns == 4 ? 160.0 : 165.0;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: cardWidth / cardHeight,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            overviewCard(
              title: 'Total Cars',
              icon: Icons.directions_car_rounded,
              stream: _carsStream,
            ),
            overviewCard(
              title: 'Total Bookings',
              icon: Icons.calendar_month_rounded,
              stream: _bookingsStream,
            ),
            overviewCard(
              title: 'Active Rentals',
              icon: Icons.vpn_key_rounded,
              stream: _bookingsStream,
              activeOnly: true,
            ),
            overviewCard(
              title: 'Employees',
              icon: Icons.people_alt_rounded,
              stream: _employeesStream,
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------
  // MAIN SCREEN
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildHeader(),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      25,
                      18,
                      25,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionHeading(
                          title: 'Overview',
                          icon: Icons.bar_chart_rounded,
                        ),
                        const SizedBox(height: 17),
                        buildOverviewGrid(),
                        const SizedBox(height: 29),
                        sectionHeading(
                          title: 'Management',
                          icon: Icons.layers_outlined,
                        ),
                        const SizedBox(height: 17),
                        managementTile(
                          title: 'Manage Cars',
                          subtitle: 'Vehicle information',
                          icon: Icons.directions_car_rounded,
                        ),
                        managementTile(
                          title: 'Manage Rentals',
                          subtitle: 'Customer bookings',
                          icon: Icons.event_available_rounded,
                        ),
                        managementTile(
                          title: 'Reports',
                          subtitle: 'Rental summaries',
                          icon: Icons.insert_chart_outlined_rounded,
                        ),

                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            'CAR RENTAL MANAGEMENT SYSTEM',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFAAA1B5),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
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
      ),
    );
  }
}
