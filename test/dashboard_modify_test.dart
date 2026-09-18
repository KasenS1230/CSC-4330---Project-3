
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project3/models/grocery_group.dart';
import 'package:project3/models/roommate.dart';
import 'package:project3/models/grocery_category.dart';
import 'package:project3/screens/dashboard_screen.dart';

void main() {
  GroceryGroup buildGroup() {
    return GroceryGroup(
      id: 'g1',
      name: 'Maple Street Apartment',
      period: Period.weekly,
      // added — now a required field
      roommates: [Roommate(id: 'r1', name: 'Alex')],
      categories: [GroceryCategory(id: 'c1', name: 'Produce')],
    );
  }
}