import 'package:api_test/model/history.dart';
import 'package:conduit/conduit.dart';

class AppHistoryController extends ResourceController {
  AppHistoryController(this.managedContext);

  final ManagedContext managedContext;
  @Operation.get()
  Future<Response> getHistories() async {
    final query = Query<History>(managedContext);
    return Response.ok(await query.fetch());
  }
}
