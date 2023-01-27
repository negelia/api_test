import 'dart:io';

import 'package:conduit/conduit.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class AppUtils {
  const AppUtils._();

  static int getIdfromToken(String token) {
    try {
      final key = Platform.environment["SECRET_KEY"] ?? 'SECRET_KEY';
      final jwtClaim = verifyJwtHS256Signature(token, key);
      return int.parse(jwtClaim["id"].toString());
    } catch (e) {
      rethrow;
    }
  }

  static int getIdfromHeader(String header) {
    try {
      final token = const AuthorizationBearerParser().parse(header);
      final id = getIdfromToken(token ?? "");
      return id;
    } catch (e) {
      rethrow;
    }
  }
}
