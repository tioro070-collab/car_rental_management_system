
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/car_model.dart';

class CarImportService {
  static Future<String> importCars() async {
    final firestore = FirebaseFirestore.instance;
    final carsCollection = firestore.collection('cars');

    int imported = 0;
    int skipped = 0;

    for (final car in carList) {
      // Use the plate without spaces as the document ID.
      final documentId = car.plate.replaceAll(' ', '');
      final documentRef = carsCollection.doc(documentId);

      // Check whether this car already exists.
      final existingDocument = await documentRef.get();

      if (existingDocument.exists) {
        skipped++;
        continue;
      }

      // Import the car using the existing Flutter data.
      await documentRef.set({
        'name': car.name,
        'plate': car.plate,
        'type': car.type,
        'fuel': car.fuel,
        'colour': car.colour,
        'year': car.year,
        'image': car.image,
        'price': car.price,
        'available': car.available,
        'branch': car.branch,
        'origin': car.origin,
        'seats': car.seats,
      });

      imported++;
    }

    return 'Imported $imported cars. Skipped $skipped existing cars.';
  }
}
