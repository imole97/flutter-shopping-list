import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  dairy,
  carbs,
  fruit,
  meat,
  sweets,
  spices,
  hygiene,
  other,
  convenience,
}

class Category {
  const Category(this.title, this.color);
  
  final String title;
  final Color color;

}
