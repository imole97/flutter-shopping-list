import 'package:flutter/material.dart';
import 'package:flutter_shopping/data/dummy_items.dart';

class Grocerylist extends StatelessWidget {
  const Grocerylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Grocery list'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigate to the AddItemScreen
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: groceryItems
              .length, //makes flutter know how often it has to call the builder method
          itemBuilder: (ctx, index) => ListTile(
            title: Text(groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: groceryItems[index].category.color,
            ),
            trailing: Text(groceryItems[index].quantity.toString()),
          ),
        ));
  }
}
