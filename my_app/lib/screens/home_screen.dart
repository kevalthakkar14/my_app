import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../cart_data.dart';
import 'cart_screen.dart';

class ProductItem {
  final String name;
  final int price;
  final double rating;
  final String image;
  final String category;

  ProductItem({
    required this.name,
    required this.price,
    required this.rating,
    required this.image,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'rating': rating,
      'image': image,
      'category': category,
    };
  }

  factory ProductItem.fromMap(Map<dynamic, dynamic> map) {
    return ProductItem(
      name: map['name']?.toString() ?? 'Product',
      price: int.tryParse(map['price']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(map['rating']?.toString() ?? '4.5') ?? 4.5,
      image: map['image']?.toString() ?? '',
      category: map['category']?.toString() ?? 'OTHER',
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

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseReference productsRef =
      FirebaseDatabase.instance.ref('products');

  List<ProductItem> firebaseProducts = [];

  @override
  void initState() {
    super.initState();
    loadFirebaseProducts();
  }

  void loadFirebaseProducts() {
    productsRef.onValue.listen((event) {
      final value = event.snapshot.value;

      if (value == null) {
        if (mounted) {
          setState(() {
            firebaseProducts = [];
          });
        }
        return;
      }

      if (value is! Map) {
        return;
      }

      final data = Map<dynamic, dynamic>.from(value);
      final List<ProductItem> loadedProducts = [];

      for (final item in data.values) {
        if (item is Map) {
          loadedProducts.add(
            ProductItem.fromMap(item),
          );
        }
      }

      if (mounted) {
        setState(() {
          firebaseProducts = loadedProducts;
        });
      }
    });
  }

  List<ProductItem> get products {
    return [
      ...HomeScreen.allProducts,
      ...firebaseProducts,
    ];
  }

  void openCart() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(3);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CartScreen(),
        ),
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
          builder: (_) => SearchScreen(
            products: products,
          ),
        ),
      );
    }
  }

  void openWishlist() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(2);
    }
  }

  void openProfile() {
    if (widget.onNavigate != null) {
      widget.onNavigate!(4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080D19),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset(
              'assets/images/car_logo.jfif',
              width: 42,
              height: 42,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.directions_car,
                  color: Colors.deepOrange,
                  size: 34,
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'AutoZone Premium',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: openSearch,
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
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
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          CartData.itemCount.toString(),
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
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
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
                      right: 10,
                      bottom: 0,
                      top: 0,
                      child: Image.asset(
                        'assets/images/car_image.jfif',
                        width: 230,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return const SizedBox();
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 230,
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPGRADE YOUR RIDE',
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Premium Car Accessories',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
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
              const SizedBox(height: 22),
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
                    categoryCard(
                      'SEAT COVERS',
                      Icons.event_seat,
                    ),
                    categoryCard(
                      'FLOOR MATS',
                      Icons.layers,
                    ),
                    categoryCard(
                      'LED LIGHTS',
                      Icons.lightbulb_outline,
                    ),
                    categoryCard(
                      'WHEELS',
                      Icons.tire_repair,
                    ),
                    categoryCard(
                      'INTERIORS',
                      Icons.airline_seat_recline_normal,
                    ),
                    categoryCard(
                      'EXTERIORS',
                      Icons.cleaning_services,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
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
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.76,
                ),
                itemBuilder: (context, index) {
                  return productCard(products[index]);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? bottomNavigation()
          : null,
    );
  }

  Widget categoryCard(
    String title,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryProductsScreen(
              categoryName: title,
            ),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.deepOrange,
              size: 28,
            ),
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

  Widget productCard(ProductItem product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: product.image.startsWith('assets/')
                    ? SizedBox(
                        width: double.infinity,
                        child: Image.asset(
                          product.image,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) {
                            return const Center(
                              child: Icon(
                                Icons
                                    .image_not_supported,
                                color:
                                    Colors.white38,
                                size: 45,
                              ),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.white38,
                          size: 45,
                        ),
                      ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                11,
                9,
                11,
                10,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
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
                    '₹${product.price}',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1425),
        border: Border(
          top: BorderSide(
            color: Colors.white10,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            vertical: 7,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              navItem(
                Icons.home_outlined,
                'Home',
                true,
                () {},
              ),
              navItem(
                Icons.search,
                'Browse',
                false,
                openSearch,
              ),
              navItem(
                Icons.favorite_border,
                'Wishlist',
                false,
                openWishlist,
              ),
              navItem(
                Icons.shopping_cart_outlined,
                'Cart',
                false,
                openCart,
              ),
              navItem(
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

  Widget navItem(
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
            color: selected
                ? Colors.deepOrange
                : Colors.white54,
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.deepOrange
                  : Colors.white54,
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
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final results = widget.products.where(
      (product) {
        return product.name
                .toLowerCase()
                .contains(search.toLowerCase()) ||
            product.category
                .toLowerCase()
                .contains(search.toLowerCase());
      },
    ).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFF080D19),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF080D19),
        title: const Text(
          'Browse Products',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      search = value;
                    });
                  },
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        'Search products...',
                    hintStyle:
                        const TextStyle(
                      color: Colors.white54,
                    ),
                    prefixIcon:
                        const Icon(
                      Icons.search,
                      color:
                          Colors.deepOrange,
                    ),
                    filled: true,
                    fillColor:
                        const Color(
                            0xFF111827),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius
                              .circular(14),
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  itemCount:
                      results.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  itemBuilder:
                      (context, index) {
                    return searchProductCard(
                      context,
                      results[index],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchProductCard(
    BuildContext context,
    ProductItem product,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailsScreen(
              product: product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: product.image
                      .startsWith('assets/')
                  ? Image.asset(
                      product.image,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color:
                            Colors.white38,
                        size: 45,
                      ),
                    ),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(
                      color:
                          Colors.deepOrange,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProductsScreen
    extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final products = HomeScreen.allProducts
        .where(
          (product) =>
              product.category
                  .toUpperCase() ==
              categoryName.toUpperCase(),
        )
        .toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFF080D19),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF080D19),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          child: GridView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: products.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.76,
            ),
            itemBuilder:
                (context, index) {
              final product =
                  products[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailsScreen(
                        product: product,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                            0xFF111827),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          product.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets
                                .all(10),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '₹${product.price}',
                              style:
                                  const TextStyle(
                                color: Colors
                                    .deepOrange,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ProductDetailsScreen
    extends StatelessWidget {
  final ProductItem product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF080D19),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF080D19),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 600,
          ),
          child: ListView(
            padding:
                const EdgeInsets.all(20),
            children: [
              Container(
                height: 280,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                          0xFF111827),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: product.image
                        .startsWith('assets/')
                    ? Image.asset(
                        product.image,
                        fit: BoxFit.contain,
                      )
                    : const Icon(
                        Icons.image_outlined,
                        color:
                            Colors.white38,
                        size: 80,
                      ),
              ),
              const SizedBox(height: 22),
              Text(
                product.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    product.rating
                        .toString(),
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '₹${product.price}',
                style: const TextStyle(
                  color:
                      Colors.deepOrange,
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
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
              const SizedBox(height: 25),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    CartData.addToCart(
                      product.toMap(),
                    );

                    ScaffoldMessenger.of(
                            context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Product added to cart',
                        ),
                        backgroundColor:
                            Colors
                                .deepOrange,
                      ),
                    );
                  },
                  style: ElevatedButton
                      .styleFrom(
                    backgroundColor:
                        Colors
                            .deepOrange,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                  ),
                  child: const Text(
                    'ADD TO CART',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
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