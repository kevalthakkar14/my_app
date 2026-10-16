import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../cart_data.dart';
import 'cart_screen.dart';

const Color appBackground = Color(0xFF080D19);
const Color cardBackground = Color(0xFF111827);
const Color orangeColor = Color(0xFFFF7200);

String stockStatus(int stock) {
  if (stock <= 0) return 'OUT OF STOCK';
  if (stock < 10) return 'LOW STOCK';
  return 'IN STOCK';
}

Color stockColor(int stock) {
  if (stock <= 0) return Colors.red;
  if (stock < 10) return Colors.orange;
  return Colors.green;
}

String formatPrice(int price) {
  return '₹${price.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]},',
  )}';
}

Widget productImage(String path, {BoxFit fit = BoxFit.contain}) {
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white38,
          size: 45,
        ),
      ),
    );
  }

  return Image.asset(
    path,
    fit: fit,
    errorBuilder: (_, __, ___) => const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.white38,
        size: 45,
      ),
    ),
  );
}

class ProductItem {
  final String name;
  final int price;
  final double rating;
  final String image;
  final String category;
  final int stock;

  ProductItem({
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
    required this.category,
    this.stock = 20,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'rating': rating,
      'image': image,
      'category': category,
      'stock': stock,
    };
  }

  factory ProductItem.fromMap(Map<dynamic, dynamic> map) {
    return ProductItem(
      name: map['name']?.toString() ?? 'Product',
      price: int.tryParse(map['price']?.toString() ?? '') ?? 0,
      rating: double.tryParse(map['rating']?.toString() ?? '') ?? 4.5,
      image: map['image']?.toString() ?? '',
      category: map['category']?.toString() ?? 'OTHER',
      stock: int.tryParse(map['stock']?.toString() ?? '') ?? 20,
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool showBottomNavigation;
  final ValueChanged<int>? onNavigate;

  const HomeScreen({
    super.key,
    this.showBottomNavigation = true,
    this.onNavigate,
  });

  static final List<ProductItem> allProducts = [
    ProductItem(
      name: 'Premium Leather Seat Cover',
      price: 4999,
      rating: 4.8,
      image: 'assets/images/seat_cover.jpg',
      category: 'SEAT COVERS',
    ),
    ProductItem(
      name: 'Luxury Red Seat Cover',
      price: 4499,
      rating: 4.7,
      image: 'assets/images/seat_cover2.jfif',
      category: 'SEAT COVERS',
    ),
    ProductItem(
      name: 'Sport Seat Cover',
      price: 3999,
      rating: 4.6,
      image: 'assets/images/seat_cover3.jfif',
      category: 'SEAT COVERS',
    ),
    ProductItem(
      name: 'Premium Black Floor Mat',
      price: 2499,
      rating: 4.7,
      image: 'assets/images/floor_mate.jfif',
      category: 'FLOOR MATS',
    ),
    ProductItem(
      name: 'Premium Red Floor Mat',
      price: 2299,
      rating: 4.5,
      image: 'assets/images/floor_mate2.jfif',
      category: 'FLOOR MATS',
    ),
    ProductItem(
      name: 'LED Headlight H7',
      price: 2999,
      rating: 4.6,
      image: 'assets/images/led_headlight.jfif',
      category: 'LED LIGHTS',
    ),
    ProductItem(
      name: '900W LED Headlight',
      price: 3499,
      rating: 4.8,
      image: 'assets/images/led_headlight2.jfif',
      category: 'LED LIGHTS',
    ),
    ProductItem(
      name: 'Premium Car Wheel',
      price: 7999,
      rating: 4.7,
      image: 'assets/images/car_wheel.jfif',
      category: 'WHEELS',
    ),
    ProductItem(
      name: 'Sport Car Wheel',
      price: 8499,
      rating: 4.8,
      image: 'assets/images/car_wheel2.jfif',
      category: 'WHEELS',
    ),
    ProductItem(
      name: 'Premium Engine Oil',
      price: 1899,
      rating: 4.6,
      image: 'assets/images/car_airpurifier.webp',
      category: 'ENGINE OIL',
    ),
    ProductItem(
      name: 'High Performance Oil',
      price: 2199,
      rating: 4.7,
      image: 'assets/images/car_airpurifier.webp',
      category: 'ENGINE OIL',
    ),
    ProductItem(
      name: 'Car Air Purifier',
      price: 2499,
      rating: 4.5,
      image: 'assets/images/car_airpurifier.webp',
      category: 'INTERIORS',
    ),
    ProductItem(
      name: 'Steering Wheel',
      price: 1299,
      rating: 4.4,
      image: 'assets/images/steering_wheel.jpg',
      category: 'INTERIORS',
    ),
    ProductItem(
      name: 'Alloy Wheels 17 inch',
      price: 8999,
      rating: 4.9,
      image: 'assets/images/car_wheel.jfif',
      category: 'WHEELS',
    ),
    ProductItem(
      name: 'Car Cleaning Kit',
      price: 899,
      rating: 4.7,
      image: 'assets/images/cleanning_kit.webp',
      category: 'EXTERIORS',
    ),
  ];

  static List<ProductItem> firebaseProductsCache = [];

  static List<ProductItem> get allAvailableProducts => [
        ...allProducts,
        ...firebaseProductsCache,
      ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<DatabaseEvent>? _productsSubscription;
  List<ProductItem> firebaseProducts = [];
  bool productsLoading = true;
  bool firebaseProductsUnavailable = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsSubscription = FirebaseDatabase.instance
        .ref('products')
        .onValue
        .listen(
      (event) {
        final value = event.snapshot.value;
        final loaded = <ProductItem>[];

        if (value is Map) {
          for (final entry in value.values) {
            if (entry is Map) {
              loaded.add(ProductItem.fromMap(entry));
            }
          }
        }

        if (!mounted) return;

        setState(() {
          firebaseProducts = loaded;
          productsLoading = false;
          firebaseProductsUnavailable = false;
          HomeScreen.firebaseProductsCache = loaded;
        });
      },
      onError: (Object error) {
        if (!mounted) return;

        setState(() {
          productsLoading = false;
          firebaseProductsUnavailable = true;
        });
      },
    );
  }

  List<ProductItem> get products => [
        ...HomeScreen.allProducts,
        ...firebaseProducts,
      ];

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  void openCart() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(2);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    }
  }

