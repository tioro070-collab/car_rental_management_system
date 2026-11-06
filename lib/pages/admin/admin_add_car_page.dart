
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class AdminAddCarPage extends StatefulWidget {
  const AdminAddCarPage({super.key});

  @override
  State<AdminAddCarPage> createState() => _AdminAddCarPageState();
}

class _AdminAddCarPageState extends State<AdminAddCarPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelController = TextEditingController();
  final _colourController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController(text: '5');
  final _imageController = TextEditingController();

  String _type = 'Sedan';
  String _branch = 'Muar';
  String _origin = 'Local';

  bool _available = true;
  bool _isSaving = false;

  final List<String> _branches = const [
    'Muar',
    'Johor Bahru',
    'Batu Pahat',
    'Kluang',
    'Melaka',
    'Seremban',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _fuelController.dispose();
    _colourController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(
      String label,
      String hint,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: darkPurple,
        size: 21,
      ),
      filled: true,
      fillColor: const Color(0xFFFAF9FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5DFEC),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE5DFEC),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: darkPurple,
          width: 2,
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController controller,
      String label,
      String hint,
      IconData icon, {
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: _decoration(label, hint, icon),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: _decoration(label, '', icon),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFEDE7F3),
        ),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2ECF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: darkPurple,
                  size: 23,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkPurple,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...children,
        ],
      ),
    );
  }

  Widget _responsivePair(
      Widget first,
      Widget second,
      ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            children: [
              first,
              const SizedBox(height: 15),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 15),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;

    final price = int.tryParse(
      _priceController.text.trim(),
    );
    final seats = int.tryParse(
      _seatsController.text.trim(),
    );
    final year = int.tryParse(
      _yearController.text.trim(),
    );

    if (price == null ||
        price <= 0 ||
        seats == null ||
        seats <= 0 ||
        year == null ||
        year < 1900 ||
        year > 2100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid year, positive price and seating capacity.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final plate = _plateController.text
        .trim()
        .toUpperCase()
        .replaceAll(RegExp(r'\s+'), ' ');

    final documentId = plate.replaceAll(' ', '');

    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(documentId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Plate must contain letters and numbers only.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final firestore = FirebaseFirestore.instance;
      final documentRef = firestore
          .collection('cars')
          .doc(documentId);

      await firestore.runTransaction((transaction) async {
        final existing = await transaction.get(documentRef);

        if (existing.exists) {
          throw Exception(
            'A vehicle with this plate already exists.',
          );
        }

        transaction.set(documentRef, {
          'name': _nameController.text.trim(),
          'plate': plate,
          'type': _type,
          'fuel': _fuelController.text.trim(),
          'colour': _colourController.text.trim(),
          'year': _yearController.text.trim(),
          'image': _imageController.text.trim(),
          'price': price,
          'available': _available,
          'branch': _branch,
          'origin': _origin,
          'seats': seats,
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to add vehicle: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
          'Add Vehicle',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 850,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(25),
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: darkPurple,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.directions_car_filled_rounded,
                          color: orange,
                          size: 35,
                        ),
                      ),
                      const SizedBox(width: 17),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Register New Vehicle',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Add a new vehicle to your rental fleet',
                              style: TextStyle(
                                color: Color(0xFFE2D8ED),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // VEHICLE INFORMATION
                _section(
                  title: 'Vehicle Information',
                  subtitle: 'Basic identification details',
                  icon: Icons.directions_car_outlined,
                  children: [
                    _field(
                      _nameController,
                      'Car Name',
                      'e.g. Proton S70',
                      Icons.drive_eta_outlined,
                    ),
                    const SizedBox(height: 15),
                    _responsivePair(
                      _field(
                        _plateController,
                        'Registration Plate',
                        'e.g. JMU 1001',
                        Icons.pin_outlined,
                      ),
                      _dropdown(
                        label: 'Vehicle Type',
                        value: _type,
                        items: const [
                          'Sedan',
                          'SUV',
                          'MPV',
                          'Hatchback',
                        ],
                        icon: Icons.category_outlined,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _type = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                // SPECIFICATIONS
                _section(
                  title: 'Vehicle Specifications',
                  subtitle: 'Technical and physical details',
                  icon: Icons.tune_rounded,
                  children: [
                    _responsivePair(
                      _field(
                        _fuelController,
                        'Fuel Type',
                        'e.g. Petrol',
                        Icons.local_gas_station_outlined,
                      ),
                      _field(
                        _colourController,
                        'Colour',
                        'e.g. Blue',
                        Icons.palette_outlined,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _responsivePair(
                      _field(
                        _yearController,
                        'Manufacturing Year',
                        'e.g. 2025',
                        Icons.calendar_month_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      _field(
                        _seatsController,
                        'Seating Capacity',
                        'e.g. 5',
                        Icons.event_seat_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                // RENTAL DETAILS
                _section(
                  title: 'Rental Details',
                  subtitle: 'Branch, pricing and availability',
                  icon: Icons.payments_outlined,
                  children: [
                    _responsivePair(
                      _dropdown(
                        label: 'Pickup Branch',
                        value: _branch,
                        items: _branches,
                        icon: Icons.location_on_outlined,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _branch = value);
                          }
                        },
                      ),
                      _dropdown(
                        label: 'Vehicle Origin',
                        value: _origin,
                        items: const [
                          'Local',
                          'International',
                        ],
                        icon: Icons.public_outlined,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _origin = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    _field(
                      _priceController,
                      'Daily Rental Price (RM)',
                      'e.g. 150',
                      Icons.sell_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F5FB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: darkPurple,
                        title: const Text(
                          'Available for Rental',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: const Text(
                          'Allow customers to book this vehicle',
                        ),
                        value: _available,
                        onChanged: (value) {
                          setState(() => _available = value);
                        },
                      ),
                    ),
                  ],
                ),

                // IMAGE DETAILS
                _section(
                  title: 'Vehicle Image',
                  subtitle: 'Image used in the vehicle listing',
                  icon: Icons.image_outlined,
                  children: [
                    _field(
                      _imageController,
                      'Image Asset Path',
                      'e.g. assets/cars/bezza.jpg',
                      Icons.folder_outlined,
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 17,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Use an image already included in '
                                'your Flutter assets. This field '
                                'does not upload an image.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveCar,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.save_outlined,
                    ),
                    label: Text(
                      _isSaving
                          ? 'Saving Vehicle...'
                          : 'Save Vehicle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      darkPurple.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
