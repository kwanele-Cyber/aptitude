import 'package:myapp/core/data/repositories/request_repository.dart';

class AcceptRequestUseCase {
  Future<void> execute({required String requestId}) async {
    final requestRepo = RequestRepository();

    await requestRepo.update("requests/$requestId", {"status": "accepted"});
  }
}
