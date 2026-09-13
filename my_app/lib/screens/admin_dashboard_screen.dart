import 'package:flutter/material.dart';
import 'admin_login_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  void openProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminProductsScreen(),
      ),
    );
  }

  void openOrders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminOrdersScreen(),
      ),
    );
  }

  void comingSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title is coming soon'),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  void logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminLoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.deepOrange,
            size: 28,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget managementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.deepOrange,
                size: 27,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080D19),
        elevation: 0,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white70,
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome, Admin 👋',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Manage your AutoZone Premium store',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.45,
                  children: [
                    statCard(
                      'Products',
                      '15',
                      Icons.inventory_2_outlined,
                    ),
                    statCard(
                      'Orders',
                      '0',
                      Icons.shopping_cart_outlined,
                    ),
                    statCard(
                      'Users',
                      '0',
                      Icons.people_outline,
                    ),
                    statCard(
                      'Sales',
                      '₹0',
                      Icons.currency_rupee,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'MANAGEMENT',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),

                managementCard(
                  context,
                  'Products',
                  'Add, edit and delete products',
                  Icons.inventory_2_outlined,
                  () {
                    openProducts(context);
                  },
                ),

                const SizedBox(height: 12),

                managementCard(
                  context,
                  'Orders',
                  'View and manage customer orders',
                  Icons.shopping_cart_outlined,
                  () {
                    openOrders(context);
                  },
                ),

                const SizedBox(height: 12),

                managementCard(
                  context,
                  'Users',
                  'View registered customers',
                  Icons.people_outline,
                  () {
                    comingSoon(context, 'Users');
                  },
                ),

                const SizedBox(height: 12),

                managementCard(
                  context,
                  'Categories',
                  'Manage product categories',
                  Icons.category_outlined,
                  () {
                    comingSoon(context, 'Categories');
                  },
                ),

                const SizedBox(height: 30),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        color: Colors.deepOrange,
                        size: 30,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AutoZone Premium',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Administrator Panel',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}