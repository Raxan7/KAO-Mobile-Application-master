import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kao_app/services/user_preferences.dart';
import 'package:kao_app/utils/constants.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/screens/profile_base_screen.dart';
import '../../models/user_property.dart';
import '../../views/user/property_detail.dart';

class PropertyCard extends StatefulWidget {
  final UserProperty property;
  final List<String> images;

  const PropertyCard({
    required this.property,
    required this.images,
    super.key,
  });

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentImageIndex = 0;
  Timer? _imageTimer;

  String? profilePicUrl;
  String? username;
  String? currentUserId;

  int likes = 0;
  bool isLiked = false;

  int comments = 0;
  int shares = 0;
  bool isBookmarked = false;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1) {
      _startImageCarousel();
    }
    _fetchUserDetails();
    _fetchInteractionCounts();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    currentUserId = await UserPreferences().getUserId();
    setState(() {});

    if (currentUserId != null) {
      _fetchInteractionCounts();
    }
  }

  void _startImageCarousel() {
    _imageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % widget.images.length;
        });
      }
    });
  }

  Future<void> _fetchUserDetails() async {
    final String apiUrl =
        "$baseUrl/api/dalali/get_user_details.php?userId=${widget.property.userId}";
    const String imageUrl = "$baseUrl/images/users/";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);

        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              profilePicUrl =
                  imageUrl + (responseData['data']['profile_picture'] ?? '');
              username = responseData['data']['name'] ?? 'Unknown User';
            });
          }
        } else {
          debugPrint("Error: ${responseData['message']}");
        }
      } else {
        debugPrint(
            "Error: Failed to load user details (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  String getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final adjustedCreatedAt =
        createdAt.add(const Duration(hours: 8)); // Fix time lag
    final difference = now.difference(adjustedCreatedAt);

    if (difference.inMinutes < 120) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 48) {
      return "${difference.inHours} hrs ago";
    } else if (difference.inDays < 14) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays < 63) {
      return "${(difference.inDays / 7).floor()} weeks ago";
    } else if (difference.inDays < 365) {
      return "${(difference.inDays / 30).floor()} months ago";
    } else {
      return "${(difference.inDays / 365).floor()} years ago";
    }
  }

  // Interactions Start
  Future<void> _fetchInteractionCounts() async {
    if (currentUserId == null) return; // Ensure currentUserId is loaded first

    final String apiUrl =
        "$baseUrl/api/interactions/interaction_counts.php?property_id=${widget.property.propertyId}&user_id=$currentUserId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          likes = int.tryParse(data['likes'].toString()) ?? 0;
          shares = int.tryParse(data['shares'].toString()) ?? 0;
          isLiked = data['isLiked'] ?? false; // Ensure isLiked is set
          print(isLiked);
        });
      } else {
        debugPrint(
            "Error: Failed to load interaction counts (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _likeProperty() async {
    const String apiUrl = "$baseUrl/api/interactions/like.php";
    final Map<String, dynamic> requestBody = {
      "user_id": currentUserId,
      "property_id": widget.property.propertyId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            isLiked = responseData['liked'];
            isLiked ? likes++ : likes--;
          });
          print(responseData);

          final String message = isLiked ? "Liked! 🎉" : "Unliked! ❌";
          Fluttertoast.showToast(msg: message);
        }
      } else {
        debugPrint(
            "Error: Failed to like property (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _bookmarkProperty() async {
    const String apiUrl = "$baseUrl/api/interactions/bookmark.php";
    final Map<String, dynamic> requestBody = {
      "user_id": currentUserId, // Replace with the logged-in user's ID
      "property_id": widget.property.propertyId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            isBookmarked = !isBookmarked;
          });
          Fluttertoast.showToast(
              msg: isBookmarked ? "Bookmarked!" : "Removed Bookmark");
        }
      } else {
        debugPrint(
            "Error: Failed to bookmark property (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _shareProperty() async {
    const String apiUrl = "$baseUrl/api/interactions/share.php";
    final Map<String, dynamic> requestBody = {
      "user_id": currentUserId, // Replace with the logged-in user's ID
      "property_id": widget.property.propertyId,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            shares++;
          });
          Fluttertoast.showToast(msg: "Shared!");
        }
      } else {
        debugPrint(
            "Error: Failed to share property (Status: ${response.statusCode})");
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Interactions End

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks
    _imageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat('#,###');
    final String formattedPrice = currencyFormat.format(widget.property.price);
    // final String formattedPostedDate = DateFormat('dd MMM yyyy, hh:mm a').format(widget.property.createdAt);
    final String timeAgo = getTimeAgo(widget.property.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetail(
              propertyId:
                  int.parse(widget.property.propertyId), // Passing propertyId
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.all(12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 12.0,
        shadowColor: Colors.black.withOpacity(0.3),
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              if (profilePicUrl != null && username != null)
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _navigateToProfile();
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(profilePicUrl!),
                          onBackgroundImageError: (_, __) {
                            debugPrint("Error loading profile picture");
                          },
                          backgroundColor: Colors.grey.shade200,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _navigateToProfile();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                username!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                timeAgo,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Image Section with Caption
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Image.network(
                      widget.images[_currentImageIndex],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red),
                    ),
                    if (widget.images.length > 1)
                      Positioned(
                        right: 8.0,
                        bottom: 8.0,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Colors.white),
                          onPressed: () {
                            if (mounted) {
                              setState(() {
                                _currentImageIndex = (_currentImageIndex + 1) %
                                    widget.images.length;
                              });
                            }
                          },
                        ),
                      ),
                    // Display "Posted by" only if username is not null
                    if (username != null)
                      Positioned(
                        bottom: 16.0,
                        left: 16.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            "$username",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Property Details Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interaction Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Like Button
                        _interactionButton(
                          icon:
                              isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                          count: likes,
                          onPressed: _likeProperty,
                        ),

                        // Comment Button
                        _interactionButton(
                          icon: Icons.comment_outlined,
                          color: Colors.blue,
                          count: comments,
                          onPressed: _showCommentsPopup,
                        ),

                        // Share Button
                        _interactionButton(
                          icon: Icons.share,
                          color: Colors.green,
                          count: shares,
                          onPressed: _shareProperty,
                        ),

                        // Bookmark Button
                        IconButton(
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: Colors.orange,
                          ),
                          onPressed: _bookmarkProperty,
                        ),
                      ],
                    ),
                    Text(
                      widget.property.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: Tsh $formattedPrice',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getShortDescription(widget.property.description),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.property.description.split(' ').length > 12)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(_isExpanded ? "Less" : "More"),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _interactionButton({
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text("$count", style: TextStyle(color: color)),
    );
  }

  void _showCommentsPopup() {
    // TODO: Implement comment section UI
    Fluttertoast.showToast(msg: "Comments section will be displayed");
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileBaseScreen(userId: widget.property.userId),
      ),
    );
  }

  String _getShortDescription(String description) {
    // Decode the description to handle emojis and special characters
    final decodedDescription = utf8.decode(description.runes.toList());

    final words = decodedDescription.split(' ');
    if (words.length <= 12 || _isExpanded) return decodedDescription;
    return words.take(12).join(' ') + '...';
  }
}
