import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/agreements/domain/usecases/accept_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/cancel_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/create_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/get_agreement_by_id_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/modify_agreement_usecase.dart';
import 'package:myapp/features/agreements/domain/usecases/view_agreements_usecase.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_event.dart';
import 'package:myapp/features/agreements/presentation/bloc/agreement_state.dart';

class AgreementBloc extends Bloc<AgreementEvent, AgreementState> {
  final CreateAgreementUseCase createAgreementUseCase;
  final AcceptAgreementUseCase acceptAgreementUseCase;
  final ModifyAgreementUseCase modifyAgreementUseCase;
  final CancelAgreementUseCase cancelAgreementUseCase;
  final ViewAgreementsUseCase viewAgreementsUseCase;
  final GetAgreementByIdUseCase getAgreementByIdUseCase;

  AgreementBloc({
    required this.createAgreementUseCase,
    required this.acceptAgreementUseCase,
    required this.modifyAgreementUseCase,
    required this.cancelAgreementUseCase,
    required this.viewAgreementsUseCase,
    required this.getAgreementByIdUseCase,
  }) : super(AgreementInitial()) {
    on<CreateAgreementRequested>(_onCreateAgreementRequested);
    on<AcceptAgreementRequested>(_onAcceptAgreementRequested);
    on<ModifyAgreementRequested>(_onModifyAgreementRequested);
    on<CancelAgreementRequested>(_onCancelAgreementRequested);
    on<FetchAgreementsRequested>(_onFetchAgreementsRequested);
    on<FetchAgreementByIdRequested>(_onFetchAgreementByIdRequested);
  }

  Future _onCreateAgreementRequested(
    CreateAgreementRequested event,
    Emitter<AgreementState> emit,
  ) async {
    emit(AgreementLoading());
    final result = await createAgreementUseCase(
      CreateAgreementParams(
        initiatorId: event.initiatorId,
        initiatorName: event.initiatorName,
        partnerId: event.partnerId,
        partnerName: event.partnerName,
        initiatorSkillId: event.initiatorSkillId,
        initiatorSkillTitle: event.initiatorSkillTitle,
        partnerSkillId: event.partnerSkillId,
        partnerSkillTitle: event.partnerSkillTitle,
        duration: event.duration,
        frequency: event.frequency,
        sessionsCount: event.sessionsCount,
        notes: event.notes,
      ),
    );

    await result.fold(
      (left) async {
        emit(AgreementError(message: 'Failed to create agreement'));
      },
      (right) async {
        emit(AgreementCreated(agreement: right));
      },
    );
  }

  Future _onAcceptAgreementRequested(
    AcceptAgreementRequested event,
    Emitter<AgreementState> emit,
  ) async {
    emit(AgreementLoading());
    final result = await acceptAgreementUseCase(
      AcceptAgreementParams(
        agreementId: event.agreementId,
        userId: event.userId,
      ),
    );

    await result.fold(
      (left) async {
        emit(AgreementError(message: 'Failed to accept agreement'));
      },
      (right) async {
        emit(AgreementActionSuccess(message: 'Agreement accepted'));
      },
    );
  }

  Future _onModifyAgreementRequested(
    ModifyAgreementRequested event,
    Emitter<AgreementState> emit,
  ) async {
    emit(AgreementLoading());
    final result = await modifyAgreementUseCase(
      ModifyAgreementParams(
        agreementId: event.agreementId,
        userId: event.userId,
        duration: event.duration,
        frequency: event.frequency,
        sessionsCount: event.sessionsCount,
        notes: event.notes,
      ),
    );

    await result.fold(
      (left) async {
        emit(AgreementError(message: 'Failed to modify agreement'));
      },
      (right) async {
        emit(AgreementDetailLoaded(agreement: right));
      },
    );
  }

  Future _onCancelAgreementRequested(
    CancelAgreementRequested event,
    Emitter<AgreementState> emit,
  ) async {
    emit(AgreementLoading());
    final result = await cancelAgreementUseCase(
      CancelAgreementParams(
        agreementId: event.agreementId,
        userId: event.userId,
      ),
    );

    await result.fold(
      (left) async {
        emit(AgreementError(message: 'Failed to cancel agreement'));
      },
      (right) async {
        emit(AgreementActionSuccess(message: 'Agreement cancelled'));
      },
    );
  }

  Future _onFetchAgreementsRequested(
    FetchAgreementsRequested event,
    Emitter<AgreementState> emit,
  ) async {
    emit(AgreementLoading());
    final result = await viewAgreementsUseCase(
      ViewAgreementsParams(userId: event.userId),
    );

    await result.fold(
      (left) async {
        emit(AgreementError(message: 'Failed to fetch agreements'));
      },
      (right) async {
        emit(AgreementsLoaded(agreements: right));
      },
    );
  }

  Future _onFetchAgreementByIdRequested(
    FetchAgreementByIdRequested event,
    Emitter<AgreementState> emit,
  ) async {
    emit(AgreementLoading());
    final result = await getAgreementByIdUseCase(
      GetAgreementByIdParams(agreementId: event.agreementId),
    );

    await result.fold(
      (left) async {
        emit(AgreementError(message: 'Failed to fetch agreement'));
      },
      (right) async {
        emit(AgreementDetailLoaded(agreement: right));
      },
    );
  }
}
