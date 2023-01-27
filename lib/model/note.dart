import 'package:api_test/model/user.dart';
import 'package:conduit/conduit.dart';

class Note extends ManagedObject<_Note> implements _Note {}

class _Note {
  @primaryKey
  int? id;
  @Column(unique: true, indexed: true)
  int? number;
  @Column(unique: true)
  String? title;
  @Column()
  String? body;
  @Column()
  String? category;
  @Column(indexed: true)
  DateTime? dateCreated;
  @Column(indexed: true)
  DateTime? dateEdited;
  @Column()
  String? logDelParam;

  @Relate(#notes, isRequired: true, onDelete: DeleteRule.cascade)
  User? user;
}
