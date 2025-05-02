import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:kao_app/views/user/professional_onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kao_app/views/user/add_space_page.dart';

class ProfessionalPage extends StatefulWidget {
  const ProfessionalPage({super.key});

  @override
  _ProfessionalPageState createState() => _ProfessionalPageState();
}

class _ProfessionalPageState extends State<ProfessionalPage> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _businessProfile;
  bool _isLoading = true;
  String _username = "User";
  bool _showOnboarding = false;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    print('Loading professional profile data...');
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('name') ?? "User";
      final userIdString = prefs.getString('userId');
      _userId = userIdString != null ? int.tryParse(userIdString)?.toString() : null;
      print('User ID from shared prefs: $_userId');
    });

    if (_userId == null) {
      print('No user ID found, cannot load profile');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      print('Checking if business profile exists for user $_userId');
      final hasProfile = await _apiService.checkBusinessProfileExists(int.parse(_userId!));
      print('Profile exists check result: $hasProfile');

      if (!hasProfile) {
        final hasSeenOnboarding = prefs.getBool('has_seen_professional_onboarding') ?? false;
        print('User has seen onboarding: $hasSeenOnboarding');
        if (mounted) {
          setState(() {
            _showOnboarding = !hasSeenOnboarding;
          });
        }
        if (_showOnboarding) {
          print('Showing onboarding screen');
          return;
        }
      }

      print('Fetching business profile for user $_userId');
      final profile = await _apiService.getBusinessProfile(int.parse(_userId!));
      print('Received profile data: $profile');
      
      if (mounted) {
        setState(() {
          _businessProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      if (!e.toString().contains('Business profile not found')) {
        print('Non-profile-not-found error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BusinessProfileEditScreen(
          userId: int.parse(_userId!),
          businessProfile: _businessProfile ?? {},
        ),
      ),
    );
    if (result == true) await _loadData();
  }

  Future<void> _skipOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_professional_onboarding', true);
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return ProfessionalOnboarding(
        userId: int.parse(_userId!),
        onComplete: () async => await _loadData(),
        onSkip: _skipOnboarding,
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'Authentication Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please login to access professional features',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          _businessProfile?['business_name'] ?? 'Professional',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          if (_businessProfile != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _editProfile,
            ),
        ],
      ),
      body: _businessProfile == null ? _buildEmptyState() : _buildProfileContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.business, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'No Professional Profile',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Set up your professional profile to access all features',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => setState(() => _showOnboarding = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Set Up Profile'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe Later'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                if (_businessProfile?['company_logo'] != null)
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(_businessProfile!['company_logo']),
                  )
                else
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.business, size: 40, color: Colors.white),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _businessProfile?['business_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _businessProfile?['industry_category'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _businessProfile?['company_description'] ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Contact',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.grey),
                      title: Text(_businessProfile?['business_email'] ?? ''),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone, color: Colors.grey),
                      title: Text(_businessProfile?['business_phone'] ?? ''),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.grey),
                      title: Text(_businessProfile?['business_location'] ?? ''),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildMenuItem(
            Icons.add_circle_outline,
            'Add Property',
            'Create new listing',
            Colors.red,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddSpacePage()),
            ),
          ),
          _buildMenuItem(
            Icons.inbox,
            'Inbox',
            'View messages',
            Colors.blue,
            onTap: () {},
          ),
          _buildMenuItem(
            Icons.settings,
            'Settings',
            'Configure profile',
            Colors.orange,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}

class BusinessProfileEditScreen extends StatefulWidget {
  final int userId;
  final Map<String, dynamic> businessProfile;

  const BusinessProfileEditScreen({
    super.key,
    required this.userId,
    required this.businessProfile,
  });

  @override
  _BusinessProfileEditScreenState createState() => _BusinessProfileEditScreenState();
}

class _BusinessProfileEditScreenState extends State<BusinessProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  String? _industryCategory;
  File? _newLogo;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.businessProfile['business_name'] ?? '');
    _emailController = TextEditingController(text: widget.businessProfile['business_email'] ?? '');
    _phoneController = TextEditingController(text: widget.businessProfile['business_phone'] ?? '');
    _locationController = TextEditingController(text: widget.businessProfile['business_location'] ?? '');
    _descriptionController = TextEditingController(text: widget.businessProfile['company_description'] ?? '');
    _industryCategory = widget.businessProfile['industry_category'];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newLogo = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      String? logoUrl = widget.businessProfile['company_logo'];
      if (_newLogo != null) {
        final uploadResult = await _apiService.uploadBusinessLogo(widget.userId, _newLogo!);
        logoUrl = uploadResult['url'];
      }

      final updatedProfile = {
        'business_name': _nameController.text,
        'business_email': _emailController.text,
        'business_phone': _phoneController.text,
        'industry_category': _industryCategory,
        'business_location': _locationController.text,
        'company_description': _descriptionController.text,
        'company_logo': logoUrl,
      };

      final response = await _apiService.updateBusinessProfile(widget.userId, updatedProfile);
      if (response['success']) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final industryCategories = [
      'Creators & Designers',
      'Education',
      'Technology',
      'News',
      'Other'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _newLogo != null
                    ? FileImage(_newLogo!)
                    : widget.businessProfile['company_logo'] != null
                        ? NetworkImage(widget.businessProfile['company_logo'])
                        : null,
                child: _newLogo == null && widget.businessProfile['company_logo'] == null
                    ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Business Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Business Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Industry',
                border: OutlineInputBorder(),
              ),
              value: _industryCategory,
              items: industryCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) => setState(() => _industryCategory = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}