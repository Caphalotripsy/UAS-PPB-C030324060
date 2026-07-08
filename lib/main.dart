import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
// Note: Import file screen lainnya setelah nanti dibuat
import 'screens/mahasiswa_form_screen.dart';
import 'screens/admin_dashboard_screen.dart';

void main() {
  runApp(
    // Membungkus aplikasi dengan ProviderScope untuk Riverpod
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String?> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role'); // Kita akan simpan role saat login nanti
    
    if (token != null && role != null) {
      return role;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Data Mahasiswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder<String?>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          
          if (snapshot.hasData) {
            // Logika rute berdasarkan role
            if (snapshot.data == 'admin') {
              return const AdminDashboardScreen(); // Uncomment setelah file dibuat
            } else {
              return const MahasiswaFormScreen(); // Uncomment setelah file dibuat
            }
          }
          
          // Jika belum login, arahkan ke LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}