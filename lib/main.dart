import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:resturant_app/cache/cache.dart';
import 'package:resturant_app/firebase_options.dart';
import 'package:resturant_app/views/onBoard.dart';
import 'package:resturant_app/views/signup.dart';
import 'package:resturant_app/widgets/app_constant.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await Cache.init();
  Stripe.publishableKey = publishablekey;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  try {
    await Supabase.initialize(
        url: 'https://krjghxogprhsulzwzgig.supabase.co',
        anonKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtyamdoeG9ncHJoc3Vsend6Z2lnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxMDg1ODcsImV4cCI6MjA0ODY4NDU4N30.XJieHeMm5v7Vnbqw2epHNQkC7SflS0S62yfZZCQt6Is");
  } catch (e) {
    print('Supabase initialization error: $e');
  }
  // Replace with your Supabase URL

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Cache.getEligibilty() == true
          ? const SignUp()
          : OnboardingScreen(), // Directly open AdminLogin
    );
  }
}
