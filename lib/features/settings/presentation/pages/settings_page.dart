import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:wms_durich/core/theme/app_colors.dart';
import 'package:wms_durich/features/auth/presentation/providers/auth_provider.dart';
import 'package:wms_durich/features/settings/presentation/providers/settings_provider.dart';
import 'package:wms_durich/shared/widgets/app_notification.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Update Password Controllers
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _updateFormKey = GlobalKey<FormState>();

  // Reset Password Controllers
  final _resetEmailController = TextEditingController();
  final _resetPassController = TextEditingController();
  final _resetFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    _resetEmailController.dispose();
    _resetPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isAdmin = user?.isAdmin ?? false;
    final settingsState = ref.watch(settingsProvider);

    ref.listen(settingsProvider, (prev, next) {
      if (next.error != null) {
        AppNotification.show(
          context, 
          message: next.error!, 
          type: NotificationType.error
        );
      } else if (next.successMessage != null) {
        AppNotification.show(
          context, 
          message: next.successMessage!, 
          type: NotificationType.success
        );
        
        _oldPassController.clear();
        _newPassController.clear();
        _resetEmailController.clear();
        _resetPassController.clear();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          if (isAdmin)
            Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.black,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.black,
                tabs: const [
                  Tab(text: 'My Password'),
                  Tab(text: 'User Management'),
                ],
              ),
            ),
          Expanded(
            child: isAdmin
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUpdatePasswordForm(settingsState.isLoading),
                      _buildResetPasswordForm(settingsState.isLoading),
                    ],
                  )
                : _buildUpdatePasswordForm(settingsState.isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatePasswordForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _updateFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Password',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _oldPassController,
              label: 'Old Password',
              isPassword: true,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _newPassController,
              label: 'New Password',
              isPassword: true,
              validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 chars' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_updateFormKey.currentState!.validate()) {
                          ref.read(settingsProvider.notifier).updatePassword(
                                _oldPassController.text,
                                _newPassController.text,
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _resetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.statusWarningLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.statusWarningDark.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, color: AppColors.statusWarningDark, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Admin feature to reset other user\'s password.',
                      style: TextStyle(color: AppColors.statusWarningDark, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _resetEmailController,
              label: 'User Email',
              validator: (v) => v?.contains('@') == false ? 'Invalid email' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _resetPassController,
              label: 'New Password for User',
              isPassword: true,
              validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 chars' : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_resetFormKey.currentState!.validate()) {
                          ref.read(settingsProvider.notifier).resetPassword(
                                _resetEmailController.text,
                                _resetPassController.text,
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusDangerDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Reset User Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.fieldBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
