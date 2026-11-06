
import 'package:cloud_firestore/cloud_firestore.dart';

import 'car_model.dart';

enum BookingStatus {
  upcoming,
  ongoing,
  completed,
  cancelled,
}
enum PaymentStatus {
  pending,
  paid,
}

class RentalBooking {
  final String id;
  final String userId;
  final Car car;
  final DateTime pickupDate;
  final DateTime returnDate;
  final int rentalDays;
  final int totalPrice;
  final String paymentMethod;
  final DateTime bookedAt;

  PaymentStatus paymentStatus;

  BookingStatus status;

  DateTime? actualPickupAt;
  DateTime? actualReturnAt;

  String pickupNotes;
  String returnNotes;

  Map<String, bool> pickupInspection;
  Map<String, bool> returnInspection;

  RentalBooking({
    required this.id,
    this.userId = '',
    required this.car,
    required this.pickupDate,
    required this.returnDate,
    required this.rentalDays,
    required this.totalPrice,
    required this.paymentMethod,
    required this.bookedAt,
    this.paymentStatus = PaymentStatus.pending,
    this.status = BookingStatus.upcoming,
    this.actualPickupAt,
    this.actualReturnAt,
    this.pickupNotes = '',
    this.returnNotes = '',
    Map<String, bool>? pickupInspection,
    Map<String, bool>? returnInspection,
  })  : pickupInspection = pickupInspection ?? {},
        returnInspection = returnInspection ?? {};

  // ---------------------------------------
  // EXISTING BOOKING STATUS LOGIC
  // ---------------------------------------

  bool get hasPickedUp => actualPickupAt != null;

  bool get hasReturned => actualReturnAt != null;

  BookingStatus get currentStatus {
    if (status == BookingStatus.cancelled) {
      return BookingStatus.cancelled;
    }

    if (hasReturned) {
      return BookingStatus.completed;
    }

    if (hasPickedUp) {
      return BookingStatus.ongoing;
    }

    // Preserve existing date-based status logic.
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final pickup = DateTime(
      pickupDate.year,
      pickupDate.month,
      pickupDate.day,
    );

    final returning = DateTime(
      returnDate.year,
      returnDate.month,
      returnDate.day,
    );

    if (today.isBefore(pickup)) {
      return BookingStatus.upcoming;
    }

    if (today.isAfter(returning)) {
      return BookingStatus.completed;
    }

    return BookingStatus.ongoing;
  }

  String get handoverStatus {
    if (status == BookingStatus.cancelled) {
      return 'Cancelled';
    }

    if (hasReturned) {
      return 'Returned';
    }

    if (hasPickedUp) {
      return 'On Rent';
    }

    return 'Awaiting Pickup';
  }

  // ---------------------------------------
  // CONVERT BOOKING TO FIRESTORE DATA
  // ---------------------------------------

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'car': {
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
      },
      'pickupDate': Timestamp.fromDate(pickupDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'rentalDays': rentalDays,
      'totalPrice': totalPrice,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus.name,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'status': status.name,
      'actualPickupAt': actualPickupAt == null
          ? null
          : Timestamp.fromDate(actualPickupAt!),
      'actualReturnAt': actualReturnAt == null
          ? null
          : Timestamp.fromDate(actualReturnAt!),
      'pickupNotes': pickupNotes,
      'returnNotes': returnNotes,
      'pickupInspection': pickupInspection,
      'returnInspection': returnInspection,
    };
  }

  // ---------------------------------------
  // CONVERT FIRESTORE DATA TO BOOKING
  // ---------------------------------------

  factory RentalBooking.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      throw StateError(
        'Booking document ${document.id} does not exist.',
      );
    }

    final carData = Map<String, dynamic>.from(
      data['car'] as Map,
    );

    final statusValue =
        data['status'] as String? ?? 'upcoming';

    final bookingStatus = BookingStatus.values.firstWhere(
          (value) => value.name == statusValue,
      orElse: () => BookingStatus.upcoming,
    );

    return RentalBooking(
      id: document.id,
      userId: data['userId'] as String? ?? '',
      car: Car(
        name: carData['name'] as String,
        plate: carData['plate'] as String,
        type: carData['type'] as String,
        fuel: carData['fuel'] as String,
        colour: carData['colour'] as String,
        year: carData['year'] as String,
        image: carData['image'] as String,
        price: (carData['price'] as num).toInt(),
        available: carData['available'] as bool,
        branch: carData['branch'] as String? ?? 'Unassigned',
        origin: carData['origin'] as String? ?? 'Unknown',
        seats: (carData['seats'] as num?)?.toInt() ?? 5,
      ),
      pickupDate: (data['pickupDate'] as Timestamp).toDate(),
      returnDate: (data['returnDate'] as Timestamp).toDate(),
      rentalDays: (data['rentalDays'] as num).toInt(),
      totalPrice: (data['totalPrice'] as num).toInt(),
      paymentMethod: data['paymentMethod'] as String,
      paymentStatus: PaymentStatus.values.firstWhere(
            (value) => value.name == data['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      bookedAt: (data['bookedAt'] as Timestamp).toDate(),
      status: bookingStatus,
      actualPickupAt: data['actualPickupAt'] == null
          ? null
          : (data['actualPickupAt'] as Timestamp).toDate(),
      actualReturnAt: data['actualReturnAt'] == null
          ? null
          : (data['actualReturnAt'] as Timestamp).toDate(),
      pickupNotes: data['pickupNotes'] as String? ?? '',
      returnNotes: data['returnNotes'] as String? ?? '',
      pickupInspection: Map<String, bool>.from(
        data['pickupInspection'] as Map? ?? {},
      ),
      returnInspection: Map<String, bool>.from(
        data['returnInspection'] as Map? ?? {},
      ),
    );
  }
}
