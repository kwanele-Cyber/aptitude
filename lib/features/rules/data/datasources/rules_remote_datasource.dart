import 'package:myapp/features/rules/data/models/platform_rule_model.dart';

abstract class RulesRemoteDataSource {
  Future<List<PlatformRuleModel>> getPlatformRules();
}

