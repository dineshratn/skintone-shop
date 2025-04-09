import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/skin_tone.dart';
import '../../constants/color_constants.dart';
import '../../models/user_profile.dart';
import '../home_screen.dart';

class SkinToneSelectionScreen extends StatefulWidget {
  const SkinToneSelectionScreen({Key? key}) : super(key: key);

  @override
  _SkinToneSelectionScreenState createState() => _SkinToneSelectionScreenState();
}

class _SkinToneSelectionScreenState extends State<SkinToneSelectionScreen> {
  final List<SkinTone> _skinTones = SkinTone.getPredefinedSkinTones();
  
  // Selected values
  String _selectedUndertone = '';
  String _selectedDepth = '';
  
  // Filtered skin tones based on selection
  List<SkinTone> _filteredSkinTones = [];
  
  // Selected skin tone
  SkinTone? _selectedSkinTone;
  
  @override
  void initState() {
    super.initState();
    _filteredSkinTones = _skinTones;
  }

  void _filterSkinTones() {
    setState(() {
      _filteredSkinTones = _skinTones.where((skinTone) {
        // If undertone is selected, filter by it
        if (_selectedUndertone.isNotEmpty && skinTone.undertone != _selectedUndertone) {
          return false;
        }
        
        // If depth is selected, filter by it
        if (_selectedDepth.isNotEmpty && skinTone.depth != _selectedDepth) {
          return false;
        }
        
        return true;
      }).toList();
    });
  }

  void _selectUndertone(String undertone) {
    setState(() {
      _selectedUndertone = undertone;
      _selectedSkinTone = null;
    });
    _filterSkinTones();
  }

  void _selectDepth(String depth) {
    setState(() {
      _selectedDepth = depth;
      _selectedSkinTone = null;
    });
    _filterSkinTones();
  }

  void _selectSkinTone(SkinTone skinTone) {
    setState(() {
      _selectedSkinTone = skinTone;
    });
  }

  void _saveSkinToneAndContinue() async {
    if (_selectedSkinTone == null && (_selectedUndertone.isEmpty || _selectedDepth.isEmpty)) {
      // Show error - need to make selection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your skin tone attributes'),
          backgroundColor: ColorConstants.error,
        ),
      );
      return;
    }
    
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Create skin tone info
    final skinToneInfo = SkinToneInfo(
      undertone: _selectedSkinTone?.undertone ?? _selectedUndertone,
      depth: _selectedSkinTone?.depth ?? _selectedDepth,
      recommendedColors: _selectedSkinTone?.recommendedColors ?? [],
      notRecommendedColors: _selectedSkinTone?.notRecommendedColors ?? [],
    );
    
    // Save skin tone info to user profile
    await userProvider.updateSkinToneInfo(skinToneInfo);
    
    // Mark onboarding as complete
    await userProvider.completeOnboarding();
    
    // Navigate to home screen
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Skin Tone'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Help us recommend the best clothing for you',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your skin tone characteristics so we can recommend colors that complement you best.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),
                
                // Undertone selection
                _buildSectionTitle('Undertone'),
                const SizedBox(height: 8),
                _buildUndertoneSelector(),
                const SizedBox(height: 24),
                
                // Depth selection
                _buildSectionTitle('Skin Depth'),
                const SizedBox(height: 8),
                _buildDepthSelector(),
                const SizedBox(height: 32),
                
                // Skin tone presets
                if (_filteredSkinTones.isNotEmpty) ...[
                  _buildSectionTitle('Suggested Matches'),
                  const SizedBox(height: 12),
                  _buildSkinToneGrid(),
                  const SizedBox(height: 24),
                ],
                
                // Selected skin tone details
                if (_selectedSkinTone != null) _buildSelectedSkinToneDetails(),
                
                // Continue button
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveSkinToneAndContinue,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUndertoneSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildUndertoneOption('Warm', ColorConstants.warmTone),
        _buildUndertoneOption('Cool', ColorConstants.coolTone),
        _buildUndertoneOption('Neutral', ColorConstants.neutralTone),
      ],
    );
  }

  Widget _buildUndertoneOption(String undertone, Color color) {
    final isSelected = _selectedUndertone == undertone.toLowerCase();
    
    return GestureDetector(
      onTap: () => _selectUndertone(undertone.toLowerCase()),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            undertone,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? ColorConstants.primaryColor : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDepthOption('Light'),
        _buildDepthOption('Medium'),
        _buildDepthOption('Deep'),
      ],
    );
  }

  Widget _buildDepthOption(String depth) {
    final isSelected = _selectedDepth == depth.toLowerCase();
    
    return GestureDetector(
      onTap: () => _selectDepth(depth.toLowerCase()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          depth,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : null,
          ),
        ),
      ),
    );
  }

  Widget _buildSkinToneGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredSkinTones.length,
      itemBuilder: (context, index) {
        final skinTone = _filteredSkinTones[index];
        final isSelected = _selectedSkinTone?.id == skinTone.id;
        
        Color toneColor = ColorConstants.neutralTone;
        if (skinTone.undertone == 'warm') {
          toneColor = ColorConstants.warmTone;
        } else if (skinTone.undertone == 'cool') {
          toneColor = ColorConstants.coolTone;
        }
        
        // Adjust color based on depth
        if (skinTone.depth == 'medium') {
          toneColor = toneColor.withOpacity(0.8);
        } else if (skinTone.depth == 'deep') {
          toneColor = toneColor.withOpacity(0.6);
        }
        
        return GestureDetector(
          onTap: () => _selectSkinTone(skinTone),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: toneColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? ColorConstants.primaryColor.withOpacity(0.1) : null,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Text(
                    skinTone.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? ColorConstants.primaryColor : null,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedSkinToneDetails() {
    final skinTone = _selectedSkinTone!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            skinTone.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            skinTone.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Recommended colors
          Text(
            'Recommended Colors',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skinTone.recommendedColors.map((color) {
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
          const SizedBox(height: 16),
          
          // Colors to avoid
          Text(
            'Colors to Avoid',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skinTone.notRecommendedColors.map((color) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ColorConstants.lowCompatibility.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  color,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ColorConstants.error,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
