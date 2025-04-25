import 'package:flutter/material.dart';
import 'package:plan_for_all/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Plan For All',
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: session == null ? const LoginScreen() : const HomeScreen(),
      ),
    );
  }
}
