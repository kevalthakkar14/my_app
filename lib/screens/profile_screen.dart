import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'orders_screen.dart';
import 'cart_screen.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool showBottomNavigation;
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onBack;

  const ProfileScreen({
    super.key,
    this.showBottomNavigation = true,
    this.onNavigate,
    this.onBack,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? profilePhoto;

  final ImagePicker picker = ImagePicker();

  String userName = 'Keval Thakkar';
  String userEmail = 'keval@gmail.com';
  String phone = '9876543210';

  bool notifications = true;
  bool darkMode = true;

  String language = 'English';
  String shipping = 'Standard Delivery';

  List<Map<String, String>> addresses = [
    {
      'title': 'Home',
      'address': '123, Main Road, Rajkot, Gujarat - 360001',
    },
  ];

  List<Map<String, String>> paymentMethods = [
    {
      'title': 'Cash on Delivery',
      'subtitle': 'Pay when your order arrives',
    },
  ];

  Future<void> pickProfilePhoto() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      profilePhoto = bytes;
    });
  }

  void editProfile() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);
    final phoneController = TextEditingController(text: phone);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    'Name',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: inputDecoration(
                    'Phone',
                    Icons.phone_outlined,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userName = nameController.text.trim();
                  userEmail = emailController.text.trim();
                  phone = phoneController.text.trim();
                });

                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(
        icon,
        color: Colors.white60,
      ),
      filled: true,
      fillColor: const Color(0xFF080D19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  void changePassword() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Change Password',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration(
              'New Password',
              Icons.lock_outline,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text.trim();

                if (password.length < 6) {
                  showMessage(
                    'Password must contain at least 6 characters',
                  );
                  return;
                }

                try {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    showMessage('Please login again');
                    return;
                  }

                  await user.updatePassword(password);

                  if (!mounted) {
                    return;
                  }

                  Navigator.of(dialogContext).pop();

                  showMessage('Password changed successfully');
                } on FirebaseAuthException catch (e) {
                  Navigator.of(dialogContext).pop();

                  if (e.code == 'requires-recent-login') {
                    showMessage(
                      'Please login again before changing password',
                    );
                  } else {
                    showMessage('Unable to change password');
                  }
                } catch (e) {
                  Navigator.of(dialogContext).pop();
                  showMessage('Something went wrong');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('CHANGE'),
            ),
          ],
        );
      },
    );
  }

  void manageAddresses() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Addresses',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...addresses.map(
                  (address) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080D19),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                address['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                address['address'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      addAddress();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('ADD ADDRESS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
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

  void addAddress() {
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Add Address',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: addressController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: inputDecoration(
              'Enter address',
              Icons.location_on_outlined,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final address = addressController.text.trim();

                if (address.isEmpty) {
                  return;
                }

                setState(() {
                  addresses.add({
                    'title': 'New Address',
                    'address': address,
                  });
                });

                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  void managePaymentMethods() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Methods',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...paymentMethods.map(
                  (payment) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF080D19),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                payment['title'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                payment['subtitle'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      showMessage(
                        'Cash on Delivery is currently available',
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('ADD PAYMENT METHOD'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
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

  void showCoupons() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Coupons',
            style: TextStyle(color: Colors.white),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.local_offer_outlined,
                  color: Colors.deepOrange,
                ),
                title: Text(
                  'WELCOME1000',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '₹1000 off on orders above ₹5000',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );
  }

  void changeShipping() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Shipping Method',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              RadioListTile<String>(
                value: 'Standard Delivery',
                groupValue: shipping,
                activeColor: Colors.deepOrange,
                title: const Text(
                  'Standard Delivery',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Within 5-7 days',
                  style: TextStyle(color: Colors.white60),
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    shipping = value;
                  });

                  Navigator.of(sheetContext).pop();
                },
              ),
              RadioListTile<String>(
                value: 'Express Delivery',
                groupValue: shipping,
                activeColor: Colors.deepOrange,
                title: const Text(
                  'Express Delivery',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: const Text(
                  'Within 2-3 days',
                  style: TextStyle(color: Colors.white60),
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    shipping = value;
                  });

                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void changeLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Language',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              RadioListTile<String>(
                value: 'English',
                groupValue: language,
                activeColor: Colors.deepOrange,
                title: const Text(
                  'English',
                  style: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    language = value;
                  });

                  Navigator.of(sheetContext).pop();
                },
              ),
              RadioListTile<String>(
                value: 'Hindi',
                groupValue: language,
                activeColor: Colors.deepOrange,
                title: const Text(
                  'Hindi',
                  style: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    language = value;
                  });

                  Navigator.of(sheetContext).pop();
                },
              ),
              RadioListTile<String>(
                value: 'Gujarati',
                groupValue: language,
                activeColor: Colors.deepOrange,
                title: const Text(
                  'Gujarati',
                  style: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    language = value;
                  });

                  Navigator.of(sheetContext).pop();
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void showPrivacy() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Privacy Policy',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Your personal information is used only for account, '
              'order and delivery purposes. We do not share your '
              'personal information without permission.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );
  }

  void showTerms() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Terms & Conditions',
            style: TextStyle(color: Colors.white),
          ),
          content: const SingleChildScrollView(
            child: Text(
              'By using AutoZone Premium, you agree to use the '
              'application responsibly and provide accurate account '
              'and delivery information.',
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );
  }

  void showAbout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'About AutoZone Premium',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'AutoZone Premium is a car accessories shopping '
            'application for browsing products, managing cart items '
            'and placing orders.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
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

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      showMessage('Unable to logout');
    }
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.deepOrange,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
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
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 2,
        top: 18,
        bottom: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget bottomNavigation() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Color(0xFF0C1425),
        border: Border(
          top: BorderSide(color: Colors.white12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          bottomItem(Icons.home_outlined, 'Home', 0),
          bottomItem(Icons.search, 'Browse', 1),
          bottomItem(Icons.favorite_border, 'Wishlist', 2),
          bottomItem(Icons.shopping_cart_outlined, 'Cart', 3),
          bottomItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  Widget bottomItem(
    IconData icon,
    String title,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        if (widget.onNavigate != null) {
          widget.onNavigate!(index);
          return;
        }

        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CartScreen(),
            ),
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: index == 4
                  ? Colors.deepOrange
                  : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                color: index == 4
                    ? Colors.deepOrange
                    : Colors.white54,
                fontSize: 9,
                fontWeight: index == 4
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
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
        automaticallyImplyLeading: false,
        leading: widget.onBack != null
            ? IconButton(
                onPressed: widget.onBack,
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              )
            : null,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: widget.showBottomNavigation
          ? bottomNavigation()
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              30,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF111827),
                            border: Border.all(
                              color: Colors.deepOrange,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: profilePhoto != null
                                ? Image.memory(
                                    profilePhoto!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person,
                                    color: Colors.white54,
                                    size: 50,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: pickProfilePhoto,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Center(
                    child: Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: TextButton.icon(
                      onPressed: editProfile,
                      icon: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.deepOrange,
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),

                  sectionTitle('Account'),

                  profileOption(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    subtitle: 'View your order history',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const OrdersScreen(),
                        ),
                      );
                    },
                  ),

                  profileOption(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: '$userName • $phone',
                    onTap: editProfile,
                  ),

                  profileOption(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: changePassword,
                  ),

                  sectionTitle('Shopping'),

                  profileOption(
                    icon: Icons.location_on_outlined,
                    title: 'My Addresses',
                    subtitle: 'Manage delivery addresses',
                    onTap: manageAddresses,
                  ),

                  profileOption(
                    icon: Icons.payment_outlined,
                    title: 'Payment Methods',
                    subtitle: 'Manage payment options',
                    onTap: managePaymentMethods,
                  ),

                  profileOption(
                    icon: Icons.local_offer_outlined,
                    title: 'Coupons',
                    subtitle: 'View available offers',
                    onTap: showCoupons,
                  ),

                  profileOption(
                    icon: Icons.local_shipping_outlined,
                    title: 'Shipping',
                    subtitle: shipping,
                    onTap: changeShipping,
                  ),

                  sectionTitle('Settings'),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.deepOrange,
                      ),
                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Receive order and offer notifications',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      value: notifications,
                      activeColor: Colors.deepOrange,
                      onChanged: (value) {
                        setState(() {
                          notifications = value;
                        });
                      },
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(
                        Icons.dark_mode_outlined,
                        color: Colors.deepOrange,
                      ),
                      title: const Text(
                        'Dark Mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: const Text(
                        'Use dark theme',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      value: darkMode,
                      activeColor: Colors.deepOrange,
                      onChanged: (value) {
                        setState(() {
                          darkMode = value;
                        });
                      },
                    ),
                  ),

                  profileOption(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: language,
                    onTap: changeLanguage,
                  ),

                  sectionTitle('Information'),

                  profileOption(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'Read our privacy policy',
                    onTap: showPrivacy,
                  ),

                  profileOption(
                    icon: Icons.description_outlined,
                    title: 'Terms & Conditions',
                    subtitle: 'Read terms and conditions',
                    onTap: showTerms,
                  ),

                  profileOption(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'About AutoZone Premium',
                    onTap: showAbout,
                  ),

                  sectionTitle('Account'),

                  profileOption(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    iconColor: Colors.redAccent,
                    onTap: logout,
                  ),

                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'AutoZone Premium',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}