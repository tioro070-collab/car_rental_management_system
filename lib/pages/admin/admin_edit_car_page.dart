
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../../theme/app_colors.dart';

class AdminEditCarPage extends StatefulWidget {
  const AdminEditCarPage({super.key});

  @override
  State<AdminEditCarPage> createState() => _AdminEditCarPageState();
}

class _AdminEditCarPageState extends State<AdminEditCarPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _fuelController = TextEditingController();
  final _colourController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();
  final _imageController = TextEditingController();

  String? _selectedCarId;

  String _type = 'Sedan';
  String _branch = 'Muar';
  String _origin = 'Local';

  bool _available = true;
  bool _isSaving = false;

  final _branches = const [
    'Muar',
    'Johor Bahru',
    'Batu Pahat',
    'Kluang',
    'Melaka',
    'Seremban',
  ];

  final _types = const [
    'Sedan',
    'SUV',
    'MPV',
    'Hatchback',
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

  void _loadCar(
      QueryDocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    setState(() {
      _selectedCarId = document.id;

      _nameController.text = data['name']?.toString() ?? '';
      _plateController.text = data['plate']?.toString() ?? '';
      _fuelController.text = data['fuel']?.toString() ?? '';
      _colourController.text = data['colour']?.toString() ?? '';
      _yearController.text = data['year']?.toString() ?? '';
      _priceController.text = data['price']?.toString() ?? '';
      _seatsController.text = data['seats']?.toString() ?? '';
      _imageController.text = data['image']?.toString() ?? '';

      final type = data['type']?.toString() ?? 'Sedan';
      _type = _types.contains(type) ? type : 'Sedan';

      final branch = data['branch']?.toString() ?? 'Muar';
      _branch = _branches.contains(branch) ? branch : 'Muar';

      final origin = data['origin']?.toString() ?? 'Local';
      _origin = ['Local', 'International'].contains(origin)
          ? origin
          : 'Local';

      _available = data['available'] == true;
    });
  }

  InputDecoration _decoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: darkPurple),
      filled: true,
      fillColor: const Color(0xFFFAF9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
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
      IconData icon, {
        bool readOnly = false,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: _decoration(label, icon),
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
      decoration: _decoration(label, icon),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _section(
      String title,
      IconData icon,
      List<Widget> children,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDE7F3),
        ),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: darkPurple),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: darkPurple,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _pair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) {
          return Column(
            children: [
              first,
              const SizedBox(height: 14),
              second,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 14),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Future<void> _saveChanges() async {
    if (_selectedCarId == null) return;
    if (!_formKey.currentState!.validate()) return;

    final price = int.tryParse(_priceController.text.trim());
    final seats = int.tryParse(_seatsController.text.trim());
    final year = int.tryParse(_yearController.text.trim());

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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Save Vehicle Changes?'),
        content: Text(
          'Update ${_nameController.text.trim()} '
              '(${_plateController.text.trim()}) in Firebase?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(_selectedCarId)
          .update({
        'name': _nameController.text.trim(),
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to update vehicle: $error'),
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
        title: const Text(
          'Edit Vehicle',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('cars')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load vehicles.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final cars = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final nameA = a.data()['name']?.toString() ?? '';
              final nameB = b.data()['name']?.toString() ?? '';
              return nameA.compareTo(nameB);
            });

          if (cars.isEmpty) {
            return const Center(
              child: Text('No vehicles found.'),
            );
          }

          final selectedId = cars.any(
                (car) => car.id == _selectedCarId,
          )
              ? _selectedCarId
              : null;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Form(
                key: _formKey,
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
                          Icon(
                            Icons.edit_note_rounded,
                            color: orange,
                            size: 42,
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Vehicle Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Select a vehicle and update its information',
                                  style: TextStyle(
                                    color: Color(0xFFE2D8ED),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    _section(
                      'Select Vehicle',
                      Icons.search_rounded,
                      [
                        DropdownButtonFormField<String>(
                          value: selectedId,
                          isExpanded: true,
                          decoration: _decoration(
                            'Choose Vehicle',
                            Icons.directions_car_outlined,
                          ),
                          items: cars.map((car) {
                            final data = car.data();
                            final name =
                                data['name']?.toString() ?? 'Unknown';
                            final plate =
                                data['plate']?.toString() ?? car.id;

                            return DropdownMenuItem(
                              value: car.id,
                              child: Text(
                                '$name - $plate',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _isSaving
                              ? null
                              : (id) {
                            if (id == null) return;
                            final car = cars.firstWhere(
                                  (item) => item.id == id,
                            );
                            _loadCar(car);
                          },
                        ),
                      ],
                    ),

                    if (selectedId != null) ...[
                      _section(
                        'Vehicle Information',
                        Icons.directions_car_outlined,
                        [
                          _field(
                            _nameController,
                            'Car Name',
                            Icons.drive_eta_outlined,
                          ),
                          const SizedBox(height: 14),
                          _pair(
                            _field(
                              _plateController,
                              'Registration Plate',
                              Icons.pin_outlined,
                              readOnly: true,
                            ),
                            _dropdown(
                              label: 'Vehicle Type',
                              value: _type,
                              items: _types,
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

                      _section(
                        'Vehicle Specifications',
                        Icons.tune_rounded,
                        [
                          _pair(
                            _field(
                              _fuelController,
                              'Fuel Type',
                              Icons.local_gas_station_outlined,
                            ),
                            _field(
                              _colourController,
                              'Colour',
                              Icons.palette_outlined,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _pair(
                            _field(
                              _yearController,
                              'Manufacturing Year',
                              Icons.calendar_month_outlined,
                              keyboardType: TextInputType.number,
                            ),
                            _field(
                              _seatsController,
                              'Seating Capacity',
                              Icons.event_seat_outlined,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      _section(
                        'Rental Details',
                        Icons.payments_outlined,
                        [
                          _pair(
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
                          const SizedBox(height: 14),
                          _field(
                            _priceController,
                            'Daily Rental Price (RM)',
                            Icons.sell_outlined,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          SwitchListTile(
                            title: const Text(
                              'Available for Rental',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: const Text(
                              'Allow customers to book this vehicle',
                            ),
                            activeColor: darkPurple,
                            value: _available,
                            onChanged: (value) {
                              setState(() => _available = value);
                            },
                          ),
                        ],
                      ),

                      _section(
                        'Vehicle Image',
                        Icons.image_outlined,
                        [
                          _field(
                            _imageController,
                            'Image Asset Path',
                            Icons.folder_outlined,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Use an image already included in '
                                'your Flutter assets.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed:
                          _isSaving ? null : _saveChanges,
                          icon: _isSaving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving
                                ? 'Saving Changes...'
                                : 'Save Changes',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: darkPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
