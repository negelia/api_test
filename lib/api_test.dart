import 'package:api_test/controllers/app_auth_controllers.dart';
import 'package:api_test/controllers/app_note_controller.dart';
import 'package:api_test/controllers/app_note_search_controller.dart';
import 'package:api_test/controllers/app_token_controller.dart';
import 'package:api_test/controllers/app_user_controller.dart';
import 'package:conduit/conduit.dart';
import 'dart:io';
import 'package:api_test/model/user.dart';

import 'controllers/app_history_controller.dart';
import 'controllers/app_log_del_controller.dart';
import 'controllers/app_note_page.dart';

class AppService extends ApplicationChannel {
  late final ManagedContext managedContext;

  @override
  Future prepare() {
    final persistentStore = _initDatabase();

    managedContext = ManagedContext(
        ManagedDataModel.fromCurrentMirrorSystem(), persistentStore);
    return super.prepare();
  }

  @override
  Controller get entryPoint => Router()
    ..route('token/[:refresh]').link(
      () => AppAuthController(managedContext),
    )
    ..route('user')
        .link(AppTokenController.new)!
        .link(() => AppUserController(managedContext))
    ..route('note/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppNoteController(managedContext))
    ..route('note/search')
        .link(AppTokenController.new)!
        .link(() => AppNoteSearchController(managedContext))
    ..route('pagination/[:page]')
        .link(AppTokenController.new)!
        .link(() => AppPageNoteController(managedContext))
    ..route('delete/[:id]')
        .link(AppTokenController.new)!
        .link(() => AppNoteLogDelController(managedContext))
    ..route('history')
        .link(AppTokenController.new)!
        .link(() => AppHistoryController(managedContext));

  PersistentStore _initDatabase() {
    final username = Platform.environment["DB_USERNAME"] ?? 'postgres';
    final password = Platform.environment["DB_PASSWORD"] ?? '231203';
    final host = Platform.environment["DB_HOST"] ?? '127.0.0.1';
    final port = int.parse(Platform.environment["DB_PORT"] ?? '5432');
    final databaseName = Platform.environment["DB_NAME"] ?? 'postgres';

    return PostgreSQLPersistentStore(
        username, password, host, port, databaseName);
  }
}
