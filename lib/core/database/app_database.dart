import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    final existingDatabase = _database;

    if (existingDatabase != null) {
      return existingDatabase;
    }

    final openedDatabase = await _openDatabase();
    _database = openedDatabase;

    return openedDatabase;
  }

  Future<Database> _openDatabase() async {
    final documentsDirectory = await path_provider
        .getApplicationDocumentsDirectory();
    final databasePath = '${documentsDirectory.path}/mycharacterlist.sqlite';

    return openDatabase(
      databasePath,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE characters (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            source_title TEXT NOT NULL,
            description TEXT NOT NULL,
            age TEXT NOT NULL,
            height TEXT NOT NULL,
            japanese_name TEXT NOT NULL,
            archetype TEXT NOT NULL,
            gender TEXT NOT NULL DEFAULT 'unknown'
              CHECK (gender IN ('female', 'male', 'unknown')),
            personal_notes TEXT NOT NULL,
            main_image_path TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE character_gallery_images (
            id TEXT PRIMARY KEY,
            character_id TEXT NOT NULL,
            image_path TEXT NOT NULL,
            position INTEGER NOT NULL,
            FOREIGN KEY(character_id) REFERENCES characters(id)
              ON DELETE CASCADE,
            UNIQUE(character_id, position)
          )
        ''');

        // TODO: Add custom text attributes.
        // await database.execute('''
        //   CREATE TABLE character_facts (
        //     id TEXT PRIMARY KEY,
        //     character_id TEXT NOT NULL,
        //     fact_key TEXT NOT NULL,
        //     fact_value TEXT NOT NULL,
        //     FOREIGN KEY(character_id) REFERENCES characters(id)
        //       ON DELETE CASCADE,
        //     UNIQUE(character_id, fact_key)
        //   )
        // ''');

        await database.execute('''
          CREATE TABLE character_grades (
            id TEXT PRIMARY KEY,
            character_id TEXT NOT NULL,
            grade_key TEXT NOT NULL,
            grade_value INTEGER NOT NULL,
            FOREIGN KEY(character_id) REFERENCES characters(id)
              ON DELETE CASCADE,
            UNIQUE(character_id, grade_key)
          )
        ''');

        await database.execute('''
          CREATE TABLE ranking_lists (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE,
            description TEXT NOT NULL,
            show_avatars INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE ranked_characters (
            id TEXT PRIMARY KEY,
            list_id TEXT NOT NULL,
            character_id TEXT NOT NULL,
            position INTEGER NOT NULL,
            added_at TEXT NOT NULL,
            UNIQUE(list_id, character_id),
            UNIQUE(list_id, position),
            FOREIGN KEY(list_id) REFERENCES ranking_lists(id) ON DELETE CASCADE,
            FOREIGN KEY(character_id) REFERENCES characters(id) ON DELETE CASCADE
          )
        ''');

        await database.execute(
          'CREATE INDEX ranked_characters_list_id_index '
          'ON ranked_characters(list_id)',
        );

        await database.execute(
          'CREATE INDEX ranked_characters_character_id_index '
          'ON ranked_characters(character_id)',
        );

        await database.execute(
          'CREATE INDEX character_gallery_images_character_id_index '
          'ON character_gallery_images(character_id)',
        );

        // await database.execute(
        //   'CREATE INDEX character_facts_character_id_index '
        //   'ON character_facts(character_id)',
        // );

        await database.execute(
          'CREATE INDEX character_grades_character_id_index '
          'ON character_grades(character_id)',
        );
      },
    );
  }
}
