import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  static const String imageUrl = "$baseUrl/images/spaces/";
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
    const String imageUrl = "$baseUrl/images/spaces/";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
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
      debugPrint("Error fetching user details: $e");
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
        "$baseUrl/api/interactions/space_interaction_counts.php?space_id=${widget.space.id}&user_id=$currentUserId";

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
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

      if (response.statusCode == 200) {
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

      if (response.statusCode == 200) {
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

      if (response.statusCode == 200) {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = widget.isDesktop || screenWidth > 600;
    final cardWidth = isLargeScreen ? screenWidth * 0.6 : screenWidth * 0.9;
    final String timeAgo = getTimeAgo(widget.space.createdAt);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 16.0 : 8.0,
        horizontal: isLargeScreen ? 0.0 : 8.0,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpaceDetailPage(space: widget.space),
            ),
          );
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeScreen ? 20.0 : 16.0),
          ),
          elevation: isLargeScreen ? 8.0 : 4.0,
          shadowColor: Colors.black.withOpacity(0.2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isLargeScreen ? 20.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                if (profilePicUrl != null && username != null)
                  Padding(
                    padding: EdgeInsets.all(isLargeScreen ? 16.0 : 12.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _navigateToProfile,
                          child: CircleAvatar(
                            radius: isLargeScreen ? 28 : 24,
                            backgroundImage: NetworkImage(profilePicUrl!),
                            onBackgroundImageError: (_, __) => const Icon(Icons.person),
                            backgroundColor: Colors.grey.shade200,
                          ),
                        ),
                        SizedBox(width: isLargeScreen ? 16 : 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _navigateToProfile,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username!,
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 18 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    fontSize: isLargeScreen ? 14 : 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Category Chip
                        Chip(
                          label: Text(
                            widget.space.categoryName,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 14 : 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),

                // Image Section
                if (widget.space.media.isNotEmpty)
                  AspectRatio(
                    aspectRatio: isLargeScreen ? 16/8 : 16/9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          '$imageUrl/${widget.space.media[_currentImageIndex].mediaUrl}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(color: Colors.grey[200]),
                        ),
                        if (widget.space.media.length > 1)
                          Positioned(
                            right: 12.0,
                            bottom: 12.0,
                            child: FloatingActionButton.small(
                              heroTag: null,
                              onPressed: _nextImage,
                              child: const Icon(Icons.arrow_forward),
                            ),
                          ),
                      ],
                    ),
                  )
                else
                  AspectRatio(
                    aspectRatio: isLargeScreen ? 16/8 : 16/9,
                    child: Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),

                // Interaction Buttons Section
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300),
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInteractionIcon(
                          icon: isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                          count: likes,
                          onPressed: _likeSpace,
                        ),
                        _buildInteractionIcon(
                          icon: Icons.comment_outlined,
                          color: Colors.blue,
                          count: comments,
                          onPressed: _showCommentsPopup,
                        ),
                        _buildInteractionIcon(
                          icon: Icons.share,
                          color: Colors.green,
                          count: shares,
                          onPressed: _shareSpace,
                        ),
                        _buildInteractionIcon(
                          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.orange,
                          count: 0, // Bookmark doesn't have count
                          onPressed: _bookmarkSpace,
                        ),
                      ],
                    ),
                  ),
                ),

                // Details Section
                Padding(
                  padding: EdgeInsets.all(isLargeScreen ? 20.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.space.title,
                        style: TextStyle(
                          fontSize: isLargeScreen ? 20 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Subcategory Chip
                      Chip(
                        label: Text(
                          widget.space.subcategoryName,
                          style: TextStyle(
                            fontSize: isLargeScreen ? 14 : 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.blue[300],
                      ),
                      const SizedBox(height: 12),
                      if (widget.space.location != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                widget.space.location!,
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 14 : 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        _getShortDescription(widget.space.description),
                        style: TextStyle(
                          fontSize: isLargeScreen ? 14 : 12,
                        ),
                      ),
                      if (widget.space.description.split(' ').length > 12)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _isExpanded = !_isExpanded),
                            child: Text(_isExpanded ? "Show less" : "Read more"),
                          ),
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              if (count > 0) Text('$count', style: TextStyle(color: color)),
            ],
          ),
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
    final decodedDescription = utf8.decode(description.runes.toList());
    final words = decodedDescription.split(' ');
    if (words.length <= 12 || _isExpanded) return decodedDescription;
    return '${words.take(12).join(' ')}...';
  }
}