import 'package:equatable/equatable.dart';

abstract class RulesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPlatformRulesRequested extends RulesEvent {}
