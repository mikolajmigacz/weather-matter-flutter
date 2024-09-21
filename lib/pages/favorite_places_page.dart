import 'package:flutter/material.dart';

class FavoritePlacesPage extends StatelessWidget {
  const FavoritePlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Cities')),
      body: const Center(
        child: Text('Here are your favorite places.'),
      ),
    );
  }
}
