import 'package:flutter/material.dart';
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
    final bio = _bioController.text.trim();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfilePhotoScreen(
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'),
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
                  "Tell us about yourself",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Write a short bio to let others know who you are (optional)",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _bioController,
                  maxLength: 200,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "I'm a...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    counterStyle: const TextStyle(color: Color(0xFFA78BFA)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF)),
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946EF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _handleContinue,
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
}
