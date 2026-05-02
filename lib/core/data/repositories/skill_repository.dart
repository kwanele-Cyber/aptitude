import 'package:myapp/core/data/models/skill.dart';
import 'package:myapp/core/services/firebase_service.dart';
import 'package:myapp/core/services/interfaces/database_inteface.dart';

class SkillRepository {
  FirebaseService Service = FirebaseService();
  String Tablename = "skills";

  Future<void> create({required Skill data}) async {
    await Service.create(location: "$Tablename/${data.sid}", data: data.toJson());
    return;
  }

  Future<void> delete({required String location}) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  Future<Skill?> read({required String location}) {
    // TODO: implement read
    throw UnimplementedError();
  }

  Future<void> update({
    required String location,
    required Map<String, dynamic> data,
  }) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
