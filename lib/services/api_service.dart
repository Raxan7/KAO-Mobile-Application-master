// import 'package:http/http.dart' as http; // Unused
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
// import 'dart:typed_data'; // Duplicate import removed
import '../models/hostel.dart';
import '../models/hotel.dart';
import '../models/booking.dart';
import '../models/lodge.dart';
import '../models/motel.dart';
import '../models/notification_model.dart';
import '../models/property.dart';
import '../models/user_property.dart';
import '../models/space.dart'; 
import '../models/space_category.dart';
import 'package:flutter/foundation.dart'; // Import foundation.dart for kIsWeb

import 'package:cross_file/cross_file.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import 'dart:io' as io show File;
// import 'package:path_provider/path_provider.dart'; // Unused import removed
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import '../utils/constants.dart';

class ApiService {
  static const String imageUrl = baseUrl;
  static const String baseUrl = apiUrl;

  Future<Uint8List> _getFileBytes(dynamic fileInput) async {
    if (kIsWeb) {
      if (fileInput is XFile) {
        return await fileInput.readAsBytes();
      } else if (fileInput is String && fileInput.startsWith('blob:')) {
        final completer = Completer<Uint8List>();
        final xhr = html.HttpRequest();
        xhr.open('GET', fileInput);
        xhr.responseType = 'arraybuffer';
        xhr.onLoad.listen((_) => completer.complete(Uint8List.fromList(xhr.response as List<int>)));
        xhr.onError.listen(completer.completeError);
        xhr.send();
        return await completer.future;
      } else if (fileInput is Uint8List) {
        return fileInput;
      }
    } else {
      // Mobile/Desktop
      if (fileInput is XFile) {
        return await fileInput.readAsBytes();
      } else if (fileInput is io.File) {
        return await fileInput.readAsBytes();
      } else if (fileInput is String) {
        return await io.File(fileInput).readAsBytes();
      } else if (fileInput is Uint8List) {
        return fileInput;
      }
    }
    throw Exception('Unsupported file type');
  }

  Future<List<Hotel>> fetchHotels() async {
    try {
      final supabase = Supabase.instance.client;
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

  Future<List<Motel>> fetchMotels() async {
    try {
      final supabase = Supabase.instance.client;
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

  Future<List<Hostel>> fetchHostels() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('hostels')
          .select()
          .order('id', ascending: false);
      
      return response.map<Hostel>((hostel) => Hostel.fromJson(hostel)).toList();
    } catch (e) {
      print('Error fetching hostels: $e');
      throw Exception('Failed to load hostels');
    }
  }

  Future<List<Lodge>> fetchLodges() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('lodges')
          .select()
          .order('id', ascending: false);
      
      return response.map<Lodge>((lodge) => Lodge.fromJson(lodge)).toList();
    } catch (e) {
      print('Error fetching lodges: $e');
      throw Exception('Failed to load lodges');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final supabase = Supabase.instance.client;
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print("-----------------------------------------------------------------");
      print('LOGIN RESPONSE: ${response.user!.id}, Email: ${response.user!.email}');
      print("-----------------------------------------------------------------");
      
      // Get user details from the profile table
      final userData = await supabase
          .from('user_cred')
          .select()
          .eq('id', response.user!.id)
          .single();
      
      return {
        'status': 'success',
        'message': 'Login successful',
        'userId': response.user!.id,
        'email': response.user!.email,
        'token': response.session!.accessToken,
        'role': userData['role'] ?? 'user',
        'name': userData['name'] ?? '',
        'phone': userData['phone'] ?? '',
        'user': userData
      };
    } catch (e) {
      print('Error logging in: $e');
      return {
        'status': 'error',
        'message': 'Login failed: $e'
      };
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get the user profile from the user_cred table
      final profile = await supabase
          .from('user_cred')
          .select()
          .eq('id', userId)
          .single();
          
      return {
        'status': 'success',
        'data': profile
      };
    } catch (e) {
      print('Error fetching user profile: $e');
      throw Exception('Failed to load user profile: $e');
    }
  }

  // Add the fetchRoomDetails function
  Future<Map<String, dynamic>> fetchRoomDetails(
      String roomId, String accommodationType) async {
    try {
      final supabase = Supabase.instance.client;
      
      print('Fetching room details from Supabase');
      print('Room ID: $roomId, Accommodation Type: $accommodationType');
      
      // Fetch room details from the rooms table
      final response = await supabase
          .from('rooms')
          .select('*, property_types(name)')
          .eq('id', roomId)
          .single();
      
      print('Room details fetched successfully');
      
      return {
        'status': true,
        'data': response
      };
    } catch (e) {
      print('❌ FETCH ROOM DETAILS ERROR: Exception: $e');
      print('❌ FETCH ROOM DETAILS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to load room details: $e');
    }
  }

