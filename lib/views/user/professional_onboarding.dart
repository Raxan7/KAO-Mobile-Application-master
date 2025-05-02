import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:kao_app/services/api_service.dart';
import 'package:kao_app/views/user/professional_page.dart'; // Import the ProfessionalPage
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data'; // For web image bytes

class ProfessionalOnboarding extends StatefulWidget {
  final int userId;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const ProfessionalOnboarding({
    super.key,
    required this.userId,
    this.onComplete,
    this.onSkip,
  });

  @override
  _ProfessionalOnboardingState createState() => _ProfessionalOnboardingState();
}

class _ProfessionalOnboardingState extends State<ProfessionalOnboarding> {
  final ApiService _apiService = ApiService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _industryCategory = 'Other';
  File? _companyLogo;
  Uint8List? _webImageBytes;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _companyLogo = null; // Don't use File on web
        });
      } else {
        setState(() {
          _companyLogo = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<void> _completeOnboarding() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // Unfocus any focused text field
    FocusScope.of(context).unfocus();

    // Validate form
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _isSubmitting = false);
      return;
    }

    try {
      String? logoUrl;
      if (_companyLogo != null) {
        try {
          final uploadResult = await _apiService.uploadBusinessLogo(
            widget.userId,
            _companyLogo!,
          );
          logoUrl = uploadResult['url'];
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading logo: $e')),
          );
          setState(() => _isSubmitting = false);
          return;
        }
      }

      final businessProfile = {
        'action': 'create',
        'user_id': widget.userId.toString(),
        'business_name': _nameController.text.trim(),
        'business_email': _emailController.text.trim(),
        'business_phone': _phoneController.text.trim(),
        'industry_category': _industryCategory,
        'business_location': _locationController.text.trim(),
        'company_description': _descriptionController.text.trim(),
        if (logoUrl != null) 'company_logo': logoUrl,
      };

      final response = await _apiService.createBusinessProfile(
        widget.userId,
        businessProfile,
      );

      if (response['success'] == true) {
        // Mark onboarding as completed in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_professional_onboarding', true);

        // Force navigation to ProfessionalPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProfessionalPage()),
          (route) => false, // Remove all previous routes
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server error: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Profile Setup'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : widget.onSkip ?? () {
              // Default skip behavior
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ProfessionalPage()),
                (route) => false,
              );
            },
            child: const Text('Skip', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Business Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Basic information about your business', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Business Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) return 'Required field';
                    if (!value!.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Business Phone *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.trim().isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Industry Category *',
                    border: OutlineInputBorder(),
                  ),
                  value: _industryCategory,
                  items: [
                    'Creators & Designers', 'Education', 'Technology', 'News', 'Other'
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _industryCategory = value ?? 'Other'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Please select an industry' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Business Location *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.trim().isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Company Description *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) => value?.trim().isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: kIsWeb && _webImageBytes != null
                        ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                        : _companyLogo != null
                            ? Image.file(_companyLogo!, fit: BoxFit.cover)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 40),
                                  Text('Tap to upload logo'),
                                ],
                              ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}