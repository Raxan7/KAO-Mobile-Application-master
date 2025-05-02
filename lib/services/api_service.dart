import 'package:http/http.dart' as http;
import 'dart:convert';
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
import 'dart:io'; // Import dart:io for File class
import 'package:path_provider/path_provider.dart'; // Import path_provider for getTemporaryDirectory
import '../utils/constants.dart';

class ApiService {
  static const String imageUrl = baseUrl;
  static const String baseUrl = apiUrl;

  Future<List<Hotel>> fetchHotels() async {
    final response = await http.get(Uri.parse('$baseUrl/hotels.php'));
    // print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((hotel) => Hotel.fromJson(hotel)).toList();
    } else {
      throw Exception('Failed to load hotels');
    }
  }

  Future<List<Motel>> fetchMotels() async {
    final response = await http.get(Uri.parse('$baseUrl/motels.php'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((motel) => Motel.fromJson(motel)).toList();
    } else {
      throw Exception('Failed to load motels');
    }
  }

  Future<List<Hostel>> fetchHostels() async {
    final response = await http.get(Uri.parse('$baseUrl/hostels.php'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((hostel) => Hostel.fromJson(hostel)).toList();
    } else {
      throw Exception('Failed to load hostels');
    }
  }

  Future<List<Lodge>> fetchLodges() async {
    final response = await http.get(Uri.parse('$baseUrl/lodges.php'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((lodge) => Lodge.fromJson(lodge)).toList();
    } else {
      throw Exception('Failed to load lodges');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'), // Updated endpoint
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }, // Correct content type for form data
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body); // Return the response body
    } else {
      throw Exception('Failed to login'); // Handle errors
    }
  }

  Future<Map<String, dynamic>> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/user/profile.php'), // Update with your profile endpoint
      headers: {
        'Authorization':
            'Bearer $token', // Send the token in the Authorization header
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body); // Return the response as a Map
    } else {
      throw Exception('Failed to load user profile'); // Handle errors
    }
  }

  // Add the fetchRoomDetails function
  Future<Map<String, dynamic>> fetchRoomDetails(
      String roomId, String accommodationType) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/${accommodationType}_room_detail.php?room_id=$roomId'), // Room details API endpoint
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body); // Return room details as a Map
    } else {
      throw Exception('Failed to load room details'); // Handle errors
    }
  }

  // Function to fetch bookings for a specific user
  Future<List<Booking>> fetchUserBookings(String userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/user_bookings.php?user_id=$userId'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['status']) {
        // Map the booking data to a list of Booking objects
        List<dynamic> bookingsJson = data['data'];
        return bookingsJson
            .map((booking) => Booking.fromJson(booking))
            .toList();
      } else {
        throw Exception('Failed to fetch bookings: ${data['message']}');
      }
    } else {
      throw Exception('Failed to fetch bookings');
    }
  }

  Future<Map<String, dynamic>> checkAvailability(
      String roomId, String checkIn, String checkOut) async {
    final response = await http.post(
      Uri.parse('$baseUrl/booking.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'check_availability': '',
        'check_in': checkIn,
        'check_out': checkOut,
        'room_id': roomId,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to check availability');
    }
  }

  Future<Map<String, dynamic>> createBooking(Booking booking) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/booking.php'), // Make sure this is the correct endpoint
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      }, // Form URL-encoded headers
      body: {
        'book_room':
            '', // This should match what the API expects for booking action
        'user_id': booking.userId,
        'room_id': booking
            .hotelId, // Assuming hotelId is the room_id, adjust if needed
        'check_in': booking.checkIn.toIso8601String(),
        'check_out': booking.checkOut.toIso8601String(),
        'total_amount': booking.totalAmount.toString(),
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> result = json.decode(response.body);
      if (result['status'] == 'success') {
        return result;
      } else {
        throw Exception(result['message'] ?? 'Failed to create booking');
      }
    } else {
      // // print('Response body: ${response.body}');
      throw Exception('Failed to create booking');
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
    String roomName, // Add roomName
    String roomPrice, // Add roomPrice
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book_room.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'book_room': '',
        'room_id': roomId,
        'checkin': checkIn,
        'checkout': checkOut,
        'user_id': userId,
        'name': userName,
        'phonenum': phoneNum,
        'address': address,
        'room_name': roomName, // Include room name
        'room_price': roomPrice, // Include room price
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create booking');
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
    required String role, // Add role parameter
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register_user.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'name': name,
        'email': email,
        'phonenum': phonenum,
        'address': address,
        'pincode': pincode,
        'dob': dob,
        'pass': pass,
        'cpass': cpass,
        'role': role, // Pass the selected role
        'guest_register': '', // Indicate registration type
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  // Dalali API Services

  // Add Property
  static Future<Map<String, dynamic>> addProperty(
      Map<String, dynamic> propertyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dalali/add_property.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token', // Ensure a valid token is used
      },
      body: jsonEncode(
          propertyData), // jsonEncode can handle both strings and numbers
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add property');
    }
  }

  // Upload Property Media
  static Future<Map<String, dynamic>> uploadPropertyMedia(
      String propertyId, String mediaType, String filePath, bool thumb) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/dalali/upload_property_media.php'));

      // Set fields with property_id as String
      request.fields['property_id'] = propertyId; // Property ID as String
      request.fields['media_type'] = mediaType; // Media type (image/video)
      request.fields['thumb'] = thumb ? '1' : '0'; // Thumbnail flag as String

      // Add the media file to the request
      request.files
          .add(await http.MultipartFile.fromPath('media_file', filePath));

      // Send the request and get the response
      final response = await request.send();

      // Check if the response was successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decode the response body
        final responseBody = await response.stream.bytesToString();
        print("Everything is going great $responseBody");
        return jsonDecode(responseBody);
      } else {
        // Handle non-200 responses
        return {
          'status': 'error',
          'message': 'Failed to upload media: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Catch any errors during the upload process
      return {
        'status': 'error',
        'message': 'Error occurred during media upload: $e'
      };
    }
  }

  // Delete Property Media
  static Future<Map<String, dynamic>> deletePropertyMedia(
      String mediaUrl) async {
    try {
      // Create the URL for the DELETE request
      final url = Uri.parse('$baseUrl/dalali/delete_property_media.php');

      // Prepare the request body or parameters
      final response = await http.post(
        url,
        body: {
          'media_url': mediaUrl, // URL of the media to delete
        },
      );

      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        return responseBody;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to delete media: ${response.statusCode}'
        };
      }
    } catch (e) {
      // Handle exceptions
      return {
        'status': 'error',
        'message': 'Error occurred during media deletion: $e'
      };
    }
  }

  // Delete Message
  static Future<void> deleteMessage(int messageId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_message.php?message_id=$messageId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        print("Message deleted successfully");
      } else {
        throw Exception("Failed to delete message: ${result['error']}");
      }
    } else {
      throw Exception("Failed to delete message (HTTP ${response.statusCode})");
    }
  }

  // Update Property
  static Future<Map<String, dynamic>> updateProperty(
      String propertyId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dalali/update_property.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token', // Ensure a valid token
      },
      body: jsonEncode({'property_id': propertyId, ...updatedData}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update property');
    }
  }

  // Delete Property
  static Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/dalali/delete_property.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_token', // Ensure a valid token
      },
      body: jsonEncode({'property_id': propertyId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to delete property');
    }
  }

  static Future<List<Property>> fetchProperties(String userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/dalali/fetch_properties.php?user_id=$userId'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Property.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  // Method to fetch properties overview for a specific user
  static Future<Map<String, int>> fetchPropertiesOverview(int userId) async {
    try {
      final url = Uri.parse(
          '$baseUrl/dalali/get_dalali_properties.php?user_id=$userId');

      final response = await http.get(url);
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return {
          'for_sale': int.tryParse(data['for_sale']?.toString() ?? '0') ?? 0,
          'for_rent': int.tryParse(data['for_rent']?.toString() ?? '0') ?? 0,
        };
      } else {
        throw Exception(
            'Failed to load properties overview: Server responded with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(
          'An error occurred while loading properties overview. Please check your network connection or try again later.');
    }
  }

  // Fetch unreplied enquiries for the dashboard
  static Future<List<dynamic>> fetchUnrepliedEnquiries(int userId) async {
    final response = await http.get(Uri.parse(
        '$baseUrl/dalali/get_unreplied_enquiries.php?user_id=$userId'));
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load unreplied enquiries');
    }
  }

  // Fetch all enquiries for the detailed enquiries page
  static Future<List<dynamic>> fetchAllEnquiriesDalali(int dalaliId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/dalali/get_all_enquiries.php?dalali_id=$dalaliId'));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load all enquiries');
    }
  }

  // Fetch All Enquiries
  static Future<List<dynamic>> fetchAllEnquiriesUser(int userId) async {
    final response = await http
        .get(Uri.parse('$baseUrl/user/get_all_enquiries.php?user_id=$userId'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ Decode response body properly using UTF-8
      final String decodedBody = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(decodedBody);

      if (jsonData is List) {
        return jsonData; // ✅ Return list if correct format
      } else if (jsonData is Map<String, dynamic>) {
        throw Exception("API Error: ${jsonData['error'] ?? 'Unknown error'}");
      } else {
        throw Exception("Unexpected API response format");
      }
    } else {
      throw Exception(
          'Failed to load all enquiries (HTTP ${response.statusCode})');
    }
  }

  Future<List<UserProperty>> fetchPropertiesForUser({String? userId}) async {
    final url = userId != null
        ? '$baseUrl/properties.php?user_id=$userId'
        : '$baseUrl/properties.php';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedResponse = json.decode(response.body);

      // Ensure we extract the list correctly
      List<dynamic> data;
      if (decodedResponse is List) {
        data = decodedResponse;
      } else if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('properties')) {
        data = decodedResponse['properties'];
      } else {
        throw Exception('Unexpected response format');
      }

      return data.map((property) => UserProperty.fromJson(property)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }

  static Future<Map<String, dynamic>> fetchPropertyDetailForUser(
      int propertyId) async {
    final response = await http
        .get(Uri.parse('$apiUrl/property_detail.php?property_id=$propertyId'));

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load property details');
    }
  }

  // Fetch messages
  static Future<List<Map<String, dynamic>>> fetchMessages(
      int propertyId, int senderId, int receiverId) async {
    final response = await http.get(
      Uri.parse(
          '$apiUrl/get_messages.php?property_id=$propertyId&sender_id=$senderId&receiver_id=$receiverId'),
    );

    // // print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Send a message
  static Future<void> sendMessageForUser({
    required int senderId,
    required int receiverId,
    required int propertyId,
    required String message,
    String messageType = 'text', // Default message type is 'text'
    String? attachmentUrl, // Optional attachment URL for other media types
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/send_message.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'sender_id': senderId,
        'receiver_id': receiverId,
        'property_id': propertyId,
        'message': message,
        'message_type': messageType,
        'attachment_url': attachmentUrl,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  static Future<void> replyToUserMessage({
    required int dalaliId,
    required int userId, // Added userId
    required int propertyId, // Added propertyId
    required String message,
    String messageType = 'text', // Default to 'text' if not provided
    String? attachmentUrl, // Optional attachment URL
  }) async {
    final response = await http.post(
      Uri.parse('$apiUrl/dalali/reply_to_message.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'sender_id': dalaliId,
        'receiver_id': userId, // Include receiver_id
        'property_id': propertyId, // Include property_id
        'message': message,
        'message_type': messageType, // Add message type
        'attachment_url': attachmentUrl, // Add attachment URL if provided
      }),
    );

    // Log the response body for debugging
    // // print('Response status: ${response.statusCode}');
    // // print('Response body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  // Get unreplied messages count
  static Future<int> fetchUnrepliedMessageCount(int userId) async {
    final response = await http.get(Uri.parse(
        '$apiUrl/dalali/get_unreplied_count.php?userId=$userId'));

    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['unreplied_count'] ?? 0;
      }
    }
    return 0;
  }

  static Future<void> reactToMessage(int messageId, String reaction) async {
    final response = await http.post(
      Uri.parse('$apiUrl/dalali/react_to_message.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'message_id': messageId,
        'reaction': reaction,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      // // print(response.body);
      throw Exception('Failed to send reaction');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMessagesById(
      int messageId, int propertyId) async {
    final response = await http.get(
      Uri.parse(
          '$apiUrl/dalali/fetch_messages_by_id.php?message_id=$messageId&property_id=$propertyId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    // // print(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse the JSON response
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load messages');
    }
  }

  // Fetch user details by userId
  static Future<Map<String, dynamic>> fetchUserDetails(int userId) async {
    try {
      final response = await http.get(Uri.parse(
          '$apiUrl/dalali/enquiries/fetch_user_details.php?user_id=$userId'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decode the JSON response
        final data = json.decode(response.body);
        return data;
      } else {
        // Handle the case where the server returns an error
        // print('Failed to load user details: ${response.statusCode}');
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      // // print('Error fetching user details: $e');
      throw Exception('Error fetching user details');
    }
  }

  static Future<void> removeReactionFromMessage(int messageId) async {
    final response = await http.post(
      Uri.parse('$apiUrl/remove_reaction.php'),
      body: {'message_id': messageId.toString()},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to remove reaction');
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(
      String email, String googleId, String name, String profilePic) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/loginWithGoogle.php'),
        body: {
          'email': email,
          'google_id': googleId,
          'name': name,
          'profile_pic': profilePic,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to connect to the server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: $e',
      };
    }
  }

  // Create Notification
  static Future<Map<String, dynamic>> createNotification(
      int userId, int targetUserId, int propertyId) async {
    final url = Uri.parse('$baseUrl/create_notification.php');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "target_user_id": targetUserId,
          "property_id": propertyId,
          "message": "Property Requested!"
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body); // Assuming JSON response
      } else {
        return {"status": "error", "message": "Failed to create notification"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchNotifications(
      int targetUserId) async {
    final url = Uri.parse(
        '$baseUrl/dalali/fetch_unread_notifications.php?target_user_id=$targetUserId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return List<Map<String, dynamic>>.from(data['notifications']);
        } else {
          return [];
        }
      } else {
        print(response.body);
        return [];
      }
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  /// Marks a notification as read
  static Future<void> markNotificationAsRead(int notificationId) async {
    // Update the endpoint to match the PHP script
    final url =
        '$baseUrl/dalali/mark_notification_read.php?notificationId=$notificationId';

    try {
      final response = await http.get(
        Uri.parse(url), // Using GET because the PHP script expects it
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          print('Notification marked as read.');
        } else {
          throw Exception(responseBody['message'] ??
              'Failed to update notification status.');
        }
      } else {
        throw Exception(
            'Failed to update notification status: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Fetches sender details based on the user ID
  static Future<Map<String, dynamic>> fetchSenderDetails(int userId) async {
    // Update the endpoint to match the PHP script
    final url = '$baseUrl/dalali/get_user_details.php?userId=$userId';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] == true) {
          return responseBody['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
              responseBody['message'] ?? 'Failed to fetch sender details.');
        }
      } else {
        throw Exception(
            'Failed to fetch sender details: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching sender details: $e');
      return {};
    }
  }

  static Future<List<NotificationModel>> fetchNotificationsAll(
      int targetUserId) async {
    final url =
        '$baseUrl/dalali/fetch_notifications.php?target_user_id=$targetUserId';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final notifications = (data['notifications'] as List)
            .map((notification) => NotificationModel.fromJson(notification))
            .toList();
        return notifications;
      } else {
        throw Exception('Failed to fetch notifications');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<bool> updateBrokerDetails(
      int userId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('https://your-api-url.com/brokers/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Failed to update broker details');
    }
  }

  /// Fetch user details from the API
  Future<Map<String, dynamic>> getUserDetails(int userId) async {
    final String url = '$baseUrl/get_user_details.php?userId=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          // If the user data is successfully retrieved
          return responseData['data'];
        } else {
          // If the API returns a failure response
          throw Exception(
              responseData['message'] ?? 'Failed to fetch user details');
        }
      } else {
        throw Exception(
            'Failed to load user details. HTTP Status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('An error occurred while fetching user details: $error');
    }
  }

  // Bookmarked Properties
  Future<List<UserProperty>> fetchBookmarkedPropertiesForUser(
      {required String userId}) async {
    final url = '$baseUrl/bookmarked_properties.php?user_id=$userId';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decodedResponse = json.decode(response.body);

      // Extract properties from response
      List<dynamic> data;
      if (decodedResponse is Map<String, dynamic> &&
          decodedResponse.containsKey('bookmarked_properties')) {
        data = decodedResponse['bookmarked_properties'];
      } else {
        throw Exception('Unexpected response format');
      }

      return data.map((property) => UserProperty.fromJson(property)).toList();
    } else {
      throw Exception('Failed to load bookmarked properties');
    }
  }

  // Spaces
  static Future<List<SpaceCategory>> fetchSpaceCategories() async {
    try {
      print('Fetching space categories from: $baseUrl/user/fetch_space_categories.php');
      final response = await http.get(Uri.parse('$baseUrl/user/fetch_space_categories.php'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('Successfully fetched ${(data['data'] as List).length} categories');
          return (data['data'] as List)
              .map((category) => SpaceCategory.fromJson(category))
              .toList();
        } else {
          print('API Error: ${data['message'] ?? 'No error message provided'}');
          throw Exception(data['message'] ?? 'Failed to load categories');
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to load categories - HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchSpaceCategories: $e');
      print('Stack trace: ${e is Error ? (e).stackTrace : ''}');
      rethrow;
    }
  }

  static Future<List<Space>> fetchSpaces({
    String? categoryId,
    String? subcategoryId,
    String? userId,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (subcategoryId != null) queryParams['subcategory_id'] = subcategoryId;
      // if (userId != null) queryParams['user_id'] = userId;

      final uri = Uri.parse('$baseUrl/user/fetch_spaces.php').replace(queryParameters: queryParams);
      print('Fetching spaces from: $uri');
      
      final response = await http.get(uri);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('Successfully fetched ${(data['data'] as List).length} spaces');
          return (data['data'] as List)
              .map((space) => Space.fromJson(space))
              .toList();
        } else {
          print('API Error: ${data['message'] ?? 'No error message provided'}');
          throw Exception(data['message'] ?? 'Failed to load spaces');
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to load spaces - HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in fetchSpaces: $e');
      print('Stack trace: ${e is Error ? (e).stackTrace : ''}');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addSpace(Map<String, dynamic> spaceData) async {
    try {
      print('Adding space with data: ${jsonEncode(spaceData)}');
      final response = await http.post(
        Uri.parse('$baseUrl/user/add_space.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(spaceData),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          print('Successfully added space with ID: ${result['space_id']}');
        } else {
          print('API Error: ${result['message'] ?? 'No error message provided'}');
        }
        return result;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to add space - HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in addSpace: $e');
      print('Stack trace: ${e is Error ? (e).stackTrace : ''}');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> uploadSpaceMedia(
    String spaceId, 
    String mediaType, 
    dynamic fileData, // Can be File, Uint8List, or String path
    bool isThumbnail,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/user/upload_space_media.php'),
      );

      // Add required fields
      request.fields['space_id'] = spaceId;
      request.fields['media_type'] = mediaType;
      request.fields['thumb'] = isThumbnail ? '1' : '0';

      // Handle different file types
      if (fileData is File) {
        request.files.add(await http.MultipartFile.fromPath(
          'media_file',
          fileData.path,
        ));
      } else if (fileData is Uint8List) {
        if (kIsWeb) {
          // For web - convert bytes directly
          request.files.add(http.MultipartFile.fromBytes(
            'media_file',
            fileData,
            filename: 'space_media_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ));
        } else {
          // For mobile - save to temp file first
          final tempFile = File('${(await getTemporaryDirectory()).path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await tempFile.writeAsBytes(fileData);
          request.files.add(await http.MultipartFile.fromPath(
            'media_file',
            tempFile.path,
          ));
          await tempFile.delete();
        }
      } else if (fileData is String) {
        request.files.add(await http.MultipartFile.fromPath(
          'media_file',
          fileData,
        ));
      } else {
        throw ArgumentError('Unsupported file type');
      }

      // Send the request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }

      final result = jsonDecode(responseBody);
      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Upload failed');
      }

      return result;
    } catch (e) {
      print('Error uploading space media: $e');
      throw Exception('Failed to upload space media: $e');
    }
  }

  static Future<Map<String, dynamic>> updateSpace(
      String spaceId, Map<String, dynamic> updatedData) async {
    try {
      print('Updating space $spaceId with data: ${jsonEncode(updatedData)}');
      final response = await http.put(
        Uri.parse('$baseUrl/user/update_space.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'space_id': spaceId, ...updatedData}),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          print('Successfully updated space $spaceId');
        } else {
          print('API Error: ${result['message'] ?? 'No error message provided'}');
        }
        return result;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to update space - HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in updateSpace: $e');
      print('Stack trace: ${e is Error ? (e).stackTrace : ''}');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteSpace(String spaceId) async {
    try {
      print('Deleting space $spaceId');
      final response = await http.delete(
        Uri.parse('$baseUrl/user/delete_space.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'space_id': spaceId}),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        if (result['status'] == 'success') {
          print('Successfully deleted space $spaceId');
        } else {
          print('API Error: ${result['message'] ?? 'No error message provided'}');
        }
        return result;
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        throw Exception('Failed to delete space - HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in deleteSpace: $e');
      print('Stack trace: ${e is Error ? (e).stackTrace : ''}');
      rethrow;
    }
  }

  // Add these methods to your ApiService class

  // Add these methods to your ApiService class
  Future<bool> checkBusinessProfileExists(int userId) async {
    print('Checking if business profile exists for user $userId');
    try {
      final url = '$baseUrl/business_profiles.php?action=exists&user_id=$userId';
      print('Making request to: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('Exists check result: ${data['exists']}');
        return data['exists'] == true || data['exists'] == 'true';
      }
      print('Request failed with status ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error in checkBusinessProfileExists: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getBusinessProfile(int userId) async {
    print('Getting business profile for user $userId');
    try {
      final url = '$baseUrl/business_profiles.php?user_id=$userId';
      print('Making request to: $url');
      
      final response = await http.get(Uri.parse(url));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Successfully retrieved profile');
          return data['data'];
        } else {
          print('API returned error: ${data['message']}');
          throw Exception(data['message'] ?? 'Business profile not found');
        }
      } else {
        print('Request failed with status ${response.statusCode}');
        throw Exception('Failed to load business profile');
      }
    } catch (e) {
      print('Error in getBusinessProfile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBusinessProfile(int userId, Map<String, dynamic> profile) async {
    print('Creating business profile for user $userId');
    print('Profile data: $profile');
    try {
      const url = '$baseUrl/business_profiles.php';
      print('Making POST request to: $url');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'create',
          'user_id': userId,
          ...profile
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Request failed with status ${response.statusCode}');
        throw Exception('Failed to create business profile');
      }
    } catch (e) {
      print('Error in createBusinessProfile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBusinessProfile(int userId, Map<String, dynamic> profile) async {
    print('Updating business profile for user $userId');
    print('Profile data: $profile');
    try {
      const url = '$baseUrl/business_profiles.php';
      print('Making PUT request to: $url');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'update',
          'user_id': userId,
          ...profile
        }),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Request failed with status ${response.statusCode}');
        throw Exception('Failed to update business profile');
      }
    } catch (e) {
      print('Error in updateBusinessProfile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadBusinessLogo(int userId, dynamic image) async {
    print('Uploading business logo for user $userId');
    try {
      var url = '$baseUrl/upload_business_logo.php';
      print('Making multipart request to: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['user_id'] = userId.toString();

      if (image is File) {
        // Handle file upload for mobile/desktop
        request.files.add(await http.MultipartFile.fromPath('logo', image.path));
      } else if (image is Uint8List) {
        // Handle byte array upload for web
        request.files.add(http.MultipartFile.fromBytes(
          'logo',
          image,
          filename: 'business_logo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));
      } else {
        throw ArgumentError('Unsupported image type');
      }

      print('Sending logo upload request...');
      final response = await request.send();
      print('Upload response status: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      print('Upload response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(responseBody);
      } else {
        print('Logo upload failed with status ${response.statusCode}');
        throw Exception('Failed to upload logo: $responseBody');
      }
    } catch (e) {
      print('Error in uploadBusinessLogo: $e');
      throw Exception('Error uploading logo: $e');
    }
  }
}
