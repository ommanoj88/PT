import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'profile_tags_screen.dart';

/// Screen for photo upload (mock - converts to Base64)
class ProfilePhotoScreen extends StatefulWidget {
  final String name;
  final String gender;
  final String lookingFor;
  final String? bio;

  const ProfilePhotoScreen({
    super.key,
    required this.name,
    required this.gender,
    required this.lookingFor,
    this.bio,
  });

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _photos = []; // Base64 encoded photos
  final List<String> _photoPaths = []; // For display
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    if (_photos.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 photos allowed')),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64String = base64Encode(bytes);
        
        setState(() {
          _photos.add(base64String);
          _photoPaths.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.secondaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              ListTile(
                leading: Icon(Icons.camera_alt, color: colorScheme.secondary),
                title: Text('Camera', style: textTheme.bodyLarge),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: colorScheme.secondary),
                title: Text('Gallery', style: textTheme.bodyLarge),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _photos.removeAt(index);
      _photoPaths.removeAt(index);
    });
  }

  Future<void> _handleContinue() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isLoading = true;
    });

    try {
      // Save photos to profile
      if (_photos.isNotEmpty) {
        await ProfileService.updateProfile(photos: _photos);
      }

      if (mounted) {
        Navigator.of(context).push(
          FadeSlidePageRoute(
            page: ProfileTagsScreen(
              name: widget.name,
              gender: widget.gender,
              lookingFor: widget.lookingFor,
              bio: widget.bio,
            ),
          ),
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
        title: Text('Add Photos', style: textTheme.headlineSmall),
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
                  'Add your best photos',
                  style: textTheme.headlineLarge,
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Add up to 3 photos to showcase yourself',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppTheme.spacing12,
                      mainAxisSpacing: AppTheme.spacing12,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      if (index < _photoPaths.length) {
                        return _buildPhotoTile(index, colorScheme);
                      }
                      return _buildAddPhotoTile(colorScheme, textTheme);
                    },
                  ),
                ),
                PremiumButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  isLoading: _isLoading,
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
                  onPressed: _isLoading ? null : _handleContinue,
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

  Widget _buildPhotoTile(int index, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            image: DecorationImage(
              image: FileImage(File(_photoPaths[index])),
              fit: BoxFit.cover,
            ),
            border: Border.all(color: colorScheme.outline),
          ),
        ),
        Positioned(
          top: AppTheme.spacing4,
          right: AppTheme.spacing4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacing4),
              decoration: BoxDecoration(
                color: colorScheme.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoTile(ColorScheme colorScheme, TextTheme textTheme) {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: colorScheme.secondary,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: colorScheme.secondary, size: 32),
            const SizedBox(height: AppTheme.spacing8),
            Text(
              'Add Photo',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
