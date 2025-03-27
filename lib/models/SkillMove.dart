import 'package:flutter/material.dart';

class SkillMove {
  final String name;
  final String input;
  final String description;
  final String realWorldUse; // Work experience highlight
  final int mastery;
  final String enemyImage;
  final Color color;

  SkillMove({
    required this.name,
    required this.input,
    required this.description,
    required this.realWorldUse,
    required this.mastery,
    required this.enemyImage,
    required this.color,
  });
}