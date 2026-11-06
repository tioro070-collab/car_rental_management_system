
class BookingAvailability {
  BookingAvailability._();


  static String vehicleId(String plate) {
    final id = plate.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase();

    if (id.isEmpty) {
      throw ArgumentError('Vehicle plate number cannot be empty.');
    }

    return id;
  }


  static String dateKey(DateTime date) {
    final normalized = dateOnly(date);

    final year = normalized.year.toString().padLeft(4, '0');
    final month = normalized.month.toString().padLeft(2, '0');
    final day = normalized.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }


  static List<String> reservedDateKeys({
    required DateTime pickupDate,
    required DateTime returnDate,
  }) {
    final start = dateOnly(pickupDate);
    final end = dateOnly(returnDate);

    if (end.isBefore(start)) {
      throw ArgumentError(
        'Return date cannot be before pickup date.',
      );
    }

    final dates = <String>[];

    var current = start;

    while (!current.isAfter(end)) {
      dates.add(dateKey(current));

      current = DateTime(
        current.year,
        current.month,
        current.day + 1,
      );
    }

    return dates;
  }


  static bool hasDateConflict({
    required List<String> requestedDates,
    required List<String> existingDates,
  }) {
    final reserved = existingDates.toSet();

    return requestedDates.any(
          (date) => reserved.contains(date),
    );
  }




  // Compare calendar dates without considering the time.
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Both pickup and return dates are reserved.
  static bool datesOverlap({
    required DateTime newPickup,
    required DateTime newReturn,
    required DateTime existingPickup,
    required DateTime existingReturn,
  }) {
    final startA = dateOnly(newPickup);
    final endA = dateOnly(newReturn);
    final startB = dateOnly(existingPickup);
    final endB = dateOnly(existingReturn);

    if (endA.isBefore(startA) || endB.isBefore(startB)) {
      throw ArgumentError('Return date cannot be before pickup date.');
    }

    return !startA.isAfter(endB) &&
        !endA.isBefore(startB);
  }
}


class VehicleUnavailableException implements Exception {
  final String message;

  const VehicleUnavailableException([
    this.message =
    'This vehicle is already booked for the selected dates. '
        'Please choose different dates or another vehicle.',
  ]);

  @override
  String toString() => message;
}
