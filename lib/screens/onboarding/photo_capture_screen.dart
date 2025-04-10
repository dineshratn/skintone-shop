import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/user_provider.dart';
import '../../services/skin_tone_detection_service.dart';
import '../../models/skin_tone.dart';
import '../home_screen.dart';
import '../../constants/color_constants.dart';

class PhotoCaptureScreen extends StatefulWidget {
  const PhotoCaptureScreen({Key? key}) : super(key: key);

  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final SkinToneDetectionService _skinToneDetectionService = SkinToneDetectionService();
  
  File? _selectedImage;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _processingComplete = false;
  
  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }
  
  Future<void> _checkPermissions() async {
    // Check camera permission
    final cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }
    
    // Check photo permission
    final photoStatus = await Permission.photos.status;
    if (photoStatus.isDenied) {
      await Permission.photos.request();
    }
  }
  
  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );
      
      if (photo != null) {
        if (mounted) {
          setState(() {
            _selectedImage = File(photo.path);
            _errorMessage = '';
          });
          
          // Start processing automatically
          _processImage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error taking picture: $e';
        });
      }
      print('Error taking picture: $e');
    }
  }
  
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        if (mounted) {
          setState(() {
            _selectedImage = File(image.path);
            _errorMessage = '';
          });
          
          // Start processing automatically
          _processImage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error selecting image: $e';
        });
      }
      print('Error selecting from gallery: $e');
    }
  }
  
  Future<void> _processImage() async {
    if (_selectedImage == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Please select an image first';
        });
      }
      return;
    }
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }
    
    try {
      // Detect skin tone from the image
      SkinToneInfo skinToneInfo = await _skinToneDetectionService.detectSkinToneFromImage(_selectedImage!);
      
      if (!skinToneInfo.isComplete) {
        throw Exception('Could not detect skin tone from image');
      }
      
      if (!mounted) return;
      
      // Save the skin tone info
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateSkinToneInfo(skinToneInfo);
      
      // Mark onboarding as complete
      await userProvider.completeOnboarding();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          _processingComplete = true;
        });
        
        // Add a slight delay before navigating to give visual feedback
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      print('Error processing image: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error processing image: $e';
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhance Your Experience'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Text(
                  'Help us provide the best recommendations',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Take a selfie or upload a photo of yourself to enhance your shopping experience with personalized clothing recommendations.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                
                // Image preview
                if (_selectedImage != null) ...[
                  Center(
                    child: Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: kIsWeb 
                        ? Image.network(
                            _selectedImage!.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: ColorConstants.error,
                                  size: 48,
                                ),
                              );
                            },
                          )
                        : Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: ColorConstants.error,
                                  size: 48,
                                ),
                              );
                            },
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  Center(
                    child: Container(
                      height: 280,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              size: 64,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Take or select a photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Photo capture/selection buttons
                if (!_isLoading && !_processingComplete) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.photo_camera,
                          label: 'Take Photo',
                          onPressed: _takePicture,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionButton(
                          icon: Icons.photo_library,
                          label: 'From Gallery',
                          onPressed: _pickFromGallery,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Error message if any
                if (_errorMessage.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ColorConstants.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: ColorConstants.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: ColorConstants.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Loading indicator
                if (_isLoading) ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing photo...'),
                      ],
                    ),
                  ),
                ],
                
                // Success message
                if (_processingComplete) ...[
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: ColorConstants.success,
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Success!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.success,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Your personal shopping experience is ready'),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Skip button
                if (!_isLoading && !_processingComplete) ...[
                  Center(
                    child: TextButton(
                      onPressed: _skipPhotoCapture,
                      child: const Text('Skip for now'),
                    ),
                  ),
                ],
                
                // Privacy notice
                const SizedBox(height: 16),
                Text(
                  'Your privacy is important to us. Photos are processed locally and not stored or shared.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
  
  Future<void> _skipPhotoCapture() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Create default skin tone (neutral-medium)
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateSkinToneInfo(
        SkinToneInfo(
          undertone: 'neutral',
          depth: 'medium',
        ),
      );
      
      // Mark onboarding as complete
      await userProvider.completeOnboarding();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error skipping: $e';
        });
      }
    }
  }
}