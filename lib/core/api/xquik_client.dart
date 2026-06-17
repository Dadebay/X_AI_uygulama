import 'package:dio/dio.dart';

class XquikClient {
  static const String _baseUrl = 'https://xquik.com/api/v1';
  static const String _apiKey = 'xq_49ce52dbbcc88c3eecef976447239f04c1d1783db3282d9db69d4221cd87ac92';

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'x-api-key': _apiKey,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }
}
