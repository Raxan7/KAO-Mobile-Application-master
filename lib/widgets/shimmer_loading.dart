import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:kao_app/utils/responsive_utils.dart';

class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    final baseColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[300]!
        : Colors.grey[700]!;
    final highlightColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[100]!
        : Colors.grey[600]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: child,
    );
  }
}

class PropertyCardShimmer extends StatelessWidget {
  final bool isDesktop;
  
  const PropertyCardShimmer({
    super.key, 
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isLargeScreen = isDesktop || ResponsiveUtils.isDesktop(context);
    final cardPadding = isLargeScreen ? 20.0 : (isTablet ? 16.0 : 12.0);
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeScreen ? 20.0 : 16.0),
      ),
      elevation: isLargeScreen ? 8.0 : 4.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Container(
                  width: isLargeScreen ? 56 : (isTablet ? 52 : 48),
                  height: isLargeScreen ? 56 : (isTablet ? 52 : 48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: isLargeScreen ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: isLargeScreen ? 20 : 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: isLargeScreen ? 14 : 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Image section
          AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: isLargeScreen 
                    ? const Radius.circular(0) 
                    : const Radius.circular(0),
                ),
              ),
            ),
          ),
          
          // Button section
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                4,
                (index) => Container(
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          
          // Content section
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: isLargeScreen ? 24 : 20,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: isLargeScreen ? 20 : 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  height: isLargeScreen ? 16 : 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: isLargeScreen ? 16 : 14,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
