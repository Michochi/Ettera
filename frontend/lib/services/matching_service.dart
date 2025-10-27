import 'package:dio/dio.dart';
import '../utils/constants.dart';

class MatchingService {
  final Dio _dio = Dio();

  Future<Response> getProfiles({required String token, int limit = 20}) async {
    return await _dio.get(
      '$apiUrl/matching/profiles',
      queryParameters: {'limit': limit},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> likeProfile({
    required String token,
    required String profileId,
  }) async {
    return await _dio.post(
      '$apiUrl/matching/like',
      data: {'profileId': profileId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> passProfile({
    required String token,
    required String profileId,
  }) async {
    return await _dio.post(
      '$apiUrl/matching/pass',
      data: {'profileId': profileId},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> getMatches({required String token}) async {
    return await _dio.get(
      '$apiUrl/matching/matches',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<Response> unmatch({
    required String token,
    required String matchId,
  }) async {
    return await _dio.delete(
      '$apiUrl/matching/matches/$matchId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
