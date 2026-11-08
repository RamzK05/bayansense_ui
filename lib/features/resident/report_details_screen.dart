import 'package:flutter/material.dart';
import '../../models/report.dart';
import '../../models/user.dart';
import '../../services/mock_report_service.dart';

class ReportDetailsScreen extends StatefulWidget {
  final Report report;
  final User? currentUser;

  const ReportDetailsScreen({
    super.key,
    required this.report,
    this.currentUser,
  });

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  static const Color _navy = Color(0xFF144370);
  static const Color _paper = Color(0xFFF4F6F9);
  static const Color _line = Color(0xFFDDE3EA);

  late Report _report;
  bool _isUpdating = false;
  bool _hasUpdated = false;

  bool get _canUpdateStatus {
    if (widget.currentUser == null) return false;
    return widget.currentUser!.role == UserRole.personnel ||
        widget.currentUser!.role == UserRole.admin;
  }

  @override
  void initState() {
    super.initState();
    _report = widget.report;
  }

  Future<void> _handleStatusChange(ReportStatus newStatus) async {
    if (newStatus == _report.status) return;

    setState(() => _isUpdating = true);

    final success = MockReportService().updateStatus(_report.id, newStatus);

    if (mounted) {
      setState(() {
        _isUpdating = false;
        if (success) {
          _report = _report.copyWith(status: newStatus);
          _hasUpdated = true; // Noted pero dili usa mag-show og notification dinhi
        }
      });
    }
  }

  void _handleDone() {
    final messenger = ScaffoldMessenger.of(context);
    final statusLabel = _report.status.label;
    final wasUpdated = _hasUpdated;

    // Mo-close una balik sa Dashboard
    Navigator.pop(context);

    // Mo-gawas ang notification sa Dashboard human mapislit ang Done
    if (wasUpdated) {
      _showFloatingNotification(
        messenger,
        'Status Updated',
        'Report is now marked as $statusLabel.',
      );
    }
  }

  void _showFloatingNotification(
    ScaffoldMessengerState messenger,
    String title,
    String message,
  ) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        duration: const Duration(seconds: 3),
        content: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA7F3D0), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.10),
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
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: const TextStyle(
                            fontSize: 13,
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
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
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
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _report.id,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 18),
                _buildDetailsCard(),
                const SizedBox(height: 18),
                _buildClassifierCard(),
                if (_canUpdateStatus) ...[
                  const SizedBox(height: 18),
                  _buildStaffActionCard(),
                ],
                const SizedBox(height: 24),

                // Bottom Done Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _handleDone,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: _line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _navy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final statusColor = Color(_report.status.colorHex);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08144370),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _report.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _report.status.label,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _report.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _navy,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B829D)),
              const SizedBox(width: 4),
              Text(
                _report.purok,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B829D),
                ),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6B829D)),
              const SizedBox(width: 4),
              Text(
                _report.dateSubmitted,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B829D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CITIZEN REPORT DESCRIPTION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF6B829D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _report.description,
            style: const TextStyle(
              fontSize: 14,
              color: _navy,
              height: 1.6,
            ),
          ),
          const Divider(height: 32, color: _line),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Color(0xFF6B829D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _report.category.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                    Text(
                      _report.category.bisayaHint,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8A9BA8),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ASSIGNED DEPARTMENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: Color(0xFF6B829D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _report.assignedDepartment ?? 'Unassigned',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_report.category == ReportCategory.outOfScope) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Clean-water supply issues are outside barangay scope and must be forwarded to the local Water District.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClassifierCard() {
    final confidence = _report.confidenceScore;
    final percent = confidence != null ? (confidence * 100).toStringAsFixed(0) : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, size: 20, color: Color(0xFF0E5793)),
              const SizedBox(width: 8),
              const Text(
                'AI Classifier Advisory (Bisaya Model)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const Spacer(),
              if (percent != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$percent% match',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Predictions are experimental and generated from Bisaya text patterns. Personnel should verify on-site conditions before taking final action.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffActionCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESPONDER ACTIONS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF6B829D),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Update Status: ',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<ReportStatus>(
                  initialValue: _report.status,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _line),
                    ),
                  ),
                  items: ReportStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status.label,
                        style: TextStyle(
                          color: Color(status.colorHex),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _isUpdating ? null : (val) => val != null ? _handleStatusChange(val) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
