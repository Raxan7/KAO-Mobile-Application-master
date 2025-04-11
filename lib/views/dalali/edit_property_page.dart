import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';

class EditPropertyPage extends StatefulWidget {
  final Property property;

  const EditPropertyPage({super.key, required this.property});

  @override
  _EditPropertyPageState createState() => _EditPropertyPageState();
}

class _EditPropertyPageState extends State<EditPropertyPage> {
  late TextEditingController _titleController;
  late TextEditingController _sizeController;
  late TextEditingController _roomsController;
  late TextEditingController _descriptionAndFeatureController;
  late TextEditingController _priceController;
  late TextEditingController _locationController;
  bool _featured = false;
  String? _status;
  final _formKey = GlobalKey<FormState>();
  final List<File?> _selectedImages = [];
  final List<File> _localImages = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.property.title);
    _sizeController = TextEditingController(text: widget.property.size);
    _roomsController =
        TextEditingController(text: widget.property.numberOfRooms.toString());
    _descriptionAndFeatureController =
        TextEditingController(text: widget.property.description);
    _priceController =
        TextEditingController(text: widget.property.price.toString());
    _locationController =
        TextEditingController(text: widget.property.location.toString());
    _featured = widget.property.featured;
    _status = widget.property.status;
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

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'title': _titleController.text.trim(),
        // 'description': widget.property.description,
        'price': double.parse(_priceController.text.trim()),
        'size': _sizeController.text.trim(),
        'number_of_rooms': int.parse(_roomsController.text.trim()),
        'description': _descriptionAndFeatureController.text.trim(),
        'status': _status ?? widget.property.status,
        'location': _locationController.text.trim(),
        'featured': _featured ? 1 : 0,
      };

      try {
        // Update property details
        final response =
            await ApiService.updateProperty(widget.property.id, updatedData);

        if (response['status'] == 'success') {
          // Upload new media files, if any
          if (_selectedImages.isNotEmpty) {
            for (var imageFile in _selectedImages) {
              await ApiService.uploadPropertyMedia(
                widget.property.id.toString(),
                'image', // media type
                imageFile!.path, // file path
                false, // isPrimaryMedia
              );
            }
          }

          // Update the property instance and navigate back
          final updatedProperty = Property(
            id: widget.property.id,
            title: _titleController.text.trim(),
            description: _descriptionAndFeatureController.text.trim(),
            price: double.parse(_priceController.text.trim()),
            size: _sizeController.text.trim(),
            numberOfRooms: int.parse(_roomsController.text.trim()),
            status: _status ?? widget.property.status,
            location: _locationController.text.trim(),
            featured: _featured,
            media: widget.property.media, // You may want to refresh this list
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Property updated successfully!')),
          );

          Navigator.pop(context, updatedProperty);
        } else {
          throw Exception(response['message'] ?? 'Unknown error occurred');
        }
      } catch (e) {
        debugPrint('Error updating property: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update property: $e')),
        );
      }
    }
  }


  Future<void> _pickImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    setState(() {
      _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
    });
    }


  Future<void> _deleteImage(int index, bool isLocal) async {
    if (isLocal) {
      setState(() {
        _localImages.removeAt(index);
      });
    } else {
      final media = widget.property.media[index];
      List<String> mediaList = media.mediaUrl.split('/');
      final imageName = mediaList[mediaList.length - 1];

      final response =
          (await ApiService.deletePropertyMedia(imageName));
      if (response['status'] == 'success') {
        setState(() {
          widget.property.media.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete image.')),
        );
      }
    }
  }

  Widget _buildImageGrid() {
    final allImages = [
      ..._selectedImages.map((file) => Image.file(file!)),
      ...widget.property.media.map((media) => Image.network(media.mediaUrl)),
    ];

    return GridView.builder(
      itemCount: allImages.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final isLocal = index < _selectedImages.length;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isLocal
                    ? Image.file(
                        _selectedImages[index]!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      )
                    : Image.network(
                        widget.property.media[index - _selectedImages.length]
                            .mediaUrl,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: () => isLocal
                    ? setState(() {
                        _selectedImages.removeAt(index);
                      })
                    : _deleteImage(index - _selectedImages.length, false),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
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
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Property')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Property Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              // TextFormField(
              //   controller: _sizeController,
              //   decoration: const InputDecoration(labelText: 'Size (sqft)'),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter the size';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 10),
              // TextFormField(
              //   controller: _roomsController,
              //   decoration: const InputDecoration(labelText: 'Number of Rooms'),
              //   keyboardType: TextInputType.number,
              //   validator: (value) {
              //     if (value == null ||
              //         value.isEmpty ||
              //         int.tryParse(value) == null) {
              //       return 'Please enter a valid number';
              //     }
              //     return null;
              //   },
              // ),
              // const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionAndFeatureController,
                decoration: const InputDecoration(labelText: 'Description & Features'),
                maxLines: 5,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'For Sale', child: Text('For Sale')),
                  DropdownMenuItem(value: 'For Rent', child: Text('For Rent')),
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
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Featured'),
                value: _featured,
                onChanged: (value) {
                  setState(() {
                    _featured = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Property Images',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  _selectedImages.isNotEmpty || widget.property.media.isNotEmpty
                      ? _buildImageGrid()
                      : const Text('No images available'),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add Images'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
