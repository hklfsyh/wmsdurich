import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';

const List<String> homeShellRoutes = [
  '/home',
  '/home/warehouse',
  '/home/sales'
];

class HomeShell extends StatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _previousIndex = 0;

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).fullPath ?? '/home';
    final index = homeShellRoutes.indexOf(location);
    return index != -1 ? index : 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    // Update previous index sebelum navigasi
    setState(() {
      _previousIndex = _calculateSelectedIndex(context);
    });
    context.go(homeShellRoutes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    
    // Tentukan arah slide berdasarkan posisi sebelumnya dan sekarang
    final isSlideRight = selectedIndex > _previousIndex;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Offset untuk slide animation
          // Jika index naik (0->1, 1->2): slide dari kanan (1.0) ke tengah (0.0)
          // Jika index turun (2->1, 1->0): slide dari kiri (-1.0) ke tengah (0.0)
          final offsetAnimation = Tween<Offset>(
            begin: Offset(isSlideRight ? 1.0 : -1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ));

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        child: KeyedSubtree(
          key: ValueKey(selectedIndex),
          child: widget.child,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.inactiveGray,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 0 ? AssetPaths.homeBlack : AssetPaths.homeGray,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 1 ? AssetPaths.boxBlack : AssetPaths.boxGray,
              height: 24,
            ),
            label: 'Warehouse',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 2 ? AssetPaths.salesBlack : AssetPaths.salesGray,
              height: 24,
            ),
            label: 'Sales',
          ),
        ],
      ),
    );
  }
}
