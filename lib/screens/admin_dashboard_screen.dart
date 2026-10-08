import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'admin_login_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_users_screen.dart';
import 'admin_categories_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseReference productsRef =
      FirebaseDatabase.instance.ref('products');

  final DatabaseReference ordersRef =
      FirebaseDatabase.instance.ref('orders');

  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref('users');

  int totalProducts = 0;
  int totalOrders = 0;
  int totalUsers = 0;
  double totalSales = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final productsSnapshot = await productsRef.get();
      final ordersSnapshot = await ordersRef.get();
      final usersSnapshot = await usersRef.get();

      int productsCount = 0;
      int ordersCount = 0;
      int usersCount = 0;
      double sales = 0;

      if (productsSnapshot.exists && productsSnapshot.value is Map) {
        final products =
            Map<dynamic, dynamic>.from(productsSnapshot.value as Map);
        productsCount = products.length;
      }

      if (ordersSnapshot.exists && ordersSnapshot.value is Map) {
        final orders =
            Map<dynamic, dynamic>.from(ordersSnapshot.value as Map);

        ordersCount = orders.length;

        for (final order in orders.values) {
          if (order is Map) {
            final orderData = Map<dynamic, dynamic>.from(order);

            final status =
                orderData['status']?.toString().toUpperCase() ?? '';

            if (status != 'CANCELLED') {
              final totalValue = orderData['total'];

              if (totalValue is num) {
                sales += totalValue.toDouble();
              } else {
                sales +=
                    double.tryParse(totalValue?.toString() ?? '0') ?? 0;
              }
            }
          }
        }
      }

      if (usersSnapshot.exists && usersSnapshot.value is Map) {
        final users =
            Map<dynamic, dynamic>.from(usersSnapshot.value as Map);
        usersCount = users.length;
      }

      if (mounted) {
        setState(() {
          totalProducts = productsCount;
          totalOrders = ordersCount;
          totalUsers = usersCount;
          totalSales = sales;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading dashboard data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminProductsScreen(),
      ),
    );
  }

  void openOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminOrdersScreen(),
      ),
    );
  }

  void openUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminUsersScreen(),
      ),
    );
  }

  void openCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminCategoriesScreen(),
      ),
    );
  }

  void logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminLoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.deepOrange,
              size: 26,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget managementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(alpha: 0.15),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white54,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  String formatSales(double value) {
    return '₹${value.toStringAsFixed(2)}';
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
            onPressed: loadDashboardData,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.deepOrange,
        backgroundColor: const Color(0xFF111827),
        onRefresh: loadDashboardData,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome, Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Manage your car accessories store',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.35,
                      children: [
                        statCard(
                          title: 'Products',
                          value: totalProducts.toString(),
                          icon: Icons.inventory_2_outlined,
                        ),
                        statCard(
                          title: 'Orders',
                          value: totalOrders.toString(),
                          icon: Icons.shopping_bag_outlined,
                        ),
                        statCard(
                          title: 'Users',
                          value: totalUsers.toString(),
                          icon: Icons.people_outline,
                        ),
                        statCard(
                          title: 'Sales',
                          value: formatSales(totalSales),
                          icon: Icons.currency_rupee,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Management',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    managementCard(
                      title: 'Products',
                      subtitle: 'Add, edit and delete products',
                      icon: Icons.inventory_2_outlined,
                      onTap: openProducts,
                    ),
                    const SizedBox(height: 14),
                    managementCard(
                      title: 'Orders',
                      subtitle: 'View and manage customer orders',
                      icon: Icons.shopping_cart_outlined,
                      onTap: openOrders,
                    ),
                    const SizedBox(height: 14),
                    managementCard(
                      title: 'Users',
                      subtitle: 'View registered users',
                      icon: Icons.people_outline,
                      onTap: openUsers,
                    ),
                    const SizedBox(height: 14),
                    managementCard(
                      title: 'Categories',
                      subtitle: 'Manage product categories',
                      icon: Icons.category_outlined,
                      onTap: openCategories,
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.cloud_done_outlined,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Firebase Database',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Connected and ready',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
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
    );
  }
}