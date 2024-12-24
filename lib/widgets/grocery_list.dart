import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shopping/data/categories.dart';
import 'package:flutter_shopping/models/category.dart';
import 'package:flutter_shopping/models/grocery_item.dart';
import 'package:flutter_shopping/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class Grocerylist extends StatefulWidget {
  const Grocerylist({super.key});

  @override
  State<Grocerylist> createState() => _GrocerylistState();
}

class _GrocerylistState extends State<Grocerylist> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadGroceryItems();
  }

  void _loadGroceryItems() async {
    final url = Uri.https(
        'flutter-http-prep-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          category: category,
          quantity: item.value['quantity'],
        ));
        setState(() {
          _groceryItems = loadedItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred.';
        _isLoading = false;
      });
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return Center(
        child: Text(_error!),
      );
    }
    if (_groceryItems.isEmpty) {
      return const Center(
        child: Text('No items added yet'),
      );
    }
    if (_groceryItems.isNotEmpty) {
      return ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('flutter-http-prep-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    try {
      await http.delete(url);
    } catch (e) {
      setState(() {
        _error = 'An error occurred.';
        _groceryItems.insert(index, item);
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery list'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addItem,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}
