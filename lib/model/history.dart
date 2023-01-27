import 'package:api_test/model/user.dart';
import 'package:conduit/conduit.dart';

class History extends ManagedObject<_History> implements _History {}

class _History {
  @primaryKey
  int? id;
  @Column()
  String? activity;

  @Relate(#histories, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
}
