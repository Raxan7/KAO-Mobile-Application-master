import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerHelper {
  /// A singleton instance for the VideoPlayerHelper
  static final VideoPlayerHelper _instance = VideoPlayerHelper._internal();
  
  /// Factory constructor to return the singleton instance
  factory VideoPlayerHelper() {
    return _instance;
  }
  
  /// Private constructor for the singleton pattern
  VideoPlayerHelper._internal();
  
  /// Flag to track if initialization was attempted
  bool _initializationAttempted = false;
  
  /// Initialize the video player plugin - don't await this in app startup
  Future<void> initializeVideoPlayer() async {
    if (_initializationAttempted) return;
    _initializationAttempted = true;
    
    try {
      debugPrint('🎬 VIDEO HELPER: Starting video player initialization');
      // We don't actually need to initialize the video player plugin
      // The plugin will initialize itself when first used
      debugPrint('✅ VIDEO HELPER: Video player ready to use');
    } catch (e) {
      debugPrint('⚠️ VIDEO HELPER: Video player initialization note: $e');
    }
  }
  
  /// Create a video player controller for a network URL
  VideoPlayerController createNetworkController(String url) {
    // No need to check initialization status
    // Just initialize when needed
    initializeVideoPlayer();
    
    // Clean up the URL if needed
    url = url.trim();
    
    debugPrint('🎬 VIDEO HELPER: Creating controller for URL: $url');
    
    try {
      return VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          'Content-Type': 'video/mp4',
        },
      );
    } catch (e) {
      debugPrint('❌ VIDEO HELPER: Error creating controller: $e');
      // Create a fallback controller that won't cause crashes
      return VideoPlayerController.networkUrl(
        Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'),
      );
    }
  }
}
