import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");
  fetchAndStoreFlags();

  runApp(
    ChangeNotifierProvider(
      create: (context) => GlobalStore(),
      child: const MyApp(),
    ),
  );
}

Future<void> fetchAndStoreFlags() async {
  try {
    final response = await http.get(
      Uri.parse('https://countriesnow.space/api/v0.1/countries/flag/images'),
    );

    if (response.statusCode == 200) {
      final List countries = json.decode(response.body)['data'];

      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (var country in countries) {
        DocumentReference countryDoc = FirebaseFirestore.instance
            .collection(FirestoreCollections.flags.collectionName)
            .doc(country['iso2']);

        batch.set(countryDoc, {
          FirestoreCollections.flags.name: country['name'],
          FirestoreCollections.flags.flagUrl: country['flag'],
          FirestoreCollections.flags.iso2: country['iso2'],
          FirestoreCollections.flags.iso3: country['iso3'],
        });
      }

      await batch.commit();
    } else {
      throw Exception('Failed to load country flags');
    }
  } catch (e) {}
}

class AuthMiddleware extends StatelessWidget {
  final Widget child;

  const AuthMiddleware({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<GlobalStore>(
      builder: (context, store, _) {
        if (store.userId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return child;
      },
    );
  }
}

// Modified MyApp class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather Matter',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const AuthWrapper(),
        AppRoutes.favoriteCities: (context) => const AuthMiddleware(
              child: FavoritePlacesPage(),
            ),
        AppRoutes.cities: (context) => const AuthMiddleware(
              child: CitiesPage(),
            ),
        AppRoutes.map: (context) => const AuthMiddleware(
              child: MapPage(),
            ),
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
          }

          // Check if user data is in GlobalStore
          return Consumer<GlobalStore>(
            builder: (context, store, _) {
              if (store.userId.isEmpty) {
                // Fetch user data from Firestore
                FirebaseFirestore.instance
                    .collection(FirestoreCollections.users.collectionName)
                    .doc(user.uid)
                    .get()
                    .then((userDoc) {
                  if (userDoc.exists) {
                    store.setUserData(
                      userId: user.uid,
                      login: userDoc[FirestoreCollections.users.login],
                      name: userDoc[FirestoreCollections.users.name],
                      favoriteCity:
                          userDoc[FirestoreCollections.users.favoriteCity],
                    );
                  }
                });

                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              return const HomePage();
            },
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
