import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'profile_looking_for_screen.dart';

/// Screen 1: Name & Gender selection
class ProfileNameGenderScreen extends StatefulWidget {
  const ProfileNameGenderScreen({super.key});

  @override
  State<ProfileNameGenderScreen> createState() => _ProfileNameGenderScreenState();
}

class _ProfileNameGenderScreenState extends State<ProfileNameGenderScreen> {
  final _nameController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your gender')),
      );
      return;
    }

    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      FadeSlidePageRoute(
        page: ProfileLookingForScreen(
          name: name,
          gender: _selectedGender!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile', style: textTheme.headlineSmall),
        backgroundColor: colorScheme.secondaryContainer,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "What's your name?",
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.spacing16),
                TextFormField(
                  controller: _nameController,
                  style: textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),
                Text(
                  'I am a...',
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.spacing16),
                _buildGenderOption('Male', Icons.male, colorScheme, textTheme),
                const SizedBox(height: AppTheme.spacing12),
                _buildGenderOption('Female', Icons.female, colorScheme, textTheme),
                const SizedBox(height: AppTheme.spacing12),
                _buildGenderOption('Non-Binary', Icons.transgender, colorScheme, textTheme),
                const Spacer(),
                PremiumButton(
                  onPressed: _handleContinue,
                  gradient: AppTheme.primaryGradient,
                  child: Text(
                    'Continue',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    String label,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedGender == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedGender = label.toLowerCase();
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.all(AppTheme.spacing16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.accentPurple.withOpacity(0.3),
                    AppTheme.accentFuchsia.withOpacity(0.3),
                  ],
                )
              : null,
          color: isSelected ? null : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.secondary, size: 28),
            const SizedBox(width: AppTheme.spacing16),
            Text(
              label,
              style: textTheme.titleMedium,
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
