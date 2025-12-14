import 'package:flutter/material.dart';
import '../services/profile_service.dart';
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
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Vibe'),
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
                  "What's your vibe?",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Select tags that describe you (optional)",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _availableTags.map((tag) => _buildTagChip(tag)).toList(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleComplete,
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
                          'Complete Profile',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _isLoading ? null : _handleComplete,
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

  Widget _buildTagChip(String tag) {
    final isSelected = _selectedTags.contains(tag);
    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedTags.add(tag);
          } else {
            _selectedTags.remove(tag);
          }
        });
      },
      backgroundColor: Colors.white.withOpacity(0.1),
      selectedColor: const Color(0xFFD946EF).withOpacity(0.5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFFA78BFA),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? const Color(0xFFD946EF) : const Color(0xFFA78BFA),
      ),
    );
  }
}
