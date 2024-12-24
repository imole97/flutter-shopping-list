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
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadedItems = _loadGroceryItems();
  }

  Future<List<GroceryItem>> _loadGroceryItems() async {
    final url = Uri.https(
        'flutter-http-prep-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if (response.body == 'null') {
      return [];
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
     
    }
    return loadedItems;
  
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
      // body: _buildContent(),
      body: FutureBuilder(
          future: _loadedItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No items added yet'),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(snapshot.data![index].id),
                onDismissed: (direction) {
                  _removeItem(snapshot.data![index]);
                },
                child: ListTile(
                  title: Text(snapshot.data![index].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: snapshot.data![index].category.color,
                  ),
                  trailing: Text(snapshot.data![index].quantity.toString()),
                ),
              ),
            );
          }),
    );
  }
}
