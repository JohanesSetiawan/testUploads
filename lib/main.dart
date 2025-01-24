import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'login.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.initializeAuth();

  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Check if user is logged in
          if (authProvider.isLoggedIn()) {
            return const Homepage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
