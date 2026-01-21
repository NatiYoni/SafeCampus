import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final StreamController<void> _sessionExpiredController = StreamController.broadcast();

  Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  AuthInterceptor(this._dio, this._storage);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token'; // Standard Bearer
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // If the failed request was already the refresh endpoint, prevent loop
      if (err.requestOptions.path.contains('refresh-token')) {
        await _logout();
        super.onError(err, handler);
        return;
      }

      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) {
        await _logout();
        super.onError(err, handler);
        return;
      }

      try {
        // Create a new Dio instance for the refresh call to avoid interceptors
        // running again on the refresh call itself (though we added a check above)
        final tokenDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl)); 
        
        final response = await tokenDio.post('/refresh-token', data: {
          'refresh_token': refreshToken,
        });

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'];
          
          await _storage.write(key: 'access_token', value: newAccessToken);

          // Retry the original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';

          final clonedResponse = await _dio.fetch(opts);
          return handler.resolve(clonedResponse);
        } else {
           await _logout();
        }
      } catch (e) {
        await _logout();
      }
    }
    super.onError(err, handler);
  }

  Future<void> _logout() async {
    await _storage.deleteAll();
    _sessionExpiredController.add(null);
  }
}
