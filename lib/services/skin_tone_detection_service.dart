import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import '../models/skin_tone.dart';

class SkinToneDetectionService {
  // The ML API url for skin tone analysis
  static const String _mlApiUrl = 'http://localhost:5001/api/analyze-skin-tone';
  
  // The minimum percentage of skin pixels required for a valid detection
  static const double _minSkinPixelPercentage = 0.05;
  
  // HSV thresholds for skin detection
  static const double _minHue = 0.0;
  static const double _maxHue = 50.0;
  static const double _minSaturation = 0.1;
  static const double _maxSaturation = 0.8;
  static const double _minValue = 0.2;
  static const double _maxValue = 1.0;
  
  // Sample size reduction to improve performance
  static const int _sampleReduction = 4;
  
  /// Detects skin tone information from an image file using the ML recommendation engine
  Future<SkinToneInfo> detectSkinToneWithAI(File imageFile) async {
    try {
      // Read the image file as bytes
      final Uint8List bytes = await imageFile.readAsBytes();
      
      // Convert to base64
      final String base64Image = base64Encode(bytes);
      
      // Call the ML API
      final response = await http.post(
        Uri.parse(_mlApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );
      
      if (response.statusCode == 200) {
        // Parse the response
        final data = jsonDecode(response.body);
        
        // Extract data from the response
        final String undertone = data['undertone'] ?? 'neutral';
        final String depth = data['depth'] ?? 'medium';
        final List<dynamic> recommendedColors = data['recommendedColors'] ?? [];
        final List<dynamic> notRecommendedColors = data['notRecommendedColors'] ?? [];
        final String description = data['description'] ?? '';
        
        // Convert dynamic lists to string lists
        final List<String> recommendedColorsList = 
            recommendedColors.map((color) => color.toString()).toList();
        final List<String> notRecommendedColorsList = 
            notRecommendedColors.map((color) => color.toString()).toList();
        
        // Create the skin tone info
        return SkinToneInfo(
          undertone: undertone,
          depth: depth,
          recommendedColors: recommendedColorsList,
          notRecommendedColors: notRecommendedColorsList,
          description: description,
        );
      } else {
        // Log the error
        print('ML API error: ${response.statusCode} - ${response.body}');
        
        // Fall back to basic detection
        return detectSkinToneFromImage(imageFile);
      }
    } catch (e) {
      // Log the error
      print('AI skin tone detection error: $e');
      
      // Fall back to basic detection
      return detectSkinToneFromImage(imageFile);
    }
  }
  
  /// Detects skin tone information from an image file using basic image processing
  /// This is a fallback if the ML API fails
  Future<SkinToneInfo> detectSkinToneFromImage(File imageFile) async {
    try {
      // Handle web platform differently
      Uint8List bytes;
      
      try {
        // Read and decode the image
        bytes = await imageFile.readAsBytes();
      } catch (e) {
        print('Error reading file bytes: $e');
        // For web platform or if reading fails, return a default
        return _getDefaultSkinToneInfo();
      }
      
      final decodedImage = img.decodeImage(bytes);
      
      if (decodedImage == null) {
        print('Failed to decode image');
        return _getDefaultSkinToneInfo();
      }
      
      // Extract skin pixels
      final skinPixels = _extractSkinPixels(decodedImage);
      
      if (skinPixels.isEmpty) {
        throw Exception('No skin pixels detected in the image');
      }
      
      // Calculate average color
      final averageColor = _calculateAverageColor(skinPixels);
      
      // Determine undertone and depth
      final undertone = _determineUndertone(averageColor);
      final depth = _determineDepth(averageColor);
      
      // Generate recommended colors based on undertone and depth
      final recommendedColors = _generateRecommendedColors(undertone, depth);
      
      return SkinToneInfo(
        undertone: undertone,
        depth: depth,
        recommendedColors: recommendedColors,
      );
    } catch (e) {
      // Log the error for debugging but don't show to user
      print('Skin tone detection error: $e');
      
      // Return a default skin tone
      return _getDefaultSkinToneInfo();
    }
  }
  
  /// Returns a default skin tone info with neutral-medium tone
  /// This is used as a fallback when detection fails
  SkinToneInfo _getDefaultSkinToneInfo() {
    return SkinToneInfo(
      undertone: 'neutral',
      depth: 'medium',
      recommendedColors: _generateRecommendedColors('neutral', 'medium'),
    );
  }
  
  /// Extracts likely skin pixels from the image
  List<Color> _extractSkinPixels(img.Image image) {
    final List<Color> skinPixels = [];
    final int width = image.width;
    final int height = image.height;
    
    // Use face detection region if available (center of image as fallback)
    final int centerX = width ~/ 2;
    final int centerY = height ~/ 2;
    final int faceRegionSize = min(width, height) ~/ 3;
    
    // Sample pixels in the likely face region with reduced sample rate
    for (int y = centerY - faceRegionSize; y < centerY + faceRegionSize; y += _sampleReduction) {
      if (y < 0 || y >= height) continue;
      
      for (int x = centerX - faceRegionSize; x < centerX + faceRegionSize; x += _sampleReduction) {
        if (x < 0 || x >= width) continue;
        
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        final color = Color.fromARGB(255, r, g, b);
        
        if (_isSkinColor(color)) {
          skinPixels.add(color);
        }
      }
    }
    
    // If not enough skin pixels were found in the face region, sample the entire image
    if (skinPixels.length < (width * height * _minSkinPixelPercentage / (_sampleReduction * _sampleReduction))) {
      skinPixels.clear();
      
      for (int y = 0; y < height; y += _sampleReduction) {
        for (int x = 0; x < width; x += _sampleReduction) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r.toInt();
          final g = pixel.g.toInt();
          final b = pixel.b.toInt();
          
          final color = Color.fromARGB(255, r, g, b);
          
          if (_isSkinColor(color)) {
            skinPixels.add(color);
          }
        }
      }
    }
    
    return skinPixels;
  }
  
