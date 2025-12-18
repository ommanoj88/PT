import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'profile_bio_screen.dart';

/// Screen 2: "Looking For" selection
class ProfileLookingForScreen extends StatefulWidget {
  final String name;
  final String gender;

  const ProfileLookingForScreen({
    super.key,
    required this.name,
    required this.gender,
  });

  @override
  State<ProfileLookingForScreen> createState() => _ProfileLookingForScreenState();
}

class _ProfileLookingForScreenState extends State<ProfileLookingForScreen> {
  String? _selectedLookingFor;

  void _handleContinue() {
    if (_selectedLookingFor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select who you are looking for')),
      );
      return;
    }

    HapticFeedback.lightImpact();

    Navigator.of(context).push(
      FadeSlidePageRoute(
        page: ProfileBioScreen(
          name: widget.name,
          gender: widget.gender,
          lookingFor: _selectedLookingFor!,
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
                  "I'm looking for...",
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Hey ${widget.name}, who would you like to meet?',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),
                _buildOption('Men', Icons.male, colorScheme, textTheme),
                const SizedBox(height: AppTheme.spacing12),
                _buildOption('Women', Icons.female, colorScheme, textTheme),
                const SizedBox(height: AppTheme.spacing12),
                _buildOption('Couples', Icons.people, colorScheme, textTheme),
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

  Widget _buildOption(
    String label,
    IconData icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final isSelected = _selectedLookingFor == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedLookingFor = label.toLowerCase();
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
