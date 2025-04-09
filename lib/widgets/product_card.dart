import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../constants/color_constants.dart';
import '../providers/user_provider.dart';
import 'compatibility_badge.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ProductCompatibility? compatibility;
  final Function()? onTap;
  final bool showWishlistButton;
  final bool inWishlist;

  const ProductCard({
    Key? key,
    required this.product,
    this.compatibility,
    this.onTap,
    this.showWishlistButton = true,
    this.inWishlist = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image with wishlist button
            Stack(
              children: [
                // Product image
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      product.images.isNotEmpty ? product.images[0] : '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Retailer badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.retailer,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                
                // Wishlist button
                if (showWishlistButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final isInWishlist = userProvider.isInWishlist(product.id);
                        
                        return GestureDetector(
                          onTap: () {
                            if (isInWishlist) {
                              userProvider.removeFromWishlist(product.id);
                            } else {
                              userProvider.addToWishlist(product.id);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isInWishlist 
                                  ? ColorConstants.error.withOpacity(0.8) 
                                  : Colors.white.withOpacity(0.8),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isInWishlist ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isInWishlist ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Out of stock overlay
                if (!product.inStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Product info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name (limited to 2 lines)
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Price
                  Text(
                    product.formattedPrice,
                    style: TextStyle(
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Compatibility badge (if provided)
                  if (compatibility != null)
                    CompatibilityBadge(compatibility: compatibility!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
