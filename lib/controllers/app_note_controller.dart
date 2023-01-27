import 'dart:io';

import 'package:api_test/model/history.dart';
import 'package:api_test/model/model_response.dart';
import 'package:api_test/model/note.dart';
import 'package:api_test/utils/app_utils.dart';
import 'package:conduit/conduit.dart';

import '../model/user.dart';
import '../utils/app_response.dart';

class AppNoteController extends ResourceController {
  AppNoteController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.post()
  Future<Response> addNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.body() Note note) async {
    if (note.number == null ||
        note.title == null ||
        note.body == null ||
        note.category == null) {
      return Response.badRequest(
          body: ModelResponse(message: 'поля обязательны для заполнения!'));
    }

    try {
      late final int id;

      late final int idHist;

      final idUser = AppUtils.getIdfromHeader(header);

      final userData = await managedContext.fetchObjectWithID<User>(idUser);

      await managedContext.transaction((transaction) async {
        final qCreateNote = Query<Note>(transaction)
          ..values.number = note.number
          ..values.title = note.title
          ..values.body = note.body
          ..values.category = note.category
          ..values.dateCreated = DateTime.now()
          ..values.dateEdited = DateTime.now()
          ..values.user = userData
          ..values.logDelParam = "unhide";

        final createNote = await qCreateNote.insert();

        id = createNote.id!;
        //
        //await
      });

      await managedContext.transaction((transaction) async {
        final qCreateHistory = Query<History>(transaction)
          ..values.activity = "дабавление заметки"
          ..values.user = userData;

        final createHistory = await qCreateHistory.insert();

        idHist = createHistory.id!;
      });

      return AppResponse.ok(message: 'успешное добавление');
    } on QueryException catch (e) {
      return Response.serverError(body: ModelResponse(message: e.message));
    }
  }

  @Operation.get()
  Future<Response> getNotes(
      @Bind.header(HttpHeaders.authorizationHeader) String header) async {
    late final int idHist;

    final idUser = AppUtils.getIdfromHeader(header);

    final userData = await managedContext.fetchObjectWithID<User>(idUser);

    final query = Query<Note>(managedContext)
      ..where((x) => x.logDelParam).equalTo("unhide")
      ..where((x) => x.user?.id).equalTo(idUser);

    await managedContext.transaction((transaction) async {
      final qCreateHistory = Query<History>(transaction)
        ..values.activity = "просмотр заметок"
        ..values.user = userData;

      final createHistory = await qCreateHistory.insert();

      idHist = createHistory.id!;
    });

    return Response.ok(await query.fetch());
  }

  @Operation.put('id')
  Future<Response> updateNote(
      @Bind.header(HttpHeaders.authorizationHeader) String header,
      @Bind.path("id") int id,
      @Bind.body() Note bodyNote) async {
    try {
      final currentAuthorId = AppUtils.getIdfromHeader(header);
      final note = await managedContext.fetchObjectWithID<Note>(id);
      if (note == null) {
        return AppResponse.ok(message: "заметка не найдена");
      }
      if (note.user?.id != currentAuthorId) {
        return AppResponse.ok(message: "нет доступа к заметке");
      }

      final qUpdateNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id)
        ..values.body = bodyNote.body;

      await qUpdateNote.update();

      late final int idHist;

      final userData =
          await managedContext.fetchObjectWithID<User>(currentAuthorId);

      await managedContext.transaction((transaction) async {
        final qCreateHistory = Query<History>(transaction)
          ..values.activity = "изменение заметок"
          ..values.user = userData;

        final createHistory = await qCreateHistory.insert();

        idHist = createHistory.id!;
      });

      return AppResponse.ok(message: "заметка обновлена");
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }

  @Operation.delete('id')
  Future<Response> deleteNote(
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

      final qDeleteNote = Query<Note>(managedContext)
        ..where((x) => x.id).equalTo(id);

      await qDeleteNote.delete();

      late final int idHist;

      final userData =
          await managedContext.fetchObjectWithID<User>(currentAuthorId);

      await managedContext.transaction((transaction) async {
        final qCreateHistory = Query<History>(transaction)
          ..values.activity = "удаление заметок"
          ..values.user = userData;

        final createHistory = await qCreateHistory.insert();

        idHist = createHistory.id!;
      });

      return AppResponse.ok(message: "заметка удалена");
    } catch (e) {
      return AppResponse.serverError(e);
    }
  }
}
