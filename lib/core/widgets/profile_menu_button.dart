import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';

class ProfileMenuButton extends ConsumerWidget {
  const ProfileMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);

    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.fieldBackground,
        child: Icon(LucideIcons.user, color: AppColors.textPrimary, size: 20),
      ),
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onSelected: (value) async {
        if (value == 'logout') {
          await authNotifier.logout();
          if (context.mounted) {
            context.go('/login');
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(LucideIcons.logOut,
                  size: 18, color: AppColors.statusDangerDark),
              SizedBox(width: 12),
              Text('Logout',
                  style: TextStyle(color: AppColors.statusDangerDark)),
            ],
          ),
        ),
      ],
    );
  }
}
