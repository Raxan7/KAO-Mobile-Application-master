import 'dart:io';
import 'dart:async';
// Add this import
import 'package:flutter/foundation.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Add this import
// Import path_provider
import '../../services/api_service.dart';
import '../../models/space_category.dart';
import 'professional_page.dart';
import '../login_page.dart';

class AddSpacePage extends StatefulWidget {
  const AddSpacePage({super.key});

  @override
  _AddSpacePageState createState() => _AddSpacePageState();
}

class _AddSpacePageState extends State<AddSpacePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactInfoController = TextEditingController();
  final TextEditingController _websiteUrlController = TextEditingController();

  final List<dynamic> _imageFiles = []; // Use dynamic to handle both File and Uint8List
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  bool _showImagePicker = true;
  Timer? _timer;

  // Category and subcategory selection
  List<SpaceCategory> _categories = [];
  SpaceCategory? _selectedCategory;
  SpaceSubcategory? _selectedSubcategory;
  List<SpaceSubcategory> _filteredSubcategories = [];

  final Map<String, String> _categoryMapping = {
    'Home': '0',
    'Education': '1',
    'Creators & Designers': '2',
    'Technology': '3',
    'News': '4',
    'Discover': '5',
  };

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Check login status
    _loadCategories();
    _loadProfessionalData(); // Load professional data
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          _showImagePicker = !_showImagePicker;
        });
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _contactInfoController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.fetchSpaceCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Future<void> _loadProfessionalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoryId = prefs.getString('category_id');
      final location = prefs.getString('business_location');
      final websiteUrl = prefs.getString('business_website');
      final contactInfo = prefs.getString('business_phone'); // Fetch contact info

      print('Fetched category ID: ${_categoryMapping[categoryId]}'); // Debugging print statement

      if (categoryId != null) {
        // Ensure categories are loaded before accessing them
        if (_categories.isEmpty) {
          await _loadCategories();
        }

        setState(() {
          final categoryName = _categoryMapping[categoryId];
          _selectedCategory = _categories.firstWhere((category) => category.id == categoryName);
          _filteredSubcategories = _selectedCategory?.subcategories ?? [];
          _websiteUrlController.text = websiteUrl ?? '';
          _contactInfoController.text = contactInfo ?? ''; // Set contact info
        });

        print('Mapped category ID: ${_categoryMapping[_selectedCategory?.name ?? '']}'); // Debugging print statement
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load professional data: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      for (var pickedFile in pickedFiles) {
        if (kIsWeb) {
          // For web
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _imageFiles.add(bytes);
          });
        } else {
          // For mobile
          setState(() {
            _imageFiles.add(File(pickedFile.path));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _imageFiles.removeAt(index);
    });
  }

  Future<void> _addSpace() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null || _selectedSubcategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category and subcategory')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId');
        
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found. Please log in again.')),
          );
          return;
        }

        // Prepare space data
        final spaceData = {
          'user_id': userId,
          'category_id': _selectedCategory!.id,
          'subcategory_id': _selectedSubcategory!.id,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'contact_info': _contactInfoController.text,
          'website_url': _websiteUrlController.text,
        };

        // Add space
        final response = await ApiService.addSpace(spaceData);
        if (response['status'] == 'success') {
          final spaceId = response['space_id'].toString();

          // Upload images
          for (var i = 0; i < _imageFiles.length; i++) {
            try {
              final isThumbnail = i == 0; // First image as thumbnail
              await ApiService.uploadSpaceMedia(
                spaceId,
                'image',
                _imageFiles[i], // Pass the file data directly
                isThumbnail,
              );
            } catch (e) {
              print('Error uploading image ${i + 1}: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload image ${i + 1}: ${e.toString()}')),
              );
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Space created successfully!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfessionalPage(), // Navigate to ProfessionalPage
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create space')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
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
        title: const Text('Create New Space'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Informational Space',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              // Subcategory Dropdown
              DropdownButtonFormField<SpaceSubcategory>(
                decoration: const InputDecoration(
                  labelText: 'Subcategory',
                  border: OutlineInputBorder(),
                ),
                value: _selectedSubcategory,
                items: _filteredSubcategories.map((subcategory) {
                  return DropdownMenuItem(
                    value: subcategory,
                    child: Text(subcategory.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSubcategory = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a subcategory' : null,
              ),
              const SizedBox(height: 16),

              // Image Picker
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: ElevatedButton.icon(
                    key: ValueKey(_showImagePicker),
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Add Image'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Display selected images
              if (_imageFiles.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    final image = _imageFiles[index];
                    return Stack(
                      children: [
                        image is Uint8List
                            ? Image.memory(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              )
                            : Image.file(
                                image as File,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: const CircleAvatar(
                              backgroundColor: Colors.red,
                              radius: 12,
                              child: Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),

              // Submit Button
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _addSpace,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Create Space'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}