import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../constants/color_constants.dart';
import '../models/skin_tone.dart';
import 'onboarding/photo_capture_screen.dart';
import 'retailer_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final user = userProvider.userProfile;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info card
                  _buildUserInfoCard(context, user.name, user.email),
                  const SizedBox(height: 24),
                  
                  // Style profile section
                  _buildSectionTitle(context, 'Your Style Profile'),
                  const SizedBox(height: 16),
                  
                  if (userProvider.hasCompletedSkinToneSelection)
                    _buildSkinToneInfo(context, user.skinToneInfo)
                  else
                    _buildCompleteSkinTonePrompt(context),
                  
                  const SizedBox(height: 24),
                  
                  // Account settings
                  _buildSectionTitle(context, 'Account'),
                  const SizedBox(height: 16),
                  _buildSettingsOptions(context, userProvider),
                  
                  const SizedBox(height: 24),
                  
                  // About section
                  _buildSectionTitle(context, 'About'),
                  const SizedBox(height: 16),
                  _buildAboutOptions(context),
                  
                  const SizedBox(height: 32),
                  
                  // Sign out button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _confirmSignOut(context, userProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.error,
                        side: const BorderSide(color: ColorConstants.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Sign Out'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, String name, String email) {
    final displayName = name.isNotEmpty ? name : 'Guest User';
    final displayEmail = email.isNotEmpty ? email : 'No email provided';
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // User avatar
            CircleAvatar(
              radius: 32,
              backgroundColor: ColorConstants.primaryColor.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'G',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Edit icon
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                // Show edit profile dialog
                _showEditProfileDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSkinToneInfo(BuildContext context, SkinToneInfo skinToneInfo) {
    final undertoneText = skinToneInfo.undertone.isNotEmpty
        ? skinToneInfo.undertone[0].toUpperCase() + skinToneInfo.undertone.substring(1)
        : 'Unknown';
    
    final depthText = skinToneInfo.depth.isNotEmpty
        ? skinToneInfo.depth[0].toUpperCase() + skinToneInfo.depth.substring(1)
        : 'Unknown';
    
    Color toneColor = ColorConstants.neutralTone;
    if (skinToneInfo.undertone == 'warm') {
      toneColor = ColorConstants.warmTone;
    } else if (skinToneInfo.undertone == 'cool') {
      toneColor = ColorConstants.coolTone;
    }
    
    // Adjust color based on depth
    if (skinToneInfo.depth == 'medium') {
      toneColor = toneColor.withOpacity(0.8);
    } else if (skinToneInfo.depth == 'deep') {
      toneColor = toneColor.withOpacity(0.6);
    }
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Skin tone color display
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
              color: toneColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          
          // Skin tone info
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your personalized color palette',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Change'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PhotoCaptureScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Recommended colors
                if (skinToneInfo.recommendedColors.isNotEmpty) ...[
                  Text(
                    'Colors that complement you:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skinToneInfo.recommendedColors.map((color) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: ColorConstants.highCompatibility.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          color,
                          style: const TextStyle(
                            fontSize: 12,
                            color: ColorConstants.success,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteSkinTonePrompt(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete Your Profile',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a photo to get personalized clothing recommendations based on your unique features.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PhotoCaptureScreen(),
                    ),
                  );
                },
                child: const Text('Upload a Photo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOptions(BuildContext context, UserProvider userProvider) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.store_outlined,
            title: 'Retailer Settings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RetailerSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // Open notifications settings
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.security_outlined,
            title: 'Privacy Settings',
            onTap: () {
              // Open privacy settings
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            onTap: () {
              _confirmDeleteAccount(context, userProvider);
            },
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutOptions(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.info_outline,
            title: 'About SkinTone Shop',
            onTap: () {
              // Show about dialog
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.star_outline,
            title: 'Rate the App',
            onTap: () {
              // Open app store rating
            },
          ),
          const Divider(height: 1),
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // Open help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? ColorConstants.error : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? ColorConstants.error : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final nameController = TextEditingController(text: userProvider.userProfile.name);
    final emailController = TextEditingController(text: userProvider.userProfile.email);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedProfile = userProvider.userProfile.copyWith(
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                );
                userProvider.updateUserProfile(updatedProfile);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmSignOut(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await userProvider.signOut();
                // Navigate to onboarding
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.error,
              ),
              child: const Text('Sign Out'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context, UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await userProvider.signOut();
                // Navigate to onboarding
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.error,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }
}
