import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _metadata;

  User? get user => _user;
  String get nickname => _metadata?['display_name'] ?? _user?.email ?? '사용자';
  String? get avatarUrl => _metadata?['avatar_url'];

  Future<void> loadUser() async {
    final response = await Supabase.instance.client.auth.getUser();
    _user = response.user;
    _metadata = _user?.userMetadata;
    notifyListeners();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _user = null;
    _metadata = null;
    notifyListeners();
  }
}