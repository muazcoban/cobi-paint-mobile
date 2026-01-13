import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  /// Converts a color image to a black and white line drawing
  /// suitable for coloring
  Future<Uint8List> convertToColoringPage(
    Uint8List imageData, {
    int edgeThreshold = 30,
    int lineThickness = 2,
    bool invertColors = false,
    double contrastBoost = 1.5,
  }) async {
    // Decode the image
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large (max 1024px on longest side)
    img.Image processedImage = image;
    final maxSize = 1024;
    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        processedImage = img.copyResize(image, width: maxSize);
      } else {
        processedImage = img.copyResize(image, height: maxSize);
      }
    }

    // Convert to grayscale
    final grayscale = img.grayscale(processedImage);

    // Apply Gaussian blur to reduce noise
    final blurred = img.gaussianBlur(grayscale, radius: 1);

    // Edge detection using Sobel operator
    final edges = _sobelEdgeDetection(blurred, edgeThreshold);

    // Dilate edges to make lines thicker
    final dilated = _dilateEdges(edges, lineThickness);

    // Invert if needed (white background, black lines)
    final result = invertColors ? dilated : img.invert(dilated);

    // Enhance contrast
    final enhanced = img.adjustColor(result, contrast: contrastBoost);

    // Encode as PNG
    return Uint8List.fromList(img.encodePng(enhanced));
  }

  /// Sobel edge detection
  img.Image _sobelEdgeDetection(img.Image image, int threshold) {
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Fill with white
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
      }
    }

    // Sobel kernels
    final sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ];
    final sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1]
    ];

    for (int y = 1; y < height - 1; y++) {
      for (int x = 1; x < width - 1; x++) {
        double gx = 0;
        double gy = 0;

        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            final pixel = image.getPixel(x + kx, y + ky);
            final gray = pixel.r.toDouble();
            gx += gray * sobelX[ky + 1][kx + 1];
            gy += gray * sobelY[ky + 1][kx + 1];
          }
        }

        final magnitude = math.sqrt(gx * gx + gy * gy);

        if (magnitude > threshold) {
          result.setPixel(x, y, img.ColorRgb8(0, 0, 0));
        }
      }
    }

    return result;
  }

  /// Dilate edges to make lines thicker
  img.Image _dilateEdges(img.Image image, int radius) {
    if (radius <= 1) return image;

    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Fill with white
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        result.setPixel(x, y, img.ColorRgb8(255, 255, 255));
      }
    }

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);
        if (pixel.r < 128) {
          // Black pixel (edge)
          // Dilate
          for (int dy = -radius; dy <= radius; dy++) {
            for (int dx = -radius; dx <= radius; dx++) {
              final nx = x + dx;
              final ny = y + dy;
              if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                if (dx * dx + dy * dy <= radius * radius) {
                  result.setPixel(nx, ny, img.ColorRgb8(0, 0, 0));
                }
              }
            }
          }
        }
      }
    }

    return result;
  }

  /// Advanced edge detection with Canny algorithm
  Future<Uint8List> convertToColoringPageCanny(
    Uint8List imageData, {
    int lowThreshold = 50,
    int highThreshold = 150,
  }) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large
    img.Image processedImage = image;
    final maxSize = 1024;
    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        processedImage = img.copyResize(image, width: maxSize);
      } else {
        processedImage = img.copyResize(image, height: maxSize);
      }
    }

    // Convert to grayscale
    final grayscale = img.grayscale(processedImage);

    // Apply Gaussian blur
    final blurred = img.gaussianBlur(grayscale, radius: 2);

    // Sobel edge detection
    final edges = _sobelEdgeDetection(blurred, lowThreshold);

    // Non-maximum suppression and hysteresis would be here
    // For simplicity, using the basic edge detection

    // Invert for white background
    final inverted = img.invert(edges);

    return Uint8List.fromList(img.encodePng(inverted));
  }

  /// Converts image to a simplified cartoon style
  Future<Uint8List> convertToCartoonStyle(
    Uint8List imageData, {
    int colorLevels = 8,
    int edgeThreshold = 40,
  }) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize if too large
    img.Image processedImage = image;
    final maxSize = 1024;
    if (image.width > maxSize || image.height > maxSize) {
      if (image.width > image.height) {
        processedImage = img.copyResize(image, width: maxSize);
      } else {
        processedImage = img.copyResize(image, height: maxSize);
      }
    }

    // Quantize colors
    final quantized = img.quantize(
      processedImage,
      numberOfColors: colorLevels,
      method: img.QuantizeMethod.octree,
    );

    // Get edges
    final grayscale = img.grayscale(processedImage);
    final edges = _sobelEdgeDetection(grayscale, edgeThreshold);

    // Overlay edges on quantized image
    final result = img.Image(width: quantized.width, height: quantized.height);
    for (int y = 0; y < quantized.height; y++) {
      for (int x = 0; x < quantized.width; x++) {
        final edgePixel = edges.getPixel(x, y);
        if (edgePixel.r < 128) {
          result.setPixel(x, y, img.ColorRgb8(0, 0, 0));
        } else {
          result.setPixel(x, y, quantized.getPixel(x, y));
        }
      }
    }

    return Uint8List.fromList(img.encodePng(result));
  }

  /// Get image dimensions
  Future<Size> getImageSize(Uint8List imageData) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  /// Resize image while maintaining aspect ratio
  Future<Uint8List> resizeImage(
    Uint8List imageData, {
    int? maxWidth,
    int? maxHeight,
  }) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    img.Image resized;
    if (maxWidth != null && maxHeight != null) {
      // Fit within bounds - resize based on dominant dimension
      if (image.width > image.height) {
        resized = img.copyResize(image, width: maxWidth);
      } else {
        resized = img.copyResize(image, height: maxHeight);
      }
    } else if (maxWidth != null) {
      resized = img.copyResize(image, width: maxWidth);
    } else if (maxHeight != null) {
      resized = img.copyResize(image, height: maxHeight);
    } else {
      resized = image;
    }

    return Uint8List.fromList(img.encodePng(resized));
  }

  /// Create thumbnail
  Future<Uint8List> createThumbnail(Uint8List imageData, {int size = 200}) async {
    final image = img.decodeImage(imageData);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    final thumbnail = img.copyResizeCropSquare(image, size: size);
    return Uint8List.fromList(img.encodePng(thumbnail));
  }
}
