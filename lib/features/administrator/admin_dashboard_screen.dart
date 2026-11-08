import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../services/mock_report_service.dart';
import '../authentication/login_screen.dart';
import '../resident/report_details_screen.dart'; 

// Model for Barangay Personnel (matching /admin/personnel requirements)
class PersonnelMember {
  final String id;
  final String fullName;
  final String email;
  final String department;
  final String role;
  final bool isActive;

  PersonnelMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
    required this.role,
    this.isActive = true,
  });
}

class AdminDashboardScreen extends StatefulWidget {
  final User? user;
  final String? adminEmail;

  const AdminDashboardScreen({
    super.key,
    this.user,
    this.adminEmail,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final MockReportService _reportService = MockReportService();

  // Navigation state: 0 = Overview, 1 = All Reports, 2 = Personnel, 3 = Categories & System
  int _selectedNavIndex = 0;

  // Filter states for Reports tab
  String _selectedStatusFilter = 'All';
  String _selectedDeptFilter = 'All';

  // Mock list of Barangay Personnel (GET /admin/personnel)
  final List<PersonnelMember> _personnelList = [
    PersonnelMember(
      id: 'PER-001',
      fullName: 'Engr. Marco Santos',
      email: 'marco.santos@barangay.gov.ph',
      department: 'Drainage & Flood Control',
      role: 'Field Supervisor',
    ),
    PersonnelMember(
      id: 'PER-002',
      fullName: 'Maria Elena Reyes',
      email: 'maria.reyes@barangay.gov.ph',
      department: 'Sanitation & Sewer',
      role: 'Inspector',
    ),
    PersonnelMember(
      id: 'PER-003',
      fullName: 'Danilo Cruz',
      email: 'danilo.cruz@barangay.gov.ph',
      department: 'Drainage & Flood Control',
      role: 'Field Technician',
    ),
    PersonnelMember(
      id: 'PER-004',
      fullName: 'Aileen Tan',
      email: 'aileen.tan@barangay.gov.ph',
      department: 'Sanitation & Sewer',
      role: 'Response Officer',
    ),
  ];

  // Colors
  static const Color navyPrimary = Color(0xFF0D2240);
  static const Color navySurface = Color(0xFF162D4A);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color bgLight = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 900;
    final allReports = _reportService.getAllReports();

    return Scaffold(
      backgroundColor: bgLight,
      drawer: isWide ? null : _buildDrawer(allReports),
      appBar: AppBar(
        backgroundColor: navyPrimary,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: goldAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: goldAccent),
              ),
              child: const Text(
                'ADMIN PORTAL',
                style: TextStyle(
                  color: goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'BayanSense',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // Clean "Admin" role badge in top-right
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: goldAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: goldAccent.withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, size: 15, color: goldAccent),
                  SizedBox(width: 6),
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWide) SizedBox(width: 250, child: _buildSidebar(allReports)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildCurrentTab(allReports),
            ),
          ),
        ],
      ),
    );
  }

  // --- CURRENT ACTIVE TAB ROUTING ---
  Widget _buildCurrentTab(List<Report> allReports) {
    switch (_selectedNavIndex) {
      case 0:
        return _buildOverviewTab(allReports);
      case 1:
        return _buildReportsTab(allReports);
      case 2:
        return _buildPersonnelTab();
      case 3:
        return _buildSystemSettingsTab();
      default:
        return _buildOverviewTab(allReports);
    }
  }

  // --- TAB 1: OVERVIEW & STATS ---
  Widget _buildOverviewTab(List<Report> allReports) {
    final pendingCount = allReports.where((r) => r.status == ReportStatus.submitted || r.status == ReportStatus.underReview).length;
    final inProgressCount = allReports.where((r) => r.status == ReportStatus.inProgress).length;
    final resolvedCount = allReports.where((r) => r.status == ReportStatus.resolved).length;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Executive Summary',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Barangay infrastructure incident metrics, departmental load, and staffing.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // Stat Cards Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMetricCard(
                title: 'Total Reports',
                value: allReports.length.toString(),
                icon: Icons.assignment_outlined,
                color: Colors.indigo,
              ),
              _buildMetricCard(
                title: 'Pending Review',
                value: pendingCount.toString(),
                icon: Icons.hourglass_top,
                color: Colors.orange,
              ),
              _buildMetricCard(
                title: 'In Progress',
                value: inProgressCount.toString(),
                icon: Icons.engineering_outlined,
                color: Colors.blue,
              ),
              _buildMetricCard(
                title: 'Resolved',
                value: resolvedCount.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              _buildMetricCard(
                title: 'Active Staff',
                value: _personnelList.length.toString(),
                icon: Icons.badge_outlined,
                color: goldAccent,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Department Breakdown Section
          const Text(
            'Departmental Workload',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDepartmentCards(allReports),

          const SizedBox(height: 28),

          // Recent 5 Reports Table Preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Citizen Submissions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navyPrimary,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
                onPressed: () => setState(() => _selectedNavIndex = 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildReportsTable(allReports.take(5).toList()),
        ],
      ),
    );
  }

  // --- TAB 2: ALL REPORTS MASTER TABLE ---
  Widget _buildReportsTab(List<Report> allReports) {
    var filtered = allReports.where((r) {
      final matchesStatus = _selectedStatusFilter == 'All' || r.status.label == _selectedStatusFilter;
      final matchesDept = _selectedDeptFilter == 'All' || r.assignedDepartment == _selectedDeptFilter;
      return matchesStatus && matchesDept;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Master Incident Reports',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: navyPrimary,
                  ),
                ),
                Text(
                  'Total ${filtered.length} reports matching active filters',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyPrimary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Status: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    DropdownButton<String>(
                      value: _selectedStatusFilter,
                      underline: const SizedBox(),
                      items: [
                        'All',
                        ...ReportStatus.values.map((s) => s.label),
                      ]
                          .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedStatusFilter = val ?? 'All'),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Department: ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    DropdownButton<String>(
                      value: _selectedDeptFilter,
                      underline: const SizedBox(),
                      items: [
                        'All',
                        'Drainage & Flood Control',
                        'Sanitation & Sewer',
                        'Water District / External',
                        'Unassigned',
                      ]
                          .map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedDeptFilter = val ?? 'All'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(child: SingleChildScrollView(child: _buildReportsTable(filtered))),
      ],
    );
  }

  // --- TAB 3: PERSONNEL MANAGEMENT (GET /admin/personnel) ---
  Widget _buildPersonnelTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Barangay Personnel Roster',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: navyPrimary,
                  ),
                ),
                Text(
                  'Manage field staff, inspectors, and department assignments.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: navyPrimary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Add Staff'),
              onPressed: _showAddPersonnelDialog,
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListView.separated(
              itemCount: _personnelList.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final staff = _personnelList[index];  
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: navyPrimary.withValues(alpha: 0.1),
                    child: const Icon(Icons.badge, color: navyPrimary),
                  ),
                  title: Row(
                    children: [
                      Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: staff.isActive ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: staff.isActive ? Colors.green : Colors.red),
                        ),
                        child: Text(
                          staff.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: staff.isActive ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text('${staff.role} • ${staff.department}\n${staff.email}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'toggle') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Updated status for ${staff.fullName}')),
                        );
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit Assignment')),
                      const PopupMenuItem(value: 'toggle', child: Text('Toggle Status')),
                    ],
                  ),
                  isThreeLine: true,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 4: CATEGORIES & INFRASTRUCTURE OVERVIEW ---
  Widget _buildSystemSettingsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Barangay Infrastructure & Categories',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navyPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Official taxonomy mapped to barangay response units based on handoff rules.',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Incident Categories',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ...ReportCategory.values.map((c) {
                    final isOutOfScope = c == ReportCategory.outOfScope;
                    String dept = 'Drainage & Flood Control';
                    if (c == ReportCategory.sewerProblem || c == ReportCategory.waterWaste) {
                      dept = 'Sanitation & Sewer';
                    } else if (isOutOfScope) {
                      dept = 'Water District / External';
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isOutOfScope ? Icons.info_outline : Icons.check_circle_outline,
                        color: isOutOfScope ? Colors.orange : Colors.green,
                      ),
                      title: Text(c.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${c.bisayaHint}\nMapped Unit: $dept'),
                      isThreeLine: true,
                      trailing: Chip(
                        label: Text(isOutOfScope ? 'Out of Scope' : 'In Scope', style: const TextStyle(fontSize: 11)),
                        backgroundColor: isOutOfScope ? Colors.orange.shade50 : Colors.green.shade50,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology, color: Colors.blue, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'XLM-RoBERTa Classifier Status',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 15),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Currently configured for Bisaya text inputs. Predictions remain advisory and subject to field personnel validation before action.',
                          style: TextStyle(fontSize: 12.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- METRIC CARD WIDGET ---
  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // --- DEPARTMENT CARDS ---
  Widget _buildDepartmentCards(List<Report> allReports) {
    final drainageCount = allReports.where((r) => r.assignedDepartment == 'Drainage & Flood Control').length;
    final sewerCount = allReports.where((r) => r.assignedDepartment == 'Sanitation & Sewer').length;

    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Drainage & Flood Control',
                    style: TextStyle(fontWeight: FontWeight.bold, color: navyPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$drainageCount Active ${drainageCount == 1 ? "Report" : "Reports"}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Covers: Flooding, Clogged/Damaged Canal drainage', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sanitation & Sewerage',
                    style: TextStyle(fontWeight: FontWeight.bold, color: navyPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$sewerCount Active ${sewerCount == 1 ? "Report" : "Reports"}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Covers: Sewer overflowing, Wastewater runoff', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MASTER REPORTS TABLE ---
  Widget _buildReportsTable(List<Report> reports) {
    if (reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: const Text('No incident reports match current criteria.'),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          showCheckboxColumn: false,
          columnSpacing: 18,
          horizontalMargin: 16,
          headingRowColor: WidgetStateProperty.all(navyPrimary.withValues(alpha: 0.04)),
          columns: const [
            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Purok', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: reports.map((r) {
            return DataRow(
              onSelectChanged: (_) => _openReportDetails(r),
              cells: [
                DataCell(Text(r.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 180),
                    child: Text(r.title, overflow: TextOverflow.ellipsis),
                  ),
                ),
                DataCell(Text(r.category.label)),
                DataCell(Text(r.assignedDepartment ?? 'Unassigned')),
                DataCell(Text(r.purok)),
                DataCell(_buildStatusBadge(r.status)),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.visibility, size: 18, color: navyPrimary),
                    tooltip: 'View Report Details',
                    onPressed: () => _openReportDetails(r),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(status.colorHex).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(status.colorHex).withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: Color(status.colorHex),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // --- REPORT DETAILS NAVIGATION ---
  void _openReportDetails(Report report) async {
    final effectiveUser = widget.user ??
        User(
          id: 'ADM-001',
          name: 'Barangay Administrator',
          email: widget.adminEmail ?? 'admin@bayansense.gov.ph',
          role: UserRole.admin,
        );

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(
          report: report,
          currentUser: effectiveUser,
        ),
      ),
    );

    if (result == true || mounted) {
      setState(() {});
    }
  }

  // --- ADD PERSONNEL DIALOG ---
  void _showAddPersonnelDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Field Inspector');
    String department = 'Drainage & Flood Control';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Barangay Personnel'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Official Email'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: department,
                  decoration: const InputDecoration(labelText: 'Assigned Department'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Drainage & Flood Control',
                      child: Text('Drainage & Flood Control'),
                    ),
                    DropdownMenuItem(
                      value: 'Sanitation & Sewer',
                      child: Text('Sanitation & Sewer'),
                    ),
                  ],
                  onChanged: (val) => setDialogState(() => department = val ?? department),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleCtrl,
                  decoration: const InputDecoration(labelText: 'Designation / Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: navyPrimary, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && emailCtrl.text.isNotEmpty) {
                  setState(() {
                    _personnelList.add(
                      PersonnelMember(
                        id: 'PER-00${_personnelList.length + 1}',
                        fullName: nameCtrl.text.trim(),
                        email: emailCtrl.text.trim(),
                        department: department,
                        role: roleCtrl.text.trim(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Staff'),
            ),
          ],
        ),
      ),
    );
  }

  // --- SIDEBAR / DRAWER WIDGETS ---
  Widget _buildSidebar(List<Report> allReports) {
    return Container(
      color: navySurface,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildNavTile(index: 0, icon: Icons.dashboard, title: 'Overview'),
          _buildNavTile(index: 1, icon: Icons.assignment, title: 'All Reports'),
          _buildNavTile(index: 2, icon: Icons.people, title: 'Personnel'),
          _buildNavTile(index: 3, icon: Icons.category, title: 'Categories & Scope'),
          const Spacer(),
          const Divider(color: Colors.white24),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70),
              title: const Text('Sign out', style: TextStyle(color: Colors.white70)),
              onTap: _handleSignOut,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavTile({required int index, required IconData icon, required String title}) {
    final bool isSelected = _selectedNavIndex == index;
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isSelected ? goldAccent : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        tileColor: isSelected ? Colors.white.withValues(alpha: 0.1) : null,
        onTap: () {
          setState(() => _selectedNavIndex = index);
        },
      ),
    );
  }

  Widget _buildDrawer(List<Report> allReports) {
    return Drawer(child: _buildSidebar(allReports));
  }

  void _handleSignOut() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
