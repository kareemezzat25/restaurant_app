import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordView extends StatefulWidget {
  final String email;
  const ChangePasswordView({super.key, required this.email});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordView> {
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> changePassword() async {
    try {
      final response = await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: passwordController.text),
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password updated successfully."),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: ${error.toString()}"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    changePassword();
                  }
                },
                child: Text("Change Password"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
