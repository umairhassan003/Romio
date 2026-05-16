import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'top_bar.dart';

class AdminScaffold extends StatefulWidget {
  final Widget child;

  const AdminScaffold({super.key, required this.child});

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final autoCollapse = screenWidth < 1024;
    final isCollapsed = autoCollapse || _isSidebarCollapsed;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            isCollapsed: isCollapsed,
            onToggleCollapse: () {
              setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
            },
          ),
          Expanded(
            child: Column(
              children: [
                TopBar(
                  onToggleSidebar: autoCollapse
                      ? null
                      : () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
