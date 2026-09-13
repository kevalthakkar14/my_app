import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  List<String> addresses = [
    '123, Main Road, Rajkot, Gujarat - 360001',
  ];

  List<String> paymentMethods = [
    'Cash on Delivery',
  ];

  Future<void> pickPhoto(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes = await image.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        profilePhoto = bytes;
      });

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select photo'),
        ),
      );
    }
  }

  void showPhotoOptions() {
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
              children: [
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Colors.orange,
                  ),
                  title: const Text(
                    'Take Photo',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Colors.orange,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.deepOrange,
      ),
    );
  }

  InputDecoration fieldDecoration(
    String label,
    IconData icon,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.white60,
      ),
      prefixIcon: Icon(
        icon,
        color: Colors.orange,
      ),
      filled: true,
      fillColor: const Color(0xFF080D19),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget profileImage() {
    if (profilePhoto != null) {
      return ClipOval(
        child: Image.memory(
          profilePhoto!,
          width: 76,
          height: 76,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipOval(
      child: Image.asset(
        'assets/images/car_logo.jfif',
        width: 76,
        height: 76,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white24,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: Colors.orange,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 18,
        bottom: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void editProfile() {
    final nameController = TextEditingController(
      text: userName,
    );

    final emailController = TextEditingController(
      text: userEmail,
    );

    final phoneController = TextEditingController(
      text: phone,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: fieldDecoration(
                    'Name',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: fieldDecoration(
                    'Email',
                    Icons.email_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: fieldDecoration(
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
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                setState(() {
                  userName = nameController.text.trim();
                  userEmail = emailController.text.trim();
                  phone = phoneController.text.trim();
                });

                Navigator.of(dialogContext).pop();

                showMessage(
                  'Profile updated successfully',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  void profileInformation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Profile Information',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Name: $userName',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Email: $userEmail',
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Phone: $phone',
                style: const TextStyle(
                  color: Colors.white70,
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
                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> changePassword() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Change Password',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: fieldDecoration(
                    'Current Password',
                    Icons.lock_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newController,
                  obscureText: true,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: fieldDecoration(
                    'New Password',
                    Icons.lock_reset,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: fieldDecoration(
                    'Confirm Password',
                    Icons.lock_reset,
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
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final current =
                    currentController.text.trim();

                final newPassword =
                    newController.text.trim();

                final confirm =
                    confirmController.text.trim();

                if (current.isEmpty ||
                    newPassword.isEmpty ||
                    confirm.isEmpty) {
                  showMessage(
                    'Please fill all fields',
                  );
                  return;
                }

                if (newPassword != confirm) {
                  showMessage(
                    'Passwords do not match',
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  showMessage(
                    'Password must be at least 6 characters',
                  );
                  return;
                }

                try {
                  final user =
                      FirebaseAuth.instance.currentUser;

                  if (user == null ||
                      user.email == null) {
                    showMessage(
                      'Please login again',
                    );
                    return;
                  }

                  final credential =
                      EmailAuthProvider.credential(
                    email: user.email!,
                    password: current,
                  );

                  await user.reauthenticateWithCredential(
                    credential,
                  );

                  await user.updatePassword(
                    newPassword,
                  );

                  if (!mounted) {
                    return;
                  }

                  Navigator.of(dialogContext).pop();

                  showMessage(
                    'Password changed successfully',
                  );
                } on FirebaseAuthException catch (e) {
                  if (!mounted) {
                    return;
                  }

                  if (e.code == 'wrong-password' ||
                      e.code == 'invalid-credential') {
                    showMessage(
                      'Current password is incorrect',
                    );
                  } else {
                    showMessage(
                      e.message ??
                          'Unable to change password',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              child: const Text('CHANGE'),
            ),
          ],
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  void addressesPage() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'My Addresses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...List.generate(
                      addresses.length,
                      (index) {
                        return Container(
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white24,
                            ),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.orange,
                            ),
                            title: Text(
                              addresses[index],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                setSheetState(() {
                                  addresses.removeAt(index);
                                });

                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          addAddress(setSheetState);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'ADD ADDRESS',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void addAddress(
    void Function(void Function()) setSheetState,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Add Address',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: TextField(
            controller: controller,
            maxLines: 3,
            style: const TextStyle(
              color: Colors.white,
            ),
            decoration: fieldDecoration(
              'Address',
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
                style: TextStyle(
                  color: Colors.white60,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  return;
                }

                setSheetState(() {
                  addresses.add(
                    controller.text.trim(),
                  );
                });

                setState(() {});

                Navigator.of(dialogContext).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
              ),
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );
  }

  void paymentMethodsPage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111827),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Payment Methods',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ...List.generate(
                      paymentMethods.length,
                      (index) {
                        return ListTile(
                          leading: const Icon(
                            Icons.payment,
                            color: Colors.orange,
                          ),
                          title: Text(
                            paymentMethods[index],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing:
                              paymentMethods[index] ==
                                      'Cash on Delivery'
                                  ? null
                                  : IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color:
                                            Colors.redAccent,
                                      ),
                                      onPressed: () {
                                        setSheetState(() {
                                          paymentMethods
                                              .removeAt(
                                            index,
                                          );
                                        });

                                        setState(() {});
                                      },
                                    ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showPaymentChoices(
                            setSheetState,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'ADD PAYMENT METHOD',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showPaymentChoices(
    void Function(void Function()) setSheetState,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Select Payment Method',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.credit_card,
                  color: Colors.orange,
                ),
                title: const Text(
                  'Credit / Debit Card',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  setSheetState(() {
                    paymentMethods.add(
                      'Credit / Debit Card',
                    );
                  });

                  setState(() {});

                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
                title: const Text(
                  'UPI',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  setSheetState(() {
                    paymentMethods.add('UPI');
                  });

                  setState(() {});

                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void couponsPage() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Coupons & Offers',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              coupon(
                'WELCOME100',
                '₹100 OFF on your order',
              ),
              coupon(
                'AUTO500',
                '₹500 OFF above ₹3000',
              ),
              coupon(
                'FREESHIP',
                'Free delivery',
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
                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget coupon(
    String code,
    String description,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            code,
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void shippingSettings() {
    String selected = shipping;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111827),
              title: const Text(
                'Shipping Settings',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  shippingChoice(
                    title: 'Standard Delivery',
                    selected: selected,
                    onTap: () {
                      setDialogState(() {
                        selected = 'Standard Delivery';
                      });
                    },
                  ),
                  shippingChoice(
                    title: 'Express Delivery',
                    selected: selected,
                    onTap: () {
                      setDialogState(() {
                        selected = 'Express Delivery';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      shipping = selected;
                    });

                    Navigator.of(dialogContext).pop();

                    showMessage(
                      'Shipping setting updated',
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('SAVE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget shippingChoice({
    required String title,
    required String selected,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selected == title;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Colors.orange
                  : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void notificationSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111827),
              title: const Text(
                'Notifications',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: SwitchListTile(
                value: notifications,
                activeThumbColor: Colors.orange,
                title: const Text(
                  'Allow Notifications',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {
                    notifications = value;
                  });

                  setState(() {
                    notifications = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void darkModeSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111827),
              title: const Text(
                'Dark Mode',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: SwitchListTile(
                value: darkMode,
                activeThumbColor: Colors.orange,
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onChanged: (value) {
                  setDialogState(() {
                    darkMode = value;
                  });

                  setState(() {
                    darkMode = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text(
                    'DONE',
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void languageSettings() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF111827),
              title: const Text(
                'Language',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  languageChoice(
                    value: 'English',
                    selected: language,
                    onTap: () {
                      setDialogState(() {
                        language = 'English';
                      });

                      setState(() {
                        language = 'English';
                      });

                      Navigator.of(dialogContext).pop();

                      showMessage(
                        'Language changed to English',
                      );
                    },
                  ),
                  languageChoice(
                    value: 'Hindi',
                    selected: language,
                    onTap: () {
                      setDialogState(() {
                        language = 'Hindi';
                      });

                      setState(() {
                        language = 'Hindi';
                      });

                      Navigator.of(dialogContext).pop();

                      showMessage(
                        'Language changed to Hindi',
                      );
                    },
                  ),
                  languageChoice(
                    value: 'Gujarati',
                    selected: language,
                    onTap: () {
                      setDialogState(() {
                        language = 'Gujarati';
                      });

                      setState(() {
                        language = 'Gujarati';
                      });

                      Navigator.of(dialogContext).pop();

                      showMessage(
                        'Language changed to Gujarati',
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget languageChoice({
    required String value,
    required String selected,
    required VoidCallback onTap,
  }) {
    final bool isSelected = value == selected;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Colors.orange
                  : Colors.white54,
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void informationPage(
    String title,
    String text,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            text,
            style: const TextStyle(
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
                style: TextStyle(
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF071426),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071426),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          30,
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: profileImage(),
                ),
                GestureDetector(
                  onTap: showPhotoOptions,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.black,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              userEmail,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: editProfile,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Colors.orange,
                ),
                foregroundColor: Colors.orange,
              ),
              child: const Text('Edit Profile'),
            ),

            sectionTitle('ACCOUNT'),

            profileOption(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              subtitle: 'View your orders',
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
              title: 'Profile Information',
              subtitle:
                  'Manage your personal information',
              onTap: profileInformation,
            ),

            profileOption(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle:
                  'Change your Firebase password',
              onTap: changePassword,
            ),

            profileOption(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
              subtitle:
                  '${addresses.length} saved address',
              onTap: addressesPage,
            ),

            profileOption(
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              subtitle:
                  '${paymentMethods.length} payment method',
              onTap: paymentMethodsPage,
            ),

            sectionTitle('STORE MANAGEMENT'),

            profileOption(
              icon: Icons.local_offer_outlined,
              title: 'Coupons & Offers',
              subtitle: '3 active coupons',
              onTap: couponsPage,
            ),

            profileOption(
              icon: Icons.local_shipping_outlined,
              title: 'Shipping Settings',
              subtitle: shipping,
              onTap: shippingSettings,
            ),

            sectionTitle('APP SETTINGS'),

            profileOption(
              icon: Icons.notifications_none,
              title: 'Notifications',
              subtitle:
                  notifications ? 'Enabled' : 'Disabled',
              onTap: notificationSettings,
            ),

            profileOption(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle:
                  darkMode ? 'Enabled' : 'Disabled',
              onTap: darkModeSettings,
            ),

            profileOption(
              icon: Icons.language,
              title: 'Language',
              subtitle: language,
              onTap: languageSettings,
            ),

            profileOption(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                informationPage(
                  'Privacy Policy',
                  'Your personal information is used only to provide and improve the AutoZone Premium shopping experience. We do not share your information without permission.',
                );
              },
            ),

            profileOption(
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              onTap: () {
                informationPage(
                  'Terms & Conditions',
                  'By using AutoZone Premium, you agree to our terms of service, product information, payment rules, delivery conditions and other applicable policies.',
                );
              },
            ),

            profileOption(
              icon: Icons.info_outline,
              title: 'About Us',
              onTap: () {
                informationPage(
                  'About AutoZone Premium',
                  'AutoZone Premium is a car accessories shopping application where users can browse car accessories, add products to cart and place orders.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}