  // Function to fetch bookings for a specific user
  Future<List<Booking>> fetchUserBookings(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      print('Fetching bookings for user: $userId from Supabase');
      final response = await supabase
          .from('bookings')
          .select('*, rooms(*)')  // Include room details in the response
          .eq('user_id', userId)
          .order('created_at', ascending: false);
          
      print('Fetched ${response.length} bookings');
      
      // Map the booking data to a list of Booking objects
      return response.map((booking) => Booking.fromJson(booking)).toList();
    } catch (e) {
      print('❌ FETCH USER BOOKINGS ERROR: Exception: $e');
      print('❌ FETCH USER BOOKINGS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  Future<Map<String, dynamic>> checkAvailability(
      String roomId, String checkIn, String checkOut) async {
    try {
      final supabase = Supabase.instance.client;
      
      print('Checking room availability in Supabase');
      print('Room ID: $roomId, Check-in: $checkIn, Check-out: $checkOut');
      
      // Parse dates for validation (no need to store in variables as we're using the string format)
      
      // Check for overlapping bookings
      final response = await supabase
          .from('bookings')
          .select()
          .eq('room_id', roomId)
          .or('status.eq.confirmed,status.eq.pending')
          .not('status', 'eq', 'cancelled')
          .lte('checkin', checkOut)  // Check-in date is before or on the checkout date
          .gte('checkout', checkIn); // Check-out date is after or on the check-in date
      
      final isAvailable = response.isEmpty;
      
      print('Room availability: ${isAvailable ? 'Available' : 'Not Available'}');
      
      return {
        'status': true,
        'available': isAvailable,
        'message': isAvailable ? 'Room is available' : 'Room is not available for the selected dates'
      };
    } catch (e) {
      print('❌ CHECK AVAILABILITY ERROR: Exception: $e');
      print('❌ CHECK AVAILABILITY ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return {
        'status': false,
        'available': false,
        'message': 'Failed to check availability: $e'
      };
    }
  }

  Future<Map<String, dynamic>> createBooking(Booking booking) async {
    try {
      final supabase = Supabase.instance.client;
      
      print('Creating booking in Supabase');
      print('User ID: ${booking.userId}, Room ID: ${booking.hotelId}');
      
      // Create booking data
      final bookingData = {
        'user_id': booking.userId,
        'room_id': booking.hotelId,
        'checkin': booking.checkIn.toIso8601String(),
        'checkout': booking.checkOut.toIso8601String(),
        'total_amount': booking.totalAmount.toString(),
        'status': 'confirmed',
        'created_at': DateTime.now().toIso8601String(),
        // Use default values as these fields are not in the Booking model
        'name': 'Guest',
        'phonenum': '',
        'address': '',
      };
      
      // Insert booking data into bookings table
      final response = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();
      
      print('Booking created with ID: ${response['id']}');
      
      return {
        'status': 'success',
        'message': 'Booking created successfully',
        'booking_id': response['id'],
        'data': response
      };
    } catch (e) {
      print('❌ CREATE BOOKING ERROR: Exception: $e');
      print('❌ CREATE BOOKING ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<Map<String, dynamic>> bookRoom(
    String roomId,
    String checkIn,
    String checkOut,
    String userId,
    String userName,
    String phoneNum,
    String address,
    String roomName,
    String roomPrice,
  ) async {
    try {
      final supabase = Supabase.instance.client;
      
      print('Booking room in Supabase');
      print('Room ID: $roomId, Check-in: $checkIn, Check-out: $checkOut, User ID: $userId');
      
      // Create booking data
      final bookingData = {
        'room_id': roomId,
        'checkin': checkIn,
        'checkout': checkOut,
        'user_id': userId,
        'name': userName,
        'phonenum': phoneNum,
        'address': address,
        'room_name': roomName,
        'room_price': roomPrice,
        'status': 'confirmed',
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Insert booking data into bookings table
      final response = await supabase
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();
      
      print('Booking created with ID: ${response['id']}');
      
      return {
        'status': true,
        'message': 'Booking created successfully',
        'booking_id': response['id'],
        'data': response
      };
    } catch (e) {
      print('❌ BOOK ROOM ERROR: Exception: $e');
      print('❌ BOOK ROOM ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return {
        'status': false,
        'message': 'Failed to create booking: $e'
      };
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phonenum,
    required String address,
    required String pincode,
    required String dob,
    required String pass,
    required String cpass,
    required String role,
  }) async {
    try {
      final supabase = Supabase.instance.client;

      // Sanitize inputs
      final cleanEmail = email.trim();
      final cleanPass = pass.trim();
      final cleanCpass = cpass.trim();

      print('Registering user in Supabase');
      print('Email: $cleanEmail, Role: $role');

      // Validate email format (better regex)
      final emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
      if (!emailRegex.hasMatch(cleanEmail)) {
        throw Exception('Invalid email format: $cleanEmail');
      }

      // Validate password
      if (cleanPass.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (cleanPass != cleanCpass) {
        throw Exception('Passwords do not match');
      }

      // Register with Supabase Auth
      final authResponse = await supabase.auth.signUp(
        email: cleanEmail,
        password: cleanPass,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account: ${authResponse.session?.accessToken ?? 'No access token'}');
      }

      final userId = authResponse.user!.id;
      print('✅ User registered with ID: $userId');

      // Prepare user data
      final userData = {
        'id': userId,
        'name': name,
        'email': cleanEmail,
        'phone': phonenum,
        'address': address,
        'pincode': pincode,
        'dob': dob,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert user profile to Supabase table
      await supabase.from('user_cred').insert(userData);

      return {
        'status': true,
        'message': 'User registered successfully',
        'user_id': userId
      };
    } on AuthException catch (authError) {
      print('❌ REGISTER USER AUTH ERROR: ${authError.message}');
      return {
        'status': false,
        'message': authError.message
      };
    } catch (e) {
      print('❌ REGISTER USER ERROR: Exception: $e');
      return {
        'status': false,
        'message': 'Failed to register user: $e'
      };
    }
  }


  // Dalali API Services

  // Add Property
Future<Map<String, dynamic>> addProperty(Map<String, dynamic> propertyData) async {
    print('🏠 ADD PROPERTY: Starting property addition');
    print('🏠 ADD PROPERTY: Property data = $propertyData');
    try {
      final supabase = Supabase.instance.client;
      if (!propertyData.containsKey('created_at')) {
        propertyData['created_at'] = DateTime.now().toIso8601String();
      }
      propertyData.remove('id');
      // Insert and fetch the inserted property with its id
      final response = await supabase.from('properties').insert(propertyData).select().single();
      print('✅ ADD PROPERTY: Successfully added property with id ${response['id']}');
      return {
        'status': 'success',
        'message': 'Property added successfully',
        'property_id': response['id'],
        'property': response,
      };
    } catch (e) {
      print('❌ ADD PROPERTY ERROR: Exception: $e');
      print('❌ ADD PROPERTY ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Error during property addition: $e');
    }
  }
  
  Future<Map<String, dynamic>> uploadPropertyMedia(
      String propertyId, String mediaType, dynamic fileInput, bool thumb) async {
    try {
      final supabase = Supabase.instance.client;
      String bucketName = mediaType == 'video' ? 'properties-videos' : 'properties-images';
      String contentType = mediaType == 'video' ? 'video/mp4' : 'image/jpeg';
      String fileExtension = mediaType == 'video' ? '.mp4' : '.jpg';
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${propertyId}_$timestamp$fileExtension';
  
      final bytes = await _getFileBytes(fileInput);
  
      await supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, bytes, fileOptions: FileOptions(contentType: contentType));
  
      final fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
  
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
      print('❌ UPLOAD MEDIA ERROR: $e');
      return {'status': 'error', 'message': 'Failed to upload media: $e'};
    }
  }
  
  Future<Map<String, dynamic>> uploadWebVideoDirectly(
      String propertyId, String blobUrl, bool thumb) async {
    try {
      final supabase = Supabase.instance.client;
      final String bucketName = 'properties-videos';
      final String contentType = 'video/mp4';
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${propertyId}_$timestamp.mp4';
  
      final completer = Completer<Uint8List>();
      final xhr = html.HttpRequest();
  
      xhr.open('GET', blobUrl);
      xhr.responseType = 'arraybuffer';
  
      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          completer.complete(Uint8List.fromList(xhr.response as List<int>));
        } else {
          completer.completeError('Failed with status: ${xhr.status}');
        }
      });
  
      xhr.onError.listen((event) => completer.completeError('Failed to load blob URL'));
      xhr.send();
  
      final bytes = await completer.future;
      await supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, bytes, fileOptions: FileOptions(contentType: contentType));
  
      final fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
  
      final mediaData = {
        'property_id': propertyId,
        'media_url': fileUrl,
        'media_type': 'video',
        'is_thumbnail': thumb,
        'created_at': DateTime.now().toIso8601String()
      };
  
      await supabase.from('property_media').insert(mediaData);
  
      return {
        'status': 'success',
        'message': 'Video uploaded successfully',
        'file_path': fileUrl,
        'media_type': 'video'
      };
    } catch (e) {
      print('❌ UPLOAD WEB VIDEO ERROR: $e');
      return {'status': 'error', 'message': 'Failed to upload video: $e'};
    }
  }

  // Delete Property Media
  Future<Map<String, dynamic>> deletePropertyMedia(
      String mediaUrl) async {
    try {
      print('🗑️ DELETE MEDIA: Starting media deletion for URL: $mediaUrl');
      final supabase = Supabase.instance.client;
      
      // First, get the media record from database to have property_id and other details
      final mediaRecords = await supabase
          .from('property_media')
          .select()
          .eq('media_url', mediaUrl);
      
      if (mediaRecords.isEmpty) {
        print('⚠️ DELETE MEDIA: No database record found for media URL');
        return {
          'status': 'error',
          'message': 'Media record not found in database'
        };
      }
      
      // Extract file path from URL to get the storage path
      final mediaRecord = mediaRecords[0];
      final String fullUrl = mediaRecord['media_url'];
      
      // Parse the URL to extract the filename
      // The URL format should be like: https://supabasehost.com/storage/v1/object/public/bucket_name/filename
      final Uri uri = Uri.parse(fullUrl);
      final pathSegments = uri.pathSegments;
      
      // The filename should be the last segment in the path
      if (pathSegments.isEmpty) {
        print('⚠️ DELETE MEDIA: Could not parse filename from URL: $fullUrl');
        return {
          'status': 'error',
          'message': 'Invalid media URL format'
        };
      }
      
      // Determine the bucket name based on media type
      final String mediaType = mediaRecord['media_type'];
      final String bucketName = mediaType == 'video' ? 'properties-videos' : 'properties-images';
      final String filename = pathSegments.last;
      
      try {
        // Delete from storage
        await supabase.storage.from(bucketName).remove([filename]);
        print('✅ DELETE MEDIA: File deleted from storage: $filename');
        
        // Delete from database
        await supabase
            .from('property_media')
            .delete()
            .eq('media_url', mediaUrl);
        
        print('✅ DELETE MEDIA: Record deleted from database');
        
        return {
          'status': 'success',
          'message': 'Media deleted successfully'
        };
      } catch (storageError) {
        print('⚠️ DELETE MEDIA: Storage deletion error: $storageError');
        
        // Try to delete the database record anyway
        try {
          await supabase
              .from('property_media')
              .delete()
              .eq('media_url', mediaUrl);
          
          print('⚠️ DELETE MEDIA: Record deleted from database, but file deletion failed');
          
          return {
            'status': 'partial_success',
            'message': 'Database record deleted, but file deletion failed: $storageError'
          };
        } catch (dbError) {
          print('❌ DELETE MEDIA: Database deletion also failed: $dbError');
          return {
            'status': 'error',
            'message': 'Failed to delete media: $storageError. Database error: $dbError'
          };
        }
      }
    } catch (e) {
      print('❌ DELETE MEDIA ERROR: $e');
      return {
        'status': 'error',
        'message': 'Error occurred during media deletion: $e'
      };
    }
  }

  // Delete Message
  Future<void> deleteMessage(int messageId) async {
    try {
      print('🗑️ DELETE MESSAGE: Deleting message with ID: $messageId');
      
      final supabase = Supabase.instance.client;
      
      // Delete the message from the messages table
      await supabase
          .from('messages')
          .delete()
          .eq('id', messageId);
      
      print('✅ DELETE MESSAGE: Message deleted successfully');
    } catch (e) {
      print('❌ DELETE MESSAGE ERROR: $e');
      throw Exception("Failed to delete message: $e");
    }
  }

  // Update Property
  Future<Map<String, dynamic>> updateProperty(
      String propertyId, Map<String, dynamic> updatedData) async {
    try {
      print('🏠 UPDATE PROPERTY: Starting property update for ID: $propertyId');
      print('🏠 UPDATE PROPERTY: Updated data = $updatedData');
      
      final supabase = Supabase.instance.client;
      
      // Add updated timestamp
      updatedData['updated_at'] = DateTime.now().toIso8601String();
      
      // Update the property in the database
      await supabase
          .from('properties')
          .update(updatedData)
          .eq('id', propertyId);
          
      print('✅ UPDATE PROPERTY: Property updated successfully');
      
      return {
        'status': 'success',
        'message': 'Property updated successfully',
        'property_id': propertyId
      };
    } catch (e) {
      print('❌ UPDATE PROPERTY ERROR: $e');
      throw Exception('Failed to update property: $e');
    }
  }

  // Delete Property
  Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    try {
      print('🗑️ DELETE PROPERTY: Starting property deletion for ID: $propertyId');
      
      final supabase = Supabase.instance.client;
      
      // First, delete associated media files from storage
      // This assumes media files are stored in a 'property_media' folder with property ID as subfolder
      try {
        final List<FileObject> files = await supabase
            .storage
            .from('property_media')
            .list(path: propertyId);
            
        if (files.isNotEmpty) {
          final List<String> filePaths = files.map((file) => '$propertyId/${file.name}').toList();
          await supabase.storage.from('property_media').remove(filePaths);
          print('✅ DELETE PROPERTY: Associated media files deleted');
        }
      } catch (e) {
        // Continue with property deletion even if media deletion fails
        print('⚠️ DELETE PROPERTY: Could not delete associated media: $e');
      }
      
      // Delete property record
      await supabase
          .from('properties')
          .delete()
          .eq('id', propertyId);
          
      print('✅ DELETE PROPERTY: Property deleted successfully');
      
      return {
        'status': 'success',
        'message': 'Property deleted successfully'
      };
    } catch (e) {
      print('❌ DELETE PROPERTY ERROR: $e');
      throw Exception('Failed to delete property: $e');
    }
  }

