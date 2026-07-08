import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'mahasiswa_form_screen.dart'; // Admin bisa menggunakan form ini juga untuk input

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _mahasiswaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getMahasiswa();
      if (response.statusCode == 200) {
        setState(() {
          _mahasiswaList = response.data;
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil data')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _apiService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Master Mahasiswa (Admin)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mahasiswaList.isEmpty
              ? const Center(child: Text('Belum ada data mahasiswa.'))
              : ListView.builder(
                  itemCount: _mahasiswaList.length,
                  itemBuilder: (context, index) {
                    final mhs = _mahasiswaList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(mhs['jenis_kelamin'] == 'Laki Laki' ? Icons.male : Icons.female),
                        ),
                        title: Text(mhs['nama']),
                        subtitle: Text('${mhs['nim']} - ${mhs['jurusan']} (${mhs['tahun_masuk']})'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // TODO: Tambahkan logika delete API di sini (fase perbaikan nanti)
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Hapus belum aktif')));
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke form untuk admin menambah data
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MahasiswaFormScreen()))
              .then((_) => _fetchData()); // Refresh data setelah kembali
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}