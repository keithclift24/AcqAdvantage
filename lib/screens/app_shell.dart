import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'apply_screen.dart';
import 'learn_screen.dart';
import 'cite_screen.dart';
import 'simplify_screen.dart';
import 'tools_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const ChatScreen(),
    const ApplyScreen(),
    const LearnScreen(),
    const CiteScreen(),
    const SimplifyScreen(),
    const ToolsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Research',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Apply',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Cite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Simplify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Tools',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
