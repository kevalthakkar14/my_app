import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  String money(dynamic value) {
    int amount = 0;

    if (value is int) {
      amount = value;
    } else if (value is num) {
      amount = value.toInt();
    } else if (value is String) {
      amount = int.tryParse(value) ?? 0;
    }

    return '₹${amount.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  String formatDate(dynamic value) {
    if (value == null) return 'Date not available';

    try {
      final DateTime date = DateTime.parse(value.toString());

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return const Color(0xFF00D95F);

      case 'SHIPPED':
        return Colors.blueAccent;

      case 'CONFIRMED':
        return Colors.cyanAccent;

      case 'CANCELLED':
        return Colors.redAccent;

      case 'PENDING':
      default:
        return const Color(0xFFFF7200);
    }
  }

  IconData statusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return Icons.check_circle_outline;

      case 'SHIPPED':
        return Icons.local_shipping_outlined;

      case 'CONFIRMED':
        return Icons.verified_outlined;

      case 'CANCELLED':
        return Icons.cancel_outlined;

      case 'PENDING':
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1428),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B1428),
          elevation: 0,
          title: const Text(
            'My Orders',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Please login to view your orders',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    final DatabaseReference ordersRef =
        FirebaseDatabase.instance.ref('orders');

    return Scaffold(
      backgroundColor: const Color(0xFF0B1428),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1428),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: ordersRef.onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF7200),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load orders',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            );
          }

          final List<Map<String, dynamic>> orders = [];

          if (snapshot.hasData &&
              snapshot.data!.snapshot.value != null) {
            final dynamic data = snapshot.data!.snapshot.value;

            if (data is Map) {
              data.forEach((key, value) {
                if (value is Map) {
                  final Map<String, dynamic> order =
                      Map<String, dynamic>.from(value);

                  final String email =
                      order['email']?.toString().toLowerCase() ?? '';

                  final String userId =
                      order['userId']?.toString() ?? '';

                  if (email == (user.email ?? '').toLowerCase() ||
                      userId == user.uid) {
                    order['firebaseKey'] = key.toString();
                    orders.add(order);
                  }
                }
              });
            }
          }

          orders.sort((a, b) {
            final String dateA =
                a['createdAt']?.toString() ??
                    a['date']?.toString() ??
                    '';

            final String dateB =
                b['createdAt']?.toString() ??
                    b['date']?.toString() ??
                    '';

            return dateB.compareTo(dateA);
          });

          if (orders.isEmpty) {
            return _emptyOrders(context);
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  25,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  return _orderCard(
                    context,
                    orders[index],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF101A2E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white12,
                ),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFFFF7200),
                size: 42,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your placed orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7200),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'Start Shopping',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
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

  Widget _orderCard(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final String orderId =
        order['orderId']?.toString() ??
            order['firebaseKey']?.toString() ??
            'Unknown';

    final String status =
        order['status']?.toString().toUpperCase() ??
            'PENDING';

    final int total = order['total'] ?? order['amount'] ?? 0;

    final String date =
        order['createdAt']?.toString() ??
            order['date']?.toString() ??
            '';

    final dynamic rawItems = order['items'];

    final List<Map<String, dynamic>> items = [];

    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(
            Map<String, dynamic>.from(item),
          );
        }
      }
    } else if (rawItems is Map) {
      rawItems.forEach((key, value) {
        if (value is Map) {
          items.add(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF27232A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_outlined,
                  color: const Color(0xFFFF7200),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ORDER ID',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      orderId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(status),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            color: Colors.white12,
            height: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoItem(
                  Icons.calendar_today_outlined,
                  'DATE',
                  formatDate(date),
                ),
              ),
              Expanded(
                child: _infoItem(
                  Icons.currency_rupee,
                  'TOTAL',
                  money(total),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isNotEmpty) ...[
            const Text(
              'PRODUCTS',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final item in items)
              _productRow(item),
          ],
          const SizedBox(height: 12),
          _addressSection(order),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final Color color = statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon(status),
            color: color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(
    IconData icon,
    String title,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white54,
          size: 15,
        ),
        const SizedBox(width: 7),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 7,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _productRow(Map<String, dynamic> item) {
    final String name =
        item['name']?.toString() ?? 'Product';

    final int price = _toInt(item['price']);

    final int quantity =
        _toInt(item['quantity'], 1);

    final String image =
        item['image']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFF182238),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF101A2E),
              borderRadius: BorderRadius.circular(7),
            ),
            child: image.startsWith('http')
                ? Image.network(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white38,
                        size: 22,
                      );
                    },
                  )
                : Image.asset(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white38,
                        size: 22,
                      );
                    },
                  ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $quantity',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          Text(
            money(price * quantity),
            style: const TextStyle(
              color: Color(0xFFFF7200),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressSection(
    Map<String, dynamic> order,
  ) {
    final String address =
        order['address']?.toString() ?? '';

    final String phone =
        order['phone']?.toString() ?? '';

    if (address.isEmpty && phone.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF182238),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFFFF7200),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'DELIVERY ADDRESS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (address.isNotEmpty)
                  Text(
                    address,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      height: 1.3,
                    ),
                  ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Phone: $phone',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _toInt(
    dynamic value, [
    int defaultValue = 0,
  ]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
}