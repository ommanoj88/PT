import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'profile_photo_screen.dart';

/// Screen 3: Bio input (Max 200 chars)
class ProfileBioScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String lookingFor;

  const ProfileBioScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.lookingFor,
  });

  @override
  State<ProfileBioScreen> createState() => _ProfileBioScreenState();
}

class _ProfileBioScreenState extends State<ProfileBioScreen> {
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    HapticFeedback.lightImpact();
    final bio = _bioController.text.trim();

    Navigator.of(context).push(
      FadeSlidePageRoute(
        page: ProfilePhotoScreen(
          name: widget.name,
          gender: widget.gender,
          lookingFor: widget.lookingFor,
          bio: bio.isNotEmpty ? bio : null,
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
                  'Tell us about yourself',
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Write a short bio to let others know who you are (optional)',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                TextFormField(
                  controller: _bioController,
                  maxLength: 200,
                  maxLines: 5,
                  style: textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: "I'm a...",
                    counterStyle: textTheme.bodySmall?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
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
                const SizedBox(height: AppTheme.spacing12),
                TextButton(
                  onPressed: _handleContinue,
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
}
