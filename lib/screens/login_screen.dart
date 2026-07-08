import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'package:dio/dio.dart';
import 'mahasiswa_form_screen.dart';
import 'admin_dashboard_screen.dart';
// Note: Import ini akan kita buka komentarnya setelah file dibuat
// import 'mahasiswa_form_screen.dart';
// import 'admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final role = response.data['user']['role'];

        // Simpan token dan role
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);

        if (!mounted) return;

        // Routing berdasarkan role
        // Routing berdasarkan role
     if (role == 'admin') {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Admin Berhasil')));
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
     } else {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Mahasiswa Berhasil')));
       Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MahasiswaFormScreen()));
     }
      }
    } on DioException catch (e) {
      String errorMessage = 'Login Gagal';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Email atau Password salah';
      } else {
        errorMessage = e.response?.data['message'] ?? e.message ?? 'Terjadi kesalahan jaringan/server';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      print('Error Login Detail: ${e.response?.data}'); // Tampil di terminal VSCode
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan sistem: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Sistem')),
      body: SingleChildScrollView( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo-poliban.png',
                height: 150,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40), // Jarak antara logo dan inputan email
            // --------------------------------

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16), // (SizedBox yang dobel sudah saya buang satu)
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Masuk'),
                  ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
              child: const Text('Belum punya akun? Daftar sekarang'),
            ),
          ], // Penutup dari array children Column
        ), // Penutup dari Column
      ), // Penutup dari Padding
    ), // Penutup dari SingleChildScrollView
  ); // Penutup dari Scaffold
} // Penutup dari fungsi build

} // <--- INI DIA YANG HILANG! (Penutup dari class _LoginScreenState)