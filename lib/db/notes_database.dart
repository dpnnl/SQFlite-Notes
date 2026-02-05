import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_notes/model/note.dart';

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();

  static Database? _database;

  NotesDatabase._init();

  // abrir db
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  // iniciar db
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // criar db
  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';

    final boolType = 'BOOLEAN NOT NULL';
    final intType = 'INTEGER NOT NULL';
    final textType = 'TEXT NOT NULL';

    await db.execute(
      'CREATE TABLE $tableNotes (${NoteFields.id} $idType, ${NoteFields.isImportant} $boolType, ${NoteFields.number} $intType, ${NoteFields.title} $textType, ${NoteFields.description} $textType, ${NoteFields.time} $textType)',
    );
  }

  // CRUD

  // criar/create
  // converte as notas para JSON e insere no banco de dados
  Future<Note> create(Note note) async {
    final db = await instance.database;

    /* 
    final json = note.toJson();
    final columns =
        '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    final values =
        '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';

    final id = await db.rawInsert(
      'INSERT INTO table_name ($columns) VALUES ($values)',
    ); */

    final id = await db.insert(tableNotes, note.toJson());

    return note.copy(id: id);
  }

  // ler/read
  // obtem as notas, converte do JSON
  Future<Note> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableNotes,
      columns: NoteFields.values,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromJson(maps.first);
    } else {
      throw Exception('ID $id não encontrado');
    }
  }

  // ler todas as notas
  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${NoteFields.isImportant} DESC, ${NoteFields.time} ASC';
    final result = await db.query(tableNotes, orderBy: orderBy);

    return result.map((json) => Note.fromJson(json)).toList();
  }

  // pesquisar notas
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;

    final result = await db.query(
      tableNotes,
      where: '${NoteFields.title} LIKE ? OR ${NoteFields.description} LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );

    return result.map((json) => Note.fromJson(json)).toList();
  }

  // atualizar/update
  Future<int> update(Note note) async {
    final db = await instance.database;

    return db.update(
      tableNotes,
      note.toJson(),
      where: '${NoteFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  // deletar/delete
  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  // fechar db
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
