import 'package:flutter/material.dart';
import 'package:plan_for_all/services/avata_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isSignUp = false;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nicknameController = TextEditingController();

  Future<void> _submit() async {
    setState(() => isLoading = true);

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final nickname = nicknameController.text.trim();
    final avatarUrl = generateRandomAvatarUrl();

    try {
      if (isSignUp) {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'display_name': nickname,
            'avatar_url': avatarUrl,
          },
        );

        if (!mounted) return;

        if (res.user == null) {
          _showSnack('회원가입 성공. 이메일 인증 후 로그인하세요.');
        } else {
          _showSnack('회원가입 완료! 바로 로그인됩니다.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.session != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          _showSnack('로그인 실패. 이메일/비밀번호 확인');
        }
      }
    } catch (e) {
      _showSnack('에러: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSignUp ? '회원가입' : '로그인',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: '이메일'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: '비밀번호'),
                  obscureText: true,
                  textInputAction: isSignUp ? TextInputAction.next : TextInputAction.done,
                  onSubmitted: (_) {
                    if (!isSignUp) _submit(); // 로그인 모드일 때만 실행
                  },
                ),
                if (isSignUp) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: nicknameController,
                    decoration: const InputDecoration(labelText: '닉네임'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    child: isLoading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : Text(isSignUp ? '회원가입' : '로그인'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => isSignUp = !isSignUp),
                  child: Text(
                    isSignUp ? '이미 계정이 있으신가요? 로그인' : '계정이 없으신가요? 회원가입',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
