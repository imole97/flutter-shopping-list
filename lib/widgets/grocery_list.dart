import 'package:flutter/material.dart';
import 'package:flutter_shopping/models/grocery_item.dart';
import 'package:flutter_shopping/widgets/new_item.dart';

class Grocerylist extends StatefulWidget {
  const Grocerylist({super.key});

  @override
  State<Grocerylist> createState() => _GrocerylistState();
}

class _GrocerylistState extends State<Grocerylist> {
  final List<GroceryItem> _groceryItems = [];

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
        body: ListView.builder(
          itemCount: _groceryItems
              .length, //makes flutter know how often it has to call the builder method
          itemBuilder: (ctx, index) => ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        ));
  }
}
