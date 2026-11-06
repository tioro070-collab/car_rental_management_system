
import 'package:flutter/material.dart';

import '../../models/car_model.dart';
import '../../models/booking_store.dart';
import '../../models/vehicle_store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/car_picture.dart';
import 'staff_vehicle_details_page.dart';

class StaffVehicleManagementPage extends StatefulWidget {
  final String branch;

  const StaffVehicleManagementPage({
    super.key,
    this.branch = 'Muar',
  });

  @override
  State<StaffVehicleManagementPage> createState() =>
      _StaffVehicleManagementPageState();
}

class _StaffVehicleManagementPageState
    extends State<StaffVehicleManagementPage> {
  final searchController = TextEditingController();
  String selectedFilter = 'All';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color colorFor(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return const Color(0xFF079B70);
      case VehicleStatus.reserved:
        return orange;
      case VehicleStatus.onRent:
        return const Color(0xFF7143DD);
      case VehicleStatus.maintenance:
        return const Color(0xFFE54266);
      case VehicleStatus.unavailable:
        return Colors.blueGrey;
    }
  }

  Widget filterChip(String label, int count) {
    final selected = selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => selectedFilter = label),
        label: Text('$label ($count)'),
        selectedColor: orange,
        backgroundColor: const Color(0xFFF1EDFB),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: selected ? Colors.white : darkPurple,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget vehicleCard(Car car) {
    final status = VehicleStore.statusFor(car);
    final color = colorFor(status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        borderRadius: BorderRadius.circular(19),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StaffVehicleDetailsPage(car: car),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 112,
                height: 102,
                child: CarPicture(car: car, height: 102),
              ),
              const SizedBox(width: 11),
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
                    const SizedBox(height: 4),
                    Text(
                      '${car.type} • ${car.plate}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${car.fuel} • ${car.year} • RM ${car.price}/day',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.11),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        VehicleStore.statusLabel(status),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: darkPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        BookingStore.bookings,
        VehicleStore.maintenance,
        VehicleStore.manuallyUnavailable,
      ]),
      builder: (context, _) {
        final cars = carList.where(
              (car) =>
          car.branch.toLowerCase() ==
              widget.branch.toLowerCase(),
        ).toList();

        final search = searchController.text.trim().toLowerCase();

        final filtered = cars.where((car) {
          final status = VehicleStore.statusLabel(
            VehicleStore.statusFor(car),
          );

          final matchesSearch = search.isEmpty ||
              car.name.toLowerCase().contains(search) ||
              car.plate.toLowerCase().contains(search) ||
              car.type.toLowerCase().contains(search);

          return matchesSearch &&
              (selectedFilter == 'All' ||
                  selectedFilter == status);
        }).toList();

        int count(String filter) {
          if (filter == 'All') return cars.length;
          return cars.where((car) {
            return VehicleStore.statusLabel(
              VehicleStore.statusFor(car),
            ) ==
                filter;
          }).length;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F3FA),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 15, 18, 22),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [darkPurple, Color(0xFF482477)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Vehicle Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.directions_car_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      Text(
                        'Manage vehicles at ${widget.branch} Branch',
                        style: const TextStyle(
                          color: Color(0xFFE5D9F4),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 17),
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search name, plate, or type...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: ListView(
                        padding: const EdgeInsets.all(15),
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (final label in [
                                  'All',
                                  'Available',
                                  'Reserved',
                                  'On Rent',
                                  'Maintenance',
                                  'Unavailable',
                                ])
                                  filterChip(label, count(label)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (filtered.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(45),
                              child: Center(
                                child: Text(
                                  'No matching vehicles found.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            )
                          else
                            for (final car in filtered) ...[
                              vehicleCard(car),
                              const SizedBox(height: 12),
                            ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
