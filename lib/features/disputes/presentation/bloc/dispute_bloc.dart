import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/disputes/domain/entities/dispute_entity.dart';
import 'package:myapp/features/disputes/domain/usecases/appeal_decision_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/create_dispute_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/report_user_usecase.dart';
import 'package:myapp/features/disputes/domain/usecases/resolve_dispute_usecase.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_event.dart';
import 'package:myapp/features/disputes/presentation/bloc/dispute_state.dart';
import 'package:myapp/features/disputes/domain/repository/dispute_repository.dart';

class DisputeBloc extends Bloc<DisputeEvent, DisputeState> {
  final ReportUserUseCase reportUserUseCase;
  final CreateDisputeUseCase createDisputeUseCase;
  final ResolveDisputeUseCase resolveDisputeUseCase;
  final AppealDecisionUseCase appealDecisionUseCase;
  final DisputeRepository disputeRepository;

  DisputeBloc({
    required this.reportUserUseCase,
    required this.createDisputeUseCase,
    required this.resolveDisputeUseCase,
    required this.appealDecisionUseCase,
    required this.disputeRepository,
  }) : super(DisputeInitial()) {
    on<ReportUserRequested>(_onReportUserRequested);
    on<CreateDisputeRequested>(_onCreateDisputeRequested);
    on<ResolveDisputeRequested>(_onResolveDisputeRequested);
    on<AppealDecisionRequested>(_onAppealDecisionRequested);
    on<FetchDisputesRequested>(_onFetchDisputesRequested);
    on<FetchAllDisputesRequested>(_onFetchAllDisputesRequested);
    on<FetchDisputeByIdRequested>(_onFetchDisputeByIdRequested);
  }

  Future _onReportUserRequested(
    ReportUserRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final result = await reportUserUseCase(
      ReportUserParams(
        reporterId: event.reporterId,
        reporterName: event.reporterName,
        reportedUserId: event.reportedUserId,
        reportedUserName: event.reportedUserName,
        reason: event.reason,
        description: event.description,
        evidenceUrls: event.evidenceUrls,
      ),
    );

    await result.fold(
      (left) async {
        emit(DisputeError(message: 'Failed to submit report'));
      },
      (right) async {
        emit(DisputeReported(dispute: right));
      },
    );
  }

  Future _onCreateDisputeRequested(
    CreateDisputeRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final result = await createDisputeUseCase(
      CreateDisputeParams(
        reporterId: event.reporterId,
        reporterName: event.reporterName,
        respondentId: event.respondentId,
        reason: event.reason,
        description: event.description,
        agreementId: event.agreementId,
        sessionId: event.sessionId,
        evidenceUrls: event.evidenceUrls,
      ),
    );

    await result.fold(
      (left) async {
        emit(DisputeError(message: 'Failed to create dispute'));
      },
      (right) async {
        emit(DisputeCreated(dispute: right));
      },
    );
  }

  Future _onResolveDisputeRequested(
    ResolveDisputeRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final status = event.newStatus == 'resolved'
        ? DisputeStatus.resolved
        : DisputeStatus.dismissed;

    final result = await resolveDisputeUseCase(
      ResolveDisputeParams(
        disputeId: event.disputeId,
        resolution: event.resolution,
        resolvedBy: event.resolvedBy,
        status: status,
      ),
    );

    await result.fold(
      (left) async {
        emit(DisputeError(
            message: left.message ?? 'Failed to resolve dispute'));
      },
      (right) async {
        emit(DisputeResolved(dispute: right));
      },
    );
  }

  Future _onAppealDecisionRequested(
    AppealDecisionRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final result = await appealDecisionUseCase(
      AppealDecisionParams(
        disputeId: event.disputeId,
        appealReason: event.appealReason,
      ),
    );

    await result.fold(
      (left) async {
        emit(DisputeError(
            message: left.message ?? 'Failed to appeal decision'));
      },
      (right) async {
        emit(DisputeAppealed(dispute: right));
      },
    );
  }

  Future _onFetchDisputesRequested(
    FetchDisputesRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final result = await disputeRepository.getDisputesForUser(event.userId);

    await result.fold(
      (left) async {
        emit(DisputeError(message: 'Failed to fetch disputes'));
      },
      (right) async {
        emit(DisputesLoaded(disputes: right));
      },
    );
  }

  Future _onFetchAllDisputesRequested(
    FetchAllDisputesRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final result = await disputeRepository.getAllDisputes();

    await result.fold(
      (left) async {
        emit(DisputeError(message: 'Failed to fetch disputes'));
      },
      (right) async {
        emit(DisputesLoaded(disputes: right));
      },
    );
  }

  Future _onFetchDisputeByIdRequested(
    FetchDisputeByIdRequested event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    final result = await disputeRepository.getDisputeById(event.disputeId);

    await result.fold(
      (left) async {
        emit(DisputeError(message: 'Failed to fetch dispute'));
      },
      (right) async {
        emit(DisputeDetailLoaded(dispute: right));
      },
    );
  }
}
