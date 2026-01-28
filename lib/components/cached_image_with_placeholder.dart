import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Cached image widget with shimmer placeholder loading effect
/// ใช้สำหรับโหลดรูปภาพแบบ cache และแสดง shimmer loading ระหว่างโหลด
class CachedImageWithPlaceholder extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const CachedImageWithPlaceholder({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.shimmerBaseColor = const Color(0xFFE0E0E0),
    this.shimmerHighlightColor = const Color(0xFFF5F5F5),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _buildDefaultErrorWidget(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      memCacheHeight: height != null ? (height! * 2).toInt() : null,
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  /// สร้าง shimmer placeholder loading effect
  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: shimmerBaseColor,
      highlightColor: shimmerHighlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: shimmerBaseColor,
          borderRadius: borderRadius,
        ),
        child: Center(
          child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
        ),
      ),
    );
  }

  /// Default error widget เมื่อโหลดรูปไม่สำเร็จ
  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 40,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            'โหลดรูปไม่สำเร็จ',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// Widget สำหรับแสดงรูปใน Card แบบกลมมน
class CachedCardImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const CachedCardImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 16.0,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedImageWithPlaceholder(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: BorderRadius.circular(borderRadius),
      errorWidget: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: const Icon(Icons.landscape, size: 50, color: Colors.grey),
      ),
    );
  }
}

/// Widget สำหรับแสดงรูปภาพแบบเต็มพื้นที่
class CachedFullImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const CachedFullImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: const Color(0xFFE0E0E0),
        highlightColor: const Color(0xFFF5F5F5),
        child: Container(color: const Color(0xFFE0E0E0)),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 50, color: Colors.grey),
      ),
      fadeInDuration: const Duration(milliseconds: 300),
    );
  }
}
