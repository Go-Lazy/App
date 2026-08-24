import 'package:flutter/material.dart';

/// A single step in the "How GoLazy Works" explainer on the home page.
class HowItWorksStep {
  const HowItWorksStep({
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
  });

  final int stepNumber;
  final IconData icon;
  final String title;
  final String description;
}
