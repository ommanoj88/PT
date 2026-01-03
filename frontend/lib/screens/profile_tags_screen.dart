import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';

/// Screen for selecting kinks/tags - "Select Your Vibe"
class ProfileTagsScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String lookingFor;
  final String? bio;

  const ProfileTagsScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.lookingFor,
    this.bio,
  });

  @override
  State<ProfileTagsScreen> createState() => _ProfileTagsScreenState();
}

class _ProfileTagsScreenState extends State<ProfileTagsScreen> {
  final Set<String> _selectedTags = {};
  bool _isLoading = false;

  // Available tags/kinks
  static const List<String> _availableTags = [
    'Dom',
    'Sub',
    'Switch',
    'NSA',
    'FWB',
    'ONS',
    'Roleplay',
    'Adventure',
    'Casual',
    'Serious',
    'Open-minded',
    'Discreet',
    'Traveler',
    'Foodie',
    'Night Owl',
    'Fitness',
  ];

  Future<void> _handleComplete() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      // Save profile with all data
      await ProfileService.updateProfile(
        name: widget.name,
        gender: widget.gender,
        lookingFor: widget.lookingFor,
        bio: widget.bio,
        tags: _selectedTags.toList(),
      );

      if (mounted) {
        // Navigate to home screen
        Navigator.of(context).pushAndRemoveUntil(
          FadeSlidePageRoute(page: const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
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
      appBar: AppBar(
        title: Text('Select Your Vibe', style: textTheme.headlineSmall),
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
                  "What's your vibe?",
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Select tags that describe you (optional)',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: AppTheme.spacing8,
                      runSpacing: AppTheme.spacing8,
                      children: _availableTags
                          .map((tag) => _buildTagChip(tag, colorScheme, textTheme))
                          .toList(),
                    ),
                  ),
                ),
                PremiumButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  isLoading: _isLoading,
                  gradient: AppTheme.primaryGradient,
                  child: Text(
                    'Complete Profile',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                TextButton(
                  onPressed: _isLoading ? null : _handleComplete,
                  child: Text(
                    'Skip for now',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
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

  Widget _buildTagChip(String tag, ColorScheme colorScheme, TextTheme textTheme) {
    final isSelected = _selectedTags.contains(tag);
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          if (isSelected) {
            _selectedTags.remove(tag);
          } else {
            _selectedTags.add(tag);
          }
        });
      },
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppTheme.accentRed.withOpacity(0.5),
                    AppTheme.accentRedDark.withOpacity(0.5),
                  ],
                )
              : null,
          color: isSelected ? null : colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check, color: Colors.white, size: 16),
              const SizedBox(width: AppTheme.spacing4),
            ],
            Text(
              tag,
              style: textTheme.labelLarge?.copyWith(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
