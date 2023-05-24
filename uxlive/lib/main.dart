import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SignInPage(),
      routes: {
        '/home': (context) => HomePage(),
      },
    );
  }
}

class SignInPage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  SignInPage({super.key});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error occurred during Google sign-in: $error');
      // Handle sign-in error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _signInWithGoogle(context),
          icon: const Icon(Icons.login),
          label: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  HomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/');
    } catch (error) {
      // ignore: avoid_print
      print('Error occurred during Google sign-out: $error');
      // Handle sign-out error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _signOut(context),
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ),
    );
  }
}
