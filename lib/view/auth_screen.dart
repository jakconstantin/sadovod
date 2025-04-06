import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../models/firebase_service.dart';
import '../models/supabase_service.dart';
import 'auth_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final SupabaseService firebaseService = SupabaseService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onAuth = isLogin
        ? () => firebaseService.onLogin(
      email: emailController.text,
      password: passwordController.text,
    )
        : () => firebaseService.onRegister(
      email: emailController.text,
      password: passwordController.text,
    );
    final buttonText = isLogin ? 'Авторизоваться' : 'Register';

    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Text('Садовод подключение'),
      //   centerTitle: true,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Image.asset(AppAssets.images.logo),
              ),
              const SizedBox(height: 16.0),
              AuthForm(
                authButtonText: buttonText,
                onAuth: onAuth,
                emailController: emailController,
                passwordController: passwordController,
              ),
              // TextButton(
              //   child: Text(buttonText),
              //   onPressed: () {
              //     setState(() {
              //       isLogin = !isLogin;
              //     });
              //   },
              // ),
            ],
          ),
        ),
      ),

    );
  }
}