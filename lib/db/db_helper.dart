import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/car_report.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;
  DbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'car_sell_reports.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE car_reports ADD COLUMN owner_name TEXT');
      await db.execute('ALTER TABLE car_reports ADD COLUMN owner_mobile TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE app_settings (
          key TEXT PRIMARY KEY,
          value TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute("ALTER TABLE car_reports ADD COLUMN status TEXT DEFAULT 'unsold'");
      await db.execute("ALTER TABLE car_reports ADD COLUMN customer_name TEXT");
      await db.execute("ALTER TABLE car_reports ADD COLUMN customer_mobile TEXT");
      await db.execute("ALTER TABLE car_reports ADD COLUMN customer_address TEXT");
      await db.execute("ALTER TABLE car_reports ADD COLUMN sold_price TEXT");
      await db.execute("ALTER TABLE car_reports ADD COLUMN sold_date TEXT");
      await db.execute("ALTER TABLE car_reports ADD COLUMN remarks TEXT");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE car_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model TEXT,
        owner TEXT,
        owner_name TEXT,
        owner_mobile TEXT,
        kilometers TEXT,
        vimo TEXT,
        body_dent_1 TEXT,
        body_dent_2 TEXT,
        body_dent_3 TEXT,
        body_dent_4 TEXT,
        dickey TEXT,
        door_1 TEXT,
        door_2 TEXT,
        door_3 TEXT,
        door_4 TEXT,
        touchup TEXT,
        ac TEXT,
        interior TEXT,
        engine_line TEXT,
        engine_oil_check TEXT,
        engine_smoke TEXT,
        engine_noise TEXT,
        driving_condition TEXT,
        suspension TEXT,
        pickup TEXT,
        brake TEXT,
        gear TEXT,
        starting_condition TEXT,
        glass_1 TEXT,
        glass_2 TEXT,
        glass_3 TEXT,
        glass_4 TEXT,
        fender_driver TEXT,
        fender_passenger TEXT,
        bonnet_inside TEXT,
        bonnet_outside TEXT,
        status TEXT DEFAULT 'unsold',
        customer_name TEXT,
        customer_mobile TEXT,
        customer_address TEXT,
        sold_price TEXT,
        sold_date TEXT,
        remarks TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE report_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER,
        image_path TEXT,
        label TEXT,
        FOREIGN KEY (report_id) REFERENCES car_reports (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // Insert a full report and its images
  Future<int> insertReport(CarReport report) async {
    final db = await database;
    return await db.transaction((txn) async {
      // 1. Insert the report
      final reportId = await txn.insert(
        'car_reports',
        report.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Insert all images associated with the report
      for (final image in report.images) {
        final imageMap = image.toMap();
        imageMap['report_id'] = reportId;
        await txn.insert(
          'report_images',
          imageMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      return reportId;
    });
  }

  // Get all reports, optionally filtered by query (model or owner)
  Future<List<CarReport>> getAllReports({String? query}) async {
    final db = await database;
    
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'car_reports',
        where: 'model LIKE ? OR owner LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query('car_reports', orderBy: 'id DESC');
    }

    final List<CarReport> reports = [];
    for (final map in maps) {
      final reportId = map['id'] as int;
      // Get images for this report
      final imgMaps = await db.query(
        'report_images',
        where: 'report_id = ?',
        whereArgs: [reportId],
      );
      final images = imgMaps.map((e) => ReportImage.fromMap(e)).toList();
      reports.add(CarReport.fromMap(map, images: images));
    }
    return reports;
  }

  // Get reports by status (unsold or sold), filtered by query
  Future<List<CarReport>> getReportsByStatus({required String status, String? query}) async {
    final db = await database;
    
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'car_reports',
        where: 'status = ? AND (model LIKE ? OR owner LIKE ?)',
        whereArgs: [status, '%$query%', '%$query%'],
        orderBy: 'id DESC',
      );
    } else {
      maps = await db.query(
        'car_reports',
        where: 'status = ?',
        whereArgs: [status],
        orderBy: 'id DESC',
      );
    }

    final List<CarReport> reports = [];
    for (final map in maps) {
      final reportId = map['id'] as int;
      final imgMaps = await db.query(
        'report_images',
        where: 'report_id = ?',
        whereArgs: [reportId],
      );
      final images = imgMaps.map((e) => ReportImage.fromMap(e)).toList();
      reports.add(CarReport.fromMap(map, images: images));
    }
    return reports;
  }

  // Get a single report by ID
  Future<CarReport?> getReportById(int id) async {
    final db = await database;
    final maps = await db.query(
      'car_reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    final imgMaps = await db.query(
      'report_images',
      where: 'report_id = ?',
      whereArgs: [id],
    );
    final images = imgMaps.map((e) => ReportImage.fromMap(e)).toList();
    return CarReport.fromMap(maps.first, images: images);
  }

  // Delete a report (and cascading images)
  Future<int> deleteReport(int id) async {
    final db = await database;
    return await db.delete(
      'car_reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a report and its associated images in a transaction
  Future<void> updateReport(CarReport report) async {
    final db = await database;
    await db.transaction((txn) async {
      // 1. Update the report details
      await txn.update(
        'car_reports',
        report.toMap(),
        where: 'id = ?',
        whereArgs: [report.id],
      );

      // 2. Delete all existing images for this report
      await txn.delete(
        'report_images',
        where: 'report_id = ?',
        whereArgs: [report.id],
      );

      // 3. Insert the updated list of images
      for (final image in report.images) {
        final imageMap = image.toMap();
        imageMap['report_id'] = report.id;
        // Strip the internal SQLite ID to prevent primary key conflicts
        imageMap.remove('id');
        await txn.insert(
          'report_images',
          imageMap,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // App settings helpers
  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }

  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
  }
}
