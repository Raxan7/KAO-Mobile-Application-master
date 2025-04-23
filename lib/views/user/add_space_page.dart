import 'dart:io';
import 'dart:async';
// Add this import
import 'package:flutter/foundation.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Add this import
import '../../services/api_service.dart';
import '../../models/space_category.dart';
import 'spaces_list_page.dart'; // Import SpacesListPage

class AddSpacePage extends StatefulWidget {
  const AddSpacePage({super.key});

  @override
  _AddSpacePageState createState() => _AddSpacePageState();
}

class _AddSpacePageState extends State<AddSpacePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _getCurrentLocation();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          _showImagePicker = !_showImagePicker;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
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

  Future<void> _getCurrentLocation() async {
    // Implement location fetching similar to AddPropertyPage
    // This is a simplified version
    setState(() {
      _locationController.text = 'Current Location';
    });
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      // For web, use pickMultiImage and store as Uint8List
      final pickedFiles = await _picker.pickMultiImage();
      final imageBytes = await Future.wait(pickedFiles.map((file) async => await file.readAsBytes()));
      setState(() {
        _imageFiles.addAll(imageBytes);
      });
    } else {
      // For mobile, use pickImage and store as File
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      }
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
        final userName = prefs.getString('userName');
        final userEmail = prefs.getString('userEmail');
        final isLoggedIn = prefs.getBool('isLoggedIn');
        onThemeChanged() {} // Replace with the actual callback

        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found. Please log in again.')),
          );
          return;
        }

        final spaceData = {
          'user_id': userId,
          'category_id': _selectedCategory!.id,
          'subcategory_id': _selectedSubcategory!.id,
          'title': _titleController.text,
          'description': _descriptionController.text,
          'location': _locationController.text,
          'contact_info': _contactInfoController.text,
          'website_url': _websiteUrlController.text,
        };

        final response = await ApiService.addSpace(spaceData);
        if (response['status'] == 'success') {
          final spaceId = response['space_id'].toString();

          // Upload all selected images
          for (var imageFile in _imageFiles) {
            try {
              if (imageFile is File) {
                // Upload File directly
                await ApiService.uploadSpaceMedia(spaceId, 'image', imageFile.path, false);
              } else if (imageFile is Uint8List) {
                // Convert Uint8List to base64 string for web
                final base64Image = base64Encode(imageFile);
                await ApiService.uploadSpaceMedia(spaceId, 'image', base64Image, true);
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to upload image: $e')),
              );
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Space created successfully!')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpacesListPage(
                userId: userId,
                userName: userName,
                userEmail: userEmail,
                isLoggedIn: isLoggedIn ?? false, // Provide a default value for isLoggedIn
                onThemeChanged: onThemeChanged as Function(bool), // Explicitly cast to Function(bool)
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create space')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
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

              // Category Dropdown
              DropdownButtonFormField<SpaceCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<SpaceCategory>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                    _selectedSubcategory = null;
                    _filteredSubcategories = category?.subcategories ?? [];
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Subcategory Dropdown
              DropdownButtonFormField<SpaceSubcategory>(
                value: _selectedSubcategory,
                decoration: const InputDecoration(
                  labelText: 'Subcategory',
                  border: OutlineInputBorder(),
                ),
                items: _filteredSubcategories.map((subcategory) {
                  return DropdownMenuItem<SpaceSubcategory>(
                    value: subcategory,
                    child: Text(subcategory.name),
                  );
                }).toList(),
                onChanged: (subcategory) {
                  setState(() {
                    _selectedSubcategory = subcategory;
                  });
                },
                validator: (value) => value == null ? 'Please select a subcategory' : null,
              ),
              const SizedBox(height: 16),

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

              // Location
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_searching),
                    onPressed: _getCurrentLocation,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Contact Info
              TextFormField(
                controller: _contactInfoController,
                decoration: const InputDecoration(
                  labelText: 'Contact Information',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Website URL
              TextFormField(
                controller: _websiteUrlController,
                decoration: const InputDecoration(
                  labelText: 'Website URL (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),

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