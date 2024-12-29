import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:resturant_app/views/bottomnav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final supabase = Supabase.instance.client;

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final existingUser = await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google, idToken: googleAuth.idToken!);

      print("Session: ${existingUser.session}");

      if (existingUser.session != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('email', googleUser.email)
            .maybeSingle();

        if (response == null) {
          await supabase.from('users').insert({
            'username': googleUser.displayName ?? 'Google User',
            'email': googleUser.email,
            'idAuth': existingUser.user!.id,
            'role': 'user',
          });
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
        );
      } else {
        final signUpResponse = await supabase.auth.signUp(
          email: googleUser.email,
          password: googleAuth.idToken!,
        );

        if (signUpResponse.user != null) {
          await supabase.from('users').insert({
            'username': googleUser.displayName ?? 'Google User',
            'email': googleUser.email,
            'idAuth': signUpResponse.user!.id,
            'role': 'user',
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BottomNav()),
          );
        } else {
          throw Exception("supabase Authentication");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in signin $e")),
      );
    }
  }
}
