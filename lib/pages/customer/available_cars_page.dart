import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/car_model.dart';
import '../../widgets/car_picture.dart';
import '../../widgets/app_bottom_bar.dart';
import 'car_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailableCarsScreen extends StatefulWidget {
  final String initialBranch;
  final String initialCategory;

  const AvailableCarsScreen({
    super.key,
    this.initialBranch = 'All Branches',
    this.initialCategory = '',
  });

  @override
  State<AvailableCarsScreen> createState() =>
      _AvailableCarsScreenState();
}

class _AvailableCarsScreenState
    extends State<AvailableCarsScreen> {
  static const List<String> branches = [
    'All Branches',
    'Muar',
    'Johor Bahru',
    'Batu Pahat',
    'Kluang',
    'Melaka',
    'Seremban',
  ];

  static const List<String> types = [
    'All Types',
    'Sedan',
    'SUV',
    'MPV',
  ];

  static const List<String> origins = [
    'All Brands',
    'Local',
    'International',
  ];

  late String selectedBranch;
  String selectedType = 'All Types';
  String selectedOrigin = 'All Brands';
  int? selectedSeats;

  double maximumPrice = 300;
  bool availableOnly = false;

  late DateTime selectedDate;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _carsStream =
  FirebaseFirestore.instance.collection('cars').snapshots();

  @override
  void initState() {
    super.initState();

    selectedDate = DateTime.now();

    selectedBranch = branches.contains(widget.initialBranch)
        ? widget.initialBranch
        : 'All Branches';

    switch (widget.initialCategory.toLowerCase()) {
      case 'local':
        selectedOrigin = 'Local';
        break;

      case 'international':
        selectedOrigin = 'International';
        break;

      case 'sedan':
        selectedType = 'Sedan';
        break;

      case 'suv':
        selectedType = 'SUV';
        break;

      case 'mpv':
        selectedType = 'MPV';
        break;

      case 'budget':
        maximumPrice = 120;
        break;
    }
  }

  // --------------------------------------
  // ACTUAL FILTERING LOGIC
  // --------------------------------------

  List<Car> filterCars(List<Car> allCars) {
    return allCars.where((car) {
      final matchesBranch =
          selectedBranch == 'All Branches' ||
              car.branch == selectedBranch;

      final matchesType =
          selectedType == 'All Types' ||
              car.type.toLowerCase() ==
                  selectedType.toLowerCase();

      final matchesOrigin =
          selectedOrigin == 'All Brands' ||
              car.origin == selectedOrigin;

      final matchesPrice =
          car.price <= maximumPrice;

      final matchesAvailability =
          !availableOnly || car.available;
      final matchesSeats =
          selectedSeats == null || car.seats == selectedSeats;

      return matchesBranch &&
          matchesType &&
          matchesOrigin &&
          matchesPrice &&
          matchesAvailability &&
          matchesSeats;
    }).toList();
  }

  // --------------------------------------
  // DATE PICKER
  // --------------------------------------

  Future<void> chooseDate() async {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate.isBefore(today)
          ? today
          : selectedDate,
      firstDate: today,
      lastDate: DateTime(now.year + 3),
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // --------------------------------------
  // RESET FILTERS
  // --------------------------------------

  void resetFilters() {
    setState(() {
      selectedBranch = 'All Branches';
      selectedType = 'All Types';
      selectedOrigin = 'All Brands';
      selectedSeats = null;
      maximumPrice = 300;
      availableOnly = false;
    });
  }

  // --------------------------------------
  // FILTER INPUT DECORATION
  // --------------------------------------

  InputDecoration filterDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: lightGrey.withOpacity(0.40),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE9E1F2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE9E1F2)),
      ),
    );
  }

  // --------------------------------------
  // ADVANCED FILTER BOTTOM SHEET
  // --------------------------------------

  void openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, updateSheet) {
            void refreshFilters(VoidCallback change) {
              setState(change);
              updateSheet(() {});
            }

            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                  MediaQuery.of(sheetContext).size.height *
                      0.88,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    20,
                    24,
                    30,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: lightGrey,
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Filter Vehicles',
                              style: TextStyle(
                                color: darkPurple,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              resetFilters();
                              updateSheet(() {});
                            },
                            child: const Text(
                              'Reset',
                              style: TextStyle(
                                color: orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'PICKUP BRANCH',
                        style: TextStyle(
                          color: darkPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      DropdownButtonFormField<String>(
                        value: selectedBranch,
                        isExpanded: true,
                        decoration: filterDecoration(),
                        items: branches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch,
                            child: Text(branch),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refreshFilters(() {
                              selectedBranch = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 23),

                      const Text(
                        'VEHICLE TYPE',
                        style: TextStyle(
                          color: darkPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      DropdownButtonFormField<String>(
                        value: selectedType,
                        isExpanded: true,
                        decoration: filterDecoration(),
                        items: types.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refreshFilters(() {
                              selectedType = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 23),

                      const Text(
                        'BRAND ORIGIN',
                        style: TextStyle(
                          color: darkPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      DropdownButtonFormField<String>(
                        value: selectedOrigin,
                        isExpanded: true,
                        decoration: filterDecoration(),
                        items: origins.map((origin) {
                          return DropdownMenuItem<String>(
                            value: origin,
                            child: Text(origin),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            refreshFilters(() {
                              selectedOrigin = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 23),

                      const Text(
                        'SEATING CAPACITY',
                        style: TextStyle(
                          color: darkPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 9),

                      DropdownButtonFormField<int?>(
                        value: selectedSeats,
                        isExpanded: true,
                        decoration: filterDecoration(),
                        items: const [
                          DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All Seats'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 5,
                            child: Text('5 Seats'),
                          ),
                          DropdownMenuItem<int?>(
                            value: 6,
                            child: Text('6 Seats'),
                          ),
                        ],
                        onChanged: (value) {
                          refreshFilters(() {
                            selectedSeats = value;
                          });
                        },
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'MAXIMUM PRICE PER DAY',
                              style: TextStyle(
                                color: darkPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'RM${maximumPrice.round()}',
                            style: const TextStyle(
                              color: orange,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      Slider(
                        value: maximumPrice,
                        min: 50,
                        max: 300,
                        divisions: 25,
                        activeColor: orange,
                        onChanged: (value) {
                          refreshFilters(() {
                            maximumPrice = value;
                          });
                        },
                      ),

                      const SizedBox(height: 8),

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Available Cars Only',
                          style: TextStyle(
                            color: darkPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'Hide currently unavailable cars',
                        ),
                        activeColor: orange,
                        value: availableOnly,
                        onChanged: (value) {
                          refreshFilters(() {
                            availableOnly = value;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'APPLY FILTERS',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --------------------------------------
  // QUICK FILTER CHIP
  // --------------------------------------

  Widget quickFilter({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected ? orange : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: selected
                ? orange
                : const Color(0xFFE9E1F2),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : darkPurple,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --------------------------------------
  // CAR CARD
  // --------------------------------------

  Widget carCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 17),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE9E1F2)),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 160,
            decoration: BoxDecoration(
              color: lightGrey.withOpacity(0.35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CarPicture(
                car: car,
                height: 160,
              ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  car.name,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: car.available
                      ? const Color(0xFFE4F7EC)
                      : const Color(0xFFFFE8E8),
                  borderRadius: BorderRadius.circular(20),
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

          const SizedBox(height: 9),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${car.type}  •  ${car.origin} Brand',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.airline_seat_recline_normal_rounded,
                color: orange,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${car.seats} Seats',
                style: const TextStyle(
                  color: darkPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: orange,
                size: 18,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${car.branch} Branch',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Row(
            children: [
              const Icon(
                Icons.local_gas_station_outlined,
                color: orange,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                '${car.fuel}  •  ${car.year}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            'Plate No: ${car.plate}',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RM${car.price}',
                      style: const TextStyle(
                        color: orange,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
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

              ElevatedButton(
                onPressed: car.available
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CarDetailsScreen(
                            car: car,
                          ),
                    ),
                  );
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'VIEW DETAILS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------
  // EMPTY RESULTS
  // --------------------------------------

  Widget emptyResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 55,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: darkPurple,
            size: 65,
          ),
          const SizedBox(height: 15),
          const Text(
            'No Cars Found',
            style: TextStyle(
              color: darkPurple,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Try changing your filters to see more vehicles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: resetFilters,
            style: OutlinedButton.styleFrom(
              foregroundColor: orange,
              side: const BorderSide(color: orange),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  // --------------------------------------
  // MAIN PAGE
  // --------------------------------------

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _carsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Explore Cars')),
            body: Center(
              child: Text(
                'Unable to load vehicles: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: darkPurple)),
          );
        }

        final allCars = snapshot.data!.docs
            .map((doc) => Car.fromFirestore(doc.data()))
            .toList();
        final cars = filterCars(allCars);

        return Scaffold(
          backgroundColor: const Color(0xFFF6F3FA),

          bottomNavigationBar: const AppBottomBar(
            selectedIndex: 1,
          ),

          body: SafeArea(
            child: Column(
              children: [
                // TOP PURPLE HEADER
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    20,
                    20,
                    24,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [darkPurple, Color(0xFF35135B), Color(0xFF49216F)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(maxWidth: 900),
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
                          const SizedBox(width: 7),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Explore Cars',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Find your perfect ride',
                                  style: TextStyle(
                                    color: Color(0xFFCCC2DB),
                                    fontSize: 13,
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

                // SCROLLABLE CONTENT
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                      const BoxConstraints(maxWidth: 900),
                      child: ListView(
                        padding: const EdgeInsets.all(18),
                        children: [
                          // PICKUP DATE
                          InkWell(
                            onTap: chooseDate,
                            borderRadius:
                            BorderRadius.circular(17),
                            child: Container(
                              padding: const EdgeInsets.all(17),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(17),
                                border: Border.all(color: const Color(0xFFE9E1F2)),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkPurple.withOpacity(0.04),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    color: orange,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PICKUP DATE',
                                          style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 10,
                                            fontWeight:
                                            FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '${selectedDate.day}/'
                                              '${selectedDate.month}/'
                                              '${selectedDate.year}',
                                          style: const TextStyle(
                                            color: darkPurple,
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: darkPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // QUICK FILTERS
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                quickFilter(
                                  title: 'All Cars',
                                  selected:
                                  selectedBranch ==
                                      'All Branches' &&
                                      selectedType ==
                                          'All Types' &&
                                      selectedOrigin ==
                                          'All Brands' &&
                                      maximumPrice == 300 &&
                                      !availableOnly,
                                  onTap: resetFilters,
                                ),

                                const SizedBox(width: 9),

                                quickFilter(
                                  title: 'Budget',
                                  selected: maximumPrice == 120,
                                  onTap: () {
                                    setState(() {
                                      maximumPrice =
                                      maximumPrice == 120
                                          ? 300
                                          : 120;
                                    });
                                  },
                                ),

                                const SizedBox(width: 9),

                                quickFilter(
                                  title: 'Local',
                                  selected:
                                  selectedOrigin == 'Local',
                                  onTap: () {
                                    setState(() {
                                      selectedOrigin =
                                      selectedOrigin == 'Local'
                                          ? 'All Brands'
                                          : 'Local';
                                    });
                                  },
                                ),

                                const SizedBox(width: 9),

                                quickFilter(
                                  title: 'International',
                                  selected: selectedOrigin ==
                                      'International',
                                  onTap: () {
                                    setState(() {
                                      selectedOrigin =
                                      selectedOrigin ==
                                          'International'
                                          ? 'All Brands'
                                          : 'International';
                                    });
                                  },
                                ),

                                const SizedBox(width: 9),

                                quickFilter(
                                  title: 'Sedan',
                                  selected:
                                  selectedType == 'Sedan',
                                  onTap: () {
                                    setState(() {
                                      selectedType =
                                      selectedType == 'Sedan'
                                          ? 'All Types'
                                          : 'Sedan';
                                    });
                                  },
                                ),

                                const SizedBox(width: 9),

                                quickFilter(
                                  title: 'Available',
                                  selected: availableOnly,
                                  onTap: () {
                                    setState(() {
                                      availableOnly =
                                      !availableOnly;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 23),

                          // RESULTS + FILTER BUTTON
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${cars.length} Vehicles Found',
                                  style: const TextStyle(
                                    color: darkPurple,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: openFilters,
                                icon: const Icon(
                                  Icons.tune_rounded,
                                  color: orange,
                                ),
                                label: const Text(
                                  'Filters',
                                  style: TextStyle(
                                    color: orange,
                                    fontWeight:
                                    FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // CURRENT BRANCH
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 2,
                              bottom: 17,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  selectedBranch,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CAR RESULTS
                          if (cars.isEmpty)
                            emptyResults()
                          else
                            for (final car in cars)
                              carCard(car),

                          const SizedBox(height: 20),
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
