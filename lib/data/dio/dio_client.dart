import "package:dio/dio.dart";
import "package:flutter/services.dart";

import "../../core/constants/api_constants.dart";

/// Client Dio prêt pour Laravel ; les réponses sont mockées via assets JSON.
class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: ApiConstants.connectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeoutSeconds),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Exemple : GET /restaurants → renvoie le JSON mock (fichier asset).
          if (options.path.endsWith("/restaurants")) {
            final raw = await rootBundle.loadString("assets/mock/restaurants.json");
            return handler.resolve(
              Response<dynamic>(
                requestOptions: options,
                statusCode: 200,
                data: raw,
              ),
            );
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
