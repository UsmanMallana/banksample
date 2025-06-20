import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(Duration duration, double moneySaved) isAchieved;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isAchieved,
  });
}
