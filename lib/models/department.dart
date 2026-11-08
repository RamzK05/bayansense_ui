class Department {
  final String id;
  final String name;
  final String code;
  final String description;
  final List<String> handledCategories;

  const Department({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.handledCategories,
  });

  // Pre-configured barangay departments based on BayanSense scope
  static const Department drainageAndFlood = Department(
    id: 'dept-01',
    name: 'Drainage & Flood Control',
    code: 'DFC',
    description: 'Handles street flooding, culvert cleaning, and canal repairs.',
    handledCategories: [
      'Flooding',
      'Drainage Problem',
      'Clogged/Damaged Drainage',
    ],
  );

  static const Department sanitationAndSewer = Department(
    id: 'dept-02',
    name: 'Sanitation & Sewer',
    code: 'SAN',
    description: 'Manages imburnal blockages, sewer runoff, and wastewater contamination.',
    handledCategories: [
      'Sewer Problem',
      'Water Waste',
    ],
  );

  static const Department externalWaterDistrict = Department(
    id: 'dept-03',
    name: 'Water District / External',
    code: 'EXT',
    description: 'Outside barangay jurisdiction. Refers clean-water line issues.',
    handledCategories: [
      'Out of Scope',
    ],
  );

  static const List<Department> all = [
    drainageAndFlood,
    sanitationAndSewer,
    externalWaterDistrict,
  ];

  /// Helper to find which department handles a given category label
  static Department forCategory(String categoryLabel) {
    for (final dept in all) {
      if (dept.handledCategories.contains(categoryLabel)) {
        return dept;
      }
    }
    return drainageAndFlood;
  }
}
