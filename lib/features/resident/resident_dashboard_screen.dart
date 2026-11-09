
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../services/mock_report_service.dart';
import '../authentication/login_screen.dart';
import '../resident/report_details_screen.dart';
import 'submit_report_dialog.dart';

class ResidentDashboardScreen extends StatefulWidget {
  final User? user;

  const ResidentDashboardScreen({super.key, this.user});

  @override
  State<ResidentDashboardScreen> createState() =>
      _ResidentDashboardScreenState();
}

class _ResidentDashboardScreenState extends State<ResidentDashboardScreen> {
  final MockReportService _service = MockReportService();

  List<Report> _reports = [];
  int _selectedNavIndex = 0;
  ReportStatus? _filterStatus;

  late String _currentName;
  String _currentPurok = 'Purok 1';
  String _currentPhone = '0912 345 6789';

  @override
  void initState() {
    super.initState();
    _currentName = widget.user?.name ?? 'Juan Dela Cruz';
    _refresh();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _reports = _service.getAllReports();
    });
  }

  void _openReportDetails(Report report) {
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

  void _openSubmitDialog([ReportCategory? category]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => SubmitReportDialog(initialCategory: category),
    );

    if (result == true && mounted) {
      _refresh();
      _showAppNotification(
        title: 'Report Submitted',
        message:
            'Your concern was recorded and sent for automated barangay review.',
      );
    }
  }

  void _showProfileDialog() {
    final nameCtrl = TextEditingController(text: _currentName);
    final phoneCtrl = TextEditingController(text: _currentPhone);
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    String selectedPurok = _currentPurok;
    bool showPasswordSection = false;
    bool obscureCurrentPass = true;
    bool obscureNewPass = true;
    bool obscureConfirmPass = true;
    String? passwordError;

    final purokOptions = [
      'Purok 1',
      'Purok 2',
      'Purok 3',
      'Purok 4',
      'Purok 5',
      'Purok 6',
      'Purok 7',
    ];

    if (!purokOptions.contains(selectedPurok)) {
      selectedPurok = purokOptions.first;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
          actionsPadding: const EdgeInsets.all(16),
          title: const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppTheme.navy, size: 22),
              SizedBox(width: 8),
              Text(
                'Resident Profile',
                style: TextStyle(
                  color: AppTheme.navy,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6FB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4E2F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.navy,
                          child: Text(
                            _currentName.isNotEmpty
                                ? _currentName[0].toUpperCase()
                                : 'R',
                            style: const TextStyle(
                              color: AppTheme.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentName,
                                style: const TextStyle(
                                  color: AppTheme.navy,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.user?.email ?? 'resident@test.com',
                                style: const TextStyle(
                                  color: Color(0xFF6B829D),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Verified Resident • Barangay Central',
                                  style: TextStyle(
                                    color: AppTheme.navy,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'BASIC INFORMATION',
                    style: TextStyle(
                      color: AppTheme.goldDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: AppTheme.inputDecoration(
                      label: 'Full Name',
                      hint: 'Juan Dela Cruz',
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppTheme.navy,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: AppTheme.inputDecoration(
                      label: 'Contact Number',
                      hint: '09XX XXX XXXX',
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: AppTheme.navy,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPurok,
                    decoration: AppTheme.inputDecoration(
                      label: 'Purok / Zone',
                      hint: 'Select your purok',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.navy,
                        size: 20,
                      ),
                    ),
                    items: purokOptions
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              p,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedPurok = val);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setDialogState(() {
                              showPasswordSection = !showPasswordSection;
                              passwordError = null;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.navy,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Security & Password',
                                        style: TextStyle(
                                          color: AppTheme.navy,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Update your login credentials',
                                        style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  showPasswordSection
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: const Color(0xFF64748B),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showPasswordSection) ...[
                          const Divider(
                            height: 1,
                            color: Color(0xFFE2E8F0),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (passwordError != null) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFFECACA),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          color: Color(0xFFEF4444),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            passwordError!,
                                            style: const TextStyle(
                                              color: Color(0xFFB91C1C),
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                TextFormField(
                                  controller: currentPassCtrl,
                                  obscureText: obscureCurrentPass,
                                  decoration: AppTheme.inputDecoration(
                                    label: 'Current Password',
                                    hint: 'Enter existing password',
                                    prefixIcon: const Icon(
                                      Icons.key_outlined,
                                      color: AppTheme.navy,
                                      size: 20,
                                    ),
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureCurrentPass
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      onPressed: () => setDialogState(
                                        () => obscureCurrentPass =
                                            !obscureCurrentPass,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: newPassCtrl,
                                  obscureText: obscureNewPass,
                                  decoration: AppTheme.inputDecoration(
                                    label: 'New Password',
                                    hint: 'At least 6 characters',
                                    prefixIcon: const Icon(
                                      Icons.lock_reset,
                                      color: AppTheme.navy,
                                      size: 20,
                                    ),
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureNewPass
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      onPressed: () => setDialogState(
                                        () => obscureNewPass = !obscureNewPass,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: confirmPassCtrl,
                                  obscureText: obscureConfirmPass,
                                  decoration: AppTheme.inputDecoration(
                                    label: 'Confirm New Password',
                                    hint: 'Re-enter new password',
                                    prefixIcon: const Icon(
                                      Icons.check_circle_outline,
                                      color: AppTheme.navy,
                                      size: 20,
                                    ),
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureConfirmPass
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        size: 18,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                      onPressed: () => setDialogState(
                                        () => obscureConfirmPass =
                                            !obscureConfirmPass,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF6B829D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                final newName = nameCtrl.text.trim();
                final newPhone = phoneCtrl.text.trim();

                if (newName.isEmpty) return;

                bool passwordChanged = false;

                if (showPasswordSection &&
                    (currentPassCtrl.text.isNotEmpty ||
                        newPassCtrl.text.isNotEmpty ||
                        confirmPassCtrl.text.isNotEmpty)) {
                  if (currentPassCtrl.text.isEmpty) {
                    setDialogState(
                      () => passwordError =
                          'Please enter your current password.',
                    );
                    return;
                  }

                  if (newPassCtrl.text.length < 6) {
                    setDialogState(
                      () => passwordError =
                          'New password must be at least 6 characters.',
                    );
                    return;
                  }

                  if (newPassCtrl.text != confirmPassCtrl.text) {
                    setDialogState(
                      () => passwordError = 'New passwords do not match.',
                    );
                    return;
                  }

                  passwordChanged = true;
                }

                setState(() {
                  _currentName = newName;
                  _currentPhone = newPhone;
                  _currentPurok = selectedPurok;
                });

                Navigator.pop(ctx);

                _showAppNotification(
                  title: passwordChanged
                      ? 'Profile & Password Updated'
                      : 'Profile Updated',
                  message: passwordChanged
                      ? 'Your profile information and password were saved successfully.'
                      : 'Your name, contact number, and purok have been saved.',
                );
              },
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      currentPassCtrl.dispose();
      newPassCtrl.dispose();
      confirmPassCtrl.dispose();
    });
  }

  void _showAppNotification({
    required String title,
    required String message,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(
          bottom: 24,
          left: 20,
          right: 20,
        ),
        duration: const Duration(seconds: 3),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFA7F3D0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF475569),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => messenger.hideCurrentSnackBar(),
                    borderRadius: BorderRadius.circular(16),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final name = _currentName;

    return Scaffold(
      backgroundColor: AppTheme.paper,
      drawer: isDesktop ? null : _buildSidebar(isDrawer: true),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 260,
              child: _buildSidebar(),
            ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(name, isDesktop),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(screenWidth < 500 ? 16 : 24),
                    child: _selectedNavIndex == 0
                        ? _buildDashboardView(name)
                        : _buildMyReportsView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardView(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHero(name),
        const SizedBox(height: 24),
        _buildStatCards(),
        const SizedBox(height: 28),
        _buildQuickCategoryGrid(),
        const SizedBox(height: 28),
        _buildReportsTable(
          title: 'Recent Submitted Reports',
          showViewAll: true,
        ),
        const SizedBox(height: 24),
        _buildWaterDistrictNotice(),
      ],
    );
  }

  Widget _buildMyReportsView() {
    final filtered = _filterStatus == null
        ? _reports
        : _reports.where((r) => r.status == _filterStatus).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 500;

            return Flex(
              direction: compact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Submitted Reports',
                      style: TextStyle(
                        color: AppTheme.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track your incidents and barangay response updates.',
                      style: TextStyle(
                        color: Color(0xFF6B829D),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (compact) const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _openSubmitDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'New Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.navy,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('All (${_reports.length})', null),
              const SizedBox(width: 8),
              _filterChip('Submitted', ReportStatus.submitted),
              const SizedBox(width: 8),
              _filterChip('Under Review', ReportStatus.underReview),
              const SizedBox(width: 8),
              _filterChip('In Progress', ReportStatus.inProgress),
              const SizedBox(width: 8),
              _filterChip('Resolved', ReportStatus.resolved),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildReportsTable(customList: filtered),
      ],
    );
  }

  Widget _filterChip(String label, ReportStatus? status) {
    final isSelected = _filterStatus == status;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filterStatus = status),
      selectedColor: AppTheme.gold.withValues(alpha: 0.3),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppTheme.goldDeep : AppTheme.line,
      ),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.navy : const Color(0xFF6B829D),
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        fontSize: 12,
      ),
    );
  }

  Widget _buildTopBar(String name, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 430;

        return Container(
          height: 70,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppTheme.line),
            ),
          ),
          child: Row(
            children: [
              if (!isDesktop)
                Builder(
                  builder: (ctx) => IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.menu,
                      color: AppTheme.navy,
                    ),
                    onPressed: () => Scaffold.of(ctx).openDrawer(),
                  ),
                ),
              Expanded(
                child: Text(
                  _selectedNavIndex == 0
                      ? 'Resident Portal'
                      : 'My Reports',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontSize: compact ? 15 : 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (compact)
                IconButton(
                  tooltip: 'Submit Report',
                  onPressed: () => _openSubmitDialog(),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.navy,
                  ),
                  icon: const Icon(Icons.add, size: 20),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _openSubmitDialog(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text(
                    'Submit Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.navy,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _showProfileDialog,
                borderRadius: BorderRadius.circular(18),
                child: CircleAvatar(
                  backgroundColor: AppTheme.navy,
                  radius: 18,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'R',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHero(String name) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 500;

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
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFF1E3E62),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF0B192C).withValues(alpha: 0.65),
                        const Color(0xFF0B192C).withValues(alpha: 0.35),
                        Colors.black.withValues(alpha: 0.15),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 16 : 28,
                  vertical: compact ? 20 : 26,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B192C)
                            .withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.gold.withValues(alpha: 0.7),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '✦',
                            style: TextStyle(
                              color: AppTheme.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'BARANGAY ENVIRONMENTAL & INFRASTRUCTURE REPORTING SYSTEM',
                              style: TextStyle(
                                color: AppTheme.gold,
                                fontSize: compact ? 8 : 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: compact ? 0.3 : 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Maayong adlaw, $name!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 21 : 25,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: Text(
                        'Report road flooding, clogged imburnal, broken canals, and wastewater issues directly to barangay responders with automated dispatch.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: compact ? 12 : 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(0, 1.5),
                              blurRadius: 3,
                            ),
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
      },
    );
  }

  Widget _buildStatCards() {
    final sub = _service.countByStatus(ReportStatus.submitted);
    final rev = _service.countByStatus(ReportStatus.underReview);
    final prog = _service.countByStatus(ReportStatus.inProgress);
    final res = _service.countByStatus(ReportStatus.resolved);

    return LayoutBuilder(
      builder: (context, constraints) {
        final useGrid = constraints.maxWidth < 700;

        if (useGrid) {
          final cardWidth = (constraints.maxWidth - 12) / 2;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: cardWidth,
                child: _statTile(
                  'Submitted',
                  sub,
                  AppTheme.goldDeep,
                  Icons.send_outlined,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: _statTile(
                  'Under Review',
                  rev,
                  const Color(0xFF0E5793),
                  Icons.visibility_outlined,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: _statTile(
                  'In Progress',
                  prog,
                  const Color(0xFF2A85FF),
                  Icons.engineering_outlined,
                ),
              ),
              SizedBox(
                width: cardWidth,
                child: _statTile(
                  'Resolved',
                  res,
                  AppTheme.green,
                  Icons.check_circle_outline,
                ),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _statTile(
                'Submitted',
                sub,
                AppTheme.goldDeep,
                Icons.send_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statTile(
                'Under Review',
                rev,
                const Color(0xFF0E5793),
                Icons.visibility_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statTile(
                'In Progress',
                prog,
                const Color(0xFF2A85FF),
                Icons.engineering_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statTile(
                'Resolved',
                res,
                AppTheme.green,
                Icons.check_circle_outline,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _statTile(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B829D),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 16,
            child: Icon(icon, color: color, size: 18),
          ),
        ],
      ),
    );
  }

  // Updated responsive Quick Incident Reporting grid.
  Widget _buildQuickCategoryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Incident Reporting',
          style: TextStyle(
            color: AppTheme.navy,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 650;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isNarrow ? 2 : 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: isNarrow ? 132 : 120,
              ),
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return _catCard(
                      'Flooding',
                      'Baha / Taas tubig',
                      Icons.flood,
                      ReportCategory.flooding,
                    );
                  case 1:
                    return _catCard(
                      'Sewer Problem',
                      'Kanal / Imburnal',
                      Icons.plumbing,
                      ReportCategory.sewerProblem,
                    );
                  case 2:
                    return _catCard(
                      'Drainage Issue',
                      'Barado o guba',
                      Icons.alt_route,
                      ReportCategory.cloggedDrainage,
                    );
                  default:
                    return _catCard(
                      'Water Waste',
                      'Gaawas nga tubo',
                      Icons.water_drop_outlined,
                      ReportCategory.waterWaste,
                    );
                }
              },
            );
          },
        ),
      ],
    );
  }

  // Updated category card with flexible text wrapping.
  Widget _catCard(
    String title,
    String subtitle,
    IconData icon,
    ReportCategory cat,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openSubmitDialog(cat),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.line),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: AppTheme.goldDeep,
                size: 22,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B829D),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportsTable({
    String? title,
    bool showViewAll = false,
    List<Report>? customList,
  }) {
    final list = customList ?? _reports;

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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                title ?? 'Submitted Reports',
                style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (showViewAll)
                TextButton(
                  onPressed: () {
                    setState(() => _selectedNavIndex = 1);
                  },
                  child: const Text(
                    'View all →',
                    style: TextStyle(
                      color: Color(0xFF0E5793),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  '${list.length} total',
                  style: const TextStyle(
                    color: Color(0xFF6B829D),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'No reports found.',
                  style: TextStyle(
                    color: Color(0xFF6B829D),
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF7FAFC),
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'INCIDENT / TITLE',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'PUROK',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'AI CATEGORY',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                ],
                rows: list.map((r) {
                  return DataRow(
                    onSelectChanged: (_) => _openReportDetails(r),
                    cells: [
                      DataCell(
                        Text(
                          r.id,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      DataCell(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              r.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppTheme.navy,
                              ),
                            ),
                            Text(
                              r.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B829D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      DataCell(
                        Text(
                          r.purok,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      DataCell(
                        Row(
                          children: [
                            Text(
                              r.category.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (r.confidenceScore != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '(${(r.confidenceScore! * 100).toInt()}%)',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF6B829D),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      DataCell(_statusBadge(r.status)),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusBadge(ReportStatus st) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Color(st.colorHex).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(st.colorHex).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        st.label,
        style: TextStyle(
          color: Color(st.colorHex),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildWaterDistrictNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4E2F0),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF0E5793),
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Notice: Tap water supply concerns (no water, low pressure, supplier interruptions) are handled directly by the Water District, not the barangay.',
              style: TextStyle(
                color: Color(0xFF0E5793),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({bool isDrawer = false}) {
    return Container(
      color: AppTheme.navy,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '✦',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'BayanSense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _sidebarItem(
            Icons.dashboard_outlined,
            'Dashboard',
            isSelected: _selectedNavIndex == 0,
            onTap: () {
              setState(() => _selectedNavIndex = 0);
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _sidebarItem(
            Icons.assignment_outlined,
            'My Reports',
            isSelected: _selectedNavIndex == 1,
            onTap: () {
              setState(() => _selectedNavIndex = 1);
              if (isDrawer) Navigator.pop(context);
            },
          ),
          _sidebarItem(
            Icons.person_outline,
            'Profile',
            isSelected: false,
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              _showProfileDialog();
            },
          ),
          const Spacer(),
          const Divider(color: Color(0x33FFFFFF)),
          Material(
            color: Colors.transparent,
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.white70,
                size: 20,
              ),
              title: const Text(
                'Sign out',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0x29E5A93C)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          leading: Icon(
            icon,
            color: isSelected ? AppTheme.gold : Colors.white70,
            size: 20,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight:
                  isSelected ? FontWeight.w800 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