  void openSearch() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(1);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchScreen(products: products),
        ),
      );
    }
  }

  void openProfile() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(3);
    }
  }

  void openCategory(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProductsScreen(
          categoryName: title,
          products: products,
        ),
      ),
    );
  }

  void openProduct(ProductItem product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailsScreen(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/car_logo.jfif',
              width: 42,
              height: 42,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.directions_car,
                color: orangeColor,
                size: 34,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'AutoZone Premium',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: openSearch,
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: CartData.items,
            builder: (context, cart, _) {
              return Stack(
                children: [
                  IconButton(
                    onPressed: openCart,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                  ),
                  if (CartData.itemCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: orangeColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${CartData.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1C2538),
                      Color(0xFF111827),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 5,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 220,
                        child: productImage(
                          'assets/images/car_image.jfif',
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 215,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPGRADE YOUR RIDE',
                                style: TextStyle(
                                  color: orangeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Premium Car Accessories',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Quality accessories for your car.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Categories',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 95,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryCard('SEAT COVERS', Icons.event_seat),
                    _categoryCard('FLOOR MATS', Icons.layers),
                    _categoryCard('LED LIGHTS', Icons.lightbulb_outline),
                    _categoryCard('WHEELS', Icons.tire_repair),
                    _categoryCard(
                      'ENGINE OIL',
                      Icons.oil_barrel_outlined,
                    ),
                    _categoryCard(
                      'INTERIORS',
                      Icons.airline_seat_recline_normal,
                    ),
                    _categoryCard(
                      'EXTERIORS',
                      Icons.cleaning_services,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Products',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${products.length} items',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (productsLoading)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(
                    color: orangeColor,
                    backgroundColor: cardBackground,
                  ),
                ),
              if (firebaseProductsUnavailable)
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    'Showing available products. Firebase products could not load; check database permissions and connection.',
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.76,
                ),
                itemBuilder: (context, index) {
                  return _productCard(products[index]);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          widget.showBottomNavigation ? _bottomNavigation() : null,
    );
  }

  Widget _categoryCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () => openCategory(title),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: orangeColor, size: 28),
            const SizedBox(height: 7),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(ProductItem product) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => openProduct(product),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox.expand(
                  child: productImage(product.image),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () => openProduct(product),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      color: orangeColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    stockStatus(product.stock),
                    style: TextStyle(
                      color: stockColor(product.stock),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1425),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', true, () {}),
              _navItem(Icons.search, 'Browse', false, openSearch),
              _navItem(
                Icons.shopping_cart_outlined,
                'Cart',
                false,
                openCart,
              ),
              _navItem(
                Icons.person_outline,
                'Profile',
                false,
                openProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String title,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: selected ? orangeColor : Colors.white54,
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: selected ? orangeColor : Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  final List<ProductItem> products;

  const SearchScreen({
    super.key,
    required this.products,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.products.where((product) {
      return product.name.toLowerCase().contains(search.toLowerCase()) ||
          product.category.toLowerCase().contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        title: const Text(
          'Browse Products',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) => setState(() => search = value),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: orangeColor,
                    ),
                    filled: true,
                    fillColor: cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: results.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.76,
                        ),
                        itemBuilder: (context, index) {
                          final product = results[index];
                          return _searchProductCard(context, product);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchProductCard(BuildContext context, ProductItem product) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(product: product),
                ),
              ),
              child: SizedBox.expand(
                child: productImage(product.image),
              ),
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    formatPrice(product.price),
                    style: const TextStyle(
                      color: orangeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    stockStatus(product.stock),
                    style: TextStyle(
                      color: stockColor(product.stock),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;
  final List<ProductItem>? products;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
    this.products,
  });

  @override
  Widget build(BuildContext context) {
    final source = products ?? HomeScreen.allAvailableProducts;
    final filtered = source
        .where(
          (product) =>
              product.category.toUpperCase() == categoryName.toUpperCase(),
        )
        .toList();

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        title: Text(
          categoryName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No products in this category',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  itemBuilder: (context, index) {
                    final product = filtered[index];

                    return Container(
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              ),
                              child: SizedBox.expand(
                                child: productImage(product.image),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  formatPrice(product.price),
                                  style: const TextStyle(
                                    color: orangeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  stockStatus(product.stock),
                                  style: TextStyle(
                                    color: stockColor(product.stock),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final ProductItem product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;

    return Scaffold(
      backgroundColor: appBackground,
      appBar: AppBar(
        backgroundColor: appBackground,
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: productImage(product.image),
              ),
              const SizedBox(height: 22),
              Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 5),
                  Text(
                    product.rating.toString(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatPrice(product.price),
                style: const TextStyle(
                  color: orangeColor,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.category,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: stockColor(product.stock).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: stockColor(product.stock),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      stockStatus(product.stock),
                      style: TextStyle(
                        color: stockColor(product.stock),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${product.stock} available',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: outOfStock
                      ? null
                      : () {
                          CartData.addToCart(product.toMap());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Product added to cart'),
                              backgroundColor: orangeColor,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangeColor,
                    disabledBackgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    outOfStock ? 'OUT OF STOCK' : 'ADD TO CART',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}