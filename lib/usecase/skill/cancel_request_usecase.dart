import 'package:myapp/core/data/repositories/request_repository.dart';

class CancelRequestUseCase {
  Future<void> execute({required String requestId}) async {
    final requestRepo = RequestRepository();

    await requestRepo.delete("requests/$requestId");
  }
}
