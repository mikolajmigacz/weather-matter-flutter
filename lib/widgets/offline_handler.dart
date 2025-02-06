import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class OfflineHandler extends StatelessWidget {
  final Widget child;

  const OfflineHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Connectivity()
          .onConnectivityChanged
          .map((result) => result != ConnectivityResult.none),
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (!isOnline) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'You are offline',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Please check your internet connection',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return child;
      },
    );
  }
}
