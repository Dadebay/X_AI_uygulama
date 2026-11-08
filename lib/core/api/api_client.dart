import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

class ApiClient {
  static const String baseUrl = String.fromEnvironment(
    'APP_API_BASE_URL',
    defaultValue: 'http://216.250.11.77:7000/api/',
  );

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(_AppInterceptor());
    return dio;
  }
}

class _AppInterceptor extends Interceptor {
  final _storage = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kReleaseMode && options.uri.scheme != 'https') {
      handler.reject(DioException(
        requestOptions: options,
        message: 'APP_API_BASE_URL must use HTTPS in release builds.',
      ));
      return;
    }
    final token = _storage.read<String>('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Add language header
    try {
      final langController = getx.Get.find<LanguageController>();
      final lang = langController.selectedLanguage.value;
      options.headers['Accept-Language'] = lang;
    } catch (_) {
      // If LanguageController is not initialized, use stored language or default
      final lang = _storage.read<String>('langCode') ?? 'tk';
      options.headers['Accept-Language'] = lang;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
