import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../models/booking_model.dart';
import '../../models/booking_store.dart';
import 'my_bookings_page.dart';


class PaymentScreen extends StatefulWidget {
  final RentalBooking booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;
  bool paymentCompleted = false;

  bool get isCash => widget.booking.paymentMethod == 'Cash';

  void handlePaymentAction() {
    if (isCash) {
      completePayment();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TngPaymentScreen(
            onPaymentConfirmed: completePayment,
          ),
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> completePayment() async {
    if (isProcessing || paymentCompleted) return;

    setState(() => isProcessing = true);

    try {
      // Demo payment only. No actual transaction occurs.
      widget.booking.paymentStatus =
      isCash ? PaymentStatus.pending : PaymentStatus.paid;

      await BookingStore.addBooking(widget.booking);

      if (!mounted) return;

      setState(() => paymentCompleted = true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCash
                ? 'Booking confirmed! Pay at the pickup branch.'
                : 'Payment confirmed! Your booking is ready.',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MyBookingsScreen(),
        ),
            (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to complete booking: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: darkPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complete Your Reservation',
                    style: TextStyle(
                      color: darkPurple,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Review your booking before confirming.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Summary',
                          style: TextStyle(
                            color: darkPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Divider(height: 28),
                        detailRow('Car', booking.car.name),
                        detailRow('Plate Number', booking.car.plate),
                        detailRow(
                          'Seating Capacity',
                          '${booking.car.seats} Seats',
                        ),
                        detailRow(
                          'Pickup Branch',
                          booking.car.branch,
                        ),
                        detailRow(
                          'Pickup Date',
                          formatDate(booking.pickupDate),
                        ),
                        detailRow(
                          'Return Date',
                          formatDate(booking.returnDate),
                        ),
                        detailRow(
                          'Rental Duration',
                          '${booking.rentalDays} day(s)',
                        ),
                        const Divider(height: 28),
                        detailRow(
                          'Total Amount',
                          'RM ${booking.totalPrice}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selected Payment Method',
                          style: TextStyle(
                            color: darkPurple,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Icon(
                              isCash
                                  ? Icons.payments_outlined
                                  : Icons.account_balance_wallet_outlined,
                              color: orange,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                booking.paymentMethod,
                                style: const TextStyle(
                                  color: darkPurple,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isCash
                              ? 'Pay cash at the pickup branch. '
                              'Payment will remain pending until '
                              'staff confirms collection.'
                              : 'Continue to the secure-looking project payment screen. '
                              'No actual e-wallet transaction will occur.',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isProcessing || paymentCompleted
                          ? null
                          : handlePaymentAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text(
                        isCash
                            ? 'PAY IN CASH'
                            : 'PAY NOW',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Center(
                    child: Text(
                      'Project payment simulation • No real transactions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Project simulation only. Never collect real Touch 'n Go credentials.
class TngPaymentScreen extends StatefulWidget {
  final Future<void> Function() onPaymentConfirmed;
  const TngPaymentScreen({super.key, required this.onPaymentConfirmed});

  @override
  State<TngPaymentScreen> createState() => _TngPaymentScreenState();
}

class _TngPaymentScreenState extends State<TngPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _processing = false;
  bool _hidePin = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_processing || !_formKey.currentState!.validate()) return;
    setState(() => _processing = true);
    try {
      await widget.onPaymentConfirmed();
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  InputDecoration _fieldDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: darkPurple),
      suffixIcon: suffix,
      filled: true,
      fillColor: lightGrey.withOpacity(.48),
      contentPadding: const EdgeInsets.symmetric(vertical: 19, horizontal: 17),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: darkPurple.withOpacity(.09)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        title: const Text('E-Wallet Payment', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        backgroundColor: darkPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [darkPurple, Color(0xFF5B3D85)],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: darkPurple.withOpacity(.18), blurRadius: 22, offset: const Offset(0, 9))],
                      ),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(.13), shape: BoxShape.circle),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 39),
                        ),
                        const SizedBox(height: 16),
                        const Text('Touch n Go', textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 7),
                        const Text('Complete your payment', textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFFE5DDF0), fontSize: 14)),
                      ]),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(23),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(23),
                        boxShadow: [BoxShadow(color: darkPurple.withOpacity(.045), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Payment Details', style: TextStyle(color: darkPurple, fontSize: 20, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 6),
                          const Text('Enter your information to continue.', style: TextStyle(color: Colors.black54, fontSize: 13)),
                          const SizedBox(height: 25),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [],
                            decoration: _fieldDecoration('Phone Number', Icons.phone_iphone_rounded),
                            validator: (value) {
                              final phone = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
                              return RegExp(r'^0[0-9]{8,10}$').hasMatch(phone)
                                  ? null : 'Enter a valid Malaysian phone number';
                            },
                          ),
                          const SizedBox(height: 17),
                          TextFormField(
                            controller: _pinController,
                            obscureText: _hidePin,
                            enableSuggestions: false,
                            autocorrect: false,
                            decoration: _fieldDecoration('Project Payment PIN', Icons.lock_outline_rounded,
                                suffix: IconButton(
                                  tooltip: _hidePin ? 'Show PIN' : 'Hide PIN',
                                  onPressed: () => setState(() => _hidePin = !_hidePin),
                                  icon: Icon(_hidePin ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: darkPurple),
                                )),
                            validator: (value) => value == '2468' ? null : 'Use the project PIN: 2468',
                          ),
                          const SizedBox(height: 12),
                          const Row(children: [
                          ]),
                          const SizedBox(height: 25),
                          SizedBox(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _processing ? null : _submit,
                              icon: _processing
                                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check_circle_outline_rounded),
                              label: Text(_processing ? 'PROCESSING...' : 'CONFIRM PAYMENT',
                                  style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: .5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: orange, foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
