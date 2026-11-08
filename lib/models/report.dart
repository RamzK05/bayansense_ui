enum ReportCategory {
  flooding('Flooding', 'Baha / Taas nga tubig'),
  drainageProblem('Drainage Problem', 'Problema sa agianan sa tubig'),
  cloggedDrainage('Clogged/Damaged Drainage', 'Barado o guba nga drainage'),
  sewerProblem('Sewer Problem', 'Kanal o imburnal'),
  waterWaste('Water Waste', 'Gahilak nga tubo / Hugaw nga tubig'),
  outOfScope('Out of Scope', 'Dili sakop (Water District)');

  final String label;
  final String bisayaHint;
  const ReportCategory(this.label, this.bisayaHint);
}

enum ReportStatus {
  submitted('Submitted', 0xFFE5A93C),
  underReview('Under Review', 0xFF0E5793),
  inProgress('In Progress', 0xFF2A85FF),
  resolved('Resolved', 0xFF1B8755),
  rejected('Out of Scope', 0xFF8A9BA8);

  final String label;
  final int colorHex;
  const ReportStatus(this.label, this.colorHex);
}

class Report {
  final String id;
  final String title;
  final String description;
  final String purok;
  final ReportCategory category;
  ReportStatus status;
  final DateTime createdAt;
  final double? confidenceScore;
  final String? assignedDepartment;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.purok,
    required this.category,
    this.status = ReportStatus.submitted,
    required this.createdAt,
    this.confidenceScore,
    this.assignedDepartment,
  });

  // String compatibility helpers for existing dashboard widgets
  String get dateSubmitted => createdAt.toIso8601String().substring(0, 10);
  String get statusLabel => status.label;

  Report copyWith({
    String? id,
    String? title,
    String? description,
    String? purok,
    ReportCategory? category,
    ReportStatus? status,
    DateTime? createdAt,
    double? confidenceScore,
    String? assignedDepartment,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      purok: purok ?? this.purok,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      assignedDepartment: assignedDepartment ?? this.assignedDepartment,
    );
  }
}
