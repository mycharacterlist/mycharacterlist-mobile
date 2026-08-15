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
      version: 3,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE anime_titles (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE archetypes (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE,
            created_at TEXT NOT NULL
          )
        ''');

        await database.execute('''
          CREATE TABLE grade_definitions (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE,
            max_value INTEGER NOT NULL CHECK (max_value > 0),
            position INTEGER NOT NULL UNIQUE CHECK (position > 0)
          )
        ''');

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

        await database.execute('''
          CREATE TABLE character_facts (
            id TEXT PRIMARY KEY,
            character_id TEXT NOT NULL,
            fact_key TEXT NOT NULL,
            fact_type TEXT NOT NULL
              CHECK (fact_type IN ('text', 'grade')),
            fact_value TEXT,
            numeric_value INTEGER,
            max_value INTEGER,
            FOREIGN KEY(character_id) REFERENCES characters(id)
              ON DELETE CASCADE,
            UNIQUE(character_id, fact_key),
            CHECK (
              (fact_type = 'text'
                AND fact_value IS NOT NULL
                AND numeric_value IS NULL
                AND max_value IS NULL)
              OR
              (fact_type = 'grade'
                AND fact_value IS NULL
                AND numeric_value IS NOT NULL
                AND max_value IS NOT NULL
                AND max_value > 0
                AND numeric_value BETWEEN 0 AND max_value)
            )
          )
        ''');

        await database.execute('''
          CREATE TABLE character_grades (
            id TEXT PRIMARY KEY,
            character_id TEXT NOT NULL,
            grade_definition_id TEXT NOT NULL,
            grade_value INTEGER NOT NULL,
            FOREIGN KEY(character_id) REFERENCES characters(id)
              ON DELETE CASCADE,
            FOREIGN KEY(grade_definition_id) REFERENCES grade_definitions(id),
            UNIQUE(character_id, grade_definition_id)
          )
        ''');

        await database.execute('''
          CREATE TABLE ranking_lists (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL COLLATE NOCASE UNIQUE,
            description TEXT NOT NULL,
            show_avatars INTEGER NOT NULL,
            color_value INTEGER NOT NULL DEFAULT 4285958909,
            list_order INTEGER NOT NULL DEFAULT 0,
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

        await _createRankingListPatchTables(database);

        await database.execute(
          'CREATE INDEX character_gallery_images_character_id_index '
          'ON character_gallery_images(character_id)',
        );

        await database.execute(
          'CREATE INDEX character_facts_character_id_index '
          'ON character_facts(character_id)',
        );

        await database.execute(
          'CREATE INDEX character_grades_character_id_index '
          'ON character_grades(character_id)',
        );

        await database.execute(
          'CREATE INDEX character_grades_definition_id_index '
          'ON character_grades(grade_definition_id)',
        );

        final now = DateTime.now().toIso8601String();
        const archetypes = [
          'Dandere',
          'Deredere',
          'Himedere',
          'Kuudere',
          'Tsundere',
          'Yandere',
        ];
        const gradeDefinitions = [
          ('appearance', 'Appearance', 10),
          ('character', 'Character', 10),
          ('outfit', 'Outfit', 10),
          ('haircut', 'Haircut', 10),
          ('eyes', 'Eyes', 10),
        ];

        for (final name in archetypes) {
          await database.insert('archetypes', {
            'id': name.toLowerCase(),
            'name': name,
            'created_at': now,
          });
        }

        for (var index = 0; index < gradeDefinitions.length; index++) {
          final definition = gradeDefinitions[index];
          await database.insert('grade_definitions', {
            'id': definition.$1,
            'name': definition.$2,
            'max_value': definition.$3,
            'position': index + 1,
          });
        }
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createRankingListPatchTables(database);
        }
        if (oldVersion < 3) {
          await _addRankingListOrderColumn(database);
          await _migratePatchEntriesToV3(database);
        }
      },
    );
  }

  Future<void> _addRankingListOrderColumn(Database database) async {
    final columns = await database.rawQuery('PRAGMA table_info(ranking_lists)');
    final hasOrderColumn = columns.any(
      (column) => column['name'] == 'list_order',
    );

    if (!hasOrderColumn) {
      await database.execute(
        'ALTER TABLE ranking_lists '
        'ADD COLUMN list_order INTEGER NOT NULL DEFAULT 0',
      );
    }

    final lists = await database.query(
      'ranking_lists',
      columns: ['id'],
      orderBy: 'created_at ASC',
    );

    for (var index = 0; index < lists.length; index++) {
      await database.update(
        'ranking_lists',
        {'list_order': index + 1},
        where: 'id = ?',
        whereArgs: [lists[index]['id']],
      );
    }
  }

  Future<void> _createRankingListPatchTables(Database database) async {
    await database.execute('''
      CREATE TABLE IF NOT EXISTS ranking_list_patches (
        id TEXT PRIMARY KEY,
        list_id TEXT NOT NULL,
        label TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY(list_id) REFERENCES ranking_lists(id) ON DELETE CASCADE
      )
    ''');

    await database.execute('''
      CREATE TABLE IF NOT EXISTS ranking_list_patch_entries (
        id TEXT PRIMARY KEY,
        patch_id TEXT NOT NULL,
        character_id TEXT NOT NULL,
        character_name TEXT NOT NULL,
        source_title TEXT NOT NULL,
        position INTEGER NOT NULL,
        UNIQUE(patch_id, character_id),
        UNIQUE(patch_id, position),
        FOREIGN KEY(patch_id) REFERENCES ranking_list_patches(id) ON DELETE CASCADE
      )
    ''');

    await database.execute(
      'CREATE INDEX IF NOT EXISTS ranking_list_patches_list_id_index '
      'ON ranking_list_patches(list_id)',
    );

    await database.execute(
      'CREATE INDEX IF NOT EXISTS ranking_list_patch_entries_patch_id_index '
      'ON ranking_list_patch_entries(patch_id)',
    );
  }

  Future<void> _migratePatchEntriesToV3(Database database) async {
    final tableExists = await database.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' "
      "AND name='ranking_list_patch_entries'",
    );

    if (tableExists.isEmpty) {
      return;
    }

    final columns = await database.rawQuery(
      'PRAGMA table_info(ranking_list_patch_entries)',
    );
    final hasSnapshotColumns = columns.any(
      (column) => column['name'] == 'character_name',
    );

    if (hasSnapshotColumns) {
      return;
    }

    await database.execute('''
      CREATE TABLE ranking_list_patch_entries_v3 (
        id TEXT PRIMARY KEY,
        patch_id TEXT NOT NULL,
        character_id TEXT NOT NULL,
        character_name TEXT NOT NULL DEFAULT '',
        source_title TEXT NOT NULL DEFAULT '',
        position INTEGER NOT NULL,
        UNIQUE(patch_id, character_id),
        UNIQUE(patch_id, position),
        FOREIGN KEY(patch_id) REFERENCES ranking_list_patches(id) ON DELETE CASCADE
      )
    ''');

    await database.execute('''
      INSERT INTO ranking_list_patch_entries_v3 (
        id, patch_id, character_id, character_name, source_title, position
      )
      SELECT id, patch_id, character_id, '', '', position
      FROM ranking_list_patch_entries
    ''');

    await database.execute('DROP TABLE ranking_list_patch_entries');
    await database.execute(
      'ALTER TABLE ranking_list_patch_entries_v3 '
      'RENAME TO ranking_list_patch_entries',
    );

    await database.execute(
      'CREATE INDEX IF NOT EXISTS ranking_list_patch_entries_patch_id_index '
      'ON ranking_list_patch_entries(patch_id)',
    );
  }
}
