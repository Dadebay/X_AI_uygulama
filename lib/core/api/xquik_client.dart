import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class XquikClient {
  static const String _publicApi = 'https://xquik.com/api/v1';
  static const String _baseUrl = String.fromEnvironment(
    'XQUIK_API_BASE_URL',
    defaultValue: _publicApi,
  );
  // A development key is embedded in the app binary. Production must use a
  // server-side proxy that holds the Xquik credential.
  static const String _developmentKey =
      String.fromEnvironment('XQUIK_DEV_API_KEY');

  static Dio? _instance;

  static Dio get instance => _instance ??= _createDio();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        if (!kReleaseMode && _developmentKey.isNotEmpty)
          'x-api-key': _developmentKey,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    if (_baseUrl == _publicApi && (kReleaseMode || _developmentKey.isEmpty)) {
      dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
        handler.reject(DioException(
          requestOptions: options,
          message:
              'Configure XQUIK_API_BASE_URL for production or XQUIK_DEV_API_KEY for development.',
        ));
      }));
    }
    return dio;
  }
}
