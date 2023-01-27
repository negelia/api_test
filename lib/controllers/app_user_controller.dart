import 'dart:io';

import 'package:api_test/utils/app_response.dart';
import 'package:api_test/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

import '../model/user.dart';

class AppUserController extends ResourceController {
  AppUserController(this.managedContext);
  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
  ) async {
    try {
      final id = AppUtils.getIdfromHeader(header);

      final user = await managedContext.fetchObjectWithID<User>(id);

      user!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
          message: 'успешное получение профиля', body: user.backing.contents);
    } catch (e) {
      return AppResponse.serverError(e, message: 'ошибка получения профиля');
    }
  }

  @Operation.post()
  Future<Response> updateProfile(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.body() User user,
  ) async {
    try {
      final id = AppUtils.getIdfromHeader(header);
      final fUser = await managedContext.fetchObjectWithID<User>(id);

      final qUpdateUser = Query<User>(managedContext)
        ..where((element) => element.id).equalTo(id)
        ..values.userName = user.userName ?? fUser!.userName
        ..values.email = user.email ?? fUser!.email;

      await qUpdateUser.updateOne();

      final findUser = await managedContext.fetchObjectWithID<User>(id);
      findUser!.removePropertiesFromBackingMap(['refreshToken', 'accessToken']);

      return AppResponse.ok(
        message: 'успешное обновление данных',
        body: findUser.backing.contents,
      );
    } catch (e) {
      return AppResponse.serverError(e, message: 'ошибка обновления данных');
    }
  }

  @Operation.put()
  Future<Response> updatePassword(
    @Bind.header(HttpHeaders.authorizationHeader) String header,
    @Bind.query('newPassword') String newPassword,
    @Bind.query('oldPassword') String oldPassword,
  ) async {
    try {
      final id = AppUtils.getIdfromHeader(header);
      final qFindUser = Query<User>(managedContext)
        ..where((element) => element.id).equalTo(id)
        ..returningProperties(
          (element) => [
            element.salt,
            element.hashPassword,
          ],
        );

      final fUser = await qFindUser.fetchOne();

      final oldHashPassword =
          generatePasswordHash(oldPassword, fUser!.salt ?? "");

      if (oldHashPassword != fUser.hashPassword) {
        return AppResponse.ok(message: 'неверный старый пароль');
      }

      final newHashPassword =
          generatePasswordHash(newPassword, fUser.salt ?? "");
      final qUpdateUser = Query<User>(managedContext)
        ..where((element) => element.id).equalTo(id)
        ..values.hashPassword = newHashPassword;

      await qUpdateUser.updateOne();

      return AppResponse.ok(body: 'пароль успешно обновлён');
    } catch (e) {
      return AppResponse.serverError(e, message: 'ошибка обновления пароля');
    }
  }
}
