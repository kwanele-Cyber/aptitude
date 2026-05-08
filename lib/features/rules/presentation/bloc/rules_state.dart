import 'package:equatable/equatable.dart';
import 'package:myapp/features/rules/domain/entities/platform_rule_entity.dart';

abstract class RulesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RulesInitial extends RulesState {}

class RulesLoading extends RulesState {}

class RulesLoaded extends RulesState {
  final List<PlatformRuleEntity> rules;
  RulesLoaded({required this.rules});

  @override
  List<Object?> get props => [rules];
}

class RulesError extends RulesState {
  final String message;
  RulesError({required this.message});

  @override
  List<Object?> get props => [message];
}
