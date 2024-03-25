import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginController extends StateNotifier<void> {
  LoginController() : super(null);



  Future<void> login(
      {required String email,
      required String password,
      required Function(String) onError}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        onError('Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        onError('Correo o contrasena incorrectos');
      }
      print(e);
    }
  }

  Future<void> register(
      {required String email,
      required String password,
      required String name,
      required Function(String) onError,
      required Function() onSuccess}) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        onError('Contrasena muy debil');
      } else if (e.code == 'email-already-in-use') {
        onError('Cuenta ya existente');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
