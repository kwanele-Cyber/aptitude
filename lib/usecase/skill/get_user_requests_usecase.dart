import 'package:myapp/core/data/repositories/request_repository.dart';

class GetUserRequestsUseCase {
  Future<List<dynamic>> execute({required String requesterId}) async {
    final requestRepo = RequestRepository();

    final allRequests = await requestRepo.readAll("requests");

    // Filter requests for this specific user
    return allRequests.where((req) {
      return req["requesterId"] == requesterId;
    }).toList();
  }
}
