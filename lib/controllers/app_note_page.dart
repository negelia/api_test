import 'package:api_test/model/note.dart';
import 'package:api_test/utils/app_response.dart';
import 'package:conduit/conduit.dart';

class AppPageNoteController extends ResourceController {
  AppPageNoteController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> getNotes(@Bind.query("page") int entry) async {
    //Загрузка первой страницы
    var firstQuery = Query<Note>(managedContext)
      ..pageBy((p) => p.dateCreated, QuerySortOrder.descending)
      ..fetchLimit = 20;

    var firstQueryResults = await firstQuery.fetch();
    var oldestPostWeGot = firstQueryResults.last.dateCreated;

    int i = 1;
    while (i < entry) {
      firstQuery = Query<Note>(managedContext)
        ..pageBy((p) => p.dateCreated, QuerySortOrder.descending,
            boundingValue: oldestPostWeGot)
        ..fetchLimit = 20;

      firstQueryResults = await firstQuery.fetch();
      oldestPostWeGot = firstQueryResults.last.dateCreated;
      i++;
    }
    if (firstQueryResults == null) {
      return AppResponse.badRequest(message: "всё плохо");
    }
    return Response.ok(firstQueryResults);
  }
}
