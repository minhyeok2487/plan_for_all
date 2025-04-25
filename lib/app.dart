import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'providers/user_provider.dart';
import 'services/task_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUser()), // ✅ 유저 정보 불러오기
        ChangeNotifierProvider(create: (_) => TaskService(Supabase.instance.client)),
      ],
      child: const _AppRouter(),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;

    return MaterialApp(
      title: 'Plan For All',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}