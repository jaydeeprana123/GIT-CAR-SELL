import 'package:get/get.dart';
import '../models/car_report.dart';
import '../repositories/car_report_repository.dart';

class CarReportController extends GetxController {
  final CarReportRepository repository;

  CarReportController({required this.repository});

  // Reactive state variables
  final RxList<CarReport> reports = <CarReport>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  /// Fetch all reports from the repository based on the current search query
  Future<void> fetchReports() async {
    isLoading.value = true;
    try {
      final list = await repository.getAllReports(query: searchQuery.value);
      reports.assignAll(list);
    } catch (e) {
      Get.log('Error fetching reports: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update search query and load reports
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    fetchReports();
  }

  /// Add a new inspection report
  Future<bool> addReport(CarReport report) async {
    isLoading.value = true;
    try {
      await repository.insertReport(report);
      await fetchReports();
      return true;
    } catch (e) {
      Get.log('Error adding report: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update an existing report
  Future<bool> updateReportData(CarReport report) async {
    isLoading.value = true;
    try {
      await repository.updateReport(report);
      await fetchReports();
      return true;
    } catch (e) {
      Get.log('Error updating report: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a report by ID
  Future<bool> deleteReportData(int id) async {
    isLoading.value = true;
    try {
      await repository.deleteReport(id);
      await fetchReports();
      return true;
    } catch (e) {
      Get.log('Error deleting report: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get a single report details by ID
  Future<CarReport?> getReportDetails(int id) async {
    try {
      return await repository.getReportById(id);
    } catch (e) {
      Get.log('Error getting report details: $e');
      return null;
    }
  }
}
