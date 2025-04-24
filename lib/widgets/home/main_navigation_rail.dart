import 'package:flutter/material.dart';

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 190 : 72, // 👈 확장 시 너비 커스터마이징
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
    );
  }
}
