import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:cached_network_image/cached_network_image.dart';

class ImageUtils {
  static const String BASE_HOST = 'http://192.168.1.74:8000';

  /// Widget xử lý hiển thị hình ảnh từ URL với đầy đủ xử lý lỗi, loading và placeholder
  static Widget buildNetworkImage({
    required String? imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: Icon(Icons.image_not_supported, color: Colors.grey[400]),
          );
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: Center(child: CircularProgressIndicator()),
          ),
      errorWidget: (context, url, error) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: borderRadius,
            ),
            child: Icon(Icons.error_outline, color: Colors.grey[400]),
          ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: image,
      );
    }

    return image;
  }

  /// Widget hiển thị avatar hình tròn
  static Widget buildCircleAvatar({
    required String? imageUrl,
    required double radius,
    Widget? placeholder,
    Color? backgroundColor,
  }) {
    if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'null') {
      developer.log('Avatar URL is null or empty', name: 'ImageUtils');
      return placeholder ??
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? Colors.grey[200],
            ),
            child: Icon(
              Icons.person,
              size: radius,
              color: Colors.grey[400],
            ),
          );
    }

    final validUrl = getValidImageUrl(imageUrl);
    if (validUrl == null) {
      developer.log('Invalid avatar URL: $imageUrl', name: 'ImageUtils');
      return placeholder ??
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor ?? Colors.grey[200],
            ),
            child: Icon(
              Icons.person,
              size: radius,
              color: Colors.grey[400],
            ),
          );
    }

    developer.log('Loading avatar from URL: $validUrl', name: 'ImageUtils');

    return ClipOval(
      child: buildNetworkImage(
        imageUrl: validUrl,
        width: radius * 2,
        height: radius * 2,
        placeholder: placeholder,
      ),
    );
  }

  /// Widget để hiển thị gallery ảnh dạng ngang
  static Widget buildHorizontalGallery({
    required List<dynamic> images,
    required double height,
    required double spacing,
    required BorderRadius borderRadius,
    required String Function(dynamic) imageUrlExtractor,
  }) {
    return Container(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrlExtractor(images[index]);
          return Container(
            margin:
                EdgeInsets.only(right: index < images.length - 1 ? spacing : 0),
            child: buildNetworkImage(
              imageUrl: imageUrl,
              width: height * (16 / 9),
              height: height,
              borderRadius: borderRadius,
              placeholder: Container(
                width: height * (16 / 9),
                height: height,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: borderRadius,
                ),
                child: Icon(Icons.image, color: Colors.grey[400]),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget xử lý hiển thị ảnh bìa với tỷ lệ aspect ratio
  static Widget buildCoverImage({
    required String? imageUrl,
    required double width,
    double? height,
    double? aspectRatio,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    if (height == null && aspectRatio == null) {
      aspectRatio = 16 / 9;
    }

    return AspectRatio(
      aspectRatio: aspectRatio ?? width / height!,
      child: buildNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height ?? width / aspectRatio!,
        fit: fit,
        placeholder: placeholder,
      ),
    );
  }

  /// Widget placeholder mặc định khi không có ảnh
  static Widget _buildDefaultPlaceholder(
    double width,
    double height, {
    double? iconSize,
    Color? iconColor,
  }) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: iconColor ?? Colors.grey[400],
          size: iconSize ?? width * 0.4,
        ),
      ),
    );
  }

  /// Widget hiển thị loading khi đang tải ảnh
  static Widget _buildLoadingIndicator(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
        ),
      ),
    );
  }

  /// Xử lý URL hình ảnh từ API
  static String? getValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    // Nếu URL đã là URL đầy đủ, trả về nguyên bản
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }

    // Nếu URL là đường dẫn tương đối, thêm base URL
    if (url.startsWith('/')) {
      return BASE_HOST + url;
    }

    return BASE_HOST + '/' + url;
  }

  static String? getClubImageUrl(Map<String, dynamic> club) {
    // Check background_images first
    if (club['background_images'] != null &&
        club['background_images'] is List) {
      List images = club['background_images'];
      if (images.isNotEmpty) {
        // Try to find logo image first
        var logoImage = images.firstWhere(
          (img) =>
              img is Map && (img['is_logo'] == 1 || img['is_logo'] == true),
          orElse: () => null,
        );

        if (logoImage != null && logoImage is Map) {
          String? url = logoImage['image_url'] ?? logoImage['url'];
          if (url != null && url.isNotEmpty) return url;
        }

        // If no logo found, use first image
        var firstImage = images.first;
        if (firstImage is Map) {
          String? url = firstImage['image_url'] ?? firstImage['url'];
          if (url != null && url.isNotEmpty) return url;
        }
      }
    }

    // Fallback to other image fields
    if (club['logo'] != null && club['logo'].toString().isNotEmpty) {
      return club['logo'].toString();
    }

    if (club['imageUrl'] != null && club['imageUrl'].toString().isNotEmpty) {
      return club['imageUrl'].toString();
    }

    return null;
  }
}
