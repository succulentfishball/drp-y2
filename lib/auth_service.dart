import 'package:drp/toaster.dart' show Toaster;
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  Future<UserCredential?> register({
    required String emailAddress,
    required String password
  }) async {
    try {
      UserCredential creds = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      Toaster().displayAuthToast("Successfully registered");
      await Future.delayed(const Duration(seconds: 1));
      return creds;
      
    } on FirebaseAuthException catch (e) {
      String msg = '';
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
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
}