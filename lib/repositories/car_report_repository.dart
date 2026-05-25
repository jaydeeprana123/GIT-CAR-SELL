import '../db/db_helper.dart';
import '../models/car_report.dart';

class CarReportRepository {
  final DbHelper _dbHelper;

  CarReportRepository({DbHelper? dbHelper}) : _dbHelper = dbHelper ?? DbHelper();

  /// Retrieve all reports, optionally filtered by a search query.
  Future<List<CarReport>> getAllReports({String? query}) {
    return _dbHelper.getAllReports(query: query);
  }

  /// Retrieve a specific report by its ID.
  Future<CarReport?> getReportById(int id) {
    return _dbHelper.getReportById(id);
  }

  /// Insert a new report.
  Future<int> insertReport(CarReport report) {
    return _dbHelper.insertReport(report);
  }

  /// Update an existing report details.
  Future<void> updateReport(CarReport report) {
    return _dbHelper.updateReport(report);
  }

  /// Delete a report.
  Future<int> deleteReport(int id) {
    return _dbHelper.deleteReport(id);
  }
}
