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
  String? _email, _password, _groupCode;
  bool _isRegistering = false;
  bool _isSignedIn = false;
  bool _isInGroup = false;

  void _toggleForm() {
    if (_isSignedIn) {
      // todo sign out

      setState(() {
        _isRegistering = false;
        _isSignedIn = false;
        _isInGroup = false;
      });
    } else {
      // nothing to do here for backend
      setState(() {
        _isRegistering = !_isRegistering;
      });
    }
  }

  void _submitForm(BuildContext context) async {
    AuthService authService = AuthService();
    if (_formKey.currentState!.validate()) {
      if (!_isSignedIn) {
        if (_isRegistering) {
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
          // todo sign in
          print('Email: $_email, Password: $_password');

          setState(() {
            _isSignedIn = true;
          });
        }
      } else {
        if (_isInGroup) {
          // todo exit group

          setState(() {
            _isInGroup = false;
            _groupCode = null;
          });
        } else {
          // todo join group
          print('Group Code: $_groupCode');

          setState(() {
            _isInGroup = true;
          });
        }
      }
    }

    // Redirect user
    await Future.delayed(const Duration(seconds: 2));
    if (_isSignedIn && context.mounted) {
      Navigator.pushNamed(context, "/home");
    } else {
      Toaster().displayAuthToast("Unable to redirect user, please inform admin.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(!_isSignedIn ? 
        (_isRegistering ? 'Register' : 'Sign In') : 'Group Settings'
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isSignedIn && _isInGroup)
                Text('You are in group "$_groupCode"'),
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
              if (_isSignedIn && !_isInGroup)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Group Code'),
                  onChanged: (value) => _groupCode = value,
                  validator: (value) => value!.isEmpty ? 'Enter a group code' : null,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text(!_isSignedIn ? 
                  (_isRegistering ? 'Register' : 'Sign In') :
                  (_isInGroup ? 'Exit Group' : 'Join Group')
                ),
              ),
              TextButton(
                onPressed: _toggleForm,
                child: Text(!_isSignedIn ?
                  (_isRegistering ? 'Already have an account? Sign In' : 'Create an account') : 'Sign Out'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}