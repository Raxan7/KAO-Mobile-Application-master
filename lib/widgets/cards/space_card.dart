import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:kao_app/services/user_preferences.dart';
import 'package:kao_app/utils/constants.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/screens/profile_base_screen.dart';
import '../../models/space.dart';
import '../../views/user/space_detail_page.dart';

class SpaceCard extends StatefulWidget {
  final Space space;
  final bool isDesktop;

  const SpaceCard({
    required this.space,
    this.isDesktop = false,
    super.key,
  });

  @override
  _SpaceCardState createState() => _SpaceCardState();
}

class _SpaceCardState extends State<SpaceCard> {
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
    if (widget.space.media.isNotEmpty && widget.space.media.length > 1) {
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
          _currentImageIndex = (_currentImageIndex + 1) % widget.space.media.length;
        });
      }
    });
  }

  Future<void> _fetchUserDetails() async {
    final String apiUrl =
        "$baseUrl/api/dalali/get_user_details.php?userId=${widget.space.userId}";
    const String userImageUrl = "$baseUrl/images/users/";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              profilePicUrl =
                  userImageUrl + (responseData['data']['profile_picture'] ?? '');
              username = responseData['data']['name'] ?? 'Unknown User';
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
  }

  String getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  Future<void> _fetchInteractionCounts() async {
    if (currentUserId == null) return;

    final String apiUrl =
        "$baseUrl/api/interactions/space_interaction_counts.php?space_id=${widget.space.id}&user_id=$currentUserId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          likes = int.tryParse(data['likes'].toString()) ?? 0;
          shares = int.tryParse(data['shares'].toString()) ?? 0;
          isLiked = data['isLiked'] ?? false;
          isBookmarked = data['isBookmarked'] ?? false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching interaction counts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = widget.isDesktop || screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    // Better responsive width calculation
    final cardWidth = isDesktop 
        ? screenWidth * 0.45  // Two cards per row on desktop
        : isLargeScreen 
            ? screenWidth * 0.7  // Centered on tablet
            : screenWidth * 0.95; // Full width on mobile
            
    final String timeAgo = getTimeAgo(widget.space.createdAt);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 12.0 : 8.0,
        horizontal: isDesktop ? 12.0 : 8.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpaceDetailPage(space: widget.space,),
            ),
          );
        },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLargeScreen ? 16.0 : 12.0),
        ),
        elevation: isLargeScreen ? 6.0 : 3.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section - Compact
            if (profilePicUrl != null && username != null)
              Padding(
                padding: EdgeInsets.all(isLargeScreen ? 14.0 : 12.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _navigateToProfile,
                      child: CircleAvatar(
                        radius: isLargeScreen ? 22 : 20,
                        backgroundImage: NetworkImage(profilePicUrl!),
                        onBackgroundImageError: (_, __) => const Icon(Icons.person),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                    SizedBox(width: isLargeScreen ? 12 : 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToProfile,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username!,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 12 : 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Category chip - compact
                    Chip(
                      label: Text(
                        widget.space.categoryName,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 11 : 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: Colors.blue.shade600,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                    ),
                  ],
                ),
              ),

            // Image Section - Enhanced with better space utilization
            if (widget.space.media.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 12 : 8),
                child: AspectRatio(
                  aspectRatio: isDesktop ? 16/9 : 16/10, // Better aspect ratios
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            '$baseUrl/images/spaces/${widget.space.media[_currentImageIndex].mediaUrl}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                      SizedBox(height: 4),
                                      Text('Image not available', 
                                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2.0,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (widget.space.media.length > 1)
                          Positioned(
                            right: 8.0,
                            bottom: 8.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                onPressed: _nextImage,
                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                padding: const EdgeInsets.all(4),
                              ),
                            ),
                          ),
                        // Image indicators - compact
                        if (widget.space.media.length > 1)
                          Positioned(
                            bottom: 6.0,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.space.media.length,
                                (index) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index 
                                        ? Colors.white 
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Container(
                margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 12 : 8),
                child: AspectRatio(
                  aspectRatio: isDesktop ? 16/9 : 16/10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image, size: 40, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('No image available', 
                            style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Details Section - Compact and efficient layout
            Padding(
              padding: EdgeInsets.all(isLargeScreen ? 16.0 : 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and subcategory in one row to save space
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.space.title,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 18 : 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade500,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.space.subcategoryName,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 10 : 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location with better styling
                  if (widget.space.location != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.space.location!,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 12 : 11,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Description with better line height
                  Text(
                    _getShortDescription(widget.space.description),
                    style: TextStyle(
                      fontSize: isLargeScreen ? 13 : 12,
                      height: 1.3,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Read more button - compact
                  if (widget.space.description.split(' ').length > 12)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _isExpanded = !_isExpanded),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isExpanded ? "Show less" : "Read more",
                          style: TextStyle(
                            fontSize: isLargeScreen ? 12 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Interaction Buttons - Compact and modern design
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isLargeScreen ? 10.0 : 8.0,
                  horizontal: isLargeScreen ? 16.0 : 12.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInteractionButton(
                      icon: isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey.shade600,
                      label: '$likes',
                      onPressed: _likeSpace,
                      isLargeScreen: isLargeScreen,
                    ),
                    _buildInteractionButton(
                      icon: Icons.comment_outlined,
                      color: Colors.blue.shade600,
                      label: '$comments',
                      onPressed: _showCommentsPopup,
                      isLargeScreen: isLargeScreen,
                    ),
                    _buildInteractionButton(
                      icon: Icons.share_outlined,
                      color: Colors.green.shade600,
                      label: '$shares',
                      onPressed: _shareSpace,
                      isLargeScreen: isLargeScreen,
                    ),
                    _buildInteractionButton(
                      icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.orange.shade600 : Colors.grey.shade600,
                      label: '',
                      onPressed: _bookmarkSpace,
                      isLargeScreen: isLargeScreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onPressed,
    required bool isLargeScreen,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 12 : 8,
          vertical: isLargeScreen ? 8 : 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: color,
              size: isLargeScreen ? 22 : 20,
            ),
            if (label.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color, 
                    fontSize: isLargeScreen ? 13 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _nextImage() {
    if (mounted) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % widget.space.media.length;
      });
    }
  }

  void _showCommentsPopup() {
    Fluttertoast.showToast(msg: "Comments section will be displayed");
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileBaseScreen(userId: widget.space.userId),
      ),
    );
  }

  String _getShortDescription(String description) {
    final words = description.split(' ');
    if (words.length <= 12 || _isExpanded) return description;
    return '${words.take(12).join(' ')}...';
  }

  Future<void> _likeSpace() async {
    const String apiUrl = "$baseUrl/api/interactions/like_space.php";
    final Map<String, dynamic> requestBody = {
      "user_id": currentUserId,
      "space_id": widget.space.id,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          setState(() {
            isLiked = responseData['liked'];
            isLiked ? likes++ : likes--;
          });

          Fluttertoast.showToast(
            msg: isLiked ? "Liked! 🎉" : "Unliked! ❌",
          );
        }
      }
    } catch (e) {
      debugPrint("Error liking space: $e");
    }
  }

  Future<void> _bookmarkSpace() async {
    const String apiUrl = "$baseUrl/api/interactions/bookmark_space.php";
    final Map<String, dynamic> requestBody = {
      "user_id": currentUserId,
      "space_id": widget.space.id,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            isBookmarked = !isBookmarked;
          });
          Fluttertoast.showToast(
              msg: isBookmarked ? "Bookmarked!" : "Removed Bookmark");
        }
      }
    } catch (e) {
      debugPrint("Error bookmarking space: $e");
    }
  }

  Future<void> _shareSpace() async {
    const String apiUrl = "$baseUrl/api/interactions/share_space.php";
    final Map<String, dynamic> requestBody = {
      "user_id": currentUserId,
      "space_id": widget.space.id,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            shares++;
          });
          Fluttertoast.showToast(msg: "Shared!");
        }
      }
    } catch (e) {
      debugPrint("Error sharing space: $e");
    }
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    super.dispose();
  }
}