import 'package:api_test/model/note.dart';
import 'package:conduit/conduit.dart';
import '../utils/app_response.dart';

class AppNoteSearchController extends ResourceController {
  AppNoteSearchController(this.managedContext);

  final ManagedContext managedContext;

  @Operation.get()
  Future<Response> searchNotes(@Bind.query('titleSearch') String entry) async {
    final query = Query<Note>(managedContext)
      ..where((x) => x.title).contains(entry);
    return Response.ok(await query.fetch());
  }
}
