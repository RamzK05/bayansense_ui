import 'package:flutter/material.dart';

enum CategoryType {
  flooding(
    'Flooding',
    'Baha / Taas nga tubig',
    Icons.water,
    Color(0xFF0E5793),
  ),
  drainageProblem(
    'Drainage Problem',
    'Problema sa agianan sa tubig',
    Icons.alt_route,
    Color(0xFF2A85FF),
  ),
  cloggedDrainage(
    'Clogged/Damaged Drainage',
    'Barado o guba nga drainage',
    Icons.report_problem,
    Color(0xFFE5A93C),
  ),
  sewerProblem(
    'Sewer Problem',
    'Kanal o imburnal',
    Icons.cleaning_services,
    Color(0xFF8A5322),
  ),
  waterWaste(
    'Water Waste',
    'Gahilak nga tubo / Hugaw nga tubig',
    Icons.opacity,
    Color(0xFF1B8755),
  ),
  outOfScope(
    'Out of Scope',
    'Dili sakop (Water District - Limpyo nga tubig)',
    Icons.cancel_outlined,
    Color(0xFF8A9BA8),
  );

  final String label;
  final String bisayaHint;
  final IconData icon;
  final Color color;

  const CategoryType(this.label, this.bisayaHint, this.icon, this.color);

  /// Parse from backend JSON or category name string
  static CategoryType fromString(String value) {
    return CategoryType.values.firstWhere(
      (cat) =>
          cat.name.toLowerCase() == value.toLowerCase() ||
          cat.label.toLowerCase() == value.toLowerCase(),
      orElse: () => CategoryType.drainageProblem,
    );
  }
}
