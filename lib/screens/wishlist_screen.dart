import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../constants/color_constants.dart';
import '../models/product.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state_view.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (userProvider.userProfile.wishlistIds.isNotEmpty) {
      await productProvider.fetchWishlistProducts(userProvider.userProfile.wishlistIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(title: 'My Wishlist'),
            Expanded(
              child: Consumer2<UserProvider, ProductProvider>(
                builder: (context, userProvider, productProvider, child) {
                  if (productProvider.isLoading) {
                    return const Center(child: LoadingIndicator());
                  }
                  
                  if (productProvider.error.isNotEmpty) {
                    return ErrorView(
                      message: productProvider.error,
                      onRetry: _fetchWishlist,
                    );
                  }
                  
                  if (userProvider.userProfile.wishlistIds.isEmpty) {
                    return const EmptyStateView(
                      message: 'Your wishlist is empty. Add items to your wishlist to keep track of products you love.',
                      icon: Icons.favorite_border,
                    );
                  }
                  
                  if (productProvider.wishlistProducts.isEmpty) {
                    return const EmptyStateView(
                      message: 'Unable to load wishlist items. Please try again later.',
                      icon: Icons.error_outline,
                    );
                  }
                  
                  return _buildWishlistGrid(productProvider, userProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistGrid(ProductProvider productProvider, UserProvider userProvider) {
    return RefreshIndicator(
      onRefresh: _fetchWishlist,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: productProvider.wishlistProducts.length,
        itemBuilder: (context, index) {
          final product = productProvider.wishlistProducts[index];
          return FutureBuilder<ProductCompatibility>(
            future: productProvider.getProductCompatibility(
              product, userProvider.userProfile.skinToneInfo),
            builder: (context, snapshot) {
              return ProductCard(
                product: product,
                compatibility: snapshot.data,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(
                        productId: product.id,
                        product: product,
                      ),
                    ),
                  );
                },
                showWishlistButton: true,
                inWishlist: true,
              );
            },
          );
        },
      ),
    );
  }
}
