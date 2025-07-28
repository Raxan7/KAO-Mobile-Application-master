import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kao_app/views/dalali/dalali_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../widgets/dalali/dalali_navigation_drawer.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  _AddPropertyPageState createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _descriptionAndFeatureController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _status;

  // Media files
  final List<File> _imageFiles = []; // List to store multiple image files
  File? _videoFile;
  
  // Upload options
  String _mediaUploadMode = 'both'; // Options: 'image', 'video', 'both'

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Fetch location automatically on page load
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _roomsController.dispose();
    _descriptionAndFeatureController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled. Please enable them.'),
        ),
      );
      return;
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied. Cannot fetch location.'),
        ),
      );
      return;
    }

    // Fetch the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Decode the position to an address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        final String address = '${place.street}, ${place.locality}, ${place.country}';
        setState(() {
          _locationController.text = address;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get address from location.'),
        ),
      );
    }
  }

  // Handle image picking
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFiles.add(File(pickedFile.path)); // Add the new image to the list
      }
    });
  }

  // Remove an image at a specific index
  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index); // Remove the image at the specified index
    });
  }

  // Handle video picking
  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5), // Limit to 5 minutes
    );
    setState(() {
      if (pickedFile != null) {
        _videoFile = File(pickedFile.path);
      }
    });
  }
  
  // Remove the video
  void _removeVideo() {
    setState(() {
      _videoFile = null;
    });
  }
  
  // Set media upload mode
  void _setMediaUploadMode(String mode) {
    setState(() {
      _mediaUploadMode = mode;
      
      // Clear files if needed based on the selected mode
      if (mode == 'image') {
        _videoFile = null;
      } else if (mode == 'video') {
        _imageFiles.clear();
      }
    });
  }
  
  // UI element for upload mode selection
  Widget _buildUploadOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Choose Upload Mode:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildUploadModeCard(
                icon: Icons.image,
                title: 'Image Only',
                selected: _mediaUploadMode == 'image',
                onTap: () => _setMediaUploadMode('image'),
              ),
              const SizedBox(width: 12),
              _buildUploadModeCard(
                icon: Icons.videocam,
                title: 'Video Only',
                selected: _mediaUploadMode == 'video',
                onTap: () => _setMediaUploadMode('video'),
              ),
              const SizedBox(width: 12),
              _buildUploadModeCard(
                icon: Icons.perm_media,
                title: 'Both',
                selected: _mediaUploadMode == 'both',
                onTap: () => _setMediaUploadMode('both'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UI card for upload mode selection
  Widget _buildUploadModeCard({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UI for image preview
  Widget _buildImagePreview() {
    if (_imageFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Image Preview:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFiles.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_imageFiles[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 15,
                    top: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // UI for video preview
  Widget _buildVideoPreview() {
    if (_videoFile == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Video Preview:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_file,
                    size: 48,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video Selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    _videoFile!.path.split('/').last,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: GestureDetector(
                onTap: _removeVideo,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Handle property submission
  Future<void> _addProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show the loader
      });

      try {
        // Retrieve user details from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('userId');
        if (userId == null || userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found. Please log in again.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Property data preparation
        final propertyData = {
          'user_id': userId,
          'title': _titleController.text,
          'description': _descriptionAndFeatureController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'property_size': int.tryParse(_sizeController.text) ?? 0,
          'number_of_rooms': int.tryParse(_roomsController.text) ?? 0,
          'status': _status ?? '',
          'location': _locationController.text,
        };

        // API call to add property
        final response = await ApiService.addProperty(propertyData);
        if (response['status'] == 'success') {
          final propertyId = response['property_id'];

          // Upload all selected images if mode allows
          if ((_mediaUploadMode == 'image' || _mediaUploadMode == 'both') && _imageFiles.isNotEmpty) {
            for (var imageFile in _imageFiles) {
              await ApiService.uploadPropertyMedia(
                  propertyId.toString(), 'image', imageFile.path, false);
            }
          }
          
          // Upload video if available and mode allows
          if ((_mediaUploadMode == 'video' || _mediaUploadMode == 'both') && _videoFile != null) {
            await ApiService.uploadPropertyMedia(
                propertyId.toString(), 'video', _videoFile!.path, false);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property added successfully!')),
          );

          // Navigate to the dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DalaliDashboard(userId: int.parse(userId)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add property')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loader when done
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
        backgroundColor: Colors.teal,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      drawer: DalaliNavigationDrawer(
        onLogout: () {
          // Logout functionality
        },
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Property Title',
                        prefixIcon: Icon(Icons.home),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Size
                    TextFormField(
                      controller: _sizeController,
                      decoration: const InputDecoration(
                        labelText: 'Size (sq ft)',
                        prefixIcon: Icon(Icons.square_foot),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the size';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Number of Rooms
                    TextFormField(
                      controller: _roomsController,
                      decoration: const InputDecoration(
                        labelText: 'Number of Rooms',
                        prefixIcon: Icon(Icons.meeting_room),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of rooms';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    TextFormField(
                      controller: _descriptionAndFeatureController,
                      decoration: const InputDecoration(
                        labelText: 'Description and Features',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixIcon: Icon(Icons.monetization_on),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Location
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: const Icon(Icons.location_on),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Status
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info),
                        border: OutlineInputBorder(),
                      ),
                      value: _status,
                      items: ['For Sale', 'For Rent', 'For Lease']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _status = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Media Upload Options
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Add Media Files',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Upload mode selection
                          _buildUploadOptionSelector(),
                          
                          const SizedBox(height: 16),
                          
                          // Upload buttons based on selected mode
                          Row(
                            children: [
                              if (_mediaUploadMode == 'image' || _mediaUploadMode == 'both')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('Add Images'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF0D47A1),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              if (_mediaUploadMode == 'both')
                                const SizedBox(width: 12),
                              if (_mediaUploadMode == 'video' || _mediaUploadMode == 'both')
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickVideo,
                                    icon: const Icon(Icons.videocam),
                                    label: const Text('Add Video'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF0D47A1),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          
                          // Image preview section
                          if ((_mediaUploadMode == 'image' || _mediaUploadMode == 'both') && _imageFiles.isNotEmpty)
                            _buildImagePreview(),
                            
                          // Video preview section
                          if ((_mediaUploadMode == 'video' || _mediaUploadMode == 'both') && _videoFile != null)
                            _buildVideoPreview(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addProperty,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Add Property',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
    );

    // Reverse geocoding to get the address
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Extract the desired fields
        String region = place.administrativeArea ?? 'Unknown Region';
        String fullAddress =
            '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';

        // Update the location field
        setState(() {
          // Update the text field with the region (or modify this to show the full address if needed)
          _locationController.text = region;

          // Send the full address or region to the database here
          _sendLocationToDatabase(fullAddress); // Replace this with your method
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get address. Please try again.'),
        ),
      );
    }
  }

  void _sendLocationToDatabase(String location) {
    // Implement your logic to send the location to the database
    // Example:
    print('Sending location to the database: $location');
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFiles.add(File(pickedFile.path)); // Add the new image to the list
      }
    });
  }

  Future<void> _removeImage(int index) async {
    setState(() {
      _imageFiles.removeAt(index); // Remove the image at the specified index
    });
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 5), // Limit to 5 minutes
    );
    setState(() {
      if (pickedFile != null) {
        _videoFile = File(pickedFile.path);
      }
    });
  }
  
  void _removeVideo() {
    setState(() {
      _videoFile = null;
    });
  }
  
  // Helper method to pick media based on mode
  void _pickMedia(String type) {
    if (type == 'image') {
      _pickImage();
    } else if (type == 'video') {
      _pickVideo();
    }
  }
        decoration: BoxDecoration(
          color = selected ? Colors.blue.shade50 : Colors.white,
          borderRadius = BorderRadius.circular(12),
          border = Border.all(
            color: selected ? Colors.blue.shade400 : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow = [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment = MainAxisAlignment.center,
          children = [
            Icon(
              icon,
              size: 36,
              color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setMediaUploadMode(String mode) {
    setState(() {
      _mediaUploadMode = mode;
      
      // Clear files if needed based on the selected mode
      if (mode == 'image') {
        _videoFile = null;
      } else if (mode == 'video') {
        _imageFiles.clear();
      }
    });
  }
  
  Widget _buildUploadOptionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Choose Upload Mode:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildUploadModeCard(
                icon: Icons.image,
                title: 'Image Only',
                selected: _mediaUploadMode == 'image',
                onTap: () => _setMediaUploadMode('image'),
              ),
              const SizedBox(width: 12),
              _buildUploadModeCard(
                icon: Icons.videocam,
                title: 'Video Only',
                selected: _mediaUploadMode == 'video',
                onTap: () => _setMediaUploadMode('video'),
              ),
              const SizedBox(width: 12),
              _buildUploadModeCard(
                icon: Icons.perm_media,
                title: 'Both',
                selected: _mediaUploadMode == 'both',
                onTap: () => _setMediaUploadMode('both'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUploadModeCard({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.blue.shade700 : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Image Preview:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageFiles.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(_imageFiles[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 15,
                    top: 5,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    if (_videoFile == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Text(
            'Video Preview:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_file,
                    size: 48,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Video Selected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  Text(
                    _videoFile!.path.split('/').last,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _videoFile = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addProperty() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show the loader
      });

      try {
        // Retrieve user details from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString('userId');
        if (userId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found. Please log in again.')),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }

        // Property data preparation
        final propertyData = {
          'user_id': userId,
          'title': _titleController.text,
          'description': _descriptionAndFeatureController.text,
          'price': int.tryParse(_priceController.text) ?? 0,
          'property_size': int.tryParse(_sizeController.text) ?? 0,
          'number_of_rooms': int.tryParse(_roomsController.text) ?? 0,
          'status': _status ?? '',
          'location': _locationController.text,
        };

        // API call to add property
        final response = await ApiService.addProperty(propertyData);
        if (response['status'] == 'success') {
          final propertyId = response['property_id'];

          // Upload all selected images
          if (_imageFiles.isNotEmpty) {
            for (var imageFile in _imageFiles) {
              await ApiService.uploadPropertyMedia(
                  propertyId.toString(), 'image', imageFile.path, false);
            }
          }
          
          // Upload video if available
          if (_videoFile != null) {
            await ApiService.uploadPropertyMedia(
                propertyId.toString(), 'video', _videoFile!.path, false);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property added successfully!')),
          );

          // Navigate to the dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DalaliDashboard(userId: int.parse(userId)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add property')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loader when done
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Property'),
      ),
      drawer: DalaliNavigationDrawer(
        onThemeChanged: (isDarkMode) {
          setState(() {});
        },
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Property',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Property Title Input
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Property Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter property title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // // Property Size Input
                // TextFormField(
                //   controller: _sizeController,
                //   decoration: InputDecoration(
                //     labelText: 'Size (sqm)',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     filled: true,
                //     fillColor: Colors.grey[200],
                //   ),
                // ),
                // const SizedBox(height: 20),

                // // Number of Rooms Input
                // TextFormField(
                //   controller: _roomsController,
                //   decoration: InputDecoration(
                //     labelText: 'Number of Properties',
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     filled: true,
                //     fillColor: Colors.grey[200],
                //   ),
                // ),
                // const SizedBox(height: 20),

                // Features Input
                SizedBox(
                  child: TextFormField(
                    controller: _descriptionAndFeatureController,
                    maxLines: null, // Allows unlimited lines
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Description & Features',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(height: 20),


                // Price Input
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(height: 20),

                // Location Input
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                        readOnly: true, // Make it read-only
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.location_searching),
                      onPressed:
                          _getCurrentLocation, // Trigger location fetching
                    ),
                  ],
                ),

                // Some space
                const SizedBox(
                  height: 16,
                ),

                // Property Status Dropdown
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'For Sale',
                      child: Text('For Sale'),
                    ),
                    DropdownMenuItem(
                      value: 'For Rent',
                      child: Text('For Rent'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a status';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Media Upload Options
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Add Media Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Upload mode selection
                      _buildUploadOptionSelector(),
                      
                      const SizedBox(height: 16),
                      
                      // Upload buttons based on selected mode
                      Row(
                        children: [
                          if (_mediaUploadMode == 'image' || _mediaUploadMode == 'both')
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.add_photo_alternate),
                                label: const Text('Add Images'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF0D47A1),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          if (_mediaUploadMode == 'both')
                            const SizedBox(width: 12),
                          if (_mediaUploadMode == 'video' || _mediaUploadMode == 'both')
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _pickVideo,
                                icon: const Icon(Icons.videocam),
                                label: const Text('Add Video'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: const Color(0xFF0D47A1),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Image preview section
                      if ((_mediaUploadMode == 'image' || _mediaUploadMode == 'both') && _imageFiles.isNotEmpty)
                        _buildImagePreview(),
                        
                      // Video preview section
                      if ((_mediaUploadMode == 'video' || _mediaUploadMode == 'both') && _videoFile != null)
                        _buildVideoPreview(),
                    ],
                  ),
                ),
                
                // Display selected video thumbnail
                if (_videoFile != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Selected Video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.videocam,
                                color: Colors.blue,
                                size: 36,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _videoFile!.path.split('/').last,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _videoFile = null;
                            });
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 12,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),

                _isLoading
                  ? const Center(child: CircularProgressIndicator()) // Show loader
                  : // Add Property Button
                Center(
                  child: ElevatedButton(
                    onPressed: _addProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    child: const Text(
                      'Add Property',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
