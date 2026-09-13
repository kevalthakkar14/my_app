import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> orders = [
    {
      'date': '12 MAY 2024, 10:30 AM',
      'id': '#AZ1234567890',
      'status': 'In Transit',
      'price': '₹8,997',
      'items': '3 items',
      'image': 'assets/images/seat_cover.jpg',
    },
    {
      'date': '05 MAY 2024, 09:15 AM',
      'id': '#AZ1234567889',
      'status': 'Delivered',
      'price': '₹3,499',
      'items': '1 item',
      'image': 'assets/images/steering_wheel.jpg',
    },
    {
      'date': '28 APR 2024, 08:45 PM',
      'id': '#AZ1234567888',
      'status': 'Delivered',
      'price': '₹2,999',
      'items': '2 items',
      'image': 'assets/images/car_wheel.jfif',
    },
    {
      'date': '20 APR 2024, 06:20 PM',
      'id': '#AZ1234567887',
      'status': 'Cancelled',
      'price': '₹1,299',
      'items': '1 item',
      'image': 'assets/images/car_airpurifier.webp',
    },
  ];

  List<Map<String, dynamic>> get filteredOrders {
    if (selectedTab == 0) {
      return orders;
    }

    if (selectedTab == 1) {
      return orders
          .where((order) => order['status'] == 'In Transit')
          .toList();
    }

    return orders
        .where((order) => order['status'] == 'Delivered')
        .toList();
  }

  Color statusColor(String status) {
    if (status == 'In Transit') {
      return const Color(0xFFFF7200);
    }

    if (status == 'Delivered') {
      return const Color(0xFF00C853);
    }

    return const Color(0xFFE53935);
  }

  void openOrder(Map<String, dynamic> order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order['id']} selected'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search Orders'),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white70,
              size: 21,
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white70,
              size: 21,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF171F32),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _tabButton('All', 0),
                  _tabButton('Active', 1),
                  _tabButton('Done', 2),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'No orders found',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      23,
                      5,
                      23,
                      20,
                    ),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      return _orderCard(
                        filteredOrders[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    final bool selected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF7200)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _orderCard(Map<String, dynamic> order) {
    final String status = order['status'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order['date'],
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor(status),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            order['id'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 1.5,
            color: Colors.white70,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white70,
                  ),
                ),
                child: Image.asset(
                  order['image'],
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.white38,
                    );
                  },
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order['price'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order['items'],
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  openOrder(order);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3A241E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFF7200),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}