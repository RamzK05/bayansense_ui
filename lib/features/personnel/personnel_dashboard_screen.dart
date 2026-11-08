import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../services/mock_report_service.dart';
import '../authentication/login_screen.dart';
import '../resident/report_details_screen.dart';

class PersonnelDashboardScreen extends StatefulWidget {
  final User? user;

  const PersonnelDashboardScreen({super.key, this.user});

  @override
  State<PersonnelDashboardScreen> createState() => _PersonnelDashboardScreenState();
}

class _PersonnelDashboardScreenState extends State<PersonnelDashboardScreen> {
  final MockReportService _service = MockReportService();
  List<Report> _reports = [];

  // Filter & Queue controls (0 = Department Queue, 1 = All Reports)
  int _selectedQueueTab = 0;
  ReportStatus? _filterStatus;
  ReportCategory? _filterCategory;
  String? _filterPurok;

  // Department name assigned to this personnel
  final String _departmentName = 'Infrastructure, Drainage & Flood Control';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _reports = _service.getAllReports();
    });
  }

  // Filter reports according to department scope and tab
  List<Report> get _displayedReports {
    return _reports.where((r) {
      // Tab 0: Department Queue (Drainage, Sewer, Flooding, Water Waste)
      if (_selectedQueueTab == 0) {
        if (r.category == ReportCategory.outOfScope) return false;
      }

      // Dropdown filters
      if (_filterStatus != null && r.status != _filterStatus) return false;
      if (_filterCategory != null && r.category != _filterCategory) return false;
      if (_filterPurok != null && r.purok != _filterPurok) return false;

      return true;
    }).toList();
  }

  int _countForQueueTab(int tabIndex) {
    if (tabIndex == 0) {
      return _reports.where((r) => r.category != ReportCategory.outOfScope).length;
    }
    return _reports.length;
  }

  // Opens the full ReportDetailsScreen and refreshes upon return
  void _openReportDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReportDetailsScreen(
          report: report,
          currentUser: widget.user,
        ),
      ),
    ).then((_) => _refresh());
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final staffName = widget.user?.name ?? 'Officer Maria Santos';

    return Scaffold(
      backgroundColor: AppTheme.paper,
      drawer: isDesktop ? null : _buildSidebar(staffName, isDrawer: true),
      body: Row(
        children: [
          if (isDesktop) SizedBox(width: 260, child: _buildSidebar(staffName)),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(staffName, isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroBanner(staffName),
                        const SizedBox(height: 24),
                        _buildSummaryStats(),
                        const SizedBox(height: 24),
                        _buildQueueTabs(),
                        const SizedBox(height: 16),
                        _buildFilterRow(),
                        const SizedBox(height: 16),
                        _buildManagementTable(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(String name, bool isDesktop) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.navy),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
          const Text(
            'Barangay Personnel Portal',
            style: TextStyle(color: AppTheme.navy, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.goldDeep.withValues(alpha: 0.3)),
            ),
            child: const Text('Department Responder', style: TextStyle(color: AppTheme.navy, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          CircleAvatar(
            backgroundColor: AppTheme.navy,
            radius: 18,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'P',
              style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(String name) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.line),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/barangay.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF1E3E62)),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0B192C).withValues(alpha: 0.72),
                    const Color(0xFF0B192C).withValues(alpha: 0.40),
                    Colors.black.withValues(alpha: 0.20),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B192C).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.gold.withValues(alpha: 0.7)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('✦', style: TextStyle(color: AppTheme.gold, fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 6),
                      Text(
                        'BARANGAY INFRASTRUCTURE RESPONSE OPERATIONS',
                        style: TextStyle(color: AppTheme.gold, fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Welcome, $name',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    shadows: [
                      Shadow(color: Colors.black.withValues(alpha: 0.6), offset: const Offset(0, 2), blurRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.apartment, color: AppTheme.gold, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Assigned Unit: $_departmentName',
                      style: const TextStyle(color: AppTheme.gold, fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Text(
                    'Review incoming citizen reports, verify incident locations, and update barangay resolution status.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 13.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(color: Colors.black.withValues(alpha: 0.5), offset: const Offset(0, 1.5), blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final sub = _service.countByStatus(ReportStatus.submitted);
    final rev = _service.countByStatus(ReportStatus.underReview);
    final prog = _service.countByStatus(ReportStatus.inProgress);
    final res = _service.countByStatus(ReportStatus.resolved);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 700;
        final tiles = [
          _statBox('Needs Review', sub, AppTheme.goldDeep, Icons.mark_email_unread_outlined),
          _statBox('Under Review', rev, const Color(0xFF0E5793), Icons.find_in_page_outlined),
          _statBox('Active Dispatches', prog, const Color(0xFF2A85FF), Icons.engineering_outlined),
          _statBox('Resolved Total', res, AppTheme.green, Icons.task_alt),
        ];

        if (isNarrow) {
          return Wrap(spacing: 12, runSpacing: 12, children: tiles);
        }
        return Row(
          children: tiles.map((t) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: t))).toList(),
        );
      },
    );
  }

  Widget _statBox(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF6B829D), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text('$count', style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800)),
            ],
          ),
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _queueTabButton(0, 'Department Queue', Icons.assignment_outlined),
          const SizedBox(width: 8),
          _queueTabButton(1, 'All Reports', Icons.list_alt_outlined),
        ],
      ),
    );
  }

  Widget _queueTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedQueueTab == index;
    final count = _countForQueueTab(index);

    return ElevatedButton.icon(
      onPressed: () => setState(() => _selectedQueueTab = index),
      icon: Icon(icon, size: 16),
      label: Row(
        children: [
          Text(label),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: isSelected ? AppTheme.navy : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF6B829D),
        side: BorderSide(color: isSelected ? AppTheme.navy : AppTheme.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
    );
  }

  Widget _buildFilterRow() {
    final puroks = ['Purok 1', 'Purok 2', 'Purok 3', 'Purok 4', 'Purok 5', 'Purok 6', 'Purok 7'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Filters:', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy, fontSize: 13)),

          DropdownButton<ReportStatus?>(
            value: _filterStatus,
            hint: const Text('Status: All', style: TextStyle(fontSize: 12)),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Status: All', style: TextStyle(fontSize: 12))),
              ...ReportStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12)))),
            ],
            onChanged: (v) => setState(() => _filterStatus = v),
          ),

          DropdownButton<ReportCategory?>(
            value: _filterCategory,
            hint: const Text('Category: All', style: TextStyle(fontSize: 12)),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Category: All', style: TextStyle(fontSize: 12))),
              ...ReportCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.label, style: const TextStyle(fontSize: 12)))),
            ],
            onChanged: (v) => setState(() => _filterCategory = v),
          ),

          DropdownButton<String?>(
            value: _filterPurok,
            hint: const Text('Location: All', style: TextStyle(fontSize: 12)),
            underline: const SizedBox(),
            items: [
              const DropdownMenuItem(value: null, child: Text('Location: All', style: TextStyle(fontSize: 12))),
              ...puroks.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))),
            ],
            onChanged: (v) => setState(() => _filterPurok = v),
          ),

          if (_filterStatus != null || _filterCategory != null || _filterPurok != null)
            TextButton.icon(
              icon: const Icon(Icons.clear, size: 16, color: AppTheme.red),
              label: const Text('Reset', style: TextStyle(color: AppTheme.red, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () {
                setState(() {
                  _filterStatus = null;
                  _filterCategory = null;
                  _filterPurok = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildManagementTable() {
    final list = _displayedReports;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedQueueTab == 0
                    ? 'Department Assigned Incidents'
                    : 'All Community Reports',
                style: const TextStyle(color: AppTheme.navy, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text('${list.length} reports listed', style: const TextStyle(color: Color(0xFF6B829D), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(child: Text('No reports found in this queue.', style: TextStyle(color: Color(0xFF6B829D)))),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      showCheckboxColumn: false,
                      columnSpacing: 24,
                      horizontalMargin: 16,
                      headingRowHeight: 46,
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 64,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF7FAFC)),
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.navy))),
                        DataColumn(label: Text('INCIDENT / DESCRIPTION', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.navy))),
                        DataColumn(label: Text('PUROK', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.navy))),
                        DataColumn(label: Text('AI CATEGORY', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.navy))),
                        DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppTheme.navy))),
                      ],
                      rows: list.map((r) {
                        return DataRow(
                          onSelectChanged: (_) => _openReportDetail(r),
                          cells: [
                            DataCell(Text(r.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 320),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      r.title,
                                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.navy),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      r.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B829D)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text(r.purok, style: const TextStyle(fontSize: 12))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_iconForCategory(r.category), size: 16, color: AppTheme.navy),
                                  const SizedBox(width: 6),
                                  Text(r.category.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            DataCell(_statusBadge(r.status)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _iconForCategory(ReportCategory category) {
    switch (category) {
      case ReportCategory.flooding:
        return Icons.flood;
      case ReportCategory.sewerProblem:
        return Icons.plumbing;
      case ReportCategory.cloggedDrainage:
      case ReportCategory.drainageProblem:
        return Icons.alt_route;
      case ReportCategory.waterWaste:
        return Icons.water_drop_outlined;
      case ReportCategory.outOfScope:
        return Icons.highlight_off_rounded;
    }
  }

  Widget _statusBadge(ReportStatus st) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Color(st.colorHex).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(st.colorHex).withValues(alpha: 0.3)),
      ),
      child: Text(
        st.label,
        style: TextStyle(color: Color(st.colorHex), fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildSidebar(String name, {bool isDrawer = false}) {
    return Container(
      color: AppTheme.navy,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('✦', style: TextStyle(color: AppTheme.gold, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: 8),
              Text('BayanSense', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 32),
          _sidebarItem(
            Icons.assignment_outlined,
            'Department Queue',
            isSelected: true,
          ),
          const Spacer(),
          const Divider(color: Color(0x33FFFFFF)),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.white70, size: 20),
              title: const Text('Sign out', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, {bool isSelected = false, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0x29E5A93C) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          leading: Icon(icon, color: isSelected ? AppTheme.gold : Colors.white70, size: 20),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}