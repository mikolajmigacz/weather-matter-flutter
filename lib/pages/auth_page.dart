import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_dashboard_app/constants/routes.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:provider/provider.dart'; // Potrzebne do Providera

/// Authentication screen that allows users to log in or register.
///
/// Handles authentication using Firebase Authentication and stores
/// additional user data in Firestore.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'test@test.pl');
  final _passwordController = TextEditingController(text: 'testowe');
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Widget _buildAuthForm() {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      width: isDesktop
          ? MediaQuery.of(context).size.width * 0.2
          : MediaQuery.of(context).size.width * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isLogin ? 'Logowanie' : 'Rejestracja',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.lightestGray,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
                _emailController, 'Email', TextInputType.emailAddress),
            const SizedBox(height: 12),
            _buildTextField(
                _passwordController, 'Hasło', TextInputType.visiblePassword,
                isPassword: true),
            if (!_isLogin) ...[
              const SizedBox(height: 12),
              _buildTextField(_confirmPasswordController, 'Potwierdź hasło',
                  TextInputType.visiblePassword,
                  isPassword: true),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Imię', TextInputType.text),
              const SizedBox(height: 12),
              _buildTextField(
                  _cityController, 'Ulubione miasto', TextInputType.text),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: AppColors.lightestGray,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: Text(_isLogin ? 'Zaloguj się' : 'Zarejestruj się'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin
                    ? 'Potrzebujesz konta? Zarejestruj się'
                    : 'Masz konto? Zaloguj się',
                style: const TextStyle(color: AppColors.teal),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'weather.png',
                width: isDesktop ? 400 : 200,
                height: isDesktop ? 400 : 200,
              ),
              Center(
                child: _buildAuthForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, TextInputType inputType,
      {bool isPassword = false}) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return SizedBox(
      width: isDesktop ? 250 : double.infinity,
      child: TextFormField(
        style: const TextStyle(color: AppColors.lightestGray),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.lightestGray),
          filled: true,
          fillColor: AppColors.darkestGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(
            fontSize: 14,
            color: Colors.redAccent,
          ),
        ),
        keyboardType: inputType,
        obscureText: isPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'To pole jest wymagane';
          }
          if (inputType == TextInputType.emailAddress &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Podaj prawidłowy e-mail';
          }
          if (isPassword && value.length < 6) {
            return 'Hasło musi mieć przynajmniej 6 znaków';
          }
          if (label == 'Potwierdź hasło' && value != _passwordController.text) {
            return 'Hasła różnią się';
          }
          if (label == 'Imię' && value.length < 2) {
            return 'Imię musi zawierać przynajmniej 2 znaki';
          }
          if (label == 'Ulubione miasto' && value.length < 2) {
            return 'Podane miasto musi zawierać przynajmniej 2 znaki';
          }
          return null;
        },
      ),
    );
  }

  Future<String?> _getFCMToken() async {
    try {
      // Request notification permissions
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Get the token
        String? token = await FirebaseMessaging.instance.getToken();
        return token;
      }
      return null;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _updateFCMToken(String userId, BuildContext context) async {
    if (!context.mounted) return;

    try {
      String? fcmToken = await _getFCMToken();
      if (fcmToken != null && context.mounted) {
        // Update token in Firestore
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.users.collectionName)
            .doc(userId)
            .update({
          'fcmToken': fcmToken,
        });

        // Update token in GlobalStore
        if (context.mounted) {
          Provider.of<GlobalStore>(context, listen: false)
              .setFcmToken(fcmToken);
        }

        // Listen for token refreshes
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          if (context.mounted) {
            _updateFCMToken(userId, context);
          }
        });
      }
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential;
        final globalStore = Provider.of<GlobalStore>(context, listen: false);

        if (_isLogin) {
          // Login user
          userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          final userId = userCredential.user!.uid;

          // Fetch user data from Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(FirestoreCollections.users.collectionName)
              .doc(userId)
              .get();

          if (userDoc.exists) {
            // Update FCM token
            await _updateFCMToken(userId, context);

            // Set data in GlobalStore before navigation
            globalStore.setUserData(
              userId: userId,
              login: userDoc[FirestoreCollections.users.login],
              name: userDoc[FirestoreCollections.users.name],
              favoriteCity: userDoc[FirestoreCollections.users.favoriteCity],
              fcmToken: userDoc[FirestoreCollections.users.fcmToken],
            );

            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                (route) => false,
              );
            }
          }
        } else {
          // Register user
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          final userId = userCredential.user!.uid;
          final fcmToken = await _getFCMToken();

          // Save additional data to Firestore
          await FirebaseFirestore.instance
              .collection(FirestoreCollections.users.collectionName)
              .doc(userId)
              .set({
            FirestoreCollections.users.userId: userId,
            FirestoreCollections.users.login: _emailController.text,
            FirestoreCollections.users.name: _nameController.text,
            FirestoreCollections.users.favoriteCity: _cityController.text,
            FirestoreCollections.users.fcmToken: fcmToken,
          });

          // Save all data to GlobalStore
          globalStore.setUserData(
            userId: userId,
            login: _emailController.text,
            name: _nameController.text,
            favoriteCity: _cityController.text,
            fcmToken: fcmToken,
          );

          // Set up token refresh listener
          FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
            _updateFCMToken(userId, context);
          });

          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        print('Error: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
