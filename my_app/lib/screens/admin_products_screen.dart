import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final DatabaseReference productsRef =
      FirebaseDatabase.instance.ref('products');

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  String selectedCategory = 'SEAT COVERS';
  String selectedImage = 'assets/images/seat_cover.jpg';
  String? editingId;

  final List<String> categories = [
    'SEAT COVERS',
    'FLOOR MATS',
    'LED LIGHTS',
    'WHEELS',
    'ENGINE OIL',
    'INTERIORS',
    'EXTERIORS',
  ];

  final List<String> imagePaths = [
    'assets/images/seat_cover.jpg',
    'assets/images/seat_cover2.jfif',
    'assets/images/seat_cover3.jfif',
    'assets/images/floor_mate.jfif',
    'assets/images/floor_mate2.jfif',
    'assets/images/led_headlight.jfif',
    'assets/images/led_headlight2.jfif',
    'assets/images/car_wheel.jfif',
    'assets/images/car_wheel2.jfif',
    'assets/images/car_airpurifier.webp',
    'assets/images/cleanning_kit.webp',
    'assets/images/steering_wheel.jpg',
    'assets/images/car_image.jfif',
  ];

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    ratingController.dispose();
    stockController.dispose();
    super.dispose();
  }

  void clearFields() {
    nameController.clear();
    priceController.clear();
    ratingController.clear();
    stockController.clear();

    setState(() {
      selectedCategory = 'SEAT COVERS';
      selectedImage = imagePaths[0];
      editingId = null;
    });
  }

  String stockStatus(int stock) {
    if (stock == 0) {
      return 'OUT OF STOCK';
    }

    if (stock < 10) {
      return 'LOW STOCK';
    }

    return 'IN STOCK';
  }

  Color stockColor(int stock) {
    if (stock == 0) {
      return Colors.red;
    }

    if (stock < 10) {
      return Colors.orange;
    }

    return Colors.green;
  }

  Future<bool> saveProduct() async {
    String name = nameController.text.trim();
    String price = priceController.text.trim();
    String rating = ratingController.text.trim();
    String stock = stockController.text.trim();

    if (name.isEmpty ||
        price.isEmpty ||
        rating.isEmpty ||
        stock.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    int? priceValue = int.tryParse(price);
    double? ratingValue = double.tryParse(rating);
    int? stockValue = int.tryParse(stock);

    if (priceValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (ratingValue == null ||
        ratingValue < 0 ||
        ratingValue > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rating must be between 0 and 5'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (stockValue == null || stockValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock must be 0 or more'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    final Map<String, dynamic> product = {
      'name': name,
      'price': priceValue,
      'rating': ratingValue,
      'stock': stockValue,
      'image': selectedImage,
      'category': selectedCategory,
    };

    try {
      if (editingId == null) {
        await productsRef.push().set(product);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await productsRef.child(editingId!).update(product);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  void editProduct(
    String id,
    Map<dynamic, dynamic> product,
  ) {
    nameController.text =
        product['name']?.toString() ?? '';

    priceController.text =
        product['price']?.toString() ?? '';

    ratingController.text =
        product['rating']?.toString() ?? '';

    stockController.text =
        product['stock']?.toString() ?? '20';

    String image =
        product['image']?.toString() ?? imagePaths[0];

    String category =
        product['category']?.toString() ?? 'SEAT COVERS';

    setState(() {
      editingId = id;

      if (imagePaths.contains(image)) {
        selectedImage = image;
      } else {
        selectedImage = imagePaths[0];
      }

      if (categories.contains(category)) {
        selectedCategory = category;
      } else {
        selectedCategory = 'SEAT COVERS';
      }
    });

    showProductForm();
  }

  Future<void> deleteProduct(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Delete Product',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this product?',
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

    if (confirm != true) {
      return;
    }

    try {
      await productsRef.child(id).remove();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product deleted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showProductForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111827),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          editingId == null
                              ? 'Add Product'
                              : 'Edit Product',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(bottomSheetContext);
                            clearFields();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    buildTextField(
                      controller: nameController,
                      label: 'Product Name',
                      icon: Icons.shopping_bag_outlined,
                    ),

                    const SizedBox(height: 14),

                    buildTextField(
                      controller: priceController,
                      label: 'Price',
                      icon: Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    buildTextField(
                      controller: ratingController,
                      label: 'Rating (0 - 5)',
                      icon: Icons.star_outline,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),

                    const SizedBox(height: 14),

                    buildTextField(
                      controller: stockController,
                      label: 'Stock Quantity',
                      icon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Stock Status',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080D19),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: ValueListenableBuilder(
                        valueListenable: stockController,
                        builder: (context, value, child) {
                          int stock =
                              int.tryParse(
                                    stockController.text,
                                  ) ??
                                  0;

                          return Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: stockColor(stock),
                                size: 12,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                stockStatus(stock),
                                style: TextStyle(
                                  color: stockColor(stock),
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '$stock items',
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Select Image',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080D19),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF111827),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Image.asset(
                              selectedImage,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return const Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .image_not_supported,
                                      color: Colors.red,
                                      size: 45,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Image not found',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 10),

                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedImage,
                              isExpanded: true,
                              dropdownColor:
                                  const Color(0xFF111827),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.deepOrange,
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              items: imagePaths.map((image) {
                                String fileName =
                                    image.split('/').last;

                                return DropdownMenuItem<String>(
                                  value: image,
                                  child: Text(
                                    fileName,
                                    overflow:
                                        TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setSheetState(() {
                                    selectedImage = value;
                                  });

                                  setState(() {
                                    selectedImage = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Category',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF080D19),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          dropdownColor:
                              const Color(0xFF111827),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.deepOrange,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setSheetState(() {
                                selectedCategory = value;
                              });

                              setState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          bool success =
                              await saveProduct();

                          if (success &&
                              bottomSheetContext.mounted) {
                            Navigator.pop(
                              bottomSheetContext,
                            );
                            clearFields();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.deepOrange,
                          foregroundColor: Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          editingId == null
                              ? 'ADD PRODUCT'
                              : 'UPDATE PRODUCT',
                          style: const TextStyle(
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
      },
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            const TextStyle(color: Colors.white60),
        prefixIcon: Icon(
          icon,
          color: Colors.deepOrange,
        ),
        filled: true,
        fillColor: const Color(0xFF080D19),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget productImage(String image) {
    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        width: 85,
        height: 85,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.image_not_supported,
            color: Colors.red,
            size: 35,
          );
        },
      );
    }

    if (image.startsWith('http')) {
      return Image.network(
        image,
        width: 85,
        height: 85,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.image_not_supported,
            color: Colors.red,
            size: 45,
          );
        },
      );
    }

    return const Icon(
      Icons.image_outlined,
      color: Colors.white38,
      size: 45,
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
          'Manage Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          clearFields();
          showProductForm();
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
     body: Stack(
  children: [
    Positioned.fill(
      child: Image.asset(
        'assets/images/car_pic3.jpg',
        fit: BoxFit.cover,
      ),
    ),
    Positioned.fill(
      child: Container(
        color: const Color(0xE6080D19),
      ),
    ),
    Center(
      child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 600),
          child: StreamBuilder<DatabaseEvent>(
            stream: productsRef.onValue,
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
                    'No products added yet',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              if (value is! Map) {
                return const Center(
                  child: Text(
                    'No products found',
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
                padding:
                    const EdgeInsets.all(16),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];

                  final String id =
                      entry.key.toString();

                  final Map<dynamic, dynamic> product =
                      Map<dynamic, dynamic>.from(
                    entry.value,
                  );

                  final String name =
                      product['name']?.toString() ??
                          'Product';

                  final String price =
                      product['price']?.toString() ??
                          '0';

                  final String rating =
                      product['rating']?.toString() ??
                          '0';

                  final int stock =
                      int.tryParse(
                            product['stock']
                                    ?.toString() ??
                                '20',
                          ) ??
                          20;

                  final String category =
                      product['category']?.toString() ??
                          'OTHER';

                  final String image =
                      product['image']?.toString() ??
                          '';

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    padding:
                        const EdgeInsets.all(12),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFF111827),
                      borderRadius:
                          BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                                    0xFF080D19),
                            borderRadius:
                                BorderRadius.circular(
                              14,
                            ),
                          ),
                          child: productImage(image),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                '₹$price',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.deepOrange,
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: stockColor(
                                    stock,
                                  ).withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                                child: Text(
                                  '${stockStatus(stock)} • $stock',
                                  style: TextStyle(
                                    color:
                                        stockColor(
                                      stock,
                                    ),
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                category,
                                overflow:
                                    TextOverflow.ellipsis,
                                style:
                                    const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                editProduct(
                                  id,
                                  product,
                                );
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.orange,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                deleteProduct(id);
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
  ]
     ) 
     );
  }
}