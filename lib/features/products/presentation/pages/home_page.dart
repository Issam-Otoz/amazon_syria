import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:amazon_syria/core/constants/app_constants.dart';
import 'package:amazon_syria/core/theme/app_theme.dart';
import 'package:amazon_syria/core/widgets/app_error_widget.dart';
import 'package:amazon_syria/core/widgets/loading_widget.dart';
import 'package:amazon_syria/features/auth/presentation/providers/auth_provider.dart';
import 'package:amazon_syria/features/products/presentation/providers/product_provider.dart';
import 'package:amazon_syria/core/widgets/banner_ad_widget.dart';
import 'package:amazon_syria/features/products/presentation/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showMyProducts = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<ProductProvider>().searchProducts(query);
  }

  void _onSortChanged(String sortBy, bool descending) {
    context.read<ProductProvider>().setSortBy(sortBy, descending);
  }

  Future<void> _loadMyProducts() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;
    await context.read<ProductProvider>().getSupplierProducts(user.id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final isSupplier =
        authProvider.currentUser?.userType == AppConstants.userTypeSupplier;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: _buildAppBar(context, authProvider),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildSortChips(productProvider),
            if (isSupplier) _buildViewToggle(),
            const BannerAdWidget(),
            Expanded(
              child: _buildProductsBody(productProvider, isSupplier),
            ),
          ],
        ),
        floatingActionButton: isSupplier
            ? FloatingActionButton.extended(
                onPressed: () => context.push('/add-product'),
                icon: const Icon(Icons.add),
                label: const Text(
                  'إضافة منتج',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
              )
            : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 8),
          const Text(AppConstants.appName),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_outlined),
          tooltip: 'المحادثات',
          onPressed: () => context.push('/chats'),
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'تسجيل الخروج',
          onPressed: () => authProvider.signOut(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.topBarColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onSubmitted: _onSearch,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontFamily: 'Tajawal'),
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج...',
          hintTextDirection: TextDirection.rtl,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch('');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildSortChips(ProductProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _SortChip(
            label: 'الأحدث',
            selected:
                provider.sortBy == 'createdAt' && provider.sortDescending,
            onTap: () => _onSortChanged('createdAt', true),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'السعر: الأقل',
            selected: provider.sortBy == 'price' && !provider.sortDescending,
            onTap: () => _onSortChanged('price', false),
          ),
          const SizedBox(width: 8),
          _SortChip(
            label: 'السعر: الأعلى',
            selected: provider.sortBy == 'price' && provider.sortDescending,
            onTap: () => _onSortChanged('price', true),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'جميع المنتجات',
              selected: !_showMyProducts,
              onTap: () {
                setState(() => _showMyProducts = false);
                context.read<ProductProvider>().loadProducts();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ToggleButton(
              label: 'منتجاتي',
              selected: _showMyProducts,
              onTap: () {
                setState(() => _showMyProducts = true);
                _loadMyProducts();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsBody(ProductProvider provider, bool isSupplier) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const LoadingWidget();
    }

    if (provider.error != null && provider.products.isEmpty) {
      return AppErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadProducts(),
      );
    }

    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات',
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.refreshProducts(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900
              ? 4
              : constraints.maxWidth > 600
                  ? 3
                  : 2;

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= provider.products.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              final product = provider.products[index];
              return ProductCard(
                product: product,
                onTap: () => context.push('/product/${product.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryColor.withValues(alpha: 0.15)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? AppTheme.primaryColor : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
