import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../colmi_client.dart';

/// Sync all data from the ring to a SQLite database
/// This is a comprehensive sync function that fetches all data
/// between [startDate] and [endDate]
Future<void> syncToDatabase(
    String deviceId, {
      DateTime? startDate,
      DateTime? endDate,
      String? databasePath,
    }) async {
  // Set default dates
  final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
  final end = endDate ?? DateTime.now();

  print('Syncing from $start to $end');

  // Open or create database
  final dbPath = databasePath ??
      join(await getDatabasesPath(), 'ring_data.db');
  final db = await openDatabase(
    dbPath,
    version: 1,
    onCreate: _createTables,
  );

  try {
    final client = ColmiClient(deviceId);
    await client.connect();

    try {
      // Sync heart rate data
      await _syncHeartRateData(db, client, deviceId, start, end);

      // Sync step data
      await _syncStepData(db, client, deviceId, start, end);

      // Update time on ring
      await client.setTime(DateTime.now().toUtc());

      print('Sync completed successfully');
    } finally {
      await client.disconnect();
    }
  } finally {
    await db.close();
  }
}

Future<void> _createTables(Database db, int version) async {
  await db.execute('''
    CREATE TABLE rings (
      ring_id INTEGER PRIMARY KEY AUTOINCREMENT,
      address TEXT UNIQUE NOT NULL
    )
  ''');

  await db.execute('''
    CREATE TABLE heart_rates (
      heart_rate_id INTEGER PRIMARY KEY AUTOINCREMENT,
      ring_id INTEGER NOT NULL,
      reading INTEGER NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (ring_id) REFERENCES rings (ring_id),
      UNIQUE (ring_id, timestamp)
    )
  ''');

  await db.execute('''
    CREATE TABLE sport_details (
      sport_detail_id INTEGER PRIMARY KEY AUTOINCREMENT,
      ring_id INTEGER NOT NULL,
      calories INTEGER NOT NULL,
      steps INTEGER NOT NULL,
      distance INTEGER NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (ring_id) REFERENCES rings (ring_id),
      UNIQUE (ring_id, timestamp)
    )
  ''');
}

Future<int> _getOrCreateRingId(Database db, String address) async {
  final existing = await db.query(
    'rings',
    where: 'address = ?',
    whereArgs: [address],
  );

  if (existing.isNotEmpty) {
    return existing.first['ring_id'] as int;
  }

  return await db.insert('rings', {'address': address});
}

Future<void> _syncHeartRateData(
    Database db,
    ColmiClient client,
    String deviceId,
    DateTime start,
    DateTime end,
    ) async {
  final ringId = await _getOrCreateRingId(db, deviceId);

  for (var date = start;
  date.isBefore(end) || date.isAtSameMomentAs(end);
  date = date.add(const Duration(days: 1))) {

    final log = await client.getHeartRateLog(date);
    if (log == null) continue;

    final readings = log.heartRatesWithTimes();
    for (var reading in readings) {
      if (reading.reading == 0) continue;

      await db.insert(
        'heart_rates',
        {
          'ring_id': ringId,
          'reading': reading.reading,
          'timestamp': reading.timestamp.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('Synced heart rate for ${date.toIso8601String()}');
  }
}

Future<void> _syncStepData(
    Database db,
    ColmiClient client,
    String deviceId,
    DateTime start,
    DateTime end,
    ) async {
  final ringId = await _getOrCreateRingId(db, deviceId);

  for (var date = start;
  date.isBefore(end) || date.isAtSameMomentAs(end);
  date = date.add(const Duration(days: 1))) {

    final sportDetails = await client.getSteps(date);
    if (sportDetails == null) continue;

    for (var detail in sportDetails) {
      await db.insert(
        'sport_details',
        {
          'ring_id': ringId,
          'calories': detail.calories,
          'steps': detail.steps,
          'distance': detail.distance,
          'timestamp': detail.timestamp.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('Synced steps for ${date.toIso8601String()}');
  }
}

/// Example usage:
/// ```dart
/// await syncToDatabase(
///   'XX:XX:XX:XX:XX:XX',
///   startDate: DateTime(2024, 12, 1),
///   endDate: DateTime(2024, 12, 13),
/// );
/// ```