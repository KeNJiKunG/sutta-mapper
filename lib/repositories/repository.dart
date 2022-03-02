import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

abstract class Repository {
  String _tableName;

  Repository(this._tableName);

  static final Future _databasePath = Future.sync(() async {
    // Construct a file path to copy database to
    Directory databasePath = await getApplicationDocumentsDirectory();
    return join(databasePath.path, "sutta.db");
  });

  static final Future _copyDatabaseFuture = Future.sync(() async {
    var path = await _databasePath;

    // Only copy if the database doesn't exist
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      String dbPath = 'assets/sutta.sqlite';

      // Load database from asset and copy
      ByteData data = await rootBundle.load(dbPath);

      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Save copied asset to documents
      await File(path).writeAsBytes(bytes);
    }
  });

  Future<Database> getConnection() async {
    await _copyDatabaseFuture;
    var databasePath = await _databasePath;

    return sqlite3.open(databasePath);
  }

  int getLastSeq(Database connection) {
    var result = connection.select("SELECT seq FROM sqlite_sequence WHERE name = ?", [this._tableName]);

    return result.first["seq"];
  }
}
