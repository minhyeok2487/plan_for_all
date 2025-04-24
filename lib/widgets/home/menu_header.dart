import 'package:flutter/material.dart';

class MenuHeader extends StatelessWidget {
  final bool isMobile;
  final bool isExpanded;
  final bool isRefreshing;
  final String title;
  final VoidCallback onMenuToggle;
  final Future<void> Function() onRefresh;

  const MenuHeader({
    super.key,
    required this.isMobile,
    required this.isExpanded,
    required this.isRefreshing,
    required this.title,
    required this.onMenuToggle,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.menu),
          onPressed: onMenuToggle,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          tooltip: '동기화',
          onPressed: isRefreshing ? null : onRefresh,
          icon: isRefreshing
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Icon(Icons.refresh),
        ),
      ],
    );
  }
}
