
import 'package:flutter/foundation.dart';

import 'car_model.dart';
import 'booking_model.dart';
import 'booking_store.dart';

enum VehicleStatus {
  available,
  reserved,
  onRent,
  maintenance,
  unavailable,
}

enum MaintenanceType {
  regularService,
  repair,
  inspection,
  cleaning,
}

class MaintenanceRecord {
  final String id;
  final String vehicleKey;
  final MaintenanceType type;
  final DateTime startDate;
  final DateTime endDate;
  final String notes;
  final DateTime createdAt;

  const MaintenanceRecord({
    required this.id,
    required this.vehicleKey,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.notes,
    required this.createdAt,
  });

  bool isActiveOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final end = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );

    return !day.isBefore(start) && !day.isAfter(end);
  }
}

class VehicleStore {
  VehicleStore._();

  static final ValueNotifier<List<MaintenanceRecord>> maintenance =
  ValueNotifier<List<MaintenanceRecord>>([]);

  static final ValueNotifier<Set<String>> manuallyUnavailable =
  ValueNotifier<Set<String>>({});

  static String keyFor(Car car) {
    return '${car.branch.trim().toLowerCase()}|'
        '${car.plate.trim().toLowerCase()}';
  }

  static bool sameVehicle(Car first, Car second) {
    return keyFor(first) == keyFor(second);
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool overlaps(
      DateTime firstStart,
      DateTime firstEnd,
      DateTime secondStart,
      DateTime secondEnd,
      ) {
    return !dateOnly(firstEnd).isBefore(dateOnly(secondStart)) &&
        !dateOnly(firstStart).isAfter(dateOnly(secondEnd));
  }

  static List<MaintenanceRecord> recordsFor(Car car) {
    final records = maintenance.value
        .where((record) => record.vehicleKey == keyFor(car))
        .toList();

    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  static List<RentalBooking> bookingsFor(Car car) {
    final result = BookingStore.bookings.value.where(
          (booking) => sameVehicle(booking.car, car),
    ).toList();

    result.sort((a, b) => b.bookedAt.compareTo(a.bookedAt));
    return result;
  }

  static VehicleStatus statusFor(
      Car car, {
        DateTime? onDate,
      }) {
    final day = dateOnly(onDate ?? DateTime.now());
    final key = keyFor(car);

    final activeRental = bookingsFor(car).any(
          (booking) =>
      booking.status != BookingStatus.cancelled &&
          booking.hasPickedUp &&
          !booking.hasReturned,
    );

    // An actual handover takes priority, even if
    // a conflicting maintenance entry exists.
    if (activeRental) return VehicleStatus.onRent;

    final inMaintenance = maintenance.value.any(
          (record) =>
      record.vehicleKey == key &&
          record.isActiveOn(day),
    );

    if (inMaintenance) return VehicleStatus.maintenance;

    if (!car.available ||
        manuallyUnavailable.value.contains(key)) {
      return VehicleStatus.unavailable;
    }

    final reserved = bookingsFor(car).any((booking) {
      if (booking.status == BookingStatus.cancelled ||
          booking.hasReturned ||
          booking.hasPickedUp) {
        return false;
      }

      return overlaps(
        booking.pickupDate,
        booking.returnDate,
        day,
        day,
      );
    });

    if (reserved) return VehicleStatus.reserved;

    return VehicleStatus.available;
  }

  static bool hasMaintenanceConflict(
      Car car,
      DateTime start,
      DateTime end,
      ) {
    return bookingsFor(car).any((booking) {
      if (booking.status == BookingStatus.cancelled ||
          booking.hasReturned) {
        return false;
      }

      return overlaps(
        booking.pickupDate,
        booking.returnDate,
        start,
        end,
      );
    });
  }

  static bool addMaintenance({
    required Car car,
    required MaintenanceType type,
    required DateTime startDate,
    required DateTime endDate,
    required String notes,
  }) {
    if (dateOnly(endDate).isBefore(dateOnly(startDate))) {
      return false;
    }

    if (hasMaintenanceConflict(car, startDate, endDate)) {
      return false;
    }

    final record = MaintenanceRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      vehicleKey: keyFor(car),
      type: type,
      startDate: dateOnly(startDate),
      endDate: dateOnly(endDate),
      notes: notes.trim(),
      createdAt: DateTime.now(),
    );

    maintenance.value = [record, ...maintenance.value];
    return true;
  }

  static void setUnavailable(Car car, bool unavailable) {
    final updated = Set<String>.from(manuallyUnavailable.value);
    final key = keyFor(car);

    if (unavailable) {
      updated.add(key);
    } else {
      updated.remove(key);
    }

    manuallyUnavailable.value = updated;
  }

  static String statusLabel(VehicleStatus status) {
    switch (status) {
      case VehicleStatus.available:
        return 'Available';
      case VehicleStatus.reserved:
        return 'Reserved';
      case VehicleStatus.onRent:
        return 'On Rent';
      case VehicleStatus.maintenance:
        return 'Maintenance';
      case VehicleStatus.unavailable:
        return 'Unavailable';
    }
  }

  static String maintenanceLabel(MaintenanceType type) {
    switch (type) {
      case MaintenanceType.regularService:
        return 'Regular Service';
      case MaintenanceType.repair:
        return 'Repair';
      case MaintenanceType.inspection:
        return 'Inspection';
      case MaintenanceType.cleaning:
        return 'Cleaning';
    }
  }
}
