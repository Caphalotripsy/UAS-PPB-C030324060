import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';
// Note: Import ini akan kita buka komentarnya setelah file dibuat
import 'mahasiswa_form_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (response.statusCode == 201) {
        final token = response.data['token'];
        
        // FIX: Langsung tetapkan sebagai 'mahasiswa', tidak perlu mengambil dari response API
        final String role = 'mahasiswa'; 

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role); // Sekarang role pasti berisi string 'mahasiswa'

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil!')));
        
        // FIX: Aktifkan navigasi agar setelah daftar sukses, langsung pindah ke Form Mahasiswa
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const MahasiswaFormScreen()), 
          (route) => false
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Registrasi Gagal';
      // Menangkap status 422 dari Laravel
      if (e.response?.statusCode == 422) {
        errorMessage = e.response?.data['message'] ?? 'Validasi input gagal. Coba email lain.';
      } else {
        errorMessage = e.message ?? 'Terjadi kesalahan jaringan';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan sistem: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Contoh: Ahmad Imam Nawawi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Daftar'),
                  ),
          ],
        ),
      ),
    );
  }
}