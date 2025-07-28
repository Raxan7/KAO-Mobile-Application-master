import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_property.dart';
import '../models/hostel.dart';
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/lodge.dart';
import '../models/motel.dart';
import '../models/notification_model.dart';
import '../models/property.dart';
import '../models/space.dart';
import '../models/space_category.dart';

// Import for conditional imports
import 'dart:io' if (dart.library.js) 'package:kao_app/services/web_file_stub.dart';

// Import for web
import 'package:universal_html/html.dart' as html;

class SupabaseService {
  // Get the instance of Supabase client
  final supabase = Supabase.instance.client;
  
  // Constants for storage buckets
  static const String imagesBucket = 'images';
  static const String videosBucket = 'videos';
  static const String imageUrl = 'https://your-supabase-project.supabase.co/storage/v1/object/public/';

  // Equivalent to fetchHotels
  Future<List<Hotel>> fetchHotels() async {
    try {
      final response = await supabase
          .from('hotels')
          .select()
          .order('created_at', ascending: false);
      
      return response.map<Hotel>((hotel) => Hotel.fromJson(hotel)).toList();
    } catch (e) {
      print('Error fetching hotels: $e');
      throw Exception('Failed to load hotels');
    }
  }

  // Equivalent to fetchMotels
  Future<List<Motel>> fetchMotels() async {
    try {
      final response = await supabase
          .from('motels')
          .select()
          .order('created_at', ascending: false);
      
      return response.map<Motel>((motel) => Motel.fromJson(motel)).toList();
    } catch (e) {
      print('Error fetching motels: $e');
      throw Exception('Failed to load motels');
    }
  }

  // Add property method
  Future<Map<String, dynamic>> addProperty(Map<String, dynamic> propertyData) async {
    try {
      print('📦 Adding property: $propertyData');
      
      // Format data for Supabase if needed
      final formattedData = {
        ...propertyData,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'featured': propertyData['featured'] ?? '0',
      };
      
      final response = await supabase
          .from('properties')
          .insert(formattedData)
          .select()
          .single();
      
      print('✅ Property added successfully: $response');
      
      return {
        'status': 'success',
        'property_id': response['id'],
        'message': 'Property added successfully'
      };
    } catch (e) {
      print('❌ Error adding property: $e');
      return {
        'status': 'error',
        'message': 'Failed to add property: $e'
      };
    }
  }
  
  // Upload property media
  Future<Map<String, dynamic>> uploadPropertyMedia(
      String propertyId, String mediaType, String filePath, bool thumb) async {
    try {
      print('📤 UPLOAD MEDIA: Starting upload for property $propertyId');
      print('📤 UPLOAD MEDIA: Media type = $mediaType, File path = $filePath, Thumbnail = $thumb');
      
      // Determine storage path and file extension based on media type
      String bucketName = mediaType == 'video' ? 'properties-videos' : 'properties-images';
      String contentType = mediaType == 'video' ? 'video/mp4' : 'image/jpeg';
      String fileExtension = mediaType == 'video' ? '.mp4' : '.jpg';
      
      // Generate a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${propertyId}_$timestamp$fileExtension';
      
      // Handle file upload differently for web and mobile platforms
      String fileUrl;
      
      if (kIsWeb) {
        print('🌐 UPLOAD MEDIA: Detected web platform');
        
        if (filePath.startsWith('blob:')) {
          print('📁 UPLOAD MEDIA: Detected blob URL, using web-specific handling');
          
          try {
            final completer = Completer<Uint8List>();
            final xhr = html.HttpRequest();
            
            xhr.open('GET', filePath);
            xhr.responseType = 'arraybuffer';
            
            xhr.onLoad.listen((_) {
              if (xhr.status == 200) {
                final bytes = Uint8List.fromList(xhr.response as List<int>);
                print('📁 UPLOAD MEDIA: Successfully read ${bytes.length} bytes from blob URL');
                completer.complete(bytes);
              } else {
                completer.completeError('HTTP error: ${xhr.status}');
              }
            });
            
            xhr.onError.listen((event) {
              completer.completeError('Failed to load blob URL');
            });
            
            // Send the request
            xhr.send();
            
            // Get the bytes
            final bytes = await completer.future;
            
            // Upload to Supabase storage
            await supabase.storage
                .from(bucketName)
                .uploadBinary(
                  fileName, 
                  bytes,
                  fileOptions: FileOptions(contentType: contentType)
                );
                
            // Get the public URL
            fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
            
          } catch (e) {
            print('❌ UPLOAD MEDIA ERROR: Failed to handle blob URL: $e');
            return {
              'status': 'error',
              'message': 'Failed to upload media: $e'
            };
          }
        } else if (filePath.startsWith('data:')) {
          // Handle data URIs (common in web)
          print('📁 UPLOAD MEDIA: Detected data URI');
          
          try {
            // Extract the base64 data from the data URI
            final commaIndex = filePath.indexOf(',');
            if (commaIndex == -1) {
              throw Exception('Invalid data URI format');
            }
            
            final dataString = filePath.substring(commaIndex + 1);
            final bytes = base64Decode(dataString);
            
            // Upload to Supabase storage
            await supabase.storage
                .from(bucketName)
                .uploadBinary(
                  fileName, 
                  bytes,
                  fileOptions: FileOptions(contentType: contentType)
                );
                
            // Get the public URL
            fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
          } catch (e) {
            print('❌ UPLOAD MEDIA ERROR: Failed to handle data URI: $e');
            return {
              'status': 'error',
              'message': 'Failed to upload media: $e'
            };
          }
        } else {
          return {
            'status': 'error',
            'message': 'Unsupported file path format for web'
          };
        }
      } else {
        // Mobile platform handling
        print('📱 UPLOAD MEDIA: Using mobile file handling');
        
        try {
          final file = File(filePath);
          final fileExists = await file.exists();
          
          if (!fileExists) {
            return {
              'status': 'error',
              'message': 'File does not exist at path: $filePath'
            };
          }
          
          // Verify file size and readability
          final fileStats = await file.stat();
          final fileSize = fileStats.size;
          
          if (fileSize <= 0) {
            return {
              'status': 'error',
              'message': 'File is empty'
            };
          }
          
          // Upload file to Supabase storage
          await supabase.storage
              .from(bucketName)
              .upload(
                fileName, 
                file,
                fileOptions: FileOptions(contentType: contentType)
              );
              
          // Get the public URL
          fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
          
        } catch (e) {
          print('❌ UPLOAD MEDIA ERROR: $e');
          return {
            'status': 'error',
            'message': 'Failed to upload media: $e'
          };
        }
      }
      
      // Save media information to database
      try {
        final mediaData = {
          'property_id': propertyId,
          'media_url': fileUrl,
          'media_type': mediaType,
          'is_thumbnail': thumb,
          'created_at': DateTime.now().toIso8601String()
        };
        
        await supabase.from('property_media').insert(mediaData);
        
        return {
          'status': 'success',
          'message': 'Media uploaded successfully',
          'file_path': fileUrl,
          'media_type': mediaType
        };
      } catch (e) {
        print('❌ MEDIA DATABASE ERROR: $e');
        return {
          'status': 'error',
          'message': 'Failed to save media information: $e'
        };
      }
    } catch (e) {
      print('❌ UPLOAD MEDIA ERROR: General exception: $e');
      return {
        'status': 'error',
        'message': 'Error occurred during media upload: $e'
      };
    }
  }
  
