import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';

class HomeShell extends ConsumerStatefulWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _previousIndex = 0;

  List<Map<String, dynamic>> _getNavigationItems(bool isAdmin, bool isWarehouse, bool isSales) {
    final items = <Map<String, dynamic>>[];

    if (isAdmin) {
      items.add({
        'path': '/home',
        'item': BottomNavigationBarItem(
          icon: Image.asset(AssetPaths.homeGray, height: 24),
          activeIcon: Image.asset(AssetPaths.homeBlack, height: 24),
          label: 'Home',
        ),
      });
    }

    if (isAdmin || isWarehouse) {
      items.add({
        'path': '/home/warehouse',
        'item': BottomNavigationBarItem(
          icon: Image.asset(AssetPaths.boxGray, height: 24),
          activeIcon: Image.asset(AssetPaths.boxBlack, height: 24),
          label: 'Warehouse',
        ),
      });
    }

    if (isAdmin || isSales) {
      items.add({
        'path': '/home/sales',
        'item': BottomNavigationBarItem(
          icon: Image.asset(AssetPaths.salesGray, height: 24),
          activeIcon: Image.asset(AssetPaths.salesBlack, height: 24),
          label: 'Sales',
        ),
      });
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Default roles jika belum load (secure fail-safe: hide sensitive tabs)
    final bool isAdmin = user?.isAdmin ?? false;
    final bool isWarehouse = user?.isWarehouse ?? false;
    final bool isSales = user?.isSales ?? false;

    final navItems = _getNavigationItems(isAdmin, isWarehouse, isSales);
    
    // Cari index berdasarkan URL saat ini
    final String location = GoRouterState.of(context).fullPath ?? '/home';
    int selectedIndex = navItems.indexWhere((element) => element['path'] == location);
    
    // Jika route tidak ditemukan di tab (misal direct link), default ke 0
    if (selectedIndex == -1) selectedIndex = 0;

    // Tentukan arah slide
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
        onTap: (index) {
          setState(() {
            _previousIndex = selectedIndex;
          });
          context.go(navItems[index]['path'] as String);
        },
        selectedItemColor: AppColors.black,
        unselectedItemColor: AppColors.inactiveGray,
        showUnselectedLabels: true,
        items: navItems.map((e) => e['item'] as BottomNavigationBarItem).toList(),
      ),
    );
  }
}
