import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kao_app/utils/responsive_utils.dart';
import 'package:kao_app/widgets/optimized_image.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  final double? height;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showIndicators;
  final bool showArrows;
  final Function(int)? onImageChanged;
  final BoxFit imageFit;
  final Widget Function(BuildContext, String, int)? imageBuilder;

  const ImageCarousel({
    super.key,
    required this.images,
    this.height,
    this.aspectRatio = 16 / 9,
    this.borderRadius,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showIndicators = true,
    this.showArrows = true,
    this.onImageChanged,
    this.imageFit = BoxFit.cover,
    this.imageBuilder,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentImageIndex = 0;
  Timer? _imageTimer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1 && widget.autoPlay) {
      _startImageCarousel();
    }
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startImageCarousel() {
    _imageTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (mounted && widget.images.length > 1) {
        _pageController.animateToPage(
          (_currentImageIndex + 1) % widget.images.length,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _stopImageCarousel() {
    _imageTimer?.cancel();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    _stopImageCarousel();
    if (widget.autoPlay) {
      _startImageCarousel();
    }
  }

  void _nextImage() {
    _goToPage((_currentImageIndex + 1) % widget.images.length);
  }

  void _previousImage() {
    _goToPage((_currentImageIndex - 1 + widget.images.length) % widget.images.length);
  }

  Widget _buildImage(int index) {
    final image = widget.images[index];
    if (widget.imageBuilder != null) {
      return widget.imageBuilder!(context, image, index);
    }
    
    return OptimizedImage(
      imageUrl: image,
      fit: widget.imageFit,
      borderRadius: widget.borderRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveUtils.isDesktop(context);
    final isTablet = ResponsiveUtils.isTablet(context);
    
    Widget carouselContent = PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      onPageChanged: (index) {
        setState(() {
          _currentImageIndex = index;
        });
        if (widget.onImageChanged != null) {
          widget.onImageChanged!(index);
        }
      },
      itemBuilder: (context, index) => _buildImage(index),
    );

    if (widget.height != null) {
      carouselContent = SizedBox(
        height: widget.height,
        child: carouselContent,
      );
    } else if (widget.aspectRatio != null) {
      carouselContent = AspectRatio(
        aspectRatio: widget.aspectRatio!,
        child: carouselContent,
      );
    }

    if (widget.borderRadius != null) {
      carouselContent = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: carouselContent,
      );
    }

    return Stack(
      children: [
        // Main carousel
        carouselContent,
        
        // Arrows
        if (widget.showArrows && widget.images.length > 1)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left arrow
                GestureDetector(
                  onTap: _previousImage,
                  child: Container(
                    width: isLargeScreen ? 60 : (isTablet ? 48 : 40),
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: isLargeScreen ? 24 : (isTablet ? 20 : 16),
                        ),
                      ),
                    ),
                  ),
                ),
                // Right arrow
                GestureDetector(
                  onTap: _nextImage,
                  child: Container(
                    width: isLargeScreen ? 60 : (isTablet ? 48 : 40),
                    color: Colors.transparent,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(isLargeScreen ? 12 : 8),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: isLargeScreen ? 24 : (isTablet ? 20 : 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
        // Indicators
        if (widget.showIndicators && widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => GestureDetector(
                  onTap: () => _goToPage(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentImageIndex ? 12 : 8,
                    height: index == _currentImageIndex ? 12 : 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentImageIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
