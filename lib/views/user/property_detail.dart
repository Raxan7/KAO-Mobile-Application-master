import 'package:flutter/material.dart';
import 'package:kao_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'messaging_page.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PropertyDetail extends StatefulWidget {
  final String propertyId;

  const PropertyDetail({super.key, required this.propertyId});

  @override
  _PropertyDetailState createState() => _PropertyDetailState();
}

class _PropertyDetailState extends State<PropertyDetail> with SingleTickerProviderStateMixin {
  String? userId;
  final TextEditingController _messageController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  final ApiService _apiService = ApiService();

  // Media players for videos
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};
  
  // Store media types
  List<String> mediaTypes = [];

  @override
  void initState() {
    super.initState();
    print('🔍 PROPERTY DETAIL: Initializing for property ${widget.propertyId}');
    
    // Check for video player availability
    print('🔍 PROPERTY DETAIL: Checking video dependencies:');
    try {
      print('🔍 PROPERTY DETAIL: VideoPlayer package available and imported');
      print('🔍 PROPERTY DETAIL: Chewie package available and imported');
    } catch (e) {
      print('❌ PROPERTY DETAIL ERROR: Video dependency issue: $e');
    }
    
    _loadUserId();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    print('🧹 PROPERTY DETAIL: Cleaning up resources for property ${widget.propertyId}');
    
    // Dispose video controllers
    try {
      print('🧹 PROPERTY DETAIL: Disposing ${_videoControllers.length} video controllers');
      for (final entry in _videoControllers.entries) {
        print('🧹 PROPERTY DETAIL: Disposing video controller for index ${entry.key}');
        entry.value.dispose();
      }
      
      print('🧹 PROPERTY DETAIL: Disposing ${_chewieControllers.length} chewie controllers');
      for (final entry in _chewieControllers.entries) {
        print('🧹 PROPERTY DETAIL: Disposing chewie controller for index ${entry.key}');
        entry.value.dispose();
      }
    } catch (e) {
      print('❌ PROPERTY DETAIL ERROR: Error disposing video controllers: $e');
    }
    
    _animationController.dispose();
    _messageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Debug: print propertyId value
    final String propertyId = widget.propertyId;
    print('🔍 PROPERTY DETAIL: propertyId received: "$propertyId"');
    // Only treat as invalid if null, empty, or whitespace
    if (propertyId.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Property Details'),
          centerTitle: true,
          backgroundColor: Colors.teal,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Invalid property ID. Unable to load property details.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _apiService.fetchPropertyDetailForUser(propertyId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          } else if (snapshot.hasError) {
            // Log the error for debugging
            print('❌ PROPERTY DETAIL ERROR: Failed to load property $propertyId: ${snapshot.error}');
            if (snapshot.error is Error) {
              print('❌ PROPERTY DETAIL ERROR: Stack trace: ${(snapshot.error as Error).stackTrace}');
            }
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check the debug console for more details',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('🔄 PROPERTY DETAIL: Retrying data fetch for property $propertyId...');
                      setState(() {});
                    },
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Error Details'),
                          content: SingleChildScrollView(
                            child: Text(
                              'Error: ${snapshot.error}\n\n'
                              'Type: ${snapshot.error.runtimeType}\n\n'
                              'Property ID: $propertyId\n\n'
                              'This information can help developers diagnose the issue.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Show Error Details'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No property data available',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final property = snapshot.data!;
          // Log the received property data for debugging
          print('📊 PROPERTY DETAIL: Received data for property $propertyId');
          print('📊 PROPERTY DETAIL: Raw property data keys: ${property.keys.toList()}');
          
          // Extract media URLs and types with error checking
          List<Map<String, dynamic>> mediaList = [];
          try {
            if (property.containsKey('property_media')) {
              final dynamic rawMedia = property['property_media'];
              print('📊 PROPERTY DETAIL: Raw media data type: ${rawMedia.runtimeType}');
              
              if (rawMedia is List) {
                mediaList = rawMedia.cast<Map<String, dynamic>>();
                print('📊 PROPERTY DETAIL: Found ${mediaList.length} media items');
              } else {
                print('❌ PROPERTY DETAIL ERROR: Expected List for property_media but got ${rawMedia.runtimeType}');
              }
            } else {
              print('⚠️ PROPERTY DETAIL WARNING: No property_media key found in response');
            }
          } catch (e) {
            print('❌ PROPERTY DETAIL ERROR: Exception parsing media list: $e');
          }
          
          // Extract media URLs and types
          final List<String> mediaUrls = [];
          mediaTypes = []; // Initialize or update the class-level mediaTypes list
          
          if (mediaList.isNotEmpty) {
            print('📊 PROPERTY DETAIL: Processing ${mediaList.length} media items from property_media:');
            for (var media in mediaList) {
              try {
                final url = media['media_url'] ?? '';
                final type = media['type'] ?? 'image';
                print('📊 PROPERTY DETAIL: Media item - URL: $url, Type: $type all $media');
                
                mediaUrls.add(url);
                mediaTypes.add(type);
              } catch (e) {
                print('❌ PROPERTY DETAIL ERROR: Failed to process media item: $e');
                print('❌ PROPERTY DETAIL ERROR: Media item data: $media');
              }
            }
          } else {
            print('📊 PROPERTY DETAIL: No property_media found, checking for property_image');
            
            // Handle legacy data format where only property_image was returned
            try {
              // Check what type of data property_image contains
              final propertyImageData = property['property_image'];
              print('📊 PROPERTY DETAIL: property_image data type: ${propertyImageData.runtimeType}');
              
              if (propertyImageData is List) {
                print('📊 PROPERTY DETAIL: Found property_image list with ${propertyImageData.length} items');
                for (var img in propertyImageData) {
                  mediaUrls.add(img.toString());
                  print('📊 PROPERTY DETAIL: Added legacy image URL: $img');
                }
              } else if (propertyImageData is String) {
                print('📊 PROPERTY DETAIL: Found single property_image string');
                mediaUrls.add(propertyImageData);
                print('📊 PROPERTY DETAIL: Added legacy image URL: $propertyImageData');
              } else {
                print('⚠️ PROPERTY DETAIL WARNING: property_image is neither a List nor a String');
              }
            } catch (e) {
              print('❌ PROPERTY DETAIL ERROR: Error processing property_image: $e');
              // Create a placeholder URL if nothing else worked
              if (mediaUrls.isEmpty) {
                print('❌ PROPERTY DETAIL ERROR: No media found, adding placeholder');
                mediaUrls.add('https://via.placeholder.com/400?text=No+Image');
              }
            }
            
            // All are considered images in legacy format
            print('📊 PROPERTY DETAIL: Setting all ${mediaUrls.length} legacy media items as "image" type');
            mediaTypes.addAll(List.filled(mediaUrls.length, 'image'));
          }
          
          final title = property['title'] ?? 'No Title Available';
          final description = property['description'] ?? 'No Description Available';
          final price = double.tryParse(property['price']?.toString() ?? '0.0') ?? 0.0;
          final formattedPrice = NumberFormat('#,###').format(price);
          final status = property['status'] ?? 'N/A';
          final location = property['location'] ?? 'No Location Specified';
          final dalaliId = property['user_id']?.toString() ?? '0';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 900;
              final isTablet = constraints.maxWidth > 600;

              if (isDesktop) {
                return _buildDesktopLayout(
                  mediaUrls, mediaTypes, title, description, formattedPrice, 
                  status, location, dalaliId, constraints
                );
              } else {
                return _buildMobileLayout(
                  mediaUrls, mediaTypes, title, description, formattedPrice,
                  status, location, dalaliId, isTablet
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(
    List<String> mediaUrls, List<String> mediaTypes, String title, String description, 
    String formattedPrice, String status, String location, String dalaliId, BoxConstraints constraints
  ) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side - Images
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _buildImageGallery(mediaUrls, mediaTypes, true),
                      const SizedBox(height: 16),
                      _buildImageThumbnails(mediaUrls, true),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right side - Details
                Expanded(
                  flex: 2,
                  child: _buildPropertyDetails(
                    title, description, formattedPrice, status, location, dalaliId.toString(), true
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    List<String> mediaUrls, List<String> mediaTypes, String title, String description, 
    String formattedPrice, String status, String location, String dalaliId, bool isTablet
  ) {
    return SingleChildScrollView(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildImageGallery(mediaUrls, mediaTypes, false),
              if (mediaUrls.length > 1) ...[
                const SizedBox(height: 8),
                _buildImageThumbnails(mediaUrls, false),
              ],
              _buildPropertyDetails(
                title, description, formattedPrice, status, location, dalaliId.toString(), false
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> mediaUrls, List<String> mediaTypes, bool isDesktop) {
    final aspectRatio = isDesktop ? 16/9 : 16/10;
    
    return Hero(
      tag: 'property_${widget.propertyId}',
      child: Container(
        margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isDesktop ? 16 : 12),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                      
                      // Pause all videos when changing page
                      _videoControllers.forEach((i, controller) {
                        if (controller.value.isPlaying && i != index) {
                          controller.pause();
                        }
                      });
                      
                      // Play the current video if it's a video
                      if (index < mediaTypes.length && 
                          mediaTypes[index] == 'video' && 
                          _videoControllers.containsKey(index)) {
                        _videoControllers[index]?.play();
                      }
                    });
                  },
                  itemCount: mediaUrls.length,
                  itemBuilder: (context, index) {                      // Check if it's a video
                    if (index < mediaTypes.length && mediaTypes[index] == 'video') {
                      // Log that we're trying to handle a video
                      print('🎬 PROPERTY DETAIL: Handling video at index $index, URL: ${mediaUrls[index]}');
                      
                      // Initialize video controller if needed
                      if (!_videoControllers.containsKey(index)) {
                        print('🎬 PROPERTY DETAIL: Creating new video controller for index $index');
                        try {
                          final videoController = VideoPlayerController.network(mediaUrls[index]);
                          _videoControllers[index] = videoController;
                          
                          videoController.initialize().then((_) {
                            if (!mounted) return;
                            
                            print('✅ PROPERTY DETAIL: Video initialized successfully for index $index');
                            print('📐 PROPERTY DETAIL: Video size: ${videoController.value.size}');
                            
                            // Calculate proper aspect ratio if available
                            double videoAspectRatio = aspectRatio;
                            if (videoController.value.size.width > 0 && 
                                videoController.value.size.height > 0) {
                              videoAspectRatio = videoController.value.aspectRatio;
                              print('📐 PROPERTY DETAIL: Using video aspect ratio: $videoAspectRatio');
                            }
                            
                            // Create Chewie controller
                            final chewieController = ChewieController(
                              videoPlayerController: videoController,
                              aspectRatio: videoAspectRatio,
                              autoInitialize: true,
                              autoPlay: false,
                              looping: false,
                              showOptions: false,
                              showControls: true,
                              placeholder: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade400),
                                ),
                              ),
                              errorBuilder: (context, errorMessage) {
                                print('❌ PROPERTY DETAIL ERROR: Video error: $errorMessage');
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Error: $errorMessage',
                                        style: const TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          videoController.initialize().then((_) => setState(() {}));
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                            
                            _chewieControllers[index] = chewieController;
                            setState(() {});
                          }).catchError((error) {
                            print('❌ PROPERTY DETAIL ERROR: Failed to initialize video: $error');
                            if (error is Error) {
                              print('❌ PROPERTY DETAIL ERROR: Stack trace: ${error.stackTrace}');
                            }
                          });
                        } catch (e) {
                          print('❌ PROPERTY DETAIL ERROR: Exception creating video controller: $e');
                        }
                      }
                      
                      // Show Chewie player if initialized
                      if (_chewieControllers.containsKey(index)) {
                        print('✅ PROPERTY DETAIL: Showing Chewie player for index $index');
                        return Chewie(controller: _chewieControllers[index]!);
                      } else {
                        // Show loading indicator with video thumbnail while video initializes
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Video thumbnail
                            Image.network(
                              mediaUrls[index],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[800],
                                child: const Center(
                                  child: Icon(Icons.video_library, size: 64, color: Colors.white54),
                                ),
                              ),
                            ),
                            // Loading indicator
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                              ),
                            ),
                          ],
                        );
                      }
                    } else {
                      // Show image
                      return Image.network(
                        mediaUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home, size: 48, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Image not available', 
                                  style: TextStyle(color: Colors.grey)),
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
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                // Navigation arrows for desktop
                if (isDesktop && mediaUrls.length > 1) ...[
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: _previousImage,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, color: Colors.white),
                          onPressed: _nextImage,
                        ),
                      ),
                    ),
                  ),
                ],
                // Image indicators
                if (mediaUrls.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        mediaUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 8,
                          height: 8,
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
      ),
    );
  }

  Widget _buildImageThumbnails(List<String> mediaUrls, bool isDesktop) {
    if (mediaUrls.length <= 1) return const SizedBox();
    
    return Container(
      height: isDesktop ? 80 : 60,
      margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentImageIndex;
          final isVideo = index < mediaTypes.length && mediaTypes[index] == 'video';
          
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Stack(
              children: [
                Container(
                  width: isDesktop ? 80 : 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.teal : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      mediaUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                // Video indicator
                if (isVideo)
                  Positioned(
                    top: 0,
                    right: 8, // Account for the margin
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPropertyDetails(
    String title, String description, String formattedPrice,
    String status, String location, String dalaliId, bool isDesktop
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 28 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          
          // Price
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Text(
              'Tsh $formattedPrice',
              style: TextStyle(
                fontSize: isDesktop ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Quick Info Cards
          _buildInfoCards(status, location, isDesktop),
          const SizedBox(height: 20),

          // Description
          _buildSectionHeader('Description', isDesktop),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              description,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Message Section
          _buildMessageSection(dalaliId, title, isDesktop),
          const SizedBox(height: 24),

          // Action Button
          _buildActionButton(dalaliId, isDesktop),
        ],
      ),
    );
  }

  Widget _buildInfoCards(String status, String location, bool isDesktop) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.info_outline,
            label: 'Status',
            value: status,
            color: Colors.blue,
            isDesktop: isDesktop,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: location,
            color: Colors.red,
            isDesktop: isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDesktop,
  }) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: isDesktop ? 24 : 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isDesktop ? 12 : 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(String dalaliId, String title, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Send Message', isDesktop),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Write your message about this property...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(isDesktop ? 16 : 12),
                  ),
                  maxLines: 3,
                  style: TextStyle(fontSize: isDesktop ? 16 : 14),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.send, 
                    color: Colors.white,
                    size: isDesktop ? 24 : 20,
                  ),
                  onPressed: () => _sendMessage(dalaliId.toString(), title),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String dalaliId, bool isDesktop) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _requestProperty(dalaliId.toString()),
        icon: const Icon(Icons.apartment, color: Colors.white),
        label: Text(
          'Request Property',
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: EdgeInsets.symmetric(
            vertical: isDesktop ? 16 : 14,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _nextImage() {
    if (_currentImageIndex < _getCurrentImages().length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousImage() {
    if (_currentImageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  List<String> _getCurrentImages() {
    // This should return the current images list from the context
    // For now, return empty list as placeholder
    return [];
  }

  void _sendMessage(String dalaliId, String title) {
    if (_messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a message')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagingPage(
          propertyId: widget.propertyId,
          dalaliId: dalaliId,
          propertyName: title,
          propertyImage: _getCurrentImages().isNotEmpty ? _getCurrentImages()[0] : '',
          initialMessage: _messageController.text,
        ),
      ),
    );
  }

  Future<void> _requestProperty(String dalaliId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }
    
    try {
      final response = await _apiService.createNotification(
        userId!,
        dalaliId.toString(),
        widget.propertyId,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['status'] == 'success' 
                ? response['message']
                : 'Error: ${response['message']}',
            ),
            backgroundColor: response['status'] == 'success' 
              ? Colors.green 
              : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String text, bool isDesktop) {
    return Text(
      text,
      style: TextStyle(
        fontSize: isDesktop ? 20 : 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}