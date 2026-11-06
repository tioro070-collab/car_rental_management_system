import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'admin_car_import_page.dart';
import 'admin_car_list_page.dart';
import 'admin_add_car_page.dart';
import 'admin_edit_car_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_rental_list_page.dart';

// Admin navigation/UI only. Database actions will be implemented separately.
class _AdminFeature {
  final String title;
  final String description;
  final IconData icon;
  const _AdminFeature(this.title, this.description, this.icon);
}

class _AdminPageLayout extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_AdminFeature> features;
  const _AdminPageLayout({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FA),
      appBar: AppBar(
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: darkPurple,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(children: [
                  Icon(icon, color: orange, size: 38),
                  const SizedBox(width: 16),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      Text(subtitle, style: const TextStyle(color: Color(0xFFE0D6EC))),
                    ],
                  )),
                ]),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBDD),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(children: [
                  Icon(Icons.info_outline, color: darkPurple),
                  SizedBox(width: 10),
                  Expanded(child: Text('Page layout ready. Firebase functionality will be connected next.', style: TextStyle(color: darkPurple))),
                ]),
              ),
              const SizedBox(height: 15),
              ...features.map((feature) => Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFEBDD),
                    child: Icon(feature.icon, color: darkPurple),
                  ),
                  title: Text(feature.title, style: const TextStyle(color: darkPurple, fontWeight: FontWeight.bold)),
                  subtitle: Text(feature.description),
                  trailing: const Icon(Icons.lock_clock_outlined, color: Colors.grey),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}



