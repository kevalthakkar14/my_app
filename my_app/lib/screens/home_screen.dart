  import 'package:flutter/material.dart';
  import 'cart_screen.dart';
  import 'profile_screen.dart';
  import '../cart_data.dart';

  class ProductItem {
    final String name;
    final int price;
    final String rating;
    final String image;
    final String category;

    const ProductItem({
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
  }

  class CategoryItem {
    final String name;
    final IconData icon;

    const CategoryItem({
      required this.name,
      required this.icon,
    });
  }

  class HomeScreen extends StatefulWidget {
    const HomeScreen({super.key});

    @override
    State<HomeScreen> createState() => _HomeScreenState();
  }

  class _HomeScreenState extends State<HomeScreen> {
    int selectedBottom = 0;

    final List<CategoryItem> categories = const [
      CategoryItem(
        name: 'ENGINE OIL',
        icon: Icons.bolt,
      ),
      CategoryItem(
        name: 'SEAT COVERS',
        icon: Icons.shield_outlined,
      ),
      CategoryItem(
        name: 'FLOOR MATS',
        icon: Icons.location_on_outlined,
      ),
      CategoryItem(
        name: 'LED LIGHTS',
        icon: Icons.star_border,
      ),
      CategoryItem(
        name: 'WHEELS',
        icon: Icons.tire_repair,
      ),
    ];

    final List<ProductItem> products = const [
      ProductItem(
        name: 'Premium Leather Seat Cover',
        price: 4999,
        rating: '4.8',
        image: 'assets/images/seat_cover.jpg',
        category: 'SEAT COVERS',
      ),
      ProductItem(
        name: 'LED Headlight H7',
        price: 2999,
        rating: '4.6',
        image: 'assets/images/led_headlight.jfif',
        category: 'LED LIGHTS',
      ),
      ProductItem(
        name: 'Car Air Purifier',
        price: 2499,
        rating: '4.5',
        image: 'assets/images/car_airpurifier.webp',
        category: 'INTERIORS',
      ),
      ProductItem(
        name: 'Steering Wheel',
        price: 1299,
        rating: '4.4',
        image: 'assets/images/steering_wheel.jpg',
        category: 'INTERIORS',
      ),
      ProductItem(
        name: 'Alloy Wheels 17 inch',
        price: 8999,
        rating: '4.9',
        image: 'assets/images/car_wheel.jfif',
        category: 'WHEELS',
      ),
      ProductItem(
        name: 'Car Cleaning Kit',
        price: 899,
        rating: '4.7',
        image: 'assets/images/cleanning_kit.webp',
        category: 'EXTERIORS',
      ),
    ];

    String money(int value) {
      return '₹${value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    }

    void addProduct(ProductItem product) {
      CartData.addToCart(product.toMap());

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to cart',
            style: const TextStyle(fontSize: 12),
          ),
          backgroundColor: const Color(0xFFFF7200),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    void openProduct(ProductItem product) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsScreen(
            product: product,
          ),
        ),
      );
    }

    void openCategory(String category) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryProductsScreen(
            categoryName: category,
          ),
        ),
      );
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFF080D19),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        14,
                        14,
                        14,
                        10,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _header(),
                          const SizedBox(height: 14),
                          _searchBar(),
                          const SizedBox(height: 14),
                          _saleBanner(),
                          const SizedBox(height: 17),
                          _categoryTitle(),
                          const SizedBox(height: 9),
                          _categories(),
                          const SizedBox(height: 13),
                          _services(),
                          const SizedBox(height: 17),
                          _featuredTitle(),
                          const SizedBox(height: 9),
                          _productsGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _bottomNavigation(),
      );
    }

    Widget _header() {
      return Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white54,
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/car_logo.jfif',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return const Icon(
                    Icons.directions_car,
                    color: Colors.deepOrange,
                    size: 25,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 9),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'welcome back,',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Keval Thakkar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const CartScreen(),
                ),
              );
            },
            child: ValueListenableBuilder<
                List<Map<String, dynamic>>>(
              valueListenable: CartData.items,
              builder: (context, items, child) {
                int count = 0;

                for (final item in items) {
                  count +=
                      (item['quantity'] ?? 1) as int;
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 23,
                    ),
                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -7,
                        child: Container(
                          padding:
                              const EdgeInsets.all(3),
                          decoration:
                              const BoxDecoration(
                            color: Colors.deepOrange,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      );
    }

    Widget _searchBar() {
      return Container(
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: const Color(0xFF65718A),
            width: 0.7,
          ),
        ),
        child: const TextField(
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
          ),
          decoration: InputDecoration(
            hintText:
                'Search accessories, parts...',
            hintStyle: TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white70,
              size: 18,
            ),
            suffixIcon: Icon(
              Icons.chevron_right,
              color: Colors.deepOrange,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    Widget _saleBanner() {
      return Container(
        height: 125,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          image: const DecorationImage(
            image: AssetImage(
              'assets/images/car_image.jfif',
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black54,
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius:
                      BorderRadius.circular(8),
                ),
                child: const Text(
                  'SUMMER SALE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                '40% OFF On',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Text(
                'Seat Covers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              GestureDetector(
                onTap: () {
                  openCategory('SEAT COVERS');
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                  child: const Text(
                    'Shop Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _categoryTitle() {
      return Row(
        children: [
          const Expanded(
            child: Text(
              'Categories',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'See All →',
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    Widget _categories() {
      return SizedBox(
        height: 73,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder:
              (context, index) =>
                  const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories[index];

            return GestureDetector(
              onTap: () {
                openCategory(category.name);
              },
              child: SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Colors.deepOrange
                            : const Color(0xFF101827),
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                          color: index == 0
                              ? Colors.deepOrange
                              : const Color(0xFF647087),
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        color: Colors.white,
                        size: 21,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    Widget _services() {
      return Container(
        height: 47,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF65718A),
            width: 0.6,
          ),
        ),
        child: Row(
          children: [
            _service(
              Icons.local_shipping_outlined,
              'FAST DELIVERY',
            ),
            _divider(),
            _service(
              Icons.verified_outlined,
              'GENUINE PARTS',
            ),
            _divider(),
            _service(
              Icons.star_border,
              'EXPERT SUPPORT',
            ),
          ],
        ),
      );
    }

    Widget _service(
      IconData icon,
      String title,
    ) {
      return Expanded(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.deepOrange,
              size: 14,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 6,
              ),
            ),
          ],
        ),
      );
    }

    Widget _divider() {
      return Container(
        width: 0.5,
        height: 25,
        color: Colors.white24,
      );
    }

    Widget _featuredTitle() {
      return Row(
        children: [
          const Expanded(
            child: Text(
              'Featured Products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text(
            'See All →',
            style: TextStyle(
              color: Colors.deepOrange,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    Widget _productsGrid() {
      return GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          childAspectRatio: 0.76,
        ),
        itemBuilder: (context, index) {
          return _productCard(
            products[index],
            index,
          );
        },
      );
    }

    Widget _productCard(
      ProductItem product,
      int index,
    ) {
      return GestureDetector(
        onTap: () {
          openProduct(product);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B3D45),
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.all(5),
                          child: Image.asset(
                            product.image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .image_not_supported_outlined,
                                color: Colors.white54,
                                size: 30,
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    if (index == 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 6,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration:
                            const BoxDecoration(
                          color: Color(0xAA111827),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 4,
                child: Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    8,
                    5,
                    7,
                    5,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        product.name,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.orange,
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product.rating,
                            style:
                                const TextStyle(
                              color: Colors.white60,
                              fontSize: 7,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              money(product.price),
                              style:
                                  const TextStyle(
                                color:
                                    Colors.deepOrange,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              addProduct(product);
                            },
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    Color(0xFF30271F),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons
                                    .shopping_cart_outlined,
                                color:
                                    Colors.deepOrange,
                                size: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _bottomNavigation() {
      const icons = [
        Icons.home_outlined,
        Icons.search,
        Icons.favorite_border,
        Icons.shopping_cart_outlined,
        Icons.person_outline,
      ];

      const selectedIcons = [
        Icons.home,
        Icons.search,
        Icons.favorite,
        Icons.shopping_cart,
        Icons.person,
      ];

      const labels = [
        'Home',
        'Browse',
        'Wishlist',
        'Cart',
        'Profile',
      ];

      return Container(
        height: 58,
        decoration: const BoxDecoration(
          color: Color(0xFF0C1422),
          border: Border(
            top: BorderSide(
              color: Color(0xFF273247),
              width: 0.6,
            ),
          ),
        ),
        child: Row(
          children: List.generate(
            labels.length,
            (index) {
              final selected =
                  selectedBottom == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CartScreen(),
                        ),
                      );
                      return;
                    }

                    if (index == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const ProfileScreen(),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      selectedBottom = index;
                    });
                  },
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected
                            ? selectedIcons[index]
                            : icons[index],
                        color: selected
                            ? Colors.deepOrange
                            : Colors.white60,
                        size: 18,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: selected
                              ? Colors.deepOrange
                              : Colors.white60,
                          fontSize: 7,
                          fontWeight: selected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
  }

  class CategoryProductsScreen extends StatelessWidget {
    final String categoryName;

    const CategoryProductsScreen({
      super.key,
      required this.categoryName,
  });

    List<ProductItem> get products {
      switch (categoryName) {
        case 'SEAT COVERS':
          return const [
            ProductItem(
              name: 'Premium Leather Seat Cover',
              price: 4999,
              rating: '4.8',
              image: 'assets/images/seat_cover.jpg',
              category: 'INTERIORS',
            ),
            ProductItem(
              name: 'Luxury Red Seat Cover',
              price: 3999,
              rating: '4.6',
              image: 'assets/images/seat_cover2.jfif',
              category: 'INTERIORS',
            ),
            ProductItem(
              name: 'Sport Seat Cover',
              price: 4499,
              rating: '4.7',
              image: 'assets/images/seat_cover3.jfif',
              category: 'INTERIORS',
            ),
          ];

        case 'FLOOR MATS':
          return const [
            ProductItem(
              name: 'Premium Black Floor Mat',
              price: 2499,
              rating: '4.7',
              image: 'assets/images/floor_mate.jfif',
              category: 'INTERIORS',
            ),
            ProductItem(
              name: 'Premium Red Floor Mat',
              price: 2799,
              rating: '4.8',
              image: 'assets/images/floor_mate2.jfif',
              category: 'INTERIORS',
            ),
          ];

        case 'LED LIGHTS':
          return const [
            ProductItem(
              name: 'LED Headlight H7',
              price: 2999,
              rating: '4.6',
              image: 'assets/images/led_headlight.jfif',
              category: 'LIGHTING',
            ),
            ProductItem(
              name: '900W LED Headlight',
              price: 3499,
              rating: '4.7',
              image: 'assets/images/led_headlight2.jfif',
              category: 'LIGHTING',
            ),
          ];

        case 'WHEELS':
          return const [
            ProductItem(
              name: 'Premium Car Wheel',
              price: 8999,
              rating: '4.8',
              image: 'assets/images/car_wheel.jfif',
              category: 'WHEELS',
            ),
            ProductItem(
              name: 'Sport Car Wheel',
              price: 10999,
              rating: '4.7',
              image: 'assets/images/car_wheel2.jfif',
              category: 'WHEELS',
            ),
          ];

        default:
          return const [
            ProductItem(
              name: 'Premium Engine Oil',
              price: 1499,
              rating: '4.7',
              image: 'assets/images/car_airpurifier.webp',
              category: 'ENGINE',
            ),
            ProductItem(
              name: 'High Performance Oil',
              price: 1899,
              rating: '4.8',
              image: 'assets/images/cleanning_kit.webp',
              category: 'ENGINE',
            ),
          ];
      }
    }

    String money(int value) {
      return '₹${value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFF080D19),
        appBar: AppBar(
          backgroundColor:
              const Color(0xFF080D19),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            categoryName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: GridView.builder(
          padding: const EdgeInsets.fromLTRB(
            12,
            5,
            12,
            12,
          ),
          itemCount: products.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 7,
            mainAxisSpacing: 7,
            childAspectRatio: 0.76,
          ),
          itemBuilder: (context, index) {
            final product = products[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
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
                      BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: Container(
                          width: double.infinity,
                          color:
                              const Color(0xFF3B3D45),
                          padding:
                              const EdgeInsets.all(5),
                          child: Image.asset(
                            product.image,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return const Icon(
                                Icons
                                    .image_not_supported,
                                color: Colors.white54,
                                size: 30,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(7),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  product.rating,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white60,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    money(product.price),
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.deepOrange,
                                      fontSize: 11,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    CartData.addToCart(
                                      product.toMap(),
                                    );

                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.name} added to cart',
                                          style:
                                              const TextStyle(
                                            fontSize: 11,
                                          ),
                                        ),
                                        backgroundColor:
                                            Colors.deepOrange,
                                        duration:
                                            const Duration(
                                          seconds: 1,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 25,
                                    height: 25,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Color(0xFF30271F),
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons
                                          .shopping_cart_outlined,
                                      color:
                                          Colors.deepOrange,
                                      size: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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

    String money(int value) {
      return '₹${value.toString().replaceAllMapped(
            RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color(0xFF080D19),
        appBar: AppBar(
          backgroundColor:
              const Color(0xFF080D19),
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Product Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  height: 210,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF171F32),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.all(15),
                  child: Image.asset(
                    product.image,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      product.rating,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  money(product.price),
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Product Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                const Text(
                  'Premium quality car accessory designed for comfort, style and durability. Perfect choice for your vehicle.',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      CartData.addToCart(
                        product.toMap(),
                      );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Product added to cart',
                          ),
                          backgroundColor:
                              Colors.deepOrange,
                        ),
                      );
                    },
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepOrange,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'ADD TO CART',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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