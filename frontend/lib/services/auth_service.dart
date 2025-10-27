import 'package:dio/dio.dart';
import '../utils/constants.dart';

class AuthService {
  final Dio _dio = Dio();

  Future<Response> register(String name, String email, String password) async {
    final data = {'name': name, 'email': email, 'password': password};
    return await _dio.post('$apiUrl/auth/register', data: data);
  }

  Future<Response> login(String email, String password) async {
    final data = {'email': email, 'password': password};
    return await _dio.post('$apiUrl/auth/login', data: data);
  }

  Future<Response> updateProfile({
    required String token,
    required String name,
    required String email,
    String? bio,
    String? photoUrl,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'bio': bio,
      'photoUrl': photoUrl,
    };

    return await _dio.put(
      '$apiUrl/auth/profile',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> uploadProfilePicture({
    required String token,
    required String imageData,
  }) async {
    final data = {'imageData': imageData};

    return await _dio.post(
      '$apiUrl/auth/profile/picture',
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> deleteProfilePicture({required String token}) async {
    return await _dio.delete(
      '$apiUrl/auth/profile/picture',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
