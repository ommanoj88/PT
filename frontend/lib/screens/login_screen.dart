import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';

/// Login screen for user authentication.
/// Accepts phone number and email for mock authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate that at least one field is filled
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (phone.isEmpty && email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your phone number or email';
      });
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.login(
        phone: phone.isNotEmpty ? phone : null,
        email: email.isNotEmpty ? email : null,
      );

      if (mounted) {
        // Navigate to home screen on successful login
        Navigator.of(context).pushReplacement(
          FadeSlidePageRoute(page: const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo and Title
                        _buildLogo(colorScheme),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          'VibeCheck',
                          textAlign: TextAlign.center,
                          style: textTheme.displayMedium,
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          'The Privacy-First High-Intent Dating App',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing48),

                        // Phone Input
                        _buildInputField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: AppTheme.spacing16),

                        // OR Divider
                        _buildDivider(colorScheme),
                        const SizedBox(height: AppTheme.spacing16),

                        // Email Input
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email address',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          colorScheme: colorScheme,
                        ),
                        const SizedBox(height: AppTheme.spacing24),

                        // Error Message
                        AnimatedContainer(
                          duration: AppTheme.durationMedium,
                          height: _errorMessage != null ? null : 0,
                          child: _errorMessage != null
                              ? _buildErrorMessage(colorScheme)
                              : const SizedBox.shrink(),
                        ),
                        if (_errorMessage != null)
                          const SizedBox(height: AppTheme.spacing16),

                        // Get Started Button
                        PremiumButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          isLoading: _isLoading,
                          gradient: AppTheme.primaryGradient,
                          child: Text(
                            'Get Started',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing24),

                        // Privacy Note
                        Text(
                          'By continuing, you agree to our Terms of Service and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 80,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 120),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.favorite,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required ColorScheme colorScheme,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: colorScheme.outline),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
          child: Text(
            'OR',
            style: TextStyle(color: colorScheme.secondary),
          ),
        ),
        Expanded(
          child: Divider(color: colorScheme.outline),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppTheme.spacing12),
      backgroundColor: colorScheme.error.withOpacity(0.15),
      borderColor: colorScheme.error.withOpacity(0.3),
      enableBlur: false,
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
