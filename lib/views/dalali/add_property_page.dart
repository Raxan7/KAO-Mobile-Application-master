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
  final TextEditingController _descriptionAndFeatureController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _status;

  // File? _imageFile;
  final List<File> _imageFiles = []; // List to store multiple image files
  File? _videoFile;

  final ImagePicker _picker = ImagePicker();
  bool _showImagePicker = true;

  bool _isLoading = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fetch location automatically on page load
    _getCurrentLocation();
    // Start the timer to toggle between the buttons every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        // Ensure the widget is still mounted before calling setState
        setState(() {
          _showImagePicker = !_showImagePicker;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer
        ?.cancel(); // Cancel the timer to prevent calling setState after dispose
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
          content: Text(
              'Location permissions are permanently denied. Cannot fetch location.'),
        ),
      );
      return;
    }

    // Fetch the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
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
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _videoFile = File(pickedFile.path);
      }
    });
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
          for (var imageFile in _imageFiles) {
            await ApiService.uploadPropertyMedia(
                propertyId.toString(), 'image', imageFile.path, false);
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

                // Toggle between Image and Video Picker Buttons with transition effect
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                        milliseconds: 500), // Transition duration
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: ElevatedButton.icon(
                      key: const ValueKey(1), // Unique key for Image Picker
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image, color: Colors.white),
                      label: const Text('Pick Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Display selected images in a grid
                if (_imageFiles.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _imageFiles.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Image.file(
                            _imageFiles[index],
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
                                child: Icon(
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
