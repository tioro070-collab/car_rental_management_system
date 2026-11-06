
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/car_model.dart';
import '../../widgets/car_picture.dart';
import '../../widgets/app_bottom_bar.dart';
import 'booking_page.dart';

class CarDetailsScreen extends StatelessWidget {
  final Car car;

  const CarDetailsScreen({
    super.key,
    required this.car,
  });

  // ---------------------------------------
  // VEHICLE SPECIFICATION CARD
  // ---------------------------------------

  Widget specificationCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: darkPurple.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: orange.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: orange,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------
  // SECTION TITLE
  // ---------------------------------------

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkPurple,
        fontSize: 21,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  // ---------------------------------------
  // BOOKING NAVIGATION
  // ---------------------------------------

  void openBooking(BuildContext context) {
    if (!car.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This vehicle is currently unavailable.',
          ),
          backgroundColor: darkPurple,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          car: car,
        ),
      ),
    );
  }

  // ---------------------------------------
  // MAIN SCREEN
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
                16,
                18,
                20,
                22,
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
                              'Car Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              'Everything about your next ride',
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

            // SCROLLABLE DETAILS
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
                        // CAR IMAGE
                        Container(
                          width: double.infinity,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: darkPurple.withOpacity(
                                  0.07,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(24),
                            child: CarPicture(
                              car: car,
                              height: 230,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        // CAR NAME + STATUS
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    car.name,
                                    style: const TextStyle(
                                      color: darkPurple,
                                      fontSize: 27,
                                      fontWeight:
                                      FontWeight.w900,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    '${car.type}  •  ${car.origin} Brand',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: car.available
                                    ? const Color(0xFFE4F7EC)
                                    : const Color(0xFFFFE8E8),
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                              child: Text(
                                car.available
                                    ? 'Available'
                                    : 'Unavailable',
                                style: TextStyle(
                                  color: car.available
                                      ? const Color(0xFF168447)
                                      : const Color(0xFFC0392B),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // PICKUP LOCATION
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(19),
                          decoration: BoxDecoration(
                            color: darkPurple,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: orange,
                                  borderRadius:
                                  BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 27,
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PICKUP LOCATION',
                                      style: TextStyle(
                                        color:
                                        Color(0xFFCBC2DB),
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      '${car.branch} Branch',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight:
                                        FontWeight.w900,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    const Text(
                                      'Pickup at your selected rental branch',
                                      style: TextStyle(
                                        color:
                                        Color(0xFFCBC2DB),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        sectionTitle('Vehicle Specifications'),

                        const SizedBox(height: 15),

                        // SPECIFICATIONS GRID
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics:
                          const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.45,
                          children: [
                            specificationCard(
                              icon:
                              Icons.directions_car_outlined,
                              label: 'Vehicle Type',
                              value: car.type,
                            ),

                            specificationCard(
                              icon:
                              Icons.local_gas_station_outlined,
                              label: 'Fuel Type',
                              value: car.fuel,
                            ),

                            specificationCard(
                              icon: Icons.palette_outlined,
                              label: 'Colour',
                              value: car.colour,
                            ),

                            specificationCard(
                              icon: Icons.calendar_today_outlined,
                              label: 'Model Year',
                              value: car.year,
                            ),

                            specificationCard(
                              icon: Icons.pin_outlined,
                              label: 'Plate Number',
                              value: car.plate,
                            ),

                            specificationCard(
                              icon: Icons.public_outlined,
                              label: 'Brand Origin',
                              value: car.origin,
                            ),

                            specificationCard(
                              icon: Icons.airline_seat_recline_normal_rounded,
                              label: 'Seating Capacity',
                              value: '${car.seats} Seats',
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        sectionTitle('Rental Pricing'),

                        const SizedBox(height: 14),

                        // PRICE CARD
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(21),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(21),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: orange.withOpacity(
                                    0.10,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  color: orange,
                                  size: 29,
                                ),
                              ),

                              const SizedBox(width: 15),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Daily Rental Rate',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      'RM ${car.price}',
                                      style: const TextStyle(
                                        color: darkPurple,
                                        fontSize: 28,
                                        fontWeight:
                                        FontWeight.w900,
                                      ),
                                    ),

                                    const Text(
                                      'per day',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // BOOK NOW BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 57,
                          child: ElevatedButton.icon(
                            onPressed: car.available
                                ? () => openBooking(context)
                                : null,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                            ),
                            label: Text(
                              car.available
                                  ? 'BOOK NOW'
                                  : 'CURRENTLY UNAVAILABLE',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: orange,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                              Colors.grey,
                              disabledForegroundColor:
                              Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 13),

                        const Center(
                          child: Text(
                            'Final rental total will be calculated during booking.',
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
