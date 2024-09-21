import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dashboard_app/constants/firestore_constants.dart';
import 'package:flutter_dashboard_app/store/global_store.dart';
import 'package:flutter_dashboard_app/theme/app_colors.dart';
import 'package:provider/provider.dart'; // Potrzebne do Providera

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkestGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'weather.png',
                width: 400,
                height: 400,
              ),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
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
                        _buildTextField(_emailController, 'Email',
                            TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        _buildTextField(_passwordController, 'Hasło',
                            TextInputType.visiblePassword,
                            isPassword: true),
                        if (!_isLogin) ...[
                          const SizedBox(height: 12),
                          _buildTextField(_confirmPasswordController,
                              'Potwierdź hasło', TextInputType.visiblePassword,
                              isPassword: true),
                          const SizedBox(height: 12),
                          _buildTextField(
                              _nameController, 'Imię', TextInputType.text),
                          const SizedBox(height: 12),
                          _buildTextField(_cityController, 'Ulubione miasto',
                              TextInputType.text),
                        ],
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            foregroundColor: AppColors.lightestGray,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 12),
                          ),
                          child: Text(
                              _isLogin ? 'Zaloguj się' : 'Zarejestruj się'),
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
                ),
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
    return SizedBox(
      width: 250,
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential;
        final globalStore = Provider.of<GlobalStore>(context, listen: false);

        if (_isLogin) {
          // Logowanie użytkownika
          userCredential = await _auth.signInWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Pobranie ID zalogowanego użytkownika
          final userId = userCredential.user!.uid;

          // Pobranie danych użytkownika z Firestore
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection(FirestoreCollections.users.collectionName)
              .doc(userId)
              .get();

          // Sprawdzenie, czy dokument istnieje
          if (userDoc.exists) {
            // Ustawienie danych w GlobalStore
            globalStore.setUserData(
              userId: userId,
              login: userDoc[FirestoreCollections.users.login],
              name: userDoc[FirestoreCollections.users.name],
              favoriteCity: userDoc[FirestoreCollections.users.favoriteCity],
            );
          }
        } else {
          // Rejestracja użytkownika
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

          // Pobranie ID nowego użytkownika
          final userId = userCredential.user!.uid;

          // Zapisanie dodatkowych danych do Firestore
          await FirebaseFirestore.instance
              .collection(FirestoreCollections.users.collectionName)
              .doc(userId)
              .set({
            FirestoreCollections.users.userId: userId,
            FirestoreCollections.users.login: _emailController.text,
            FirestoreCollections.users.name: _nameController.text,
            FirestoreCollections.users.favoriteCity: _cityController.text,
          });

          // Zapisanie wszystkich danych do GlobalStore
          globalStore.setUserData(
            userId: userId,
            login: _emailController.text,
            name: _nameController.text,
            favoriteCity: _cityController.text,
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
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
