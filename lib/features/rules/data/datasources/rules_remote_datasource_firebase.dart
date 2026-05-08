import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/rules/data/datasources/rules_remote_datasource.dart';
import 'package:myapp/features/rules/data/models/platform_rule_model.dart';

class RulesRemoteDataSourceFirebase implements RulesRemoteDataSource {
  final FirebaseDatabase _database;

  RulesRemoteDataSourceFirebase({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  DatabaseReference get _rulesRef => _database.ref('platform_rules');

  @override
  Future<List<PlatformRuleModel>> getPlatformRules() async {
    try {
      final snapshot = await _rulesRef.orderByChild('order').get();
      if (!snapshot.exists) return [];

      final rules = <PlatformRuleModel>[];
      final map = snapshot.value is Map
          ? Map<String, dynamic>.from(snapshot.value as Map)
          : null;
      if (map != null) {
        map.forEach((key, value) {
          final data = Map<String, dynamic>.from(value as Map);
          rules.add(PlatformRuleModel.fromJson(key, data));
        });
      }
      rules.sort((a, b) => a.order.compareTo(b.order));
      return rules;
    } catch (e) {
      throw ServerException('Failed to load platform rules');
    }
  }
}
