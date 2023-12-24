import 'package:isar/isar.dart';

part 'doc_file.g.dart';

@collection
class DocFileBytes {
  Id id = Isar.autoIncrement;
  String? filename;
  List<byte>? contents;
  bool? saveInDir;

  DocFileBytes({
    this.id = Isar.autoIncrement,
    this.filename,
    this.contents,
    this.saveInDir,
  });
}
