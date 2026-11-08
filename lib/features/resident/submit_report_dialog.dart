import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../services/mock_report_service.dart';

class SubmitReportDialog extends StatefulWidget {
  final ReportCategory? initialCategory;

  const SubmitReportDialog({super.key, this.initialCategory});

  @override
  State<SubmitReportDialog> createState() => _SubmitReportDialogState();
}

class _SubmitReportDialogState extends State<SubmitReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _purokCtrl = TextEditingController();

  bool _isSubmitting = false;

  final List<String> _puroks = [
    'Purok 1',
    'Purok 2',
    'Purok 3',
    'Purok 4',
    'Purok 5',
    'Purok 6',
  ];

  @override
  void initState() {
    super.initState();
    _purokCtrl.text = _puroks.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _purokCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Submits the raw text to MockReportService.
    // The service runs its keyword heuristic to simulate the XLM-RoBERTa classifier.
    await MockReportService().submitReport(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      purok: _purokCtrl.text.trim(),
      chosenCategory: widget.initialCategory, // null allows auto-classification
    );

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.gold.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.report_problem_outlined,
                            color: AppTheme.goldDeep,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Submit Barangay Report',
                          style: TextStyle(
                            color: AppTheme.navy,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B829D)),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Describe your infrastructure concern. Our system automatically categorizes and routes it to the responding department.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),

                // AI Routing Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: Color(0xFF16A34A), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Automated AI Classification',
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'You can write in Bisaya or English. The system detects flooding, drainage, sewer, or water waste issues automatically.',
                              style: TextStyle(
                                color: Color(0xFF166534),
                                fontSize: 11,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Location / Purok
                const Text(
                  'LOCATION / PUROK',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _purokCtrl.text,
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Select Purok',
                    prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppTheme.navy),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.navy, width: 1.5),
                    ),
                  ),
                  items: _puroks
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, style: const TextStyle(fontSize: 13, color: AppTheme.navy)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _purokCtrl.text = val);
                  },
                ),
                const SizedBox(height: 16),

                // Report Title
                const Text(
                  'SHORT TITLE',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Barado nga imburnal atbang sa kapilya',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.navy, width: 1.5),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),

                // Description (Bisaya / English)
                const Text(
                  'DETAILS (DESKRIPSYON SA HITABO)',
                  style: TextStyle(
                    color: AppTheme.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'I-esplikar ang problema (Bisaya o English pwede). Pananglit: "Kusog ang baha dapit sa eskina kay barado ang kanal..."',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.navy, width: 1.5),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 6) ? 'Please provide at least 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Clean-Water Supply Notice (Section 10 of handoff)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F6FB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4E2F0)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF0E5793), size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: Drinking water supply issues (e.g. no tap water, low pressure) are handled by the Water District, not barangay personnel.',
                          style: TextStyle(color: Color(0xFF0E5793), fontSize: 11, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.gold,
                        foregroundColor: AppTheme.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy),
                            )
                          : const Text(
                              'Submit Report',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}