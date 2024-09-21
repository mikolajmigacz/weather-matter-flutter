import 'package:flutter/material.dart';

class CitiesPage extends StatelessWidget {
  const CitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cities')),
      body: const Center(
        child: Text('Here are all available cities.'),
      ),
    );
  }
}
