import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class Hymn {
  int number;
  String words;
  bool favorite;

  Hymn(this.words, this.number, {this.favorite = false});

  @override
  String toString() {
    return 'Hymn $number\n$words';
  }
}

Future<String> _prepareDb() async {
  final docs = await getApplicationDocumentsDirectory();
  final dbFile = File('${docs.path}/hymns.db');

  return dbFile.path;
}

Future<Hymn?> grabHymn(int n) async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final ResultSet rs = db.select('SELECT * FROM hymn WHERE number = ?', [n]);
    if (rs.isEmpty) return null;
    final row = rs.first;
    return Hymn(row['words'] as String, row['number'] as int);
  } finally {
    db.close();
  }
}

Future<bool> saveHymn(int hymnNumber, String words) async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final stmt = db.prepare('''
INSERT INTO hymn (number, words)
VALUES (?, ?)
ON CONFLICT (number)
DO UPDATE SET
    words = excluded.words;''');
    stmt.execute([hymnNumber, words]);
    stmt.close();
  } on ArgumentError {
    return false;
  } finally {
    db.close();
  }
  return true;
}

Future<bool> replaceHymn(int hymnNumber, String words) async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final stmt = db.prepare('''
INSERT INTO hymn (number, words)
VALUES (?, ?)
ON CONFLICT (number)
DO UPDATE SET
    words = excluded.words;''');
    stmt.execute([hymnNumber, words]);
    stmt.close();
  } on ArgumentError {
    return false;
  } finally {
    db.close();
  }
  return true;
}

/// Creates the favorite table if it doesn't exist.
/// The favorite table stores hymn numbers that are marked as favorites.
/// Call this once on app startup.
Future<void> createFavoriteTable() async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    db.execute('''
      CREATE TABLE IF NOT EXISTS favorite (
        hymn_number INTEGER PRIMARY KEY,
        FOREIGN KEY (hymn_number) REFERENCES hymn(number) ON DELETE CASCADE
      )
    ''');
  } finally {
    db.close();
  }
}

/// Checks if a hymn is marked as favorite.
Future<bool> isFavorite(int hymnNumber) async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final ResultSet rs = db.select(
      'SELECT hymn_number FROM favorite WHERE hymn_number = ?',
      [hymnNumber],
    );
    return rs.isNotEmpty;
  } finally {
    db.close();
  }
}

/// Adds a hymn to favorites.
Future<bool> addFavorite(int hymnNumber) async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final stmt = db.prepare(
      'INSERT OR IGNORE INTO favorite (hymn_number) VALUES (?)',
    );
    stmt.execute([hymnNumber]);
    stmt.close();
    return true;
  } on ArgumentError {
    return false;
  } finally {
    db.close();
  }
}

/// Removes a hymn from favorites.
Future<bool> removeFavorite(int hymnNumber) async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final stmt = db.prepare(
      'DELETE FROM favorite WHERE hymn_number = ?',
    );
    stmt.execute([hymnNumber]);
    stmt.close();
    return true;
  } on ArgumentError {
    return false;
  } finally {
    db.close();
  }
}

/// Toggles the favorite status for a hymn.
Future<bool> toggleFavorite(int hymnNumber) async {
  final isFav = await isFavorite(hymnNumber);
  if (isFav) {
    return await removeFavorite(hymnNumber);
  } else {
    return await addFavorite(hymnNumber);
  }
}

/// Returns all favorite hymns.
Future<List<Hymn>> getFavoriteHymns() async {
  final path = await _prepareDb();
  final db = sqlite3.open(path);
  try {
    final ResultSet rs = db.select('''
      SELECT *
      FROM hymn h
      INNER JOIN favorite f ON h.number = f.hymn_number
      ORDER BY h.number
    ''');
    return rs.map((row) {
      return Hymn(
        row['words'] as String,
        row['number'] as int,
        favorite: true,
      );
    }).toList();
  } finally {
    db.close();
  }
}

/// Fetches a hymn and includes its favorite status.
Future<Hymn?> grabHymnWithFavorite(int n) async {
  final hymn = await grabHymn(n);
  if (hymn == null) return null;
  
  final isFav = await isFavorite(n);
  return Hymn(hymn.words, hymn.number, favorite: isFav);
}