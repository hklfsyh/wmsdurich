import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wms_durich/core/constants/asset_paths.dart';
import 'package:wms_durich/core/theme/app_colors.dart';

// Kita gunakan ConsumerStatefulWidget karena kita akan mengelola state visibility password
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false; // State untuk visibility password

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // TODO: Fungsi ini akan dihubungkan ke logika otentikasi API GoLang
  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Data berhasil divalidasi
      final username = _usernameController.text;
      final password = _passwordController.text;

      // TODO: Panggil provider auth untuk POST data ke API GoLang
      print('Mencoba Login dengan: $username / $password');

      // Setelah berhasil, arahkan ke /home
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // MENGHAPUS LayoutBuilder DAN ConstrainedBox
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Jarak paling atas yang kecil (Manual Bias)
              // Ini menggantikan pemusatan otomatis, menggeser konten ke atas.
              const SizedBox(height: 30),

              // 1. Logo Aplikasi
              // Ukuran logo tetap 25% (sudah dikecilkan)
              Image.asset(
                AssetPaths.durichLogo,
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
              ),

              // Jarak antara Logo dan Card tetap 0

              // 2. Card Login
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Judul Login
                        const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Input Field (rata kiri)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Input Username
                            const Text('Username',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                hintText: 'Masukkan username anda..',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Username wajib diisi';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            const Text('Password',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                hintText: 'Masukkan password anda..',
                                suffixIcon: IconButton(
                                  icon: Image.asset(
                                    _isPasswordVisible
                                        ? AssetPaths.eyeBlack
                                        : AssetPaths.eyeGray,
                                    height: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Tombol Login
                        ElevatedButton(
                          onPressed: _handleLogin,
                          child: const Text('Login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Jarak di bawah agar SCV berfungsi
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
