import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/product_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/product_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state_view.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _fetchInitialData();
  }
  
  Future<void> _fetchInitialData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    // Make sure user data is loaded
    if (!userProvider.isOnboardingComplete) {
      await userProvider.initUser();
    }
    
    // Fetch recommended products based on skin tone
    if (userProvider.hasCompletedSkinToneSelection) {
      await productProvider.generateRecommendations(userProvider.userProfile.skinToneInfo);
    } else {
      // If skin tone not selected, fetch regular products
      await productProvider.fetchProducts();
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: AppConstants.shortAnimationDuration,
        curve: Curves.easeInOut,
      );
    });
  }
  
  void _onSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          _buildHomeTab(),
          const SearchScreen(),
          const WishlistScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
  
  Widget _buildHomeTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: CustomAppBar(title: 'SkinTone Shop', showSearchIcon: true),
          ),
          _buildWelcomeSection(),
          _buildCategoriesSection(),
          _buildRecommendationsSection(),
          _buildPopularSection(),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeSection() {
    final userProvider = Provider.of<UserProvider>(context);
    final userName = userProvider.userProfile.name.isNotEmpty ? 
        userProvider.userProfile.name.split(' ')[0] : 'there';
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $userName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Discover clothing that complements your skin tone.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoriesSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: AppConstants.productCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.productCategories[index];
                return _buildCategoryItem(category);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCategoryItem(String category) {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: () {
        productProvider.fetchProducts(category: category.toLowerCase());
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchScreen(initialCategory: category),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'tops':
        return Icons.accessibility;
      case 'dresses':
        return Icons.woman;
      case 'shirts':
        return Icons.business_center;
      case 'pants':
        return Icons.straighten;
      case 'skirts':
        return Icons.airline_seat_legroom_normal;
      case 'outerwear':
        return Icons.deck;
      case 'accessories':
        return Icons.watch;
      default:
        return Icons.category;
    }
  }
  
  Widget _buildRecommendationsSection() {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    // Only show recommendations if skin tone is selected
    if (!userProvider.hasCompletedSkinToneSelection) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended for You',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Based on your skin tone',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          if (productProvider.isLoading)
            const LoadingIndicator()
          else if (productProvider.error.isNotEmpty)
            ErrorView(
              message: productProvider.error,
              onRetry: () {
                productProvider.generateRecommendations(
                  userProvider.userProfile.skinToneInfo);
              },
            )
          else if (productProvider.recommendedProducts.isEmpty)
            const EmptyStateView(
              message: 'No recommendations found. Try exploring our categories!',
            )
          else
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: productProvider.recommendedProducts.length,
                itemBuilder: (context, index) {
                  final product = productProvider.recommendedProducts[index];
                  final compatibility = productProvider.getProductCompatibility(
                    product, userProvider.userProfile.skinToneInfo);
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                      width: 180,
                      child: ProductCard(
                        product: product,
                        compatibility: compatibility,
                        onTap: () {},
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPopularSection() {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Popular Right Now',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          if (productProvider.isLoading)
            const LoadingIndicator()
          else if (productProvider.error.isNotEmpty)
            ErrorView(
              message: productProvider.error,
              onRetry: () => productProvider.fetchProducts(),
            )
          else if (productProvider.products.isEmpty)
            const EmptyStateView(
              message: 'No products found. Check back later!',
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: productProvider.products.length > 6 
                  ? 6 
                  : productProvider.products.length,
              itemBuilder: (context, index) {
                final product = productProvider.products[index];
                final compatibility = productProvider.getProductCompatibility(
                  product, userProvider.userProfile.skinToneInfo);
                
                return ProductCard(
                  product: product,
                  compatibility: compatibility,
                  onTap: () {},
                );
              },
            ),
        ],
      ),
    );
  }
}
