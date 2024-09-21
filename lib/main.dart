import 'package:flutter/material.dart';
import 'package:flutter_dashboard_app/constants/routes.dart';
import 'package:flutter_dashboard_app/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dashboard_app/pages/cities_page.dart';
import 'package:flutter_dashboard_app/pages/favorite_places_page.dart';
import 'package:flutter_dashboard_app/pages/home_page.dart';
import 'package:flutter_dashboard_app/pages/map_page.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:provider/provider.dart'; // Potrzebne do Providera
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalStore(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Matter',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Zdefiniowanie routingu
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const AuthWrapper(),
        AppRoutes.favoriteCities: (context) => const FavoritePlacesPage(),
        AppRoutes.cities: (context) => const CitiesPage(),
        AppRoutes.map: (context) => const MapPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const AuthScreen();
          } else {
            return const HomePage();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
