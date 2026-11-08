import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user.dart';
import '../administrator/admin_dashboard_screen.dart';
import '../personnel/personnel_dashboard_screen.dart';
import '../resident/resident_dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _showFloatingError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFC0392B).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showFloatingError('Please fill in both your email and password.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(milliseconds: 650));

      final email = _emailCtrl.text.trim().toLowerCase();

      UserRole role = UserRole.resident;
      String name = 'Juan Dela Cruz';

      if (email.contains('admin')) {
        role = UserRole.admin;
        name = 'Admin Ramon Rivera';
      } else if (email.contains('personnel') || email.contains('staff')) {
        role = UserRole.personnel;
        name = 'Officer Maria Santos';
      }

      final user = User(
        id: 'usr-101',
        name: name,
        email: email,
        role: role,
        token: 'mock-jwt-token',
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (role == UserRole.admin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(adminEmail: user.email),
          ),
        );
      } else if (role == UserRole.personnel) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PersonnelDashboardScreen(user: user),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResidentDashboardScreen(user: user),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showFloatingError('Login failed. Please check your credentials.');
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailCtrl.text);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_reset, color: AppTheme.navy, size: 22),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reset Password',
              style: TextStyle(
                color: AppTheme.navy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered email address and we will send instructions to reset your account password.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: resetEmailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Registered email',
                hintText: 'resident@example.com',
                prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppTheme.navy),
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
                  borderSide: const BorderSide(color: AppTheme.navy, width: 1.6),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.navy,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset instructions sent to your email.'),
                  backgroundColor: AppTheme.green,
                ),
              );
            },
            child: const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  InputDecoration _glassInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 13,
      ),
      prefixIcon: Icon(prefixIcon, size: 20, color: AppTheme.gold),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.25),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFFF8E8E),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Full-screen background across both desktop panels and mobile
          Positioned.fill(
            child: Image.asset(
              'assets/barangay.jpg',
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F2B48), Color(0xFF1B4965)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // 2. Global darkening scrim so text & glass elements pop
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    const Color(0xFF061426).withValues(alpha: 0.65),
                    const Color(0xFF0B1E38).withValues(alpha: 0.55),
                    const Color(0xFF0B192C).withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
          ),

          // 3. Foreground content
          isDesktop
              ? Row(
                  children: [
                    // Left Side: Brand Seal, Info, Badges, and Status Line
                    Expanded(
                      flex: 11,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
                        child: _buildLeftContent(),
                      ),
                    ),
                    // Right Side: Frosted Glass Form Card in place
                    Expanded(
                      flex: 9,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                          child: _buildFormCard(),
                        ),
                      ),
                    ),
                  ],
                )
              : SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Column(
                        children: [
                          _buildMobileBrandHeader(),
                          const SizedBox(height: 24),
                          _buildFormCard(),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand seal & name
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.gold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Text(
                '✦',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'BayanSense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Barangay Civic Infrastructure System',
                  style: TextStyle(
                    color: Color(0xFFB8C7D9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),

        // Civic Eyebrow Pill
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.gold.withValues(alpha: 0.4)),
              ),
              child: const Text(
                'COMMUNITY ACTION & INCIDENT TRIAGE',
                style: TextStyle(
                  color: AppTheme.gold,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Title
        const Text(
          'Your barangay.\nYour voice in action.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            height: 1.12,
            letterSpacing: -0.6,
            shadows: [
              Shadow(
                color: Color(0x99000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: const Text(
            'Report flooding, clogged imburnal, sewer blocks, and water waste directly to responders with automated classification and status tracking.',
            style: TextStyle(
              color: Color(0xFFE2EBF5),
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w400,
              shadows: [
                Shadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 2)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Glassmorphism Badges
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _buildGlassBadge(Icons.psychology, 'Bisaya NLP Classifier'),
            _buildGlassBadge(Icons.alt_route, 'Auto Dept Routing'),
            _buildGlassBadge(Icons.shield_outlined, 'Purok Priority Queue'),
          ],
        ),
        const Spacer(),

        // Bottom status line with backdrop blur
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x8022C55E), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Barangay Dispatch Gateway Online',
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassBadge(IconData icon, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.gold, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileBrandHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text(
            '✦',
            style: TextStyle(
              color: AppTheme.gold,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'BayanSense',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Barangay Incident & Infrastructure Reporting',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.28),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 36,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.gold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'CIVIC PORTAL ACCESS',
                      style: TextStyle(
                        color: AppTheme.gold,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to your account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Submit concerns or track ongoing barangay reports.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),

                // Email Field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  decoration: _glassInputDecoration(
                    label: 'Email Address',
                    hint: 'name@example.com',
                    prefixIcon: Icons.mail_outline,
                  ),
                  validator: (val) => (val == null || !val.contains('@'))
                      ? 'Please enter a valid email address'
                      : null,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  decoration: _glassInputDecoration(
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (val) =>
                      (val == null || val.isEmpty) ? 'Password is required' : null,
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 20,
                          width: 20,
                          child: Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.white70),
                            child: Checkbox(
                              value: _rememberMe,
                              activeColor: AppTheme.gold,
                              checkColor: AppTheme.navy,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (val) => setState(() => _rememberMe = val ?? false),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                          child: Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _showForgotPasswordDialog,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.navy,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.navy),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                ),
                const SizedBox(height: 22),

                // Switch to Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New resident? ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          color: AppTheme.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
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
