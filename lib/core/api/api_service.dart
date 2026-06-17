import 'package:dio/dio.dart';
import 'package:atlas/core/api/api_client.dart';

class ApiService {
  final Dio _dio = ApiClient.instance;

  // ─── FCM ────────────────────────────────────────────────────────────────────
  Future<void> registerFcmToken(String token) async {
    await _dio.post(
      'fcm/',
      data: FormData.fromMap({'fcm': token}),
    );
  }

  // ─── Device ─────────────────────────────────────────────────────────────────
  Future<void> registerDevice(String deviceId) async {
    await _dio.post(
      'device/',
      data: FormData.fromMap({'device_id': deviceId}),
    );
  }

  // ─── About ──────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getAboutContent() async {
    final response = await _dio.get('about/');
    final list = _extractList(response.data);
    if (list.isNotEmpty) return list.first as Map<String, dynamic>;
    return {};
  }

  // ─── Privacy / Terms ────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getPrivacyContent() async {
    final response = await _dio.get('privacy/');
    final list = _extractList(response.data);
    if (list.isNotEmpty) return list.first as Map<String, dynamic>;
    return {};
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List<dynamic>;
    }
    return [];
  }
}
