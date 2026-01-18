import 'package:flutter_notes_taking_app_1/models/note.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

// Platform detection
// import 'dart:io' show Platform;

import 'package:universal_io/io.dart'; // Works on web + native

// FFI import at the TOP - conditional based on platform
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal() {
    _initializeDatabase();
  }

  static Database? _database;

  Future<void> _initializeDatabase() async {
    // Only initialize FFI for desktop platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      await _initializeFfiSimple();
    }
  }

  Future<void> _initializeFfiSimple() async {
    try {
      // Direct import (simpler but may cause issues on mobile)

      ffi.sqfliteFfiInit();
      databaseFactory = ffi.databaseFactoryFfi;
    } catch (e) {
      print('FFI initialization skipped: $e');
      // Continue with default factory
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), "notes.db");
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute(
      "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT,title TEXT NOT NULL,content TEXT NOT NULL,createdAt INTEGER NOT NULL,updatedAt INTEGER NOT NULL,colorHex TEXT)",
    );
  }

  // ... keep your existing CRUD operations exactly as they were
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert("notes", note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "notes",
      orderBy: "updatedAt DESC",
    );
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  Future<Note?> getNote(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      "notes",
      where: "id = ?",
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      "notes",
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete("notes", where: "id = ?", whereArgs: [id]);
  }
}