  // Fetch properties
  Future<List<UserProperty>> fetchProperties(String userId) async {
    try {
      final properties = await supabase
          .from('properties')
          .select('*, property_media(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      List<UserProperty> propertyList = [];
      
      for (var property in properties) {
        // Find a thumbnail image or the first media
        String propertyImage = '';
        String mediaType = 'image';
        
        var mediaItems = property['property_media'];
        if (mediaItems != null && mediaItems.isNotEmpty) {
          // First try to find a thumbnail
          var thumbnail = mediaItems.firstWhere(
            (item) => item['is_thumbnail'] == true,
            orElse: () => mediaItems.first
          );
          
          propertyImage = thumbnail['media_url'];
          mediaType = thumbnail['media_type'];
        }
        
        propertyList.add(UserProperty(
          propertyId: property['id'].toString(),
          userId: property['user_id'],
          title: property['title'],
          description: property['description'],
          price: double.tryParse(property['price'].toString()) ?? 0.0,
          propertySize: property['property_size'].toString(),
          numberOfRooms: property['number_of_rooms'].toString(),
          status: property['status'],
          location: property['location'],
          featured: property['featured'] ?? '0',
          createdAt: DateTime.parse(property['created_at']),
          updatedAt: DateTime.parse(property['updated_at']),
          propertyImage: propertyImage,
          mediaType: mediaType,
        ));
      }
      
      return propertyList;
    } catch (e) {
      print('Error fetching properties: $e');
      return [];
    }
  }
  
  // Delete property
  Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    try {
      // First get all media files for this property
      final mediaItems = await supabase
          .from('property_media')
          .select()
          .eq('property_id', propertyId);
      
      // Delete each media file from storage
      for (var media in mediaItems) {
        final bucketName = media['media_type'] == 'video' ? 'properties-videos' : 'properties-images';
        final fileName = media['media_url'].split('/').last;
        
        try {
          await supabase.storage.from(bucketName).remove([fileName]);
        } catch (e) {
          print('Warning: Failed to delete media file: $e');
          // Continue with deletion even if some files fail to delete
        }
      }
      
      // Delete all property media entries
      await supabase
          .from('property_media')
          .delete()
          .eq('property_id', propertyId);
      
      // Delete the property itself
      await supabase
          .from('properties')
          .delete()
          .eq('id', propertyId);
      
      return {
        'status': 'success',
        'message': 'Property deleted successfully'
      };
    } catch (e) {
      print('Error deleting property: $e');
      return {
        'status': 'error',
        'message': 'Failed to delete property: $e'
      };
    }
  }
  
  // Get property details
  Future<UserProperty?> getPropertyDetails(String propertyId) async {
    try {
      final property = await supabase
          .from('properties')
          .select('*, property_media(*)')
          .eq('id', propertyId)
          .single();
      
      if (property == null) {
        return null;
      }
      
      // Find a thumbnail image or the first media
      String propertyImage = '';
      String mediaType = 'image';
      
      var mediaItems = property['property_media'];
      if (mediaItems != null && mediaItems.isNotEmpty) {
        // First try to find a thumbnail
        var thumbnail = mediaItems.firstWhere(
          (item) => item['is_thumbnail'] == true,
          orElse: () => mediaItems.first
        );
        
        propertyImage = thumbnail['media_url'];
        mediaType = thumbnail['media_type'];
      }
      
      return UserProperty(
        propertyId: property['id'].toString(),
        userId: property['user_id'],
        title: property['title'],
        description: property['description'],
        price: double.tryParse(property['price'].toString()) ?? 0.0,
        propertySize: property['property_size'].toString(),
        numberOfRooms: property['number_of_rooms'].toString(),
        status: property['status'],
        location: property['location'],
        featured: property['featured'] ?? '0',
        createdAt: DateTime.parse(property['created_at']),
        updatedAt: DateTime.parse(property['updated_at']),
        propertyImage: propertyImage,
        mediaType: mediaType,
      );
    } catch (e) {
      print('Error getting property details: $e');
      return null;
    }
  }

  // Additional methods can be added as needed
}
