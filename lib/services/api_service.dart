import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Gunakan 10.0.2.2 untuk Android Emulator agar bisa mengakses localhost PC
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Accept'] = 'application/json';
    
    // Interceptor untuk menyisipkan token secara otomatis ke setiap request
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  // Fungsi Login
  Future<Response> login(String email, String password) async {
    return await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  // Fungsi Register (Otomatis role Mahasiswa)
  Future<Response> register(String name, String email, String password) async {
    return await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  // Fungsi Logout
  Future<Response> logout() async {
    return await _dio.post('/logout');
  }

  // Ambil Data Mahasiswa (Bisa untuk profil sendiri atau semua data bagi admin)
  Future<Response> getMahasiswa() async {
    return await _dio.get('/mahasiswa');
  }

  // Submit Data Formulir Mahasiswa
  Future<Response> submitDataMahasiswa(Map<String, dynamic> data) async {
    return await _dio.post('/mahasiswa', data: data);
  }
}