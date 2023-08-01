import 'package:sqflite/sqflite.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:todolist_flutter_sqlite/model_todo.dart';

class DBToDo {
  static final DBToDo instance = DBToDo._init();
  static Database? _db;
  DBToDo._init();
  static const String table = 'Topic';
  static const String dbName = 'db_todo.db';

  static const String idCol = 'id';
  static const String statusCol = 'status';
  static const String labelCol = 'label';
  static const String createdAtCol = 'createdAt';


  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, dbName);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $table ($idCol INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $statusCol TEXT NOT NULL, $labelCol TEXT NOT NULL, $createdAtCol TEXT NOT NULL)");
  }

  Future<ToDo> save(ToDo toDo) async {
    var dbClient = await instance.db;
    final id = await dbClient!.insert(table, toDo.toJson());
    return toDo.copy(id: id);
  }

  Future<List<ToDo>> getToDoList() async {
    var dbClient = await instance.db;
    List<Map<String, dynamic>> maps = await dbClient!.query(table, orderBy: "$idCol DESC", columns: [idCol, statusCol, labelCol, createdAtCol]);
    List<ToDo> todoList = [];
    for (int i = 0; i < maps.length; i++) {
      todoList.add(ToDo.fromJson(maps[i]));
    }
    return todoList;
  }

  Future<int> delete(int? id) async {
    var dbClient = await instance.db;
    return await dbClient!.delete(table, where: '$idCol = ?', whereArgs: [id]);
  }

  Future<int> update(ToDo toDo) async {
    var dbClient = await instance.db;
    return await dbClient!.update(table, toDo.toJson(),
        where: '$idCol = ?', whereArgs: [toDo.id]);
  }

  Future<ToDo?> show(int? id) async {
    var dbClient = await instance.db;
    List<Map<String, dynamic>> maps = await dbClient!.query(table, where: '$idCol = ?', whereArgs: [id], columns: [idCol, statusCol, labelCol, createdAtCol]);
    if (maps.isNotEmpty) {
      return ToDo.fromJson(maps[0]);
    } else {
      return null;
    }
  }

  Future close() async {
    var dbClient = await instance.db;
    dbClient!.close();
  }
}