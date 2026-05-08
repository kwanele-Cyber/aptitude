import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/trust/domain/repository/trust_repository.dart';

class FilterByTrustUseCase {
  final TrustRepository repository;
  FilterByTrustUseCase({required this.repository});

  Future<Either<Failure, List<String>>> call(
      FilterByTrustParams params) async {
    return repository.getUsersAboveTrustThreshold(params.threshold);
  }
}

class FilterByTrustParams extends Equatable {
  final int threshold;
  const FilterByTrustParams({required this.threshold});

  @override
  List<Object?> get props => [threshold];
}
