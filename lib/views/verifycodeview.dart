import 'package:flutter/material.dart';
import 'package:resturant_app/views/changepasswordview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyCodeView extends StatefulWidget {
  final String email;
  const VerifyCodeView({super.key, required this.email});

  @override
  State<VerifyCodeView> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  TextEditingController codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> verifyCode() async {
    try {
      final response = await Supabase.instance.client
          .from('verification_codes')
          .select()
          .eq('email', widget.email)
          .eq('code', codeController.text)
          .gte('expires_at', DateTime.now().toIso8601String())
          .single();

      if (response != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ChangePasswordView(email: widget.email)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Invalid or expired code."),
        ));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${error.toString()}"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Code")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: codeController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the code';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Enter Code",
                  border: OutlineInputBorder(),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    verifyCode();
                  }
                },
                child: Text("Verify Code"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
