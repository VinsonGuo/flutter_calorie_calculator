import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calorie_calculator/ui/page/auth_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/shared_preference.dart';
import 'provider/app_provider.dart';
import 'ui/page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  await dotenv.load();
  Gemini.init(apiKey: dotenv.env['GEMINI_KEY']!);
  await Firebase.initializeApp();
  // MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      builder: (context, child) {
        return MaterialApp(
          title: 'Calorie Calculator',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          home: Selector<AppProvider, User?>(
            selector: (_, provider) => provider.user,
            builder: (_, user, __) {
              return user == null ? AuthPage() : const HomePage();
            },
          ),
        );
      },
    );
  }
}
