import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class XquikClient {
  static const String _baseUrl = 'https://xquik.com/api/v1';
  static const String _apiKey = 'xq_49ce52dbbcc88c3eecef976447239f04c1d1783db3282d9db69d4221cd87ac92';

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
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
    // Geçici ağ kesintilerinde (timeout / bağlantı hatası) GET isteklerini
    // otomatik olarak birkaç kez tekrar dener.
    dio.interceptors.add(_RetryInterceptor(dio));
    if (kDebugMode) {
      dio.interceptors.add(_CompactLogInterceptor());
    }
    return dio;
  }
}

/// Ham request/response body'sini basmak yerine method, path ve dönen
/// öğe sayısını/boyutunu tek satırda özetler (LogInterceptor çok gürültülüydü).
class _CompactLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[Xquik] → ${options.method} ${options.uri.path}${options.uri.query.isNotEmpty ? '?${options.uri.query}' : ''}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final count = _itemCount(response.data);
    final bytes = response.data?.toString().length ?? 0;
    final countPart = count != null ? '$count öğe, ' : '';
    print('[Xquik] ← ${response.statusCode} ${response.requestOptions.uri.path} — $countPart$bytes byte');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[Xquik] ✗ ${err.requestOptions.method} ${err.requestOptions.uri.path} — ${err.response?.statusCode ?? err.type}');
    handler.next(err);
  }

  int? _itemCount(dynamic data) {
    if (data is List) return data.length;
    if (data is Map) {
      for (final key in ['tweets', 'data', 'results', 'items', 'trends']) {
        final v = data[key];
        if (v is List) return v.length;
      }
    }
    return null;
  }
}

/// Timeout ve bağlantı hatalarında idempotent GET isteklerini artan gecikmeyle
/// yeniden dener. POST/DELETE gibi yan etkili istekler tekrar denenmez.
class _RetryInterceptor extends Interceptor {
  final Dio dio;
  static const int maxRetries = 2;

  _RetryInterceptor(this.dio);

  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_attempt'] as int?) ?? 0;

    if (options.method == 'GET' && attempt < maxRetries && _shouldRetry(err)) {
      final nextAttempt = attempt + 1;
      options.extra['retry_attempt'] = nextAttempt;
      await Future.delayed(Duration(milliseconds: 500 * nextAttempt));
      try {
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    return handler.next(err);
  }
}
