import 'package:dio/dio.dart';
import 'package:delivery_app/core/configurations/app_config.dart';
import 'package:delivery_app/core/constant/app_constants.dart';
import 'package:delivery_app/core/errors/exceptions.dart';
import 'package:delivery_app/core/utils/app_logger.dart';
import 'package:delivery_app/shared/service/secure_storage_service.dart';

class ApiClient {
  final Dio dio;
  final SecureStorageService secureStorage;

  ApiClient({required this.dio, required this.secureStorage}) {
    dio.options = BaseOptions(
      baseUrl: AppConfig.instance.apiBaseUrl,
      connectTimeout: AppConfig.instance.connectTimeout,
      receiveTimeout: AppConfig.instance.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(AppConstants.keyAuthToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          AppLogger.debug('HTTP Req -> [${options.method}] ${options.path}', tag: 'ApiClient');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug('HTTP Res <- [${response.statusCode}] ${response.requestOptions.path}', tag: 'ApiClient');
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          AppLogger.error(
            'HTTP Err -> [${error.response?.statusCode}] ${error.requestOptions.path}',
            error: error.message,
            tag: 'ApiClient',
          );

          if (error.response?.statusCode == 401) {
            // Handle unauthorized / token expired
            await secureStorage.delete(AppConstants.keyAuthToken);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return const UnauthorizedException();
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }

    final dynamic data = error.response?.data;
    String message = 'Server error occurred.';
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      message = data['message'].toString();
    } else if (error.message != null) {
      message = error.message!;
    }

    return ServerException(
      message: message,
      statusCode: error.response?.statusCode,
    );
  }
}
