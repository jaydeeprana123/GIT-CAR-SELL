import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_report.dart';
import '../repositories/car_report_repository.dart';
import '../db/db_helper.dart';
import 'auth_controller.dart';

class CarReportController extends GetxController {
  final CarReportRepository repository;

  CarReportController({required this.repository});

  // Reactive state variables
  final RxList<CarReport> reports = <CarReport>[].obs; // Unsold cars (for backward compatibility)
  final RxList<CarReport> soldReports = <CarReport>[].obs; // Sold cars
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchReports();
  }

  /// Fetch all reports from the repository based on status and purchaseScheme
  Future<void> fetchReports() async {
    isLoading.value = true;
    try {
      // Unsold reports are always loaded from local SQFlite database
      final unsoldList = await repository.getReportsByStatus(status: 'unsold', query: searchQuery.value);
      reports.assignAll(unsoldList);

      // Determine purchase scheme to decide sold cars data source
      final authController = Get.find<AuthController>();
      final companyDoc = authController.currentCompanyModel.value;
      final localCompanyScheme = await DbHelper().getSetting('purchaseScheme');
      final isOnlineScheme = (companyDoc?.purchaseScheme == 'online') || (localCompanyScheme == 'online');

      if (isOnlineScheme) {
        // Load sold cars from Firebase Firestore
        final companyId = companyDoc?.companyId ?? authController.localCompanyId.value;
        if (companyId.isNotEmpty) {
          final snapshot = await FirebaseFirestore.instance
              .collection('sold_cars')
              .where('companyId', isEqualTo: companyId)
              .get();

          final firestoreSoldList = snapshot.docs.map((doc) {
            final data = doc.data();
            return CarReport(
              id: data['carId'] as int?,
              model: data['model'] ?? '',
              owner: data['owner'] ?? '',
              ownerName: '',
              ownerMobile: '',
              kilometers: data['kilometers'] ?? '',
              vimo: '',
              bodyDent1: '',
              bodyDent2: '',
              bodyDent3: '',
              bodyDent4: '',
              dickey: '',
              door1: '',
              door2: '',
              door3: '',
              door4: '',
              touchup: '',
              ac: '',
              interior: '',
              engineLine: '',
              engineOilCheck: '',
              engineSmoke: '',
              engineNoise: '',
              drivingCondition: '',
              suspension: '',
              pickup: '',
              brake: '',
              gear: '',
              startingCondition: '',
              glass1: '',
              glass2: '',
              glass3: '',
              glass4: '',
              fenderDriver: '',
              fenderPassenger: '',
              bonnetInside: '',
              bonnetOutside: '',
              status: 'sold',
              customerName: data['customerName'],
              customerMobile: data['customerMobile'],
              customerAddress: data['customerAddress'],
              soldPrice: data['soldPrice'],
              soldDate: data['soldDate'],
              remarks: data['remarks'],
              createdAt: '',
              images: const [],
            );
          }).toList();

          // Sort soldDate descending
          firestoreSoldList.sort((a, b) => (b.soldDate ?? '').compareTo(a.soldDate ?? ''));

          // Perform local query filter if query exists
          if (searchQuery.value.isNotEmpty) {
            final query = searchQuery.value.toLowerCase();
            final filtered = firestoreSoldList.where((car) {
              return car.model.toLowerCase().contains(query) ||
                  car.owner.toLowerCase().contains(query) ||
                  (car.customerName ?? '').toLowerCase().contains(query);
            }).toList();
            soldReports.assignAll(filtered);
          } else {
            soldReports.assignAll(firestoreSoldList);
          }
        } else {
          soldReports.clear();
        }
      } else {
        // Load sold cars from local SQFlite database
        final soldList = await repository.getReportsByStatus(status: 'sold', query: searchQuery.value);
        soldReports.assignAll(soldList);
      }
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

  /// Mark an unsold car as sold
  Future<bool> markCarAsSold(
    int id, {
    required String customerName,
    required String customerMobile,
    required String customerAddress,
    required String soldPrice,
    required String soldDate,
    required String remarks,
  }) async {
    isLoading.value = true;
    try {
      // 1. Get the current report
      final report = await repository.getReportById(id);
      if (report == null) return false;

      // Business Rule: Only unsold cars can be marked sold, preventing duplicate selling
      if (report.status != 'unsold') {
        Get.log('આ ગાડી પહેલેથી વેચાઈ ગયેલ છે.');
        return false;
      }

      // 2. Update status and customer details locally
      final updatedReport = report.copyWith(
        status: 'sold',
        customerName: customerName,
        customerMobile: customerMobile,
        customerAddress: customerAddress,
        soldPrice: soldPrice,
        soldDate: soldDate,
        remarks: remarks,
      );
      await repository.updateReport(updatedReport);

      // 3. Sync to Firestore if the company's scheme is 'online'
      final authController = Get.find<AuthController>();
      final companyDoc = authController.currentCompanyModel.value;
      final localCompanyScheme = await DbHelper().getSetting('purchaseScheme');
      final isOnlineScheme = (companyDoc?.purchaseScheme == 'online') || (localCompanyScheme == 'online');

      if (isOnlineScheme) {
        final companyId = companyDoc?.companyId ?? authController.localCompanyId.value;
        final companyName = companyDoc?.companyName ?? authController.localCompanyName.value;
        
        await FirebaseFirestore.instance.collection('sold_cars').add({
          'companyId': companyId,
          'companyName': companyName,
          'carId': id,
          'model': report.model,
          'owner': report.owner,
          'kilometers': report.kilometers,
          'customerName': customerName,
          'customerMobile': customerMobile,
          'customerAddress': customerAddress,
          'soldPrice': soldPrice,
          'soldDate': soldDate,
          'remarks': remarks,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      }

      await fetchReports();
      return true;
    } catch (e) {
      Get.log('Error marking car as sold: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a sold car manually
  Future<bool> addManualSoldCar({
    required String model,
    required String owner,
    required String ownerName,
    required String ownerMobile,
    required String kilometers,
    required String customerName,
    required String customerMobile,
    required String customerAddress,
    required String soldPrice,
    required String soldDate,
    required String remarks,
  }) async {
    isLoading.value = true;
    try {
      // 1. Create a CarReport with status 'sold'
      final report = CarReport(
        model: model,
        owner: owner,
        ownerName: ownerName,
        ownerMobile: ownerMobile,
        kilometers: kilometers,
        vimo: '',
        bodyDent1: '',
        bodyDent2: '',
        bodyDent3: '',
        bodyDent4: '',
        dickey: '',
        door1: '',
        door2: '',
        door3: '',
        door4: '',
        touchup: '',
        ac: '',
        interior: '',
        engineLine: '',
        engineOilCheck: '',
        engineSmoke: '',
        engineNoise: '',
        drivingCondition: '',
        suspension: '',
        pickup: '',
        brake: '',
        gear: '',
        startingCondition: '',
        glass1: '',
        glass2: '',
        glass3: '',
        glass4: '',
        fenderDriver: '',
        fenderPassenger: '',
        bonnetInside: '',
        bonnetOutside: '',
        status: 'sold',
        customerName: customerName,
        customerMobile: customerMobile,
        customerAddress: customerAddress,
        soldPrice: soldPrice,
        soldDate: soldDate,
        remarks: remarks,
        createdAt: DateTime.now().toLocal().toString().split('.').first,
        images: const [],
      );

      // 2. Insert locally
      final id = await repository.insertReport(report);

      // 3. Upload to Firestore if scheme is online
      final authController = Get.find<AuthController>();
      final companyDoc = authController.currentCompanyModel.value;
      final localCompanyScheme = await DbHelper().getSetting('purchaseScheme');
      final isOnlineScheme = (companyDoc?.purchaseScheme == 'online') || (localCompanyScheme == 'online');

      if (isOnlineScheme) {
        final companyId = companyDoc?.companyId ?? authController.localCompanyId.value;
        final companyName = companyDoc?.companyName ?? authController.localCompanyName.value;
        
        await FirebaseFirestore.instance.collection('sold_cars').add({
          'companyId': companyId,
          'companyName': companyName,
          'carId': id,
          'model': model,
          'owner': owner,
          'kilometers': kilometers,
          'customerName': customerName,
          'customerMobile': customerMobile,
          'customerAddress': customerAddress,
          'soldPrice': soldPrice,
          'soldDate': soldDate,
          'remarks': remarks,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      }

      await fetchReports();
      return true;
    } catch (e) {
      Get.log('Error adding manual sold car: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
