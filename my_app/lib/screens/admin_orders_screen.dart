import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final DatabaseReference ordersRef =
      FirebaseDatabase.instance.ref('orders');

  final List<String> statuses = [
    'PENDING',
    'CONFIRMED',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED',
  ];

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await ordersRef.child(orderId).update({
        'status': status,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteOrder(String orderId) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Delete Order',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this order?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ordersRef.child(orderId).remove();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getStatus(Map<dynamic, dynamic> order) {
    String status = order['status']?.toString() ?? 'PENDING';

    if (!statuses.contains(status)) {
      return 'PENDING';
    }

    return status;
  }

  Color statusColor(String status) {
    if (status == 'DELIVERED') {
      return Colors.green;
    }

    if (status == 'CANCELLED') {
      return Colors.red;
    }

    if (status == 'SHIPPED') {
      return Colors.blue;
    }

    if (status == 'CONFIRMED') {
      return Colors.orange;
    }

    return Colors.amber;
  }

  Widget buildOrderCard(
    String orderId,
    Map<dynamic, dynamic> order,
  ) {
    String customerName =
        order['customerName']?.toString() ??
        order['name']?.toString() ??
        'Customer';

    String email =
        order['email']?.toString() ?? 'No email';

    String phone =
        order['phone']?.toString() ?? 'No phone';

    String address =
        order['address']?.toString() ?? 'No address';

    String total =
        order['total']?.toString() ??
        order['amount']?.toString() ??
        '0';

    String date =
        order['date']?.toString() ??
        order['createdAt']?.toString() ??
        'Unknown date';

    String status = getStatus(order);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Expanded(
                child: Text(
                  'ORDER #$orderId',
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  deleteOrder(orderId);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            customerName,
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
                Icons.email_outlined,
                color: Colors.white54,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                color: Colors.white54,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                phone,
                style: const TextStyle(
                  color: Colors.white60,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white54,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white60,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹$total',
                style: const TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ),
            decoration: BoxDecoration(
              color: statusColor(status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor(status).withValues(alpha: 0.35),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: status,
                isExpanded: true,
                dropdownColor: const Color(0xFF111827),
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: statusColor(status),
                ),
                style: TextStyle(
                  color: statusColor(status),
                  fontWeight: FontWeight.bold,
                ),
                items: statuses.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    updateStatus(orderId, value);
                  }
                },
              ),
            ),
          ),
        ],
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
          'Manage Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600,
          ),
          child: StreamBuilder<DatabaseEvent>(
            stream: ordersRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.deepOrange,
                  ),
                );
              }

              final value =
                  snapshot.data?.snapshot.value;

              if (value == null) {
                return const Center(
                  child: Text(
                    'No orders yet',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 17,
                    ),
                  ),
                );
              }

              if (value is! Map) {
                return const Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  ),
                );
              }

              final data =
                  Map<dynamic, dynamic>.from(value);

              final entries =
                  data.entries.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  final String orderId =
                      entry.key.toString();

                  final Map<dynamic, dynamic> order =
                      Map<dynamic, dynamic>.from(
                    entry.value,
                  );

                  return buildOrderCard(
                    orderId,
                    order,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}