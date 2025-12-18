import 'package:flutter/material.dart';
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

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileBioScreen(
          name: widget.name,
          gender: widget.gender,
          lookingFor: _selectedLookingFor!,
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
                  "I'm looking for...",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hey ${widget.name}, who would you like to meet?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
                _buildOption('Men', Icons.male),
                const SizedBox(height: 12),
                _buildOption('Women', Icons.female),
                const SizedBox(height: 12),
                _buildOption('Couples', Icons.people),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String label, IconData icon) {
    final isSelected = _selectedLookingFor == label.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLookingFor = label.toLowerCase();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD946EF).withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD946EF) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFA78BFA), size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFFD946EF)),
          ],
        ),
      ),
    );
  }
}
