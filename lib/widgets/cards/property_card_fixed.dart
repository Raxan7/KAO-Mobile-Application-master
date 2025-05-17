import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kao_app/services/user_preferences.dart';
import 'package:kao_app/utils/constants.dart';
import 'package:kao_app/utils/responsive_utils.dart';
import 'package:kao_app/views/user/dalali_profile_in_user/screens/profile_base_screen.dart';
import 'package:kao_app/widgets/image_carousel.dart';
import 'package:animations/animations.dart';
import '../../models/user_property.dart';
import '../../views/user/property_detail.dart';

class PropertyCardFixed extends StatefulWidget {
  final UserProperty property;
  final List<String> images;
  final bool isDesktop;
  final bool useHero;
  final bool showFullDetails;
  final VoidCallback? onTap;

  const PropertyCardFixed({
    required this.property,
    required this.images,
    this.isDesktop = false,
    this.useHero = true,
    this.showFullDetails = true,
    this.onTap,
    super.key,
  });

  @override
  State<PropertyCardFixed> createState() => _PropertyCardFixedState();
}

class _PropertyCardFixedState extends State<PropertyCardFixed> {
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

  void _navigateToProfile() {
    if (widget.property.userId == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileBaseScreen(
          userId: widget.property.userId,
        ),
      ),
    );
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
      debugPrint("Error: $e");
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
      debugPrint("Error: $e");
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
      debugPrint("Error: $e");
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
      debugPrint("Error: $e");
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showCommentsPopup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text(
                    'Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text('User Name'),
                          subtitle: Text('This is a comment'),
                          trailing: Text('2h ago'),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractionIcon({
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onPressed,
  }) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(isDesktop ? 12 : 8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 12.0 : 8.0,
          vertical: 8.0,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0),
            ),
            SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    final cardWidth = isLargeScreen 
        ? screenWidth * 0.6 
        : (isTablet ? screenWidth * 0.8 : screenWidth * 0.9);
    final NumberFormat currencyFormat = NumberFormat('#,###');
    final String formattedPrice = currencyFormat.format(widget.property.price);
    final String timeAgo = getTimeAgo(widget.property.createdAt);

    Widget buildCardContent() {
      return Card(
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
                        child: Hero(
                          tag: 'profile_${widget.property.userId}',
                          child: CircleAvatar(
                            radius: isLargeScreen ? 28 : (isTablet ? 26 : 24),
                            backgroundImage: profilePicUrl != null 
                              ? NetworkImage(profilePicUrl!) 
                              : null,
                            onBackgroundImageError: (_, __) => const Icon(Icons.person),
                            backgroundColor: Colors.grey.shade200,
                            child: profilePicUrl == null 
                              ? Icon(Icons.person, size: isLargeScreen ? 28 : 24) 
                              : null,
                          ),
                        ),
                      ),
                      SizedBox(width: isLargeScreen ? 16 : (isTablet ? 14 : 12)),
                      Expanded(
                        child: GestureDetector(
                          onTap: _navigateToProfile,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username ?? 'Unknown User',
                                style: TextStyle(
                                  fontSize: isLargeScreen ? 18 : (isTablet ? 16 : 14),
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
                    ],
                  ),
                ),

              // Image Section
              AspectRatio(
                aspectRatio: isLargeScreen ? 16/9 : 16/9,
                child: widget.useHero ? 
                  Hero(
                    tag: 'property_${widget.property.propertyId}',
                    child: ImageCarousel(
                      images: widget.images,
                      borderRadius: null,
                    ),
                  ) : 
                  ImageCarousel(
                    images: widget.images,
                    borderRadius: null,
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
                        onPressed: _likeProperty,
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
                        onPressed: _shareProperty,
                      ),
                      _buildInteractionIcon(
                        icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.orange,
                        count: 0, // Bookmark doesn't have count
                        onPressed: _bookmarkProperty,
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
                      widget.property.title,
                      style: TextStyle(
                        fontSize: isLargeScreen ? 20 : (isTablet ? 18 : 16),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tsh. $formattedPrice',
                      style: TextStyle(
                        fontSize: isLargeScreen ? 18 : (isTablet ? 16 : 14),
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: isLargeScreen ? 18 : 16,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.property.location,
                            style: TextStyle(
                              fontSize: isLargeScreen ? 16 : 14,
                              color: Colors.grey[700],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (widget.showFullDetails) ...[
                      SizedBox(height: 12),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property.description,
                              style: TextStyle(
                                fontSize: isLargeScreen ? 16 : 14,
                                height: 1.4,
                              ),
                              maxLines: _isExpanded ? null : 2,
                              overflow: _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            TextButton(
                              onPressed: _toggleExpanded,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isExpanded ? 'Show less' : 'Show more',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: cardWidth,
      margin: EdgeInsets.symmetric(
        vertical: isLargeScreen ? 20.0 : (isTablet ? 16.0 : 12.0),
        horizontal: isLargeScreen ? 0.0 : 8.0,
      ),
      child: widget.onTap != null 
          ? OpenContainer(
              transitionType: ContainerTransitionType.fadeThrough,
              openBuilder: (context, _) => PropertyDetail(
                propertyId: int.parse(widget.property.propertyId),
              ),
              closedElevation: 0, // No elevation to avoid double shadow
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isLargeScreen ? 20.0 : 16.0),
              ),
              closedColor: Colors.transparent, // Transparent background
              closedBuilder: (context, openContainer) => buildCardContent(),
            )
          : GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyDetail(
                      propertyId: int.parse(widget.property.propertyId),
                    ),
                  ),
                );
              },
              child: buildCardContent(),
            ),
    );
  }
}
