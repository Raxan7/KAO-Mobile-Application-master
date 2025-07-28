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
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PropertyCard extends StatefulWidget {
  final UserProperty property;
  final List<String> images;
  final List<String>? mediaTypes;  // New parameter for media types (image/video)
  final bool isDesktop;

  const PropertyCard({
    required this.property,
    required this.images,
    this.mediaTypes,  // Can be null if not provided
    this.isDesktop = false,
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
  final bool _isExpanded = false;
  
  // Video player controllers
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize video if the current media is a video
    _initializeCurrentMedia();
    
    if (widget.images.length > 1) {
      _startImageCarousel();
    }
    _fetchUserDetails();
    _fetchInteractionCounts();
    _loadCurrentUserId();
  }
  
  void _initializeCurrentMedia() {
    if (widget.mediaTypes != null && 
        _currentImageIndex < widget.mediaTypes!.length && 
        widget.mediaTypes![_currentImageIndex] == 'video') {
      _initializeVideo(widget.images[_currentImageIndex]);
    } else {
      // Stop any playing video when switching to an image
      _disposeVideoController();
    }
  }
  
  void _initializeVideo(String videoUrl) {
    print('Video URL: $videoUrl');
    _disposeVideoController();
    
    _videoController = VideoPlayerController.network(videoUrl);
    _videoController!.initialize().then((_) {
      if (!mounted) return;
      
      // Create Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: _videoController!.value.aspectRatio,
        autoPlay: false,
        looping: true,
        showControls: true,
        placeholder: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 30),
                const SizedBox(height: 4),
                Text(
                  'Error: $errorMessage',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
      
      setState(() {
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      setState(() {
        _isVideoInitialized = false;
      });
    });
  }
  
  void _disposeVideoController() {
    if (_chewieController != null) {
      _chewieController!.pause();
      _chewieController!.dispose();
      _chewieController = null;
    }
    
    if (_videoController != null) {
      _videoController!.dispose();
      _videoController = null;
    }
    
    _isVideoInitialized = false;
    _isVideoPlaying = false;
  }

  Future<void> _loadCurrentUserId() async {
    currentUserId = await UserPreferences().getUserId();
    setState(() {});

    if (currentUserId != null) {
      _fetchInteractionCounts();
    }
  }

  void _startImageCarousel() {
    _imageTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        // Don't advance automatically if we're viewing a video
        if (!(widget.mediaTypes != null &&
              _currentImageIndex < widget.mediaTypes!.length &&
              widget.mediaTypes![_currentImageIndex] == 'video' &&
              _isVideoPlaying)) {
          setState(() {
            int nextIndex = (_currentImageIndex + 1) % widget.images.length;
            _currentImageIndex = nextIndex;
            _initializeCurrentMedia();
          });
        }
      }
    });
  }

  Future<void> _fetchUserDetails() async {
    final String apiUrl =
        "$baseUrl/api/dalali/get_user_details.php?userId=${widget.property.userId}";
    const String imageUrl = "$baseUrl/images/users/";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          if (mounted) {
            setState(() {
              profilePicUrl =
                  imageUrl + (responseData['data']['profile_picture'] ?? '');
              username = responseData['data']['name'] ?? 'Unknown User';
            });
          }
        }
      }
    } catch (e) {
      // Silent error handling
    }
  }

  String getTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final adjustedCreatedAt = createdAt.add(const Duration(hours: 8));
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

  Future<void> _fetchInteractionCounts() async {
    if (currentUserId == null) return;

    final String apiUrl =
        "$baseUrl/api/interactions/interaction_counts.php?property_id=${widget.property.propertyId}&user_id=$currentUserId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          likes = int.tryParse(data['likes'].toString()) ?? 0;
          shares = int.tryParse(data['shares'].toString()) ?? 0;
          isLiked = data['isLiked'] ?? false;
        });
      }
    } catch (e) {
      // Silent error handling
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
      // Silent error handling
    }
  }

  Future<void> _bookmarkProperty() async {
    const String apiUrl = "$baseUrl/api/interactions/bookmark.php";
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
      // Silent error handling
    }
  }

  Future<void> _shareProperty() async {
    const String apiUrl = "$baseUrl/api/interactions/share.php";
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
      // Silent error handling
    }
  }

  // Video playback is handled by Chewie player

  @override
  void dispose() {
    _imageTimer?.cancel();
    _disposeVideoController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    final isDesktop = screenWidth > 900;
    
    // Better responsive width calculation
    final cardWidth = isDesktop 
        ? screenWidth * 0.45  // Two cards per row on desktop
        : isLargeScreen 
            ? screenWidth * 0.7  // Centered on tablet
            : screenWidth * 0.95; // Full width on mobile
            
    final NumberFormat currencyFormat = NumberFormat('#,###');
    final String formattedPrice = currencyFormat.format(widget.property.price);
    final String timeAgo = getTimeAgo(widget.property.createdAt);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 12.0 : 8.0,
        horizontal: isDesktop ? 12.0 : 8.0,
      ),
      child: GestureDetector(
        onTap: () {
          final propertyId = widget.property.propertyId;
          print('🏷️ PROPERTY CARD: propertyId tapped: "$propertyId"');
          if (propertyId.trim().isEmpty) {
            Fluttertoast.showToast(
              msg: 'Invalid property. Unable to open details.',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetail(
                propertyId: propertyId,
              ),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16.0 : 12.0),
          ),
          elevation: isLargeScreen ? 6.0 : 3.0,
          shadowColor: Colors.black.withOpacity(0.15),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isLargeScreen ? 16.0 : 12.0),
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
                        // Property type chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Property',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 11 : 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Image Section - Enhanced
                AspectRatio(
                  aspectRatio: isDesktop ? 16/9 : 16/10,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: isLargeScreen ? 12 : 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Check if current media is a video and initialized
                              if (widget.mediaTypes != null &&
                                  _currentImageIndex < widget.mediaTypes!.length &&
                                  widget.mediaTypes![_currentImageIndex] == 'video' &&
                                  _isVideoInitialized &&
                                  _chewieController != null)
                                // Show video player
                                AspectRatio(
                                  aspectRatio: _chewieController!.aspectRatio ?? 16/9,
                                  child: Chewie(controller: _chewieController!),
                                )
                              else
                                // Show image or video thumbnail
                                Image.network(
                                  widget.images[_currentImageIndex],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => 
                                    Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.home, size: 40, color: Colors.grey),
                                            SizedBox(height: 4),
                                            Text('Media not available', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2.0,
                                      ),
                                    );
                                  },
                                ),
                              
                              // Play button overlay for videos that are not yet initialized
                              if (widget.mediaTypes != null && 
                                  widget.mediaTypes!.isNotEmpty && 
                                  _currentImageIndex < widget.mediaTypes!.length && 
                                  widget.mediaTypes![_currentImageIndex] == 'video' &&
                                  !_isVideoInitialized)
                                GestureDetector(
                                  onTap: () {
                                    _initializeVideo(widget.images[_currentImageIndex]);
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),                            // Video indicator if the current media is a video
                        if (widget.mediaTypes != null && 
                            widget.mediaTypes!.isNotEmpty && 
                            _currentImageIndex < widget.mediaTypes!.length && 
                            widget.mediaTypes![_currentImageIndex] == 'video')
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Price overlay
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Tsh $formattedPrice',
                              style: TextStyle(
                                fontSize: isLargeScreen ? 12 : 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (widget.images.length > 1)
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
                        // Image indicator dots - compact
                        if (widget.images.length > 1)
                          Positioned(
                            bottom: 6.0,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.images.length,
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
                        // Video indicator
                        if (widget.mediaTypes != null && 
                            _currentImageIndex < widget.mediaTypes!.length && 
                            widget.mediaTypes![_currentImageIndex] == 'video')
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.videocam, color: Colors.white, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Video',
                                    style: TextStyle(
                                      fontSize: isLargeScreen ? 11 : 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Details Section - Improved layout
                Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 16.0 : 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and location in one section
                      Text(
                        widget.property.title,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.red.shade400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.property.location,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 12 : 11,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getShortDescription(widget.property.description),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 13 : 12,
                          height: 1.3,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Interaction Buttons - Compact design
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16.0),
                      bottomRight: Radius.circular(16.0),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 16.0 : 12.0,
                    vertical: isLargeScreen ? 12.0 : 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInteractionIcon(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey.shade600,
                        count: likes,
                        onPressed: _likeProperty,
                      ),
                      _buildInteractionIcon(
                        icon: Icons.chat_bubble_outline,
                        color: Colors.grey.shade600,
                        count: comments,
                        onPressed: _showCommentsPopup,
                      ),
                      _buildInteractionIcon(
                        icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.blue : Colors.grey.shade600,
                        count: 0,
                        onPressed: _bookmarkProperty,
                      ),
                      _buildInteractionIcon(
                        icon: Icons.share,
                        color: Colors.grey.shade600,
                        count: shares,
                        onPressed: _shareProperty,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractionIcon({
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onPressed,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon, 
                color: color, 
                size: isLargeScreen ? 20 : 18,
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '$count', 
                  style: TextStyle(
                    color: color,
                    fontSize: isLargeScreen ? 12 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _nextImage() {
    if (mounted) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % widget.images.length;
        _initializeCurrentMedia();
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
        builder: (context) => ProfileBaseScreen(userId: widget.property.userId),
      ),
    );
  }

  String _getShortDescription(String description) {
    final decodedDescription = utf8.decode(description.runes.toList());
    final words = decodedDescription.split(' ');
    if (words.length <= 12 || _isExpanded) return decodedDescription;
    return '${words.take(12).join(' ')}...';
  }
}