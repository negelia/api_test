import 'package:api_test/model/model_response.dart';
import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AppResponse extends Response {
  AppResponse.serverError(dynamic error, {String? message})
      : super.serverError(body: _getResponseModel(error, message));
  static ModelResponse _getResponseModel(error, String? message) {
    if (error is QueryException) {
      return ModelResponse(
          error: error.toString(), message: message ?? error.message);
    }

    if (error is JwtException) {
      return ModelResponse(
          error: error.toString(), message: message ?? error.message);
    }

    return ModelResponse(
        error: error.toString(), message: message ?? "неизвестная ошибка");
  }

  AppResponse.badRequest({String? message})
      : super.badRequest(
            body: ModelResponse(message: message ?? "ошибка запроса"));

  AppResponse.ok({dynamic body, String? message})
      : super.ok(ModelResponse(data: body, message: message));
}
