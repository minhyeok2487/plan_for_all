import 'package:flutter/material.dart';
import 'package:plan_for_all/providers/user_provider.dart';
import 'package:plan_for_all/screens/login_screen.dart';
import 'package:provider/provider.dart';

class MainNavigationRail extends StatelessWidget {
  final bool isExpanded;
  final int selectedIndex;
  final void Function(int index) onSelect;
  final void Function() onToggle;

  const MainNavigationRail({
    super.key,
    required this.isExpanded,
    required this.selectedIndex,
    required this.onSelect,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final displayName = userProvider.nickname;
    final avatarUrl = userProvider.avatarUrl;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 190 : 72,
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ✅ 드롭다운 메뉴 추가
          PopupMenuButton<String>(
            tooltip: '',
            offset: const Offset(60, 0),
            color: const Color(0xFF2A2A2A), // 어두운 톤 배경
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                height: 1,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.logout, size: 14, color: Colors.white70),
                    SizedBox(width: 10),
                    Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'logout') {
                await context.read<UserProvider>().logout();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl == null ? const Icon(Icons.person) : null,
                  radius: 24,
                ),
                const SizedBox(height: 8),
                if (isExpanded)
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: NavigationRail(
              extended: isExpanded,
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.today), label: Text('오늘')),
                NavigationRailDestination(icon: Icon(Icons.calendar_view_week), label: Text('다음 7일')),
                NavigationRailDestination(icon: Icon(Icons.folder), label: Text('기본함')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
