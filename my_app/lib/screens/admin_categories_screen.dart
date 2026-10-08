
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() =>
      _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState
    extends State<AdminCategoriesScreen> {
  final DatabaseReference categoriesRef =
      FirebaseDatabase.instance.ref('categories');

  bool isLoading = true;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    setState(() {
      isLoading = true;
    });

    try {
      final snapshot = await categoriesRef.get();

      List<Map<String, dynamic>> loadedCategories = [];

      if (snapshot.exists && snapshot.value is Map) {
        final Map data = snapshot.value as Map;

        for (final entry in data.entries) {
          if (entry.value is Map) {
            final Map category = entry.value as Map;

            loadedCategories.add({
              'key': entry.key.toString(),
              'name': category['name']?.toString() ?? 'Unnamed',
            });
          } else {
            loadedCategories.add({
              'key': entry.key.toString(),
              'name': entry.value.toString(),
            });
          }
        }
      }

      if (!mounted) return;

      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Unable to load categories');
    }
  }

  Future<void> addCategory() async {
    final TextEditingController controller =
        TextEditingController();

    final String? name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Add Category',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle:
                  const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF080D19),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('ADD'),
            ),
          ],
        );
      },
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      await categoriesRef.push().set({
        'name': name.trim(),
        'createdAt': ServerValue.timestamp,
      });

      if (!mounted) return;

      showMessage('Category added');
      loadCategories();
    } catch (e) {
      showMessage('Unable to add category');
    }
  }

  Future<void> editCategory(
      String key, String oldName) async {
    final TextEditingController controller =
        TextEditingController(text: oldName);

    final String? name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Edit Category',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Category name',
              hintStyle:
                  const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF080D19),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(dialogContext, value);
                }
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

    if (name == null || name.trim().isEmpty) return;

    try {
      await categoriesRef.child(key).update({
        'name': name.trim(),
      });

      if (!mounted) return;

      showMessage('Category updated');
      loadCategories();
    } catch (e) {
      showMessage('Unable to update category');
    }
  }

  Future<void> deleteCategory(String key) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111827),
          title: const Text(
            'Delete Category',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this category?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await categoriesRef.child(key).remove();

      if (!mounted) return;

      showMessage('Category deleted');
      loadCategories();
    } catch (e) {
      showMessage('Unable to delete category');
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

  Widget categoryCard(
      Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xDD111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.category_outlined,
              color: Colors.deepOrange,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              category['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              editCategory(
                category['key'],
                category['name'],
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.white70,
            ),
          ),
          IconButton(
            onPressed: () {
              deleteCategory(category['key']);
            },
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
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
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadCategories,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCategory,
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
              'assets/images/car_pic.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xE6080D19),
            ),
          ),
          RefreshIndicator(
            color: Colors.deepOrange,
            backgroundColor: const Color(0xFF111827),
            onRefresh: loadCategories,
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.deepOrange,
                    ),
                  )
                : categories.isEmpty
                    ? ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 220),
                          Icon(
                            Icons.category_outlined,
                            color: Colors.white30,
                            size: 70,
                          ),
                          SizedBox(height: 15),
                          Center(
                            child: Text(
                              'No categories',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: Text(
                              'Tap + to add a category',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return categoryCard(
                            categories[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
