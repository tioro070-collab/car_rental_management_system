
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../theme/app_colors.dart';
import '../staff/staff_dashboard.dart';
import '../admin/admin_dashboard.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() =>
      _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final employeeIdController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    employeeIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ----------------------------------------
  // EMPLOYEE LOGIN VALIDATION
  // ----------------------------------------


  Future<void> loginEmployee() async {
    if (isLoading) return;

    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = employeeIdController.text.trim();
    final password = passwordController.text;

    setState(() {
      isLoading = true;
    });

    try {
      // Authenticate employee using Firebase.
      final credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to verify employee account.');
      }

      // Retrieve the employee record using Firebase UID.
      final employeeDocument = await FirebaseFirestore.instance
          .collection('employees')
          .doc(user.uid)
          .get();

      if (!employeeDocument.exists) {
        throw Exception('This account is not registered as an employee.');
      }

      final employeeData = employeeDocument.data()!;

      final role = employeeData['role'] as String?;
      final active = employeeData['active'] == true;

      if (!active || (role != 'staff' && role != 'admin')) {
        throw Exception('Employee access is not authorized.');
      }

      if (!mounted) return;

      if (role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const StaffDashboard(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const AdminDashboard(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'invalid-credential'
                ? 'Invalid email or password.'
                : 'Login failed: ${e.message ?? e.code}',
          ),
          backgroundColor: const Color(0xFFE54266),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Remove the Firebase session if the account
      // does not have an authorized employee record.
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFE54266),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  // ----------------------------------------
  // INPUT FIELD DECORATION
  // ----------------------------------------

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9186A9),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF7565A0),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFD9D0EC),
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: orange,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 2,
        ),
      ),
    );
  }

  // ----------------------------------------
  // BRAND LOGO
  // ----------------------------------------

  Widget brandLogo() {
    return Column(
      children: [
        Container(
          width: 75,
          height: 75,
          decoration: BoxDecoration(
            color: orange.withOpacity(0.14),
            borderRadius: BorderRadius.circular(23),
          ),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            color: orange,
            size: 43,
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'CAR RENTAL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'MANAGEMENT SYSTEM',
          style: TextStyle(
            color: Color(0xFFE4D7F5),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  // ----------------------------------------
  // PREMIUM PURPLE HEADER
  // ----------------------------------------

  Widget header() {
    return Container(
      width: double.infinity,
      height: 330,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkPurple,
            Color(0xFF49217C),
            Color(0xFF26104F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: 120,
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 230,
              color: Colors.white.withOpacity(0.055),
            ),
          ),
          Positioned(
            left: -75,
            bottom: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: orange.withOpacity(0.09),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              25,
              24,
              70,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Expanded(
                  child: Center(
                    child: brandLogo(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------
  // EMPLOYEE LOGIN CARD
  // ----------------------------------------

  Widget employeeLoginCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        24,
        29,
        24,
        25,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: darkPurple.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Employee Login',
                style: TextStyle(
                  color: darkPurple,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 7),

            const Center(
              child: Text(
                'Authorized employees only',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF817694),
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 28),


            // EMPLOYEE EMAIL
            const Text(
              'Employee Email',
              style: TextStyle(
                color: darkPurple,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            TextFormField(
              controller: employeeIdController,
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              textInputAction: TextInputAction.next,
              decoration: fieldDecoration(
                hint: 'Enter your employee email',
                icon: Icons.email_outlined,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your employee email';
                }

                if (!RegExp(
                  r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                ).hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }

                return null;
              },
            ),


            const SizedBox(height: 9),



            const SizedBox(height: 21),

            // PASSWORD
            const Text(
              'Password',
              style: TextStyle(
                color: darkPurple,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 9),

            TextFormField(
              controller: passwordController,
              obscureText: hidePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => loginEmployee(),
              decoration: fieldDecoration(
                hint: 'Enter your password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF7565A0),
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }

                return null;
              },
            ),

            const SizedBox(height: 28),

            // LOGIN BUTTON
            SizedBox(
              width: double.infinity,
              height: 57,
              child: ElevatedButton(
                onPressed: isLoading ? null : loginEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: orange.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                child: isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VERIFY & LOGIN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward_rounded),
                  ],
                ),

              ),
            ),

            const SizedBox(height: 26),



          ],
        ),
      ),
    );
  }

  // ----------------------------------------
  // SECURITY NOTICE
  // ----------------------------------------

  Widget securityNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF7565A0),
            size: 16,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              'Employee access is restricted to authorized users.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkPurple.withOpacity(0.65),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------
  // MAIN BUILD
  // ----------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 520,
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      header(),

                      Transform.translate(
                        offset: const Offset(0, -43),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                          ),
                          child: Column(
                            children: [
                              employeeLoginCard(),

                              const SizedBox(height: 22),

                              securityNotice(),

                              const SizedBox(height: 25),

                              const Text(
                                'CAR RENTAL MANAGEMENT SYSTEM',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black38,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),

                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
