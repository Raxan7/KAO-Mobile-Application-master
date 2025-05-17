import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Duration fadeInDuration;
  
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? 
        Container(
          color: Colors.grey.shade200,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
      errorWidget: (context, url, error) => errorWidget ?? 
        Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.grey.shade400,
            size: 50,
          ),
        ),
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing = 10.0,
    this.runSpacing = 10.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Determine number of columns based on screen width
        int crossAxisCount;
        if (width < 600) {
          crossAxisCount = 1; // Mobile
        } else if (width < 900) {
          crossAxisCount = 2; // Tablet
        } else if (width < 1200) {
          crossAxisCount = 3; // Small desktop
        } else {
          crossAxisCount = 4; // Large desktop
        }

        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.0, // Adjust based on your design needs
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
