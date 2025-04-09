import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import '../constants/app_constants.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_view.dart';
import '../widgets/empty_state_view.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  
  const SearchScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeCategory = '';
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _activeCategory = widget.initialCategory!;
      _fetchProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _activeCategory = '';
      _isSearching = true;
    });
    _fetchProducts();
  }

  void _selectCategory(String category) {
    setState(() {
      _activeCategory = category;
      _searchQuery = '';
      _searchController.clear();
    });
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    
    if (_searchQuery.isNotEmpty) {
      await productProvider.searchProducts(_searchQuery);
    } else if (_activeCategory.isNotEmpty) {
      await productProvider.fetchProducts(category: _activeCategory.toLowerCase());
    } else {
      await productProvider.fetchProducts();
    }
    
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchInput() : const Text('Search'),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          _buildCategoryTabs(),
          
          // Results
          Expanded(
            child: _buildProductGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search for products...',
        border: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            if (_searchQuery.isNotEmpty) {
              setState(() {
                _searchQuery = '';
              });
              _fetchProducts();
            }
          },
        ),
      ),
      onSubmitted: _onSearch,
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: AppConstants.productCategories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.productCategories[index];
          final isActive = _activeCategory == category;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  _selectCategory(category);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final productProvider = Provider.of<ProductProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    
    if (productProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }
    
    if (productProvider.error.isNotEmpty) {
      return ErrorView(
        message: productProvider.error,
        onRetry: _fetchProducts,
      );
    }
    
    if (productProvider.products.isEmpty) {
      return EmptyStateView(
        message: _searchQuery.isNotEmpty
            ? 'No products found for "$_searchQuery"'
            : _activeCategory.isNotEmpty
                ? 'No products found in $_activeCategory'
                : 'No products found',
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: productProvider.products.length,
      itemBuilder: (context, index) {
        final product = productProvider.products[index];
        final compatibility = productProvider.getProductCompatibility(
          product, userProvider.userProfile.skinToneInfo);
        
        return ProductCard(
          product: product,
          compatibility: compatibility,
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
        );
      },
    );
  }
}
