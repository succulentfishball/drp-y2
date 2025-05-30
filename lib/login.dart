import 'package:drp/auth_service.dart';
import 'package:drp/toaster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginModal extends StatefulWidget {
  const LoginModal({super.key});

  @override
  LoginModalState createState() => LoginModalState();
}

class LoginModalState extends State<LoginModal> {
  final _formKey = GlobalKey<FormState>();
  String? _email, _password;
  bool _isRegistering = false;
  bool _isSignedIn = FirebaseAuth.instance.currentUser != null;

  void _toggleForm() {
    // nothing to do here for backend
    setState(() {
      _isRegistering = !_isRegistering;
    });
}

  void _submitForm(BuildContext context) async {
    AuthService authService = AuthService();
    if (_formKey.currentState!.validate()) {
      if (_isSignedIn) {
        // --- Case: Logging out ---
        FirebaseAuth.instance.signOut();
        Toaster().displayAuthToast("Goodbye ${FirebaseAuth.instance.currentUser!.email}!");

        setState(() {
          _isRegistering = false;
          _isSignedIn = false;
        });
      } else {
        if (_isRegistering) {
          // --- Case: Registering ---
          UserCredential? credentials = await authService.register(
            emailAddress: _email!, 
            password: _password!
          );

          if (credentials != null) {
            setState(() {
              _isSignedIn = true;
              _isRegistering = false;
            });
          }
        } else {
          // --- Case: Signing in ---
          UserCredential? credentials = await authService.signin(
            emailAddress: _email!, 
            password: _password!
          );

          if (credentials != null) {
            setState(() {
              _isSignedIn = true;
            });
          }
        }
      }
    }

    // Redirect user
    if (context.mounted) {
      if (_isSignedIn) {
        Navigator.pushNamed(context, "/home");
      } else {
        Navigator.pushNamed(context, "/");
      }
    } else {
      Toaster().displayAuthToast("Unable to redirect user, please inform admin.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(!_isSignedIn ? 
        (_isRegistering ? 'Register' : 'Sign In') : 'Sign Out'
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isSignedIn)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) => _email = value,
                  validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                ),
              if (!_isSignedIn)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (value) => _password = value,
                  validator: (value) => value!.isEmpty ? 'Enter a password' : null,
                ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text(!_isSignedIn ? (_isRegistering ? 'Register' : 'Sign In') : "Sign Out"),
              ),

              if (!_isSignedIn)
                TextButton(
                  onPressed: _toggleForm,
                  child: Text((_isRegistering ? 'Already have an account? Sign In' : 'Create an account')),
                ),
            ],
          ),
        ),
      ),
    );
  }
}