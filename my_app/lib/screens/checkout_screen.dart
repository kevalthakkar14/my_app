import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../cart_data.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String name = 'Keval';
  String phone = '9876543210';
  String address = '123, Main Road';
  String city = 'Rajkot';
  String state = 'Gujarat';
  String pincode = '360001';

  bool isPlacingOrder = false;

  String money(int value) {
    return '₹${value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  Future<void> _placeOrder() async {
    if (CartData.items.value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your cart is empty'),
        ),
      );
      return;
    }

    if (name.trim().isEmpty ||
        phone.trim().isEmpty ||
        address.trim().isEmpty ||
        city.trim().isEmpty ||
        state.trim().isEmpty ||
        pincode.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all address details'),
        ),
      );
      return;
    }

    setState(() {
      isPlacingOrder = true;
    });

    try {
      final DatabaseReference orderRef =
          FirebaseDatabase.instance.ref('orders').push();

      final User? user = FirebaseAuth.instance.currentUser;

      final List<Map<String, dynamic>> orderItems =
          CartData.items.value.map((item) {
        return {
          'name': item['name']?.toString() ?? 'Product',
          'price': CartData.toInt(item['price']),
          'quantity': CartData.toInt(item['quantity'], 1),
          'image': item['image']?.toString() ?? '',
          'category': item['category']?.toString() ?? '',
        };
      }).toList();

      final String fullAddress =
          '$address, $city, $state - $pincode';

      final Map<String, dynamic> orderData = {
        'orderId': orderRef.key,
        'customerName': name,
        'name': name,
        'email': user?.email ?? 'Not provided',
        'phone': phone,
        'address': fullAddress,
        'city': city,
        'state': state,
        'pincode': pincode,
        'items': orderItems,
        'subtotal': CartData.subtotal,
        'discount': CartData.discount,
        'deliveryCharges': CartData.deliveryCharges,
        'total': CartData.total,
        'amount': CartData.total,
        'status': 'PENDING',
        'paymentMethod': 'Cash on Delivery',
        'paymentStatus': 'Pending',
        'date': DateTime.now().toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      await orderRef.set(orderData);

      final String orderId = orderRef.key ?? 'AZ${DateTime.now().millisecondsSinceEpoch}';

      CartData.clearCart();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderId: orderId,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order failed: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPlacingOrder = false;
        });
      }
    }
  }

  void _changeAddress() {
    final nameController = TextEditingController(text: name);
    final phoneController = TextEditingController(text: phone);
    final addressController = TextEditingController(text: address);
    final cityController = TextEditingController(text: city);
    final stateController = TextEditingController(text: state);
    final pincodeController = TextEditingController(text: pincode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF101A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Change Address',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _field(
                  nameController,
                  'Full Name',
                  Icons.person_outline,
                ),
                const SizedBox(height: 10),
                _field(
                  phoneController,
                  'Phone Number',
                  Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                _field(
                  addressController,
                  'Address',
                  Icons.location_on_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _field(
                        cityController,
                        'City',
                        Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _field(
                        stateController,
                        'State',
                        Icons.map_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _field(
                  pincodeController,
                  'Pincode',
                  Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameController.text.trim().isEmpty ||
                          phoneController.text.trim().isEmpty ||
                          addressController.text.trim().isEmpty ||
                          cityController.text.trim().isEmpty ||
                          stateController.text.trim().isEmpty ||
                          pincodeController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please fill all address details',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        name = nameController.text.trim();
                        phone = phoneController.text.trim();
                        address = addressController.text.trim();
                        city = cityController.text.trim();
                        state = stateController.text.trim();
                        pincode = pincodeController.text.trim();
                      });

                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Address updated successfully',
                          ),
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
                    child: const Text(
                      'Save Address',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.white60,
          fontSize: 11,
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFFFF7200),
          size: 19,
        ),
        filled: true,
        fillColor: const Color(0xFF182238),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.white12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFFFF7200),
          ),
        ),
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
          'Checkout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: CartData.items,
        builder: (context, items, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _addressCard(),
                const SizedBox(height: 18),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _orderItems(items),
                const SizedBox(height: 15),
                _priceSummary(),
                const SizedBox(height: 18),
                _placeOrderButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _addressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFF2A2020),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFFF7200),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: _changeAddress,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: Color(0xFFFF7200),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$city, $state - $pincode',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Phone: $phone',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderItems(List<Map<String, dynamic>> items) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF101A2E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No items in cart',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (final item in items) _orderItem(item),
        ],
      ),
    );
  }

  Widget _orderItem(Map<String, dynamic> item) {
    final int price = CartData.toInt(item['price']);
    final int quantity = CartData.toInt(item['quantity'], 1);

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF182238),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              item['image']?.toString() ?? '',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  color: Colors.white38,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? 'Product',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Qty: $quantity',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Text(
            money(price * quantity),
            style: const TextStyle(
              color: Color(0xFFFF7200),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceSummary() {
    final int subtotal = CartData.subtotal;
    final int discount = CartData.discount;
    final int delivery = CartData.deliveryCharges;
    final int total = CartData.total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF101A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', money(subtotal)),
          const SizedBox(height: 10),
          _summaryRow(
            'Discount',
            '-${money(discount)}',
            orange: true,
          ),
          const SizedBox(height: 10),
          _summaryRow(
            'Delivery Charges',
            delivery == 0 ? 'FREE' : money(delivery),
            orange: delivery != 0,
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                money(total),
                style: const TextStyle(
                  color: Color(0xFFFF7200),
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
            color: orange ? const Color(0xFFFF7200) : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _placeOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isPlacingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF7200),
          disabledBackgroundColor: Colors.white24,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isPlacingOrder
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Place Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 17,
                  ),
                ],
              ),
      ),
    );
  }
}