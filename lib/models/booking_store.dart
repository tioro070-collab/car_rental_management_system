import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'booking_model.dart';
import 'booking_availability.dart';

class BookingStore {
BookingStore._();

static final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

static final FirebaseAuth _auth =
FirebaseAuth.instance;


static DocumentReference<Map<String, dynamic>>
_vehicleReservationRef(String plate) {
final vehicleId = BookingAvailability.vehicleId(plate);

return _firestore
    .collection('vehicleReservations')
    .doc(vehicleId);
}


static Future<List<RentalBooking>>
loadExistingVehicleBookings(String plate) async {
final snapshot = await _firestore
    .collection('bookings')
    .get();

final vehicleId = BookingAvailability.vehicleId(plate);
final results = <RentalBooking>[];

for (final document in snapshot.docs) {
final booking = RentalBooking.fromFirestore(document);

if (BookingAvailability.vehicleId(booking.car.plate) ==
vehicleId &&
booking.status != BookingStatus.cancelled) {
results.add(booking);
}
}

return results;
}


static Map<String, dynamic> _buildReservationEntry(
RentalBooking booking,
String userId,
) {
return {
'bookingId': booking.id,
'userId': userId,
'pickupDate': BookingAvailability.dateKey(
booking.pickupDate,
),
'returnDate': BookingAvailability.dateKey(
booking.returnDate,
),
'dates': BookingAvailability.reservedDateKeys(
pickupDate: booking.pickupDate,
returnDate: booking.returnDate,
),
};
}


static List<String> _getExistingReservedDates(
List<dynamic> reservations,
) {
final reservedDates = <String>{};

for (final reservation in reservations) {
if (reservation is! Map) continue;

final dates = reservation['dates'];

if (dates is! List) continue;

for (final date in dates) {
if (date is String) {
reservedDates.add(date);
}
}
}

return reservedDates.toList();
}


// Keep the existing ValueNotifier so current
// customer and staff screens remain compatible.
static final ValueNotifier<List<RentalBooking>> bookings =
ValueNotifier<List<RentalBooking>>([]);

static StreamSubscription<
QuerySnapshot<Map<String, dynamic>>>? _subscription;

static String? _activeUserId;
static String? _activeListenerType;

static String generateBookingId() {
return 'CR${DateTime.now().microsecondsSinceEpoch}';
}

// ---------------------------------------
// LISTEN TO CUSTOMER BOOKINGS
// ---------------------------------------

static Future<void> startListening() async {
final user = _auth.currentUser;

if (user == null) {
stopListening();
return;
}

if (_activeUserId == user.uid &&
_activeListenerType == 'customer' &&
_subscription != null) {
return;
}

stopListening();

_activeUserId = user.uid;
_activeListenerType = 'customer';

_subscription = _firestore
    .collection('bookings')
    .where('userId', isEqualTo: user.uid)
    .snapshots()
    .listen(
(snapshot) {
if (_activeUserId != user.uid) return;

final loadedBookings = <RentalBooking>[];

for (final document in snapshot.docs) {
try {
loadedBookings.add(
RentalBooking.fromFirestore(document),
);
} catch (error) {
debugPrint(
'Unable to parse booking ${document.id}: $error',
);
}
}

loadedBookings.sort(
(a, b) => b.bookedAt.compareTo(a.bookedAt),
);

bookings.value = loadedBookings;
},
onError: (Object error) {
debugPrint('Firestore booking listener error: $error');
},
);
}

static void stopListening() {
_subscription?.cancel();
_subscription = null;
_activeUserId = null;
_activeListenerType = null;
bookings.value = [];
}

// ---------------------------------------
// LISTEN TO STAFF BOOKINGS
// ---------------------------------------

static Future<void> startStaffListening() async {
final user = _auth.currentUser;

if (user == null) {
stopListening();
return;
}

// Verify that the signed-in account is
// an active Staff or Admin account.
final employeeDocument = await _firestore
    .collection('employees')
    .doc(user.uid)
    .get();

if (!employeeDocument.exists) {
throw StateError('Employee account not found.');
}

final employeeData = employeeDocument.data();

final role = employeeData?['role'];
final active = employeeData?['active'] == true;

if (!active || (role != 'staff' && role != 'admin')) {
throw StateError('Employee access is not permitted.');
}

// Avoid creating duplicate listeners.
if (_activeUserId == user.uid &&
_activeListenerType == 'staff' &&
_subscription != null) {
return;
}

stopListening();

_activeUserId = user.uid;
_activeListenerType = 'staff';

// Staff can read bookings from all customers.
// The dashboard will filter by branch.
_subscription = _firestore
    .collection('bookings')
    .snapshots()
    .listen(
(snapshot) {
if (_activeUserId != user.uid) return;

final loadedBookings = <RentalBooking>[];

for (final document in snapshot.docs) {
try {
loadedBookings.add(
RentalBooking.fromFirestore(document),
);
} catch (error) {
debugPrint(
'Unable to parse booking ${document.id}: $error',
);
}
}

loadedBookings.sort(
(a, b) => b.bookedAt.compareTo(a.bookedAt),
);

bookings.value = loadedBookings;
},
onError: (Object error) {
debugPrint(
'Staff Firestore booking listener error: $error',
);
},
);
}

// ---------------------------------------
// CREATE BOOKING IN FIRESTORE
// ---------------------------------------

static List<Map<String, dynamic>> _readReservationEntries(
Map<String, dynamic>? data,
) {
final raw = data?['reservedDates'];

if (raw == null) {
return <Map<String, dynamic>>[];
}

if (raw is! List) {
throw StateError(
'Invalid vehicle reservation data.',
);
}

return raw.map((entry) {
if (entry is! Map) {
throw StateError(
'Invalid reservation entry.',
);
}

return Map<String, dynamic>.from(entry);
}).toList();
}


static Future<void> _createBookingWithReservation(
RentalBooking booking,
String userId,
) async {
final bookingRef = _firestore
    .collection('bookings')
    .doc(booking.id);

final reservationRef =
_vehicleReservationRef(booking.car.plate);

final requestedDates =
BookingAvailability.reservedDateKeys(
pickupDate: booking.pickupDate,
returnDate: booking.returnDate,
);

await _firestore.runTransaction((transaction) async {
// Read all documents before making writes.
final reservationSnapshot =
await transaction.get(reservationRef);

final bookingSnapshot =
await transaction.get(bookingRef);

if (bookingSnapshot.exists) {
throw StateError('Booking ID already exists.');
}

if (!reservationSnapshot.exists) {
throw StateError(
'Vehicle reservations are not initialized.',
);
}

final entries = _readReservationEntries(
reservationSnapshot.data(),
);

final existingDates =
_getExistingReservedDates(entries);

final conflict =
BookingAvailability.hasDateConflict(
requestedDates: requestedDates,
existingDates: existingDates,
);

if (conflict) {
throw const VehicleUnavailableException();
}

entries.add(_buildReservationEntry(booking, userId));

final data = booking.toFirestore();
data['userId'] = userId;

transaction.update(reservationRef, {
'reservedDates': entries,
});

transaction.set(bookingRef, data);
});
}


static Future<void> addBooking(
RentalBooking booking,
) async {
final user = _auth.currentUser;

if (user == null) {
throw StateError(
'Please log in before making a booking.',
);
}

if (booking.userId.isNotEmpty &&
booking.userId != user.uid) {
throw StateError(
'This booking belongs to another account.',
);
}

final data = booking.toFirestore();

// Always use the authenticated user's UID.
data['userId'] = user.uid;

await _firestore
    .collection('bookings')
    .doc(booking.id)
    .set(data);

// Update the current UI immediately after
// Firestore confirms the write.
final savedBooking = RentalBooking(
id: booking.id,
userId: user.uid,
car: booking.car,
pickupDate: booking.pickupDate,
returnDate: booking.returnDate,
rentalDays: booking.rentalDays,
totalPrice: booking.totalPrice,
paymentMethod: booking.paymentMethod,
paymentStatus: booking.paymentStatus,
bookedAt: booking.bookedAt,
status: booking.status,
actualPickupAt: booking.actualPickupAt,
actualReturnAt: booking.actualReturnAt,
pickupNotes: booking.pickupNotes,
returnNotes: booking.returnNotes,
pickupInspection: booking.pickupInspection,
returnInspection: booking.returnInspection,
);

bookings.value = [
savedBooking,
...bookings.value.where(
(existing) => existing.id != savedBooking.id,
),
];
}

// ---------------------------------------
// FIND EXISTING BOOKING
// ---------------------------------------

static RentalBooking? findBooking(String id) {
for (final booking in bookings.value) {
if (booking.id == id) {
return booking;
}
}

return null;
}

static void _notifyChanges() {
bookings.value =
List<RentalBooking>.from(bookings.value);
}

// ---------------------------------------
// CANCEL BOOKING
// ---------------------------------------

static Future<bool> cancelBooking(
String bookingId,
) async {
final user = _auth.currentUser;
final booking = findBooking(bookingId);

if (user == null ||
booking == null ||
booking.userId != user.uid ||
booking.status == BookingStatus.cancelled ||
booking.hasPickedUp ||
booking.hasReturned ||
booking.currentStatus != BookingStatus.upcoming) {
return false;
}

await _firestore
    .collection('bookings')
    .doc(bookingId)
    .update({
'status': BookingStatus.cancelled.name,
});

booking.status = BookingStatus.cancelled;
_notifyChanges();

return true;
}

// ---------------------------------------
// CONFIRM VEHICLE PICKUP
// ---------------------------------------

static Future<bool> confirmPickup({
required String bookingId,
required Map<String, bool> inspection,
String notes = '',
}) async {
final booking = findBooking(bookingId);

if (booking == null ||
booking.status == BookingStatus.cancelled ||
booking.hasPickedUp ||
booking.hasReturned) {
return false;
}

final now = DateTime.now();

final today = DateTime(
now.year,
now.month,
now.day,
);

final scheduled = DateTime(
booking.pickupDate.year,
booking.pickupDate.month,
booking.pickupDate.day,
);

if (today.isBefore(scheduled)) {
return false;
}

final conflictingRental = bookings.value.any(
(other) =>
other.id != booking.id &&
other.car.plate == booking.car.plate &&
other.hasPickedUp &&
!other.hasReturned &&
other.status != BookingStatus.cancelled,
);

if (conflictingRental) {
return false;
}

await _firestore
    .collection('bookings')
    .doc(bookingId)
    .update({
'actualPickupAt': Timestamp.fromDate(now),
'pickupInspection': inspection,
'pickupNotes': notes.trim(),
'status': BookingStatus.ongoing.name,
});

booking.actualPickupAt = now;
booking.pickupInspection = Map.from(inspection);
booking.pickupNotes = notes.trim();
booking.status = BookingStatus.ongoing;

_notifyChanges();

return true;
}

// ---------------------------------------
// CONFIRM VEHICLE RETURN
// ---------------------------------------

static Future<bool> confirmReturn({
required String bookingId,
required Map<String, bool> inspection,
String notes = '',
}) async {
final booking = findBooking(bookingId);

if (booking == null ||
booking.status == BookingStatus.cancelled ||
!booking.hasPickedUp ||
booking.hasReturned) {
return false;
}

final now = DateTime.now();

await _firestore
    .collection('bookings')
    .doc(bookingId)
    .update({
'actualReturnAt': Timestamp.fromDate(now),
'returnInspection': inspection,
'returnNotes': notes.trim(),
'status': BookingStatus.completed.name,
});

booking.actualReturnAt = now;
booking.returnInspection = Map.from(inspection);
booking.returnNotes = notes.trim();
booking.status = BookingStatus.completed;

_notifyChanges();

return true;
}

// Staff-only cash payment confirmation.
// Firestore Security Rules must independently enforce staff permissions.
static Future<bool> confirmCashPayment(String bookingId) async {
final user = _auth.currentUser;
if (user == null) {
throw StateError('Please sign in with a staff account.');
}

final employeeDoc = await _firestore
    .collection('employees')
    .doc(user.uid)
    .get();
final employee = employeeDoc.data();
if (!employeeDoc.exists ||
employee?['active'] != true ||
(employee?['role'] != 'staff' && employee?['role'] != 'admin')) {
throw StateError('Only active staff or admins can confirm cash.');
}

final bookingRef = _firestore.collection('bookings').doc(bookingId);
final changed = await _firestore.runTransaction<bool>((transaction) async {
final snapshot = await transaction.get(bookingRef);
if (!snapshot.exists) return false;
final data = snapshot.data();
if (data == null) return false;

final method = (data['paymentMethod'] ?? '').toString().trim().toLowerCase();
final payment = (data['paymentStatus'] ?? 'pending').toString().toLowerCase();
final status = (data['status'] ?? '').toString().toLowerCase();
if (method != 'cash' || payment != 'pending' || status == 'cancelled') {
return false;
}

// Restrict branch staff to their own branch, where employee.branch exists.
// Admins may confirm bookings from any branch.
if (employee?['role'] != 'admin') {
final staffBranch = (employee?['branch'] ?? '').toString().trim().toLowerCase();
final car = data['car'];
final bookingBranch = car is Map
? (car['branch'] ?? '').toString().trim().toLowerCase()
    : '';
if (staffBranch.isEmpty || bookingBranch.isEmpty ||
staffBranch != bookingBranch) {
throw StateError('This booking is outside your assigned branch.');
}
}

transaction.update(bookingRef, {
'paymentStatus': PaymentStatus.paid.name,
'cashConfirmedAt': FieldValue.serverTimestamp(),
'cashConfirmedBy': user.uid,
});
return true;
});

// Existing Firestore listener refreshes both staff and customer views.
return changed;
}

}



