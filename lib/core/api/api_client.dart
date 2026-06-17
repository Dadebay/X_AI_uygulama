import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';

class ApiClient {
  static const String baseUrl = 'http://216.250.11.77:7000/api/';

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