class AdminManageCarsPage extends StatelessWidget {
  const AdminManageCarsPage({super.key});

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: orange, size: 23),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFE4DAED),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEDE7F3),
        ),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        enabled: onTap != null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 12,
        ),
        leading: Container(
          width: 49,
          height: 49,
          decoration: BoxDecoration(
            color: const Color(0xFFF2ECF8),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: darkPurple,
            size: 25,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: darkPurple,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            subtitle,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        trailing: Icon(
          onTap == null
              ? Icons.lock_clock_outlined
              : Icons.chevron_right_rounded,
          color: onTap == null
              ? Colors.grey
              : darkPurple,
        ),
        onTap: onTap,
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
        elevation: 0,
        title: const Text(
          'Manage Cars',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('cars')
            .snapshots(),
        builder: (context, snapshot) {
          final cars = snapshot.data?.docs ?? [];

          final branches = cars
              .map((doc) => doc.data()['branch']?.toString() ?? '')
              .where((branch) => branch.isNotEmpty)
              .toSet();

          final availableCount = cars.where((doc) {
            return doc.data()['available'] == true;
          }).length;

          final totalText = snapshot.hasData
              ? '${cars.length}'
              : '--';

          final branchText = snapshot.hasData
              ? '${branches.length}'
              : '--';

          final availableText = snapshot.hasData
              ? '$availableCount'
              : '--';

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // PURPLE DASHBOARD HEADER
                  Container(
                    padding: const EdgeInsets.all(23),
                    decoration: BoxDecoration(
                      color: darkPurple,
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius:
                                BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.directions_car_filled_rounded,
                                color: orange,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vehicle Management',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Manage your rental fleet across all branches',
                                    style: TextStyle(
                                      color: Color(0xFFE3D9ED),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            _statCard(
                              label: 'Total Cars',
                              value: totalText,
                              icon: Icons.directions_car_outlined,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: 'Branches',
                              value: branchText,
                              icon: Icons.location_on_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _statCard(
                              label: 'Available',
                              value: availableText,
                              icon: Icons.check_circle_outline,
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: 'Unavailable',
                              value: snapshot.hasData
                                  ? '${cars.length - availableCount}'
                                  : '--',
                              icon: Icons.block_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (snapshot.hasError) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Unable to load vehicle statistics.',
                      style: TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 27),

                  const Text(
                    'Vehicle Management',
                    style: TextStyle(
                      color: darkPurple,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Choose an action to manage your vehicles',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // VEHICLE LIST
                  _menuCard(
                    title: 'Vehicle List',
                    subtitle: 'View all registered vehicles',
                    icon: Icons.list_alt_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const AdminCarListPage(),
                        ),
                      );
                    },
                  ),

                  // ADD VEHICLE
                  _menuCard(
                    title: 'Add Vehicle',
                    subtitle: 'Register a new rental vehicle',
                    icon: Icons.add_circle_outline_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const AdminAddCarPage(),
                        ),
                      );
                    },
                  ),


// EDIT VEHICLE
                  _menuCard(
                    title: 'Edit Vehicle',
                    subtitle: 'Update details, price and availability',
                    icon: Icons.edit_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminEditCarPage(),
                        ),
                      );
                    },
                  ),


                  // IMPORT CARS
                  _menuCard(
                    title: 'Import Cars',
                    subtitle: 'Import existing vehicle records',
                    icon: Icons.cloud_upload_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                          const AdminCarImportPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AdminManageRentalsPage extends StatelessWidget {
  const AdminManageRentalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminRentalListPage();
  }
}

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  Widget _reportCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDE7F3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: orange, size: 28),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: darkPurple)),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
        ],
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
        title: const Text('Reports',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load rental reports.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!.docs;
          final completed = bookings.where((doc) =>
          doc.data()['status']?.toString().toLowerCase() == 'completed').length;

          // Revenue is based on confirmed paid bookings, not unpaid reservations.
          double paidRevenue = 0;
          final rentedPlates = <String>{};
          for (final doc in bookings) {
            final data = doc.data();
            final status = data['status']?.toString().toLowerCase() ?? '';
            final payment = data['paymentStatus']?.toString().toLowerCase() ?? '';
            if (payment == 'paid' && status != 'cancelled') {
              final amount = data['totalPrice'];
              if (amount is num) {
                paidRevenue += amount.toDouble();
              } else {
                paidRevenue += double.tryParse(amount?.toString() ?? '') ?? 0;
              }
            }
            if (status == 'ongoing' || status == 'completed') {
              final car = data['car'];
              if (car is Map) {
                final plate = car['plate']?.toString().trim() ?? '';
                if (plate.isNotEmpty) rentedPlates.add(plate);
              }
            }
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(23),
                    decoration: BoxDecoration(
                      color: darkPurple,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: orange, size: 36),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Rental Reports',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 21,
                                      fontWeight: FontWeight.w900)),
                              SizedBox(height: 5),
                              Text('Overview of rental performance',
                                  style: TextStyle(color: Color(0xFFE0D6EC))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  LayoutBuilder(builder: (context, constraints) {
                    final columns = constraints.maxWidth < 420 ? 1 : 2;
                    final cardWidth =
                        (constraints.maxWidth - (columns - 1) * 12) / columns;
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _reportCard('Total Bookings', '${bookings.length}',
                              Icons.calendar_month_outlined),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _reportCard('Completed Rentals', '$completed',
                              Icons.check_circle_outline),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _reportCard('Paid Revenue',
                              'RM ${paidRevenue.toStringAsFixed(2)}',
                              Icons.payments_outlined),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _reportCard('Cars Rented', '${rentedPlates.length}',
                              Icons.directions_car_outlined),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 14),
                  const Text(
                    'Paid Revenue excludes cancelled and unpaid bookings. '
                        'Cars Rented counts distinct vehicle plates in ongoing or completed rentals.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
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

class AdminManageEmployeesPage extends StatelessWidget {
  const AdminManageEmployeesPage({super.key});
  @override
  Widget build(BuildContext context) => const _AdminPageLayout(
    title: 'Manage Employees', subtitle: 'Staff accounts and branch assignments',
    icon: Icons.groups_rounded,
    features: [
      _AdminFeature('Employee List', 'View staff and assigned branches', Icons.people_outline),
      _AdminFeature('Add Employee', 'Create a staff account securely', Icons.person_add_alt_1_outlined),
      _AdminFeature('Edit Employee', 'Manage staff roles and active status', Icons.manage_accounts_outlined),
    ],
  );
}
