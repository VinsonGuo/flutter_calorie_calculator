import 'package:flutter/material.dart';
import 'package:flutter_calorie_calculator/provider/app_provider.dart';
import 'package:flutter_calorie_calculator/ui/page/home_page.dart';
import 'package:flutter_calorie_calculator/ui/widget/global_loading_widget.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return GlobalLoadingWidget(
      child: Scaffold(
        appBar: AppBar(title: Text("Firebase Auth")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text;
                  final password = passwordController.text;
                  final result = await provider.registerWithEmail(email, password);
                  if (result) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage())
                    );
                  }
                },
                child: Text("Register"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailController.text;
                  final password = passwordController.text;
                  final result = await provider.loginWithEmail(email, password);
                  if (result) {
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomePage())
                    );
                  }
                },
                child: Text("Login"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await provider.signInWithGoogle();
                  if (result) {
                    print("Google login successful");
                    Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const HomePage())
                    );
                  }
                },
                child: Text("Login with Google"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
