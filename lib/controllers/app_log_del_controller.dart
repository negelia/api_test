import 'dart:io';

import 'package:api_test/model/note.dart';
import 'package:conduit/conduit.dart';

import '../utils/app_response.dart';
import '../utils/app_utils.dart';

class AppNoteLogDelController extends ResourceController {
  AppNoteLogDelController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get('id')
  Future<Response> logDelNotes(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id) async {
    try {
      final currentAuthorId = AppUtils.getIdfromHeader(header);
      final note = await managedContext.fetchObjectWithID<Note>(id);
      if (note == null) {
        return AppResponse.ok(message: "заметка не найдена");
      }
      if (note.user?.id != currentAuthorId) {
        return AppResponse.ok(message: "нет доступа к заметке");
      }

      final qUpdateNote;

      if (note.logDelParam == "hide") {
        qUpdateNote = Query<Note>(managedContext)
          ..where((x) => x.id).equalTo(id)
          ..values.logDelParam = "unhide";

        await qUpdateNote.update();

        return AppResponse.ok(message: "заметка восстановлена");
      } else {
        qUpdateNote = Query<Note>(managedContext)
          ..where((x) => x.id).equalTo(id)
          ..values.logDelParam = "hide";

        await qUpdateNote.update();

        return AppResponse.ok(message: "заметка удалена");
      }
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }
}
