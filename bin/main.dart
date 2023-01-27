import 'package:api_test/api_test.dart' as api_test;
import 'package:api_test/api_test.dart';
import 'package:conduit/conduit.dart';
import 'dart:io';

void main() async {
  final port = int.parse(Platform.environment["PORT"] ?? '8080');
  final service = Application<AppService>()..options.port = port;
  await service.start(numberOfInstances: 3, consoleLogging: true);
}
