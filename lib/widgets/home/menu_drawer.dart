import 'package:flutter/material.dart';

class MenuDrawer extends StatelessWidget {
  final int selectedIndex;
  final List<String> menuTitles;
  final void Function(int) onTap;

  const MenuDrawer({
    super.key,
    required this.selectedIndex,
    required this.menuTitles,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text('메뉴', style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          for (int i = 0; i < menuTitles.length; i++)
            ListTile(
              title: Text(menuTitles[i]),
              selected: i == selectedIndex,
              onTap: () {
                onTap(i);
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
