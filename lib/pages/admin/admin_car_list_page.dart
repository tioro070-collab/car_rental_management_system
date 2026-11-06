
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';

class AdminCarListPage extends StatelessWidget {
  const AdminCarListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FA),
      appBar: AppBar(
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Vehicle List',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('cars')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Unable to load cars:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: darkPurple),
            );
          }

          final cars = snapshot.data!.docs.toList();

          cars.sort((a, b) {
            final branchA = (a.data()['branch'] ?? '').toString();
            final branchB = (b.data()['branch'] ?? '').toString();

            final branchComparison = branchA.compareTo(branchB);
            if (branchComparison != 0) return branchComparison;

            return (a.data()['name'] ?? '')
                .toString()
                .compareTo((b.data()['name'] ?? '').toString());
          });

          if (cars.isEmpty) {
            return const Center(
              child: Text('No vehicles found in Firebase.'),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: darkPurple,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.directions_car_rounded,
                          color: orange,
                          size: 35,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vehicle Inventory',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${cars.length} vehicles registered',
                                style: const TextStyle(
                                  color: Color(0xFFE0D6EC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  ...cars.map((document) {
                    final car = document.data();

                    final name =
                    (car['name'] ?? 'Unknown Car').toString();
                    final plate =
                    (car['plate'] ?? document.id).toString();
                    final branch =
                    (car['branch'] ?? 'Unassigned').toString();
                    final type =
                    (car['type'] ?? 'Unknown').toString();
                    final price = car['price'];
                    final available = car['available'] == true;

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBDD),
                                borderRadius:
                                BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: darkPurple,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: darkPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('$plate • $branch'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$type • RM${price ?? 0}/day',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    available
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      color: available
                                          ? Colors.green.shade700
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
