import 'package:flutter/material.dart';
import '../cart_data.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int selectedTab = 0;

  String money(int value) {
    return '₹${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1428),
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _tabs(),

            Expanded(
              child: ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: CartData.items,
                builder: (context, items, child) {
                  if (selectedTab == 1) {
                    return const Center(
                      child: Text(
                        'Wishlist',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  if (items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white38,
                            size: 60,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Your cart is empty',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Add products to your cart',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      10,
                      12,
                      20,
                    ),
                    child: Column(
                      children: [
                        for (int index = 0;
                            index < items.length;
                            index++)
                          _cartItem(
                            index,
                            items[index],
                          ),

                        const SizedBox(height: 8),

                        _discountBox(),

                        const SizedBox(height: 10),

                        _priceSummary(),

                        const SizedBox(height: 12),

                        _checkoutButton(),
                      ],
                    ),
                  );
                },
              ),
            ),

            _bottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
          ),

          const Expanded(
            child: Center(
              child: Text(
                'My Items',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF161F32),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 0;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedTab == 0
                      ? const Color(0xFFFF7200)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ValueListenableBuilder<
                    List<Map<String, dynamic>>>(
                  valueListenable: CartData.items,
                  builder: (context, items, child) {
                    return Text(
                      'My Cart (${CartData.itemCount})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedTab = 1;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selectedTab == 1
                      ? const Color(0xFFFF7200)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Wishlist (4)',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(
    int index,
    Map<String, dynamic> item,
  ) {
    int price = CartData.toInt(item['price']);
    int quantity = CartData.toInt(
      item['quantity'],
      1,
    );

    return Container(
      height: 95,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 75,
            decoration: const BoxDecoration(
              color: Color(0xFFFF7200),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),

          const SizedBox(width: 7),

          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF171F32),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              item['image']?.toString() ?? '',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  color: Colors.white38,
                  size: 30,
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? 'Product',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  money(price),
                  style: const TextStyle(
                    color: Color(0xFFFF7200),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  height: 29,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white54,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 35,
                        height: 29,
                        child: IconButton(
                          onPressed: () {
                            CartData.decrease(index);
                          },
                          padding: EdgeInsets.zero,
                          splashRadius: 16,
                          icon: const Text(
                            '−',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF7200),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 35,
                        height: 29,
                        child: IconButton(
                          onPressed: () {
                            CartData.increase(index);
                          },
                          padding: EdgeInsets.zero,
                          splashRadius: 16,
                          icon: const Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(
              right: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    CartData.removeFromCart(index);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 19,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27232A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'IN STOCK',
                    style: TextStyle(
                      color: Color(0xFFFF7200),
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountBox() {
    int discount = CartData.discount;

    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF252E3F),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF3A3030),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xFFFF7200),
              size: 16,
            ),
          ),

          const SizedBox(width: 9),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Discount Applied!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                discount > 0
                    ? 'You saved ${money(discount)} on this order'
                    : 'Add more items to get a discount',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceSummary() {
    int subtotal = CartData.subtotal;
    int discount = CartData.discount;
    int delivery = CartData.deliveryCharges;
    int total = CartData.total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Subtotal',
            money(subtotal),
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Discount',
            '-${money(discount)}',
            orange: true,
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Delivery Charges',
            delivery == 0
                ? 'FREE'
                : money(delivery),
            orange: delivery != 0,
          ),

          const SizedBox(height: 12),

          const Divider(
            color: Colors.white24,
            height: 1,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              Text(
                money(total),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool orange = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ),

        Text(
          value,
          style: TextStyle(
            color: orange
                ? const Color(0xFFFF7200)
                : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _checkoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const CheckoutScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7200),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed to Checkout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: 8),

            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavigation() {
    return Container(
      height: 55,
      decoration: const BoxDecoration(
        color: Color(0xFF0C1425),
        border: Border(
          top: BorderSide(
            color: Colors.white12,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _bottomItem(
            Icons.home_outlined,
            'Home',
          ),
          _bottomItem(
            Icons.search,
            'Browse',
          ),
          _bottomItem(
            Icons.favorite_border,
            'Wishlist',
          ),
          _bottomItem(
            Icons.shopping_cart_outlined,
            'Cart',
            true,
          ),
          _bottomItem(
            Icons.person_outline,
            'Profile',
          ),
        ],
      ),
    );
  }

  Widget _bottomItem(
    IconData icon,
    String title, [
    bool selected = false,
  ]) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: selected
              ? const Color(0xFFFF7200)
              : Colors.white54,
          size: 20,
        ),

        const SizedBox(height: 2),

        Text(
          title,
          style: TextStyle(
            color: selected
                ? const Color(0xFFFF7200)
                : Colors.white54,
            fontSize: 7,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}