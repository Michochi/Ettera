import 'package:dio/dio.dart';
import '../utils/constants.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<Response> register(
    String name,
    String email,
    String password,
    String bio,
  ) async {
    final data = {
      'name': name,
      'email': email,
      'password': password,
      'bio': bio,
    };
    return await _dio.post('$apiUrl/auth/register', data: data);
  }

  Future<Response> login(String email, String password) async {
    final data = {'email': email, 'password': password};
    return await _dio.post('$apiUrl/auth/login', data: data);
  }
}