  /// Determines if a color is likely to be skin
  bool _isSkinColor(Color color) {
    // Convert RGB to HSV for better skin detection
    final HSVColor hsv = HSVColor.fromColor(color);
    
    // Check if the color is within skin tone ranges
    return hsv.hue >= _minHue && 
           hsv.hue <= _maxHue && 
           hsv.saturation >= _minSaturation && 
           hsv.saturation <= _maxSaturation && 
           hsv.value >= _minValue && 
           hsv.value <= _maxValue &&
           // Additional constraints to avoid false positives
           color.red > color.blue; // Skin tends to have more red than blue
  }
  
  /// Calculates the average color from a list of pixels
  Color _calculateAverageColor(List<Color> pixels) {
    if (pixels.isEmpty) {
      return Colors.transparent;
    }
    
    int totalR = 0, totalG = 0, totalB = 0;
    
    for (final color in pixels) {
      totalR += color.red;
      totalG += color.green;
      totalB += color.blue;
    }
    
    final int avgR = (totalR / pixels.length).round();
    final int avgG = (totalG / pixels.length).round();
    final int avgB = (totalB / pixels.length).round();
    
    return Color.fromARGB(255, avgR, avgG, avgB);
  }
  
  /// Determines the skin undertone based on a color
  String _determineUndertone(Color color) {
    // Calculate green-red balance for undertone detection
    final double redGreenRatio = color.red / max(color.green, 1);
    final double blueRatio = color.blue / max((color.red + color.green) / 2, 1);
    
    // Yellow undertones have more red and green, less blue
    if (redGreenRatio < 1.2 && blueRatio < 0.8) {
      return 'cool';
    } 
    // Red undertones have significantly more red than green
    else if (redGreenRatio > 1.4) {
      return 'warm';
    } 
    // Balanced is considered neutral
    else {
      return 'neutral';
    }
  }
  
  /// Determines the skin depth (light, medium, deep)
  String _determineDepth(Color color) {
    // Calculate perceived brightness
    final double brightness = (color.red * 0.299 + color.green * 0.587 + color.blue * 0.114) / 255;
    
    if (brightness > 0.67) {
      return 'light';
    } else if (brightness > 0.4) {
      return 'medium';
    } else {
      return 'deep';
    }
  }
  
  /// Generates recommended colors based on skin undertone and depth
  List<String> _generateRecommendedColors(String undertone, String depth) {
    List<String> colors = [];
    
    switch (undertone) {
      case 'warm':
        colors.addAll(['Coral', 'Peach', 'Terracotta', 'Gold', 'Olive']);
        if (depth == 'light') {
          colors.addAll(['Salmon', 'Apricot', 'Burnt Orange']);
        } else if (depth == 'medium') {
          colors.addAll(['Rust', 'Bronze', 'Amber']);
        } else { // deep
          colors.addAll(['Deep Rust', 'Royal Purple', 'Mahogany']);
        }
        break;
        
      case 'cool':
        colors.addAll(['Blue', 'Purple', 'Lavender', 'Rose', 'Emerald']);
        if (depth == 'light') {
          colors.addAll(['Powder Blue', 'Lilac', 'Pink']);
        } else if (depth == 'medium') {
          colors.addAll(['Cobalt', 'Magenta', 'Royal Blue']);
        } else { // deep
          colors.addAll(['Navy', 'Indigo', 'Crimson']);
        }
        break;
        
      case 'neutral':
      default:
        colors.addAll(['Teal', 'True Red', 'True Blue', 'Green', 'Plum']);
        if (depth == 'light') {
          colors.addAll(['Light Gray', 'Mauve', 'Sky Blue']);
        } else if (depth == 'medium') {
          colors.addAll(['Turquoise', 'Burgundy', 'Forest Green']);
        } else { // deep
          colors.addAll(['Deep Purple', 'Chocolate', 'Charcoal']);
        }
        break;
    }
    
    // Shuffle and return a subset to keep it interesting
    colors.shuffle();
    return colors.take(6).toList();
  }
}