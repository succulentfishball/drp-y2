import 'package:drp/utilities/toaster.dart' show Toaster;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<UserCredential?> register({
    required String emailAddress,
    required String password
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      Toaster().displayAuthToast("Successfully registered");
      return userCredential;
      
    } on FirebaseAuthException catch (e) {
      String msg = '';
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        msg = 'Email is invalid. Please check email entered.';
      } else {
        msg = 'FirebaseAuthException caught when registering, please contact admin.';
      }
      Toaster().displayAuthToast(msg);
      return null;
    } catch (e) {
      print(e); return null;
    }
  }

  Future<UserCredential?> signin({
    required String emailAddress,
    required String password
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailAddress,
        password: password
      );
      Toaster().displayAuthToast("Successfully signed in");
      return userCredential;

    } on FirebaseAuthException catch (e) {
      String msg = '';
      print(e.toString());
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided for that user.';
      }  else if (e.code == 'invalid-email') {
        msg = 'Email is invalid. Please check email entered.';
      } else if (e.code == "invalid-credential") {
        msg = 'Email or password are incorrect or expired. Please check again';
      }else {
        msg = 'FirebaseAuthException caught when trying to sign in, please contact admin.';
      }

      Toaster().displayAuthToast(msg);
    }
    return null;
  }
}