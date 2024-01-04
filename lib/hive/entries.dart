
import 'package:hive_flutter/hive_flutter.dart';

part 'entries.g.dart';

@HiveType(typeId: 1)
class Entry extends HiveObject {
  @HiveField(0)
  final String text;
  @HiveField(1)
  final DateTime time;

  Entry({required this.text, required this.time});
}
