import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../constants/color_constants.dart';
import '../widgets/compatibility_badge.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final Product? product; // Optional pre-loaded product

  const ProductDetailScreen({
    Key? key,
    required this.productId,
    this.product,
  }) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = false;
  String _errorMessage = '';
  int _selectedImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    if (_product == null) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final product = await productProvider.getProductById(widget.productId);

      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load product details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchProductUrl() async {
    if (_product == null) return;

    final Uri url = Uri.parse(_product!.externalUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open ${_product!.retailer} website'),
          backgroundColor: ColorConstants.error,
        ),
      );
    }
  }

  void _toggleWishlist() async {
    if (_product == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.isInWishlist(_product!.id)) {
      await userProvider.removeFromWishlist(_product!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from wishlist'),
          backgroundColor: ColorConstants.info,
        ),
      );
    } else {
      await userProvider.addToWishlist(_product!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Added to wishlist'),
          backgroundColor: ColorConstants.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : _errorMessage.isNotEmpty
              ? ErrorView(
                  message: _errorMessage,
                  onRetry: _loadProduct,
                )
              : _buildProductDetail(),
      bottomNavigationBar: _product != null ? _buildBottomBar() : null,
    );
  }

  // State variable for compatibility
  ProductCompatibility? _compatibility;
  bool _loadingCompatibility = false;

  // Get ML-based compatibility when product loads
  Future<void> _loadCompatibility() async {
    if (_product == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (!userProvider.hasCompletedSkinToneSelection) return;

    setState(() {
      _loadingCompatibility = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final compatibility = await productProvider.getProductCompatibility(
        _product!,
        userProvider.userProfile.skinToneInfo,
      );

      if (mounted) {
        setState(() {
          _compatibility = compatibility;
          _loadingCompatibility = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingCompatibility = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_product != null && _compatibility == null && !_loadingCompatibility) {
      _loadCompatibility();
    }
  }

  Widget _buildProductDetail() {
    if (_product == null) {
      return const Center(
        child: Text('Product not found'),
      );
    }

    final userProvider = Provider.of<UserProvider>(context);

    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product images
              _buildImageGallery(),
              
              // Product info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Retailer badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'From ${_product!.retailer}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Product name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _product!.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          _product!.formattedPrice,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Compatibility indicator
                    if (userProvider.hasCompletedSkinToneSelection) 
                      _loadingCompatibility
                        ? const Center(child: CircularProgressIndicator())
                        : _compatibility != null
                          ? CompatibilityBadge(compatibility: _compatibility!)
                          : const SizedBox.shrink(),
                    const SizedBox(height: 24),
                    
                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _product!.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    
                    // Colors
                    if (_product!.colors.isNotEmpty) ...[
                      Text(
                        'Available Colors',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildColorOptions(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Sizes
                    if (_product!.sizes.isNotEmpty) ...[
                      Text(
                        'Available Sizes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSizeOptions(),
                      const SizedBox(height: 24),
                    ],
                    
                    // Compatibility explanation
                    if (userProvider.hasCompletedSkinToneSelection && _compatibility != null) ...[
                      Text(
                        'Why this matches you',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _compatibility!.reason,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    final userProvider = Provider.of<UserProvider>(context);
    final isInWishlist = _product != null && userProvider.isInWishlist(_product!.id);

    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        if (_product != null)
          IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? ColorConstants.error : null,
            ),
            onPressed: _toggleWishlist,
          ),
      ],
    );
  }

  Widget _buildImageGallery() {
    if (_product == null || _product!.images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        // Main image
        Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          child: Image.network(
            _product!.images[_selectedImageIndex],
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
              );
            },
          ),
        ),
        
        // Thumbnail row
        if (_product!.images.length > 1)
          Container(
            height: 80,
            margin: const EdgeInsets.only(top: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _product!.images.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedImageIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedImageIndex = index;
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.network(
                      _product!.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.image_not_supported, size: 24, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildColorOptions() {
    if (_product == null || _product!.colors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _product!.colors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            child: Text(
              color,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeOptions() {
    if (_product == null || _product!.sizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _product!.sizes.map((size) {
        final isSelected = _selectedSize == size;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSize = size;
            });
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isSelected ? ColorConstants.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
            ),
            child: Center(
              child: Text(
                size,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Wishlist button
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                final isInWishlist = _product != null && 
                    userProvider.isInWishlist(_product!.id);
                
                return Container(
                  decoration: BoxDecoration(
                    color: isInWishlist ? ColorConstants.error.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isInWishlist ? ColorConstants.error : null,
                    ),
                    onPressed: _toggleWishlist,
                  ),
                );
              },
            ),
            const SizedBox(width: 16),
            
            // Buy button
            Expanded(
              child: ElevatedButton(
                onPressed: _product != null && _product!.inStock 
                    ? _launchProductUrl 
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_product != null && _product!.inStock
                    ? 'Shop on ${_product!.retailer}'
                    : 'Out of Stock'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
