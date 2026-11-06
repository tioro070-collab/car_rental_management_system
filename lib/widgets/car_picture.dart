import 'package:flutter/material.dart';
import '../models/car_model.dart';
import '../theme/app_colors.dart';

class CarPicture extends StatelessWidget {
  final Car car;
  final double height;

  const CarPicture({
    super.key,
    required this.car,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      car.image,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.directions_car,
          color: darkPurple,
          size: height * 0.6,
        );
      },
    );
  }
}