  Future<List<Property>> fetchProperties(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('properties')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map<Property>((property) => Property.fromJson(property)).toList();
    } catch (e) {
      print('Error fetching properties: $e');
      throw Exception('Failed to load properties');
    }
  }

  // Method to fetch properties overview for a specific user
  Future<Map<String, int>> fetchPropertiesOverview(String userId) async {
    try {
      final supabase = Supabase.instance.client;
      
      // Get properties for sale
      final forSaleResponse = await supabase
          .from('properties')
          .select()
          .eq('user_id', userId.toString())
          .eq('listing_type', 'for_sale');
      
      // Get properties for rent
      final forRentResponse = await supabase
          .from('properties')
          .select()
          .eq('user_id', userId.toString())
          .eq('listing_type', 'for_rent');
      
      // Count the results
      final forSaleCount = forSaleResponse.length;
      final forRentCount = forRentResponse.length;
      
      print('Properties Overview: For Sale: $forSaleCount, For Rent: $forRentCount');
      
      return {
        'for_sale': forSaleCount,
        'for_rent': forRentCount,
      };
    } catch (e) {
      print('Error fetching properties overview: $e');
      throw Exception(
          'An error occurred while loading properties overview. Please check your connection or try again later.');
    }
  }

  // Fetch unreplied enquiries for the dashboard
  Future<List<dynamic>> fetchUnrepliedEnquiries(String userId) async {
    try {
      print('📬 FETCH UNREPLIED ENQUIRIES: Fetching for user ID: $userId');
      final supabase = Supabase.instance.client;
      
      // Get enquiries/messages that haven't been replied to
      // This assumes you have a 'replied' field in your messages table
      final response = await supabase
          .from('enquiries')
          .select('*, properties(*)')
          .eq('receiver_id', userId.toString())
          .eq('replied', false)
          .order('created_at', ascending: false);
      
      print('✅ FETCH UNREPLIED ENQUIRIES: Found ${response.length} unreplied enquiries');
      return response;
    } catch (e) {
      print('❌ FETCH UNREPLIED ENQUIRIES ERROR: $e');
      throw Exception('Failed to load unreplied enquiries: $e');
    }
  }

  // Fetch all enquiries for the detailed enquiries page
  Future<List<dynamic>> fetchAllEnquiriesDalali(int dalaliId) async {
    try {
      print('📬 FETCH ALL ENQUIRIES: Fetching for dalali ID: $dalaliId');
      final supabase = Supabase.instance.client;
      
      // Get all enquiries/messages for this dalali
      final response = await supabase
          .from('enquiries')
          .select('*, properties(*), sender:sender_id(*)')
          .eq('receiver_id', dalaliId.toString())
          .order('created_at', ascending: false);
      
      print('✅ FETCH ALL ENQUIRIES: Found ${response.length} enquiries');
      return response;
    } catch (e) {
      print('❌ FETCH ALL ENQUIRIES ERROR: $e');
      throw Exception('Failed to load all enquiries: $e');
    }
  }

  // Fetch All Enquiries
  Future<List<dynamic>> fetchAllEnquiriesUser(String userId) async {
    try {
      print('📬 FETCH USER ENQUIRIES: Fetching for user ID: $userId');
      final supabase = Supabase.instance.client;
      
      // Get all enquiries/messages where this user is the sender
      final response = await supabase
          .from('enquiries')
          .select('*, properties(*), receiver:receiver_id(*)')
          .eq('sender_id', userId.toString())
          .order('created_at', ascending: false);
      
      print('✅ FETCH USER ENQUIRIES: Found ${response.length} enquiries');
      return response;
    } catch (e) {
      print('❌ FETCH USER ENQUIRIES ERROR: $e');
      throw Exception('Failed to load user enquiries: $e');
    }
  }

  Future<List<UserProperty>> fetchPropertiesForUser({String? userId}) async {
    try {
      print('🔍 FETCH PROPERTIES: Starting request for user $userId');
      final supabase = Supabase.instance.client;
      
      // Query properties with optional user filter
      List<dynamic> propertiesData;
      if (userId != null) {
        // Get properties for a specific user
        propertiesData = await supabase
            .from('properties')
            .select('*, property_media(*)')
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        print('🔍 FETCH PROPERTIES: Found ${propertiesData.length} properties for user $userId');
      } else {
        // Get all properties
        propertiesData = await supabase
            .from('properties')
            .select('*, property_media(*)')
            .order('created_at', ascending: false);
        print('🔍 FETCH PROPERTIES: Found ${propertiesData.length} properties total');
      }
      
      // Convert to UserProperty objects
      final properties = <UserProperty>[];
      
      for (var i = 0; i < propertiesData.length; i++) {
        try {
          final propertyData = propertiesData[i];
          
          // Check if we have media items for this property
          String mediaType = 'image'; // Default
          String propertyImageUrl = '';
          
          if (propertyData['property_media'] != null && 
              propertyData['property_media'] is List && 
              propertyData['property_media'].isNotEmpty) {
              
            // Find the thumbnail image or the first media item
            final mediaItems = propertyData['property_media'] as List;
            var thumbnailMedia = mediaItems.firstWhere(
              (media) => media['is_thumbnail'] == true,
              orElse: () => mediaItems.first
            );
            
            propertyImageUrl = thumbnailMedia['media_url'] ?? '';
            mediaType = thumbnailMedia['media_type'] ?? 'image';
          }
          
          // Add the property image URL to the property data if needed
          if (!propertyData.containsKey('property_image') || propertyData['property_image'] == null) {
            propertyData['property_image'] = propertyImageUrl;
          }
          
          // Add media type to the property data
          propertyData['media_type'] = mediaType;
          
          // Create UserProperty object
          final property = UserProperty.fromJson(propertyData);
          properties.add(property);
          print('✅ FETCH PROPERTIES: Successfully parsed property ${i+1}/${propertiesData.length} - ID: ${property.propertyId}, MediaType: ${property.mediaType}');
        } catch (e) {
          print('❌ FETCH PROPERTIES ERROR: Failed to parse property ${i+1}: $e');
          print('❌ FETCH PROPERTIES ERROR: Property data: ${propertiesData[i]}');
          // Continue parsing other properties even if one fails
        }
      }
      
      print('✅ FETCH PROPERTIES: Returning ${properties.length} parsed properties');
      return properties;
    } catch (e) {
      print('❌ FETCH PROPERTIES ERROR: Exception: $e');
      print('❌ FETCH PROPERTIES ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to fetch properties: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPropertyDetailForUser(
      String propertyId) async {
    try {
      print('🔍 FETCH PROPERTY DETAIL: Requesting details for property $propertyId');
      final supabase = Supabase.instance.client;
      
      // Get property data with its media items
      final List<dynamic> result = await supabase
          .from('properties')
          .select('*, property_media(*), user:user_id(*)')
          .eq('id', propertyId)
          .limit(1);
      
      if (result.isEmpty) {
        throw Exception('Property not found');
      }
      
      final decodedData = result[0];
      print('✅ FETCH PROPERTY DETAIL: Successfully retrieved property data');
      
      // Process media items to ensure they have media_type field
      if (decodedData.containsKey('property_media') && decodedData['property_media'] != null) {
        final media = decodedData['property_media'];
        print('✅ FETCH PROPERTY DETAIL: Media data type: ${media.runtimeType}');
        
        if (media is List) {
          print('✅ FETCH PROPERTY DETAIL: Media count: ${media.length}');
          
          // Ensure each media item has a media_type field
          for (var i = 0; i < media.length; i++) {
            if (media[i] is Map<String, dynamic> && !media[i].containsKey('media_type')) {
              // If media_type is missing, add it based on file extension
              String url = media[i]['media_url'] ?? '';
              String lowerUrl = url.toLowerCase();
              
              if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mov') || 
                  lowerUrl.endsWith('.avi') || lowerUrl.endsWith('.wmv')) {
                media[i]['media_type'] = 'video';
              } else {
                media[i]['media_type'] = 'image';
              }
              
              print('✅ FETCH PROPERTY DETAIL: Added missing media_type (${media[i]['media_type']}) to item $i');
            }
            
            if (i < 5) {
              print('✅ FETCH PROPERTY DETAIL: Media item $i: ${media[i]}');
            }
          }
          
          if (media.length > 5) {
            print('✅ FETCH PROPERTY DETAIL: (${media.length - 5} more media items...)');
          }
        }
      } else {
        print('⚠️ FETCH PROPERTY DETAIL WARNING: No property_media items found');
        
        // Create empty property_media array if missing
        decodedData['property_media'] = [];
      }
      
      // Add property_image field if needed for backward compatibility
      if (!decodedData.containsKey('property_image') || decodedData['property_image'] == null) {
        // Try to find a thumbnail image from media
        if (decodedData['property_media'] is List && decodedData['property_media'].isNotEmpty) {
          final mediaList = decodedData['property_media'] as List;
          
          // Look for a thumbnail first
          var thumbnailMedia = mediaList.firstWhere(
            (media) => media['is_thumbnail'] == true,
            orElse: () => mediaList.first
          );
          
          decodedData['property_image'] = thumbnailMedia['media_url'] ?? '';
        } else {
          // Set a default image
          decodedData['property_image'] = '';
        }
      }
      
      print('✅ FETCH PROPERTY DETAIL: Successfully processed property data');
      return decodedData;
    } catch (e) {
      print('❌ FETCH PROPERTY DETAIL ERROR: Exception: $e');
      print('❌ FETCH PROPERTY DETAIL ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Error fetching property details: $e');
    }
  }

  // Fetch messages
  Future<List<Map<String, dynamic>>> fetchMessages(
      String propertyId, String senderId, String receiverId) async {
    try {
      print('🔍 FETCH MESSAGES: Requesting messages for property $propertyId between users $senderId and $receiverId');
      final supabase = Supabase.instance.client;
      
      // Get all messages for the given property between the two users
      final List<dynamic> messages = await supabase
          .from('messages')
          .select('*')
          .eq('property_id', propertyId)
          .or('sender_id.eq.$senderId,receiver_id.eq.$senderId')
          .or('sender_id.eq.$receiverId,receiver_id.eq.$receiverId')
          .order('created_at', ascending: true);
      
      print('✅ FETCH MESSAGES: Retrieved ${messages.length} messages');
      
      // Convert to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(messages);
    } catch (e) {
      print('❌ FETCH MESSAGES ERROR: Exception: $e');
      print('❌ FETCH MESSAGES ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to load messages: $e');
    }
  }

  // Send a message
  Future<void> sendMessageForUser({
    required String senderId,
    required String receiverId,
    required String propertyId,
    required String message,
    String messageType = 'text', // Default message type is 'text'
    String? attachmentUrl, // Optional attachment URL for other media types
  }) async {
    try {
      print('🔍 SEND MESSAGE: Creating message from user $senderId to user $receiverId for property $propertyId');
      final supabase = Supabase.instance.client;
      
      // Create a new message record
      await supabase.from('messages').insert({
        'sender_id': senderId,
        'receiver_id': receiverId,
        'property_id': propertyId,
        'message_content': message,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
        'read_status': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ SEND MESSAGE: Successfully sent message');
    } catch (e) {
      print('❌ SEND MESSAGE ERROR: Exception: $e');
      print('❌ SEND MESSAGE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<void> replyToUserMessage({
    required String dalaliId,
    required String userId, // Added userId
    required String propertyId, // Added propertyId
    required String message,
    String messageType = 'text', // Default to 'text' if not provided
    String? attachmentUrl, // Optional attachment URL
  }) async {
    try {
      print('🔍 REPLY TO MESSAGE: Creating reply from dalali $dalaliId to user $userId for property $propertyId');
      final supabase = Supabase.instance.client;
      
      // Create a new message record
      await supabase.from('messages').insert({
        'sender_id': dalaliId,
        'receiver_id': userId,
        'property_id': propertyId,
        'message_content': message,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
        'read_status': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_reply': true, // Mark this as a reply message
      });
      
      print('✅ REPLY TO MESSAGE: Successfully sent reply');
    } catch (e) {
      print('❌ REPLY TO MESSAGE ERROR: Exception: $e');
      print('❌ REPLY TO MESSAGE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to send reply message: $e');
    }
  }

  // Get unreplied messages count
  Future<int> fetchUnrepliedMessageCount(String userId) async {
    try {
      print('🔍 FETCH UNREPLIED COUNT: Checking unreplied messages for user $userId');
      final supabase = Supabase.instance.client;
      
      // Get all unreplied messages where the user is the receiver and count them
      final List<dynamic> messages = await supabase
          .from('messages')
          .select()
          .eq('receiver_id', userId.toString())
          .eq('read_status', false)
          .eq('is_reply', false);
      
      final count = messages.length;
      print('✅ FETCH UNREPLIED COUNT: Found $count unreplied messages');
      return count;
    } catch (e) {
      print('❌ FETCH UNREPLIED COUNT ERROR: Exception: $e');
      print('❌ FETCH UNREPLIED COUNT ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      // Return 0 instead of throwing an exception to prevent disrupting the UI
      return 0;
    }
  }

  Future<void> reactToMessage(int messageId, String reaction) async {
    try {
      print('🔍 REACT TO MESSAGE: Adding reaction $reaction to message $messageId');
      final supabase = Supabase.instance.client;
      
      // Update the message with the reaction
      await supabase
          .from('messages')
          .update({ 'reaction': reaction, 'updated_at': DateTime.now().toIso8601String() })
          .eq('id', messageId.toString());
      
      print('✅ REACT TO MESSAGE: Successfully added reaction');
    } catch (e) {
      print('❌ REACT TO MESSAGE ERROR: Exception: $e');
      print('❌ REACT TO MESSAGE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to send reaction: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessagesById(
      int messageId, String propertyId) async {
    try {
      print('🔍 FETCH MESSAGES BY ID: Requesting message $messageId for property $propertyId');
      final supabase = Supabase.instance.client;
      
      // Get the specific message and related messages for the property
      final List<dynamic> messages = await supabase
          .from('messages')
          .select('*')
          .or('id.eq.$messageId,property_id.eq.$propertyId')
          .order('created_at', ascending: true);
      
      print('✅ FETCH MESSAGES BY ID: Retrieved ${messages.length} messages');
      
      // Convert to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(messages);
    } catch (e) {
      print('❌ FETCH MESSAGES BY ID ERROR: Exception: $e');
      print('❌ FETCH MESSAGES BY ID ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to load messages: $e');
    }
  }

  // Fetch user details by userId
  Future<Map<String, dynamic>> fetchUserDetails(int userId) async {
    try {
      print('🔍 FETCH USER DETAILS: Requesting details for user $userId');
      final supabase = Supabase.instance.client;
      
      // Get user profile data
      final List<dynamic> result = await supabase
          .from('user_cred')
          .select('*, users:id(*)')
          .eq('id', userId.toString())
          .limit(1);
      
      if (result.isEmpty) {
        throw Exception('User not found');
      }
      
      final userData = result[0];
      print('✅ FETCH USER DETAILS: Successfully retrieved user data');
      
      return userData;
    } catch (e) {
      print('❌ FETCH USER DETAILS ERROR: Exception: $e');
      print('❌ FETCH USER DETAILS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Error fetching user details: $e');
    }
  }

  Future<void> removeReactionFromMessage(int messageId) async {
    try {
      print('🔍 REMOVE REACTION: Removing reaction from message $messageId');
      final supabase = Supabase.instance.client;
      
      // Update the message to remove the reaction (set to null)
      await supabase
          .from('messages')
          .update({ 'reaction': null, 'updated_at': DateTime.now().toIso8601String() })
          .eq('id', messageId.toString());
      
      print('✅ REMOVE REACTION: Successfully removed reaction');
    } catch (e) {
      print('❌ REMOVE REACTION ERROR: Exception: $e');
      print('❌ REMOVE REACTION ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to remove reaction: $e');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(
      String email, String googleId, String name, String profilePic) async {
    try {
      print('🔍 LOGIN WITH GOOGLE: Attempting to authenticate user with email: $email');
      final supabase = Supabase.instance.client;
      
      // First check if the user exists with this email
      final List<dynamic> existingUsers = await supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .limit(1);
      
      if (existingUsers.isNotEmpty) {
        // User exists, sign in with email and Google ID as password
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: googleId, // Use googleId as password
        );
        
        if (response.session != null) {
          final user = response.user;
          print('✅ LOGIN WITH GOOGLE: Successfully authenticated existing user: ${user?.email}');
          return {
            'success': true,
            'message': 'Login successful',
            'user_id': user?.id,
            'email': user?.email,
            'name': name,
            'profile_pic': profilePic,
          };
        } else {
          print('❌ LOGIN WITH GOOGLE ERROR: Failed to authenticate user - No session');
          return {
            'success': false,
            'message': 'Authentication failed',
          };
        }
      } else {
        // User doesn't exist, sign up
        final response = await supabase.auth.signUp(
          email: email,
          password: googleId, // Use googleId as password
          data: {
            'name': name,
            'profile_pic': profilePic,
            'google_id': googleId,
          },
        );
        
        if (response.user != null) {
          final user = response.user!;
          print('✅ LOGIN WITH GOOGLE: Successfully created new user: ${user.email}');
          
          // Create user profile
          await supabase.from('user_cred').insert({
            'id': user.id,
            'name': name,
            'email': email,
            'profile_pic': profilePic,
            'created_at': DateTime.now().toIso8601String(),
          });
          
          return {
            'success': true,
            'message': 'Registration successful',
            'user_id': user.id,
            'email': user.email,
            'name': name,
            'profile_pic': profilePic,
          };
        } else {
          print('❌ LOGIN WITH GOOGLE ERROR: Failed to create user');
          return {
            'success': false,
            'message': 'Registration failed',
          };
        }
      }
    } catch (e) {
      print('❌ LOGIN WITH GOOGLE ERROR: Exception: $e');
      print('❌ LOGIN WITH GOOGLE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Create Notification
  Future<Map<String, dynamic>> createNotification(
      String userId, String targetUserId, String propertyId) async {
    try {
      print('🔍 CREATE NOTIFICATION: Creating notification from user $userId to user $targetUserId for property $propertyId');
      final supabase = Supabase.instance.client;
      
      // Create a new notification record
      await supabase.from('notifications').insert({
        'user_id': userId,
        'target_user_id': targetUserId,
        'property_id': propertyId,
        'message': 'Property Requested!',
        'read_status': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ CREATE NOTIFICATION: Successfully created notification');
      return {"status": "success", "message": "Notification created successfully"};
    } catch (e) {
      print('❌ CREATE NOTIFICATION ERROR: Exception: $e');
      print('❌ CREATE NOTIFICATION ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<List<Map<String, dynamic>>> fetchNotifications(
      String targetUserId) async {
    try {
      print('🔍 FETCH NOTIFICATIONS: Requesting notifications for user $targetUserId');
      final supabase = Supabase.instance.client;
      
      // Get unread notifications for the target user
      final List<dynamic> notifications = await supabase
          .from('notifications')
          .select('*, user:user_id(*), property:property_id(*)')
          .eq('target_user_id', targetUserId.toString())
          .eq('read_status', false)
          .order('created_at', ascending: false);
      
      print('✅ FETCH NOTIFICATIONS: Retrieved ${notifications.length} notifications');
      
      // Convert to List<Map<String, dynamic>>
      return List<Map<String, dynamic>>.from(notifications);
    } catch (e) {
      print('❌ FETCH NOTIFICATIONS ERROR: Exception: $e');
      print('❌ FETCH NOTIFICATIONS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      // Return empty list instead of throwing an exception to prevent disrupting the UI
      return [];
    }
  }

  /// Marks a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      print('🔍 MARK NOTIFICATION READ: Updating notification $notificationId');
      final supabase = Supabase.instance.client;
      
      // Update the notification to mark it as read
      await supabase
          .from('notifications')
          .update({
            'read_status': true,
            'updated_at': DateTime.now().toIso8601String()
          })
          .eq('id', notificationId.toString());
      
      print('✅ MARK NOTIFICATION READ: Successfully marked notification as read');
    } catch (e) {
      print('❌ MARK NOTIFICATION READ ERROR: Exception: $e');
      print('❌ MARK NOTIFICATION READ ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to update notification status: $e');
    }
  }

  /// Fetches sender details based on the user ID
  Future<Map<String, dynamic>> fetchSenderDetails(String userId) async {
    try {
      print('🔍 FETCH SENDER DETAILS: Requesting details for user $userId');
      final supabase = Supabase.instance.client;
      
      // Get user profile data
      final List<dynamic> result = await supabase
          .from('user_cred')
          .select('*, users:id(*)')
          .eq('id', userId)
          .limit(1);
      
      if (result.isEmpty) {
        print('❌ FETCH SENDER DETAILS ERROR: User not found');
        return {};
      }
      
      final userData = result[0];
      print('✅ FETCH SENDER DETAILS: Successfully retrieved user data');
      
      return userData;
    } catch (e) {
      print('❌ FETCH SENDER DETAILS ERROR: Exception: $e');
      print('❌ FETCH SENDER DETAILS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return {};
    }
  }

  Future<List<NotificationModel>> fetchNotificationsAll(
      String targetUserId) async {
    try {
      print('🔍 FETCH ALL NOTIFICATIONS: Requesting all notifications for user $targetUserId');
      final supabase = Supabase.instance.client;
      
      // Get all notifications for the target user (both read and unread)
      final List<dynamic> results = await supabase
          .from('notifications')
          .select('*, user:user_id(*), property:property_id(*)')
          .eq('target_user_id', targetUserId.toString())
          .order('created_at', ascending: false);
      
      print('✅ FETCH ALL NOTIFICATIONS: Retrieved ${results.length} notifications');
      
      // Convert to NotificationModel objects
      final notifications = results
          .map((notification) => NotificationModel.fromJson(notification))
          .toList();
      
      return notifications;
    } catch (e) {
      print('❌ FETCH ALL NOTIFICATIONS ERROR: Exception: $e');
      print('❌ FETCH ALL NOTIFICATIONS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return [];
    }
  }

  Future<bool> updateBrokerDetails(
      int userId, Map<String, dynamic> data) async {
    try {
      print('🔍 UPDATE BROKER DETAILS: Updating details for broker $userId');
      final supabase = Supabase.instance.client;
      
      // Add updated_at timestamp to the data
      data['updated_at'] = DateTime.now().toIso8601String();
      
      // Update the broker profile in user_cred
      await supabase
          .from('user_cred')
          .update(data)
          .eq('id', userId.toString())
          .eq('user_type', 'broker');
      
      print('✅ UPDATE BROKER DETAILS: Successfully updated broker details');
      return true;
    } catch (e) {
      print('❌ UPDATE BROKER DETAILS ERROR: Exception: $e');
      print('❌ UPDATE BROKER DETAILS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to update broker details: $e');
    }
  }

  /// Fetch user details from the API
  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    try {
      print('🔍 GET USER DETAILS: Requesting details for user $userId');
      final supabase = Supabase.instance.client;
      
      // Get user profile data with related auth user data
      final List<dynamic> result = await supabase
          .from('user_cred')
          .select('*, users:id(*)')
          .eq('id', userId.toString())
          .limit(1);
      
      if (result.isEmpty) {
        print('❌ GET USER DETAILS ERROR: User not found');
        throw Exception('User not found');
      }
      
      final userData = result[0];
      print('✅ GET USER DETAILS: Successfully retrieved user data');
      
      return userData;
    } catch (error) {
      print('❌ GET USER DETAILS ERROR: Exception: $error');
      print('❌ GET USER DETAILS ERROR: Stack trace: ${error is Error ? error.stackTrace : 'No stack trace'}');
      throw Exception('An error occurred while fetching user details: $error');
    }
  }

  // Bookmarked Properties
  Future<List<UserProperty>> fetchBookmarkedPropertiesForUser(
      {required String userId}) async {
    try {
      print('🔍 FETCH BOOKMARKS: Requesting bookmarked properties for user $userId');
      final supabase = Supabase.instance.client;
      
      // Get bookmarked properties with all related media
      final List<dynamic> bookmarks = await supabase
          .from('bookmarks')
          .select('*, property:property_id(*)')
          .eq('user_id', userId);
      
      print('✅ FETCH BOOKMARKS: Found ${bookmarks.length} bookmarked properties');
      
      if (bookmarks.isEmpty) {
        return [];
      }
      
      // Extract the property data from each bookmark and convert to UserProperty objects
      final List<UserProperty> properties = [];
      
      for (var i = 0; i < bookmarks.length; i++) {
        try {
          final bookmark = bookmarks[i];
          final propertyData = bookmark['property'];
          
          if (propertyData == null) {
            print('⚠️ FETCH BOOKMARKS: Bookmark ${i+1} has no property data');
            continue;
          }
          
          // Fetch media for this property
          final List<dynamic> mediaItems = await supabase
              .from('property_media')
              .select()
              .eq('property_id', propertyData['id'])
              .order('created_at');
              
          // Add media to property data
          propertyData['property_media'] = mediaItems;
          
          // Create UserProperty object
          final property = UserProperty.fromJson(propertyData);
          properties.add(property);
          print('✅ FETCH BOOKMARKS: Successfully parsed property ${i+1}/${bookmarks.length}');
          
        } catch (e) {
          print('❌ FETCH BOOKMARKS ERROR: Failed to parse property ${i+1}: $e');
          // Continue processing other bookmarks
        }
      }
      
      print('✅ FETCH BOOKMARKS: Returning ${properties.length} parsed properties');
      return properties;
    } catch (e) {
      print('❌ FETCH BOOKMARKS ERROR: Exception: $e');
      print('❌ FETCH BOOKMARKS ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to load bookmarked properties: $e');
    }
  }

  // Spaces
  Future<List<SpaceCategory>> fetchSpaceCategories() async {
    try {
      print('🔍 FETCH SPACE CATEGORIES: Requesting categories from Supabase');
      final supabase = Supabase.instance.client;
      
      // Get all space categories
      final List<dynamic> categories = await supabase
          .from('space_categories')
          .select('*, subcategories(*)')
          .order('display_order');
      
      print('✅ FETCH SPACE CATEGORIES: Successfully fetched ${categories.length} categories');
      
      // Convert to SpaceCategory objects
      final result = categories
          .map((category) => SpaceCategory.fromJson(category))
          .toList();
          
      return result;
    } catch (e) {
      print('❌ FETCH SPACE CATEGORIES ERROR: Exception: $e');
      print('❌ FETCH SPACE CATEGORIES ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to load space categories: $e');
    }
  }

  Future<List<Space>> fetchSpaces({
    String? categoryId,
    String? subcategoryId,
    String? userId,
  }) async {
    try {
      print('🔍 FETCH SPACES: Requesting spaces with filters - categoryId: $categoryId, subcategoryId: $subcategoryId, userId: $userId');
      final supabase = Supabase.instance.client;
      
      // Start building the query
      var query = supabase
          .from('spaces')
          .select('*, category:category_id(*), subcategory:subcategory_id(*), user:user_id(*), space_media(*)');
      
      // Apply filters
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      
      if (subcategoryId != null) {
        query = query.eq('subcategory_id', subcategoryId);
      }
      
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      // Execute the query with ordering
      final List<dynamic> spaces = await query.order('created_at', ascending: false);
      
      print('✅ FETCH SPACES: Successfully fetched ${spaces.length} spaces');
      
      // Convert to Space objects
      final result = spaces
          .map((space) => Space.fromJson(space))
          .toList();
          
      return result;
    } catch (e) {
      print('❌ FETCH SPACES ERROR: Exception: $e');
      print('❌ FETCH SPACES ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to load spaces: $e');
    }
  }

  Future<Map<String, dynamic>> addSpace(Map<String, dynamic> spaceData) async {
    try {
      print('🏢 ADD SPACE: Starting space creation with data: ${jsonEncode(spaceData)}');
      final supabase = Supabase.instance.client;
      
      // Add creation timestamp if not present
      if (!spaceData.containsKey('created_at')) {
        spaceData['created_at'] = DateTime.now().toIso8601String();
      }
      
      // Generate random ID for space if not provided
      if (!spaceData.containsKey('id')) {
        final random = Random.secure();
        final randomString = List.generate(20, (_) => random.nextInt(16).toRadixString(16)).join();
        spaceData['id'] = 'space_$randomString';
      }
      
      // Insert the space into the database
      await supabase.from('spaces').insert(spaceData);
      
      print('✅ ADD SPACE: Successfully added space with ID: ${spaceData['id']}');
      
      return {
        'status': 'success',
        'message': 'Space added successfully',
        'space_id': spaceData['id']
      };
    } catch (e) {
      print('❌ ADD SPACE ERROR: Exception: $e');
      print('❌ ADD SPACE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      
      return {
        'status': 'error',
        'message': 'Failed to add space: $e'
      };
    }
  }

  Future<Map<String, dynamic>> uploadSpaceMedia(
    String spaceId, 
    String mediaType, 
    dynamic fileData, // Can be XFile, Uint8List, String path, or html.File (web)
    bool isThumbnail,
  ) async {
    try {
      print('🖼️ UPLOAD SPACE MEDIA: Starting upload for space $spaceId, mediaType $mediaType, thumbnail $isThumbnail');
      final supabase = Supabase.instance.client;
      
      // Determine storage bucket
      String bucketName = mediaType == 'video' ? 'spaces-videos' : 'spaces-images';
      String contentType = mediaType == 'video' ? 'video/mp4' : 'image/jpeg';
      String fileExtension = mediaType == 'video' ? '.mp4' : '.jpg';
      
      // Generate a unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final fileName = '${spaceId}_$timestamp$fileExtension';
      String fileUrl = '';
      
      // Convert all file types to bytes first
      Uint8List bytes;
      
      if (kIsWeb) {
        // Web platform handling
        if (fileData is html.File) {
          bytes = await _readHtmlFile(fileData);
        } else if (fileData is String && fileData.startsWith('blob:')) {
          bytes = await _readBlobData(fileData);
        } else if (fileData is String && fileData.startsWith('data:')) {
          final commaIndex = fileData.indexOf(',');
          if (commaIndex == -1) throw Exception('Invalid data URI format');
          bytes = base64Decode(fileData.substring(commaIndex + 1));
        } else if (fileData is Uint8List) {
          bytes = fileData;
        } else if (fileData is XFile) {
          bytes = await fileData.readAsBytes();
        } else {
          return {'status': 'error', 'message': 'Unsupported file type for web'};
        }
      } else {
        // Mobile platform handling
        if (fileData is XFile) {
          bytes = await fileData.readAsBytes();
        } else if (fileData is String) {
          bytes = await io.File(fileData).readAsBytes();
        } else if (fileData is Uint8List) {
          bytes = fileData;
        } else {
          return {'status': 'error', 'message': 'Unsupported file type for mobile'};
        }
      }
      
      // Upload the bytes to Supabase
      await supabase.storage
          .from(bucketName)
          .uploadBinary(fileName, bytes, fileOptions: FileOptions(contentType: contentType));
      
      fileUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
      print('✅ UPLOAD SPACE MEDIA: Successfully uploaded to $fileUrl');
      
      // Save media information to database
      final mediaData = {
        'space_id': spaceId,
        'media_url': fileUrl,
        'media_type': mediaType,
        'is_thumbnail': isThumbnail,
        'created_at': DateTime.now().toIso8601String()
      };
      
      await supabase.from('space_media').insert(mediaData);
      
      print('✅ UPLOAD SPACE MEDIA: Media information saved to database');
      
      return {
        'status': 'success',
        'message': 'Media uploaded successfully',
        'file_path': fileUrl,
        'media_type': mediaType
      };
    } catch (e) {
      print('❌ UPLOAD SPACE MEDIA ERROR: $e');
      print('❌ UPLOAD SPACE MEDIA ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return {'status': 'error', 'message': 'Error occurred during media upload: $e'};
    }
  }

  // Helper function for web file reading
  Future<Uint8List> _readHtmlFile(html.File file) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    await reader.onLoad.first;
    return reader.result as Uint8List;
  }

  // Helper function for web blob reading
  Future<Uint8List> _readBlobData(String blobUrl) async {
    final completer = Completer<Uint8List>();
    final xhr = html.HttpRequest();
    xhr.open('GET', blobUrl);
    xhr.responseType = 'arraybuffer';
    xhr.onLoad.listen((_) => completer.complete(Uint8List.fromList(xhr.response as List<int>)));
    xhr.onError.listen(completer.completeError);
    xhr.send();
    return completer.future;
  }

  Future<Map<String, dynamic>> updateSpace(
      String spaceId, Map<String, dynamic> updatedData) async {
    try {
      print('🏢 UPDATE SPACE: Updating space $spaceId with data: ${jsonEncode(updatedData)}');
      final supabase = Supabase.instance.client;
      
      // Add updated timestamp
      updatedData['updated_at'] = DateTime.now().toIso8601String();
      
      // Update the space in the database
      await supabase
          .from('spaces')
          .update(updatedData)
          .eq('id', spaceId);
          
      print('✅ UPDATE SPACE: Space updated successfully');
      
      return {
        'status': 'success',
        'message': 'Space updated successfully',
        'space_id': spaceId
      };
    } catch (e) {
      print('❌ UPDATE SPACE ERROR: Exception: $e');
      print('❌ UPDATE SPACE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      
      return {
        'status': 'error',
        'message': 'Failed to update space: $e'
      };
    }
  }

  Future<Map<String, dynamic>> deleteSpace(String spaceId) async {
    try {
      print('🗑️ DELETE SPACE: Starting space deletion for ID: $spaceId');
      final supabase = Supabase.instance.client;
      
      // First, find all media files associated with this space
      final List<dynamic> mediaFiles = await supabase
          .from('space_media')
          .select()
          .eq('space_id', spaceId);
      
      print('🗑️ DELETE SPACE: Found ${mediaFiles.length} media files to delete');
      
      // Delete each media file from storage
      for (var mediaFile in mediaFiles) {
        final String mediaUrl = mediaFile['media_url'];
        final String mediaType = mediaFile['media_type'];
        
        try {
          // Extract filename from URL
          final uri = Uri.parse(mediaUrl);
          final String filename = uri.pathSegments.last;
          final String bucketName = mediaType == 'video' ? 'spaces-videos' : 'spaces-images';
          
          // Remove file from storage
          await supabase.storage.from(bucketName).remove([filename]);
          print('✅ DELETE SPACE: Deleted file $filename from storage');
        } catch (e) {
          print('⚠️ DELETE SPACE: Error deleting media file $mediaUrl: $e');
          // Continue with other files even if one deletion fails
        }
      }
      
      // Delete media records from database
      await supabase
          .from('space_media')
          .delete()
          .eq('space_id', spaceId);
      
      print('✅ DELETE SPACE: Deleted all media records from database');
      
      // Finally, delete the space itself
      await supabase
          .from('spaces')
          .delete()
          .eq('id', spaceId);
      
      print('✅ DELETE SPACE: Space deleted successfully');
      
      return {
        'status': 'success',
        'message': 'Space and associated media deleted successfully'
      };
    } catch (e) {
      print('❌ DELETE SPACE ERROR: Exception: $e');
      print('❌ DELETE SPACE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      
      return {
        'status': 'error',
        'message': 'Failed to delete space: $e'
      };
    }
  }

  // Business profile methods
  Future<bool> checkBusinessProfileExists(String userId) async {
    try {
      print('🔍 CHECK BUSINESS PROFILE: Looking for profile for user $userId');
      final supabase = Supabase.instance.client;
      
      // Check if a business profile exists for this user
      final List<dynamic> profiles = await supabase
          .from('business_profiles')
          .select()
          .eq('user_id', userId.toString())
          .limit(1);
      
      final bool exists = profiles.isNotEmpty;
      
      print('✅ CHECK BUSINESS PROFILE: Profile exists: $exists');
      return exists;
    } catch (e) {
      print('❌ CHECK BUSINESS PROFILE ERROR: Exception: $e');
      print('❌ CHECK BUSINESS PROFILE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getBusinessProfile(String userId) async {
    print('Getting business profile for user $userId from Supabase');
    try {
      final supabase = Supabase.instance.client;
      final List<dynamic> profiles = await supabase
          .from('business_profiles')
          .select()
          .eq('user_id', userId)
          .limit(1);
      if (profiles.isNotEmpty) {
        print('Successfully retrieved profile');
        return profiles.first;
      } else {
        print('Business profile not found');
        throw Exception('Business profile not found');
      }
    } catch (e) {
      print('Error in getBusinessProfile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBusinessProfile(String userId, Map<String, dynamic> profile) async {
    print('Creating business profile for user $userId');
    print('Profile data: $profile');
    try {
      final supabase = Supabase.instance.client;
      
      // Add the userId to the profile data
      final profileData = {
        'user_id': userId,
        ...profile,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()
      };
      
      print('Inserting into supabase business_profiles table');
      final response = await supabase
          .from('business_profiles')
          .insert(profileData)
          .select()
          .single();
      
      print('Supabase response: $response');
      
      return {
        'success': true,
        'profile_id': response['id'],
        'data': response,
        'message': 'Business profile created successfully'
      };
    } catch (e) {
      print('❌ CREATE BUSINESS PROFILE ERROR: Exception: $e');
      print('❌ CREATE BUSINESS PROFILE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to create business profile: $e');
    }
  }

  Future<Map<String, dynamic>> updateBusinessProfile(String userId, Map<String, dynamic> profile) async {
    print('Updating business profile for user $userId');
    print('Profile data: $profile');
    try {
      final supabase = Supabase.instance.client;
      
      // Add updated timestamp
      final updatedData = {
        ...profile,
        'updated_at': DateTime.now().toIso8601String()
      };
      
      print('Updating supabase business_profiles table');
      final response = await supabase
          .from('business_profiles')
          .update(updatedData)
          .eq('user_id', userId)
          .select()
          .single();
      
      print('Supabase response: $response');
      
      return {
        'success': true,
        'data': response,
        'message': 'Business profile updated successfully'
      };
    } catch (e) {
      print('❌ UPDATE BUSINESS PROFILE ERROR: Exception: $e');
      print('❌ UPDATE BUSINESS PROFILE ERROR: Stack trace: ${e is Error ? e.stackTrace : 'No stack trace'}');
      throw Exception('Failed to update business profile: $e');
    }
  }

  Future<Map<String, dynamic>> uploadBusinessLogo(String userId, dynamic image, [String? fileName]) async {
    try {
      final supabase = Supabase.instance.client;
      final bucketName = 'business-logos';
      final contentType = 'image/jpeg';
      final finalFileName = fileName ?? 'business_logo_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      Uint8List bytes;
      
      if (kIsWeb) {
        // Web platform handling
        if (image is html.File) {
          bytes = await _readHtmlFile(image);
        } else if (image is Uint8List) {
          bytes = image;
        } else if (image is String && image.startsWith('blob:')) {
          bytes = await _readBlobData(image);
        } else if (image is String && image.startsWith('data:')) {
          final commaIndex = image.indexOf(',');
          if (commaIndex == -1) throw Exception('Invalid data URI format');
          bytes = base64Decode(image.substring(commaIndex + 1));
        } else {
          throw Exception('Unsupported image type for web');
        }
      } else {
        // Mobile platform handling
        if (image is io.File) {
          bytes = await image.readAsBytes();
        } else if (image is Uint8List) {
          bytes = image;
        } else if (image is String) {
          bytes = await io.File(image).readAsBytes();
        } else {
          throw Exception('Unsupported image type for mobile');
        }
      }
      
      await supabase.storage
          .from(bucketName)
          .uploadBinary(finalFileName, bytes, fileOptions: FileOptions(contentType: contentType));
      
      final fileUrl = supabase.storage.from(bucketName).getPublicUrl(finalFileName);
      
      return {
        'success': true,
        'url': fileUrl,
        'message': 'Logo uploaded successfully'
      };
    } catch (e) {
      print('❌ UPLOAD LOGO ERROR: $e');
      return {
        'success': false,
        'message': 'Failed to upload logo: $e'
      };
    }
  }

  
}
