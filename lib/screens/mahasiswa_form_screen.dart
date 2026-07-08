import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'package:dio/dio.dart';

class MahasiswaFormScreen extends StatefulWidget {
  const MahasiswaFormScreen({super.key});

  @override
  State<MahasiswaFormScreen> createState() => _MahasiswaFormScreenState();
}

class _MahasiswaFormScreenState extends State<MahasiswaFormScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  final _nimController = TextEditingController();
  final _namaController = TextEditingController();
  final _tempatLahirController = TextEditingController();
  
  String _jenisKelamin = 'Laki Laki';
  DateTime? _tanggalLahir;
  String _jurusan = 'Teknik Informatika';
  String _tahunMasuk = '2024';

  final List<String> _listJurusan = ['Teknik Informatika', 'Sistem Informasi', 'Teknik Elektro'];
  // Membuat list tahun dari 2000 sampai tahun saat ini
  final List<String> _listTahun = List.generate(30, (index) => (2000 + index).toString());

  bool _isLoading = false;

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1999, 12, 6), // Default ke tahun perkiraan mahasiswa
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalLahir) {
      setState(() => _tanggalLahir = picked);
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih Tanggal Lahir terlebih dahulu')));
      return;
    }

    // Blokir fungsi jika aplikasi sedang memuat (Mencegah Double-Tap)
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final data = {
        'nim': _nimController.text,
        'nama': _namaController.text,
        'jenis_kelamin': _jenisKelamin,
        'tanggal_lahir': DateFormat('yyyy-MM-dd').format(_tanggalLahir!),
        'tempat_lahir': _tempatLahirController.text,
        'jurusan': _jurusan,
        'tahun_masuk': _tahunMasuk,
      };

      final response = await _apiService.submitDataMahasiswa(data);
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data berhasil disimpan!')));
        
        // Opsional: Kosongkan form setelah sukses agar tidak terkirim ulang
        _nimController.clear();
        _namaController.clear();
        _tempatLahirController.clear();
      }
    } on DioException catch (e) {
      String errorMessage = 'Gagal menyimpan data';
      if (e.response?.statusCode == 422) {
        errorMessage = e.response?.data['message'] ?? 'Data sudah ada atau input tidak valid';
      } else if (e.response?.statusCode == 403) {
        errorMessage = 'Anda sudah pernah menginput data diri.';
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan sistem.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('Input Data Mahasiswa'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(labelText: 'NIM', hintText: 'Contoh: C030324060', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'NIM tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              const Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio(value: 'Laki Laki', groupValue: _jenisKelamin, onChanged: (val) => setState(() => _jenisKelamin = val.toString())),
                  const Text('Laki Laki'),
                  Radio(value: 'Perempuan', groupValue: _jenisKelamin, onChanged: (val) => setState(() => _jenisKelamin = val.toString())),
                  const Text('Perempuan'),
                ],
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _pilihTanggal(context),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Tanggal Lahir', border: OutlineInputBorder()),
                  child: Text(_tanggalLahir == null ? 'Pilih Tanggal' : DateFormat('dd MMMM yyyy').format(_tanggalLahir!)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tempatLahirController,
                decoration: const InputDecoration(labelText: 'Tempat Lahir', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Tempat Lahir tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Jurusan', border: OutlineInputBorder()),
                value: _jurusan,
                items: _listJurusan.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                onChanged: (val) => setState(() => _jurusan = val.toString()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: 'Tahun Masuk', border: OutlineInputBorder()),
                value: _tahunMasuk,
                items: _listTahun.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _tahunMasuk = val.toString()),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      child: const Text('Submit Data'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}