import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/data/models/report_model.dart';
import 'package:myapp/core/error/app_exception.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class ReportRepository {
  final String _path = "reports";
  late final DatabaseService<DataSnapshot> _databaseService;

  ReportRepository({DatabaseService<DataSnapshot>? databaseService}) {
    _databaseService = databaseService ?? FirebaseService();
  }

  Future<void> submitReport(ReportModel report) async {
    try {
      await _databaseService.create(
        location: "$_path/${report.id}",
        data: report.toJson(),
      );
    } catch (e) {
      throw ChatException('Failed to submit report', ErrorCode.databaseError, e);
    }
  }
}
