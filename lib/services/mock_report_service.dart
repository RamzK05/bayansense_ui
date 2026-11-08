import '../models/report.dart';

class MockReportService {
  static final MockReportService _instance = MockReportService._internal();

  factory MockReportService() => _instance;

  MockReportService._internal();

  final List<Report> _reports = [
    Report(
      id: 'REP-1001',
      title: 'Barado nga imburnal atbang sa chapel',
      description: 'Nipondo ang hugaw nga tubig kay puno ug basura ang imburnal.',
      purok: 'Purok 3 - San Jose',
      category: ReportCategory.sewerProblem,
      status: ReportStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      confidenceScore: 0.94,
      assignedDepartment: 'Sanitation & Sewer',
    ),
    Report(
      id: 'REP-1002',
      title: 'Baha sa kalsada pagkahuman sa ulan',
      description: 'Hapit na masulod sa balay ang tubig baha kay walay klarong agianan.',
      purok: 'Purok 4 - Riverside',
      category: ReportCategory.flooding,
      status: ReportStatus.underReview,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      confidenceScore: 0.88,
      assignedDepartment: 'Drainage & Flood Control',
    ),
    Report(
      id: 'REP-1003',
      title: 'Nabuak nga drainage cover',
      description: 'Delikado sa mga motor ug bata ang nabuak nga semento sa drainage.',
      purok: 'Purok 1 - Centro',
      category: ReportCategory.cloggedDrainage,
      status: ReportStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      confidenceScore: 0.96,
      assignedDepartment: 'Drainage & Flood Control',
    ),
  ];

  List<Report> getAllReports() => List.unmodifiable(_reports);

  List<Report> getReportsForDepartment(String department) {
    if (department == 'All') return getAllReports();
    return _reports.where((report) => report.assignedDepartment == department).toList();
  }

  int countByStatus(ReportStatus status) {
    return _reports.where((report) => report.status == status).length;
  }

  Future<Report> submitReport({
    required String title,
    required String description,
    required String purok,
    ReportCategory? chosenCategory,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    ReportCategory detected = chosenCategory ?? ReportCategory.drainageProblem;
    final lower = description.toLowerCase();

    // Simple demo rules based on the project's Bisaya reporting guide.
    if (lower.contains('imburnal') ||
        lower.contains('imbornal') ||
        lower.contains('kanal')) {
      detected = ReportCategory.sewerProblem;
    } else if (lower.contains('baha') || lower.contains('lunop')) {
      detected = ReportCategory.flooding;
    } else if (lower.contains('agas') ||
        lower.contains('walay tubig') ||
        lower.contains('water district')) {
      detected = ReportCategory.outOfScope;
    } else if (lower.contains('barado') || lower.contains('guba')) {
      detected = ReportCategory.cloggedDrainage;
    }

    // Assign department based on category
    String assignedDepartment;
    if (detected == ReportCategory.sewerProblem || detected == ReportCategory.waterWaste) {
      assignedDepartment = 'Sanitation & Sewer';
    } else if (detected == ReportCategory.outOfScope) {
      assignedDepartment = 'Water District / External';
    } else {
      assignedDepartment = 'Drainage & Flood Control';
    }

    final newReport = Report(
      id: 'REP-${1000 + _reports.length + 1}',
      title: title,
      description: description,
      purok: purok,
      category: detected,
      status: detected == ReportCategory.outOfScope
          ? ReportStatus.rejected
          : ReportStatus.submitted,
      createdAt: DateTime.now(),
      confidenceScore: 0.92,
      assignedDepartment: assignedDepartment,
    );

    _reports.insert(0, newReport);
    return newReport;
  }

  // Lets personnel or admin change a report's status in the mock data.
  bool updateStatus(String reportId, ReportStatus newStatus) {
    final index = _reports.indexWhere((report) => report.id == reportId);

    if (index == -1) {
      return false;
    }

    _reports[index] = _reports[index].withStatus(newStatus);
    return true;
  }
}

// Makes a copy of a report with a new status while keeping its other details.
extension ReportStatusUpdate on Report {
  Report withStatus(ReportStatus newStatus) {
    return Report(
      id: id,
      title: title,
      description: description,
      purok: purok,
      category: category,
      status: newStatus,
      createdAt: createdAt,
      confidenceScore: confidenceScore,
      assignedDepartment: assignedDepartment,
    );
  }
}