import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1B4B),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFA78BFA)),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFA78BFA)),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
      _photoPaths.removeAt(index);
    });
  }

  Future<void> _handleContinue() async {
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
          MaterialPageRoute(
            builder: (context) => ProfileTagsScreen(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photos'),
        backgroundColor: const Color(0xFF6B21A8),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add your best photos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add up to 3 photos to showcase yourself',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      if (index < _photoPaths.length) {
                        return _buildPhotoTile(index);
                      }
                      return _buildAddPhotoTile();
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: const Color(0xFFD946EF).withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading ? null : _handleContinue,
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(color: Color(0xFFA78BFA)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoTile(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: FileImage(File(_photoPaths[index])),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removePhoto(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoTile() {
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFA78BFA),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Color(0xFFA78BFA), size: 32),
            SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(color: Color(0xFFA78BFA), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
