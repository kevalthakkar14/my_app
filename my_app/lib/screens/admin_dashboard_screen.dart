
import 'admin_users_screen.dart';
import 'admin_categories_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'admin_login_screen.dart';
import 'admin_products_screen.dart';
import 'admin_orders_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final DatabaseReference productsRef =
      FirebaseDatabase.instance.ref('products');

  final DatabaseReference ordersRef =
      FirebaseDatabase.instance.ref('orders');

  final DatabaseReference usersRef =
      FirebaseDatabase.instance.ref('users');

  int productCount = 0;
  int orderCount = 0;
  int userCount = 0;
  int sales = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      final productsSnapshot = await productsRef.get();
      final ordersSnapshot = await ordersRef.get();
      final usersSnapshot = await usersRef.get();

      int products = 0;
      int orders = 0;
      int users = 0;
      int totalSales = 0;

      if (productsSnapshot.exists &&
          productsSnapshot.value is Map) {
        final Map productsData =
            productsSnapshot.value as Map;

        products = productsData.length;
      }

      if (ordersSnapshot.exists &&
          ordersSnapshot.value is Map) {
        final Map ordersData =
            ordersSnapshot.value as Map;

        orders = ordersData.length;

        for (final value in ordersData.values) {
          if (value is Map) {
            final status =
                value['status']?.toString().toUpperCase() ?? '';

            final amountValue =
                value['total'] ?? value['amount'] ?? 0;

            int amount = 0;

            if (amountValue is int) {
              amount = amountValue;
            } else if (amountValue is num) {
              amount = amountValue.toInt();
            } else {
              amount =
                  int.tryParse(amountValue.toString()) ?? 0;
            }

            if (status != 'CANCELLED') {
              totalSales += amount;
            }
          }
        }
      }

      if (usersSnapshot.exists &&
          usersSnapshot.value is Map) {
        final Map usersData =
            usersSnapshot.value as Map;

        users = usersData.length;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        productCount = products;
        orderCount = orders;
        userCount = users;
        sales = totalSales;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      showMessage('Unable to load dashboard data');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  void openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AdminProductsScreen(),
      ),
    ).then((_) {
      loadDashboardData();
    });
  }

  void openOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const AdminOrdersScreen(),
      ),
    ).then((_) {
      loadDashboardData();
    });
  }

 void openUsers() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AdminUsersScreen(),
    ),
  ).then((_) {
    loadDashboardData();
  });
}

void openCategories() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AdminCategoriesScreen(),
    ),
  ).then((_) {
    loadDashboardData();
  });
}

  Future<void> logout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('LOGOUT'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const AdminLoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xDD111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: Colors.deepOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget managementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(17),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xDD111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.deepOrange.withValues(
                  alpha: 0.12,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.deepOrange,
                size: 23,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    );
  }

  String formatSales(int amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }

    if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₹$amount';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080D19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080D19),
        elevation: 0,
        automaticallyImplyLeading: false,
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
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/car_pic2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xCC080D19),
            ),
          ),
          RefreshIndicator(
            color: Colors.deepOrange,
            backgroundColor: const Color(0xFF111827),
            onRefresh: loadDashboardData,
            child: Center(
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome, Admin',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Manage your AutoZone Premium store',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30),
                            child:
                                CircularProgressIndicator(
                              color: Colors.deepOrange,
                            ),
                          ),
                        )
                      else
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.7,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          children: [
                            statCard(
                              icon:
                                  Icons.inventory_2_outlined,
                              title: 'Products',
                              value:
                                  productCount.toString(),
                            ),
                            statCard(
                              icon:
                                  Icons.shopping_bag_outlined,
                              title: 'Orders',
                              value:
                                  orderCount.toString(),
                            ),
                            statCard(
                              icon: Icons.people_outline,
                              title: 'Users',
                              value:
                                  userCount.toString(),
                            ),
                            statCard(
                              icon: Icons.currency_rupee,
                              title: 'Sales',
                              value:
                                  formatSales(sales),
                            ),
                          ],
                        ),
                      const SizedBox(height: 28),
                      const Text(
                        'Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      managementCard(
                        icon:
                            Icons.inventory_2_outlined,
                        title: 'Products',
                        subtitle:
                            'Add, edit and delete products',
                        onTap: openProducts,
                      ),
                      managementCard(
                        icon:
                            Icons.shopping_bag_outlined,
                        title: 'Orders',
                        subtitle:
                            'View and manage customer orders',
                        onTap: openOrders,
                      ),
                      managementCard(
                        icon: Icons.people_outline,
                        title: 'Users',
                        subtitle:
                            'Manage registered users',
                        onTap: openUsers,
                      ),
                      managementCard(
                        icon: Icons.category_outlined,
                        title: 'Categories',
                        subtitle:
                            'Manage product categories',
                        onTap: openCategories,
                      ),
                      const SizedBox(height: 13),
                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xDD111827),
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.deepOrange
                                .withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.deepOrange,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dashboard data is connected to Firebase Realtime Database.',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}