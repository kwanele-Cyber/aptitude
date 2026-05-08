import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myapp/features/agreement/domain/entity/agreement_entity.dart';
import 'package:myapp/features/agreement/domain/usecases/agreement_usecases.dart';

// Events
abstract class AgreementEvent extends Equatable {
  const AgreementEvent();
  @override
  List<Object?> get props => [];
}

class CreateAgreementEvent extends AgreementEvent {
  final AgreementEntity agreement;
  const CreateAgreementEvent(this.agreement);
  @override
  List<Object?> get props => [agreement];
}

class LoadAgreementEvent extends AgreementEvent {
  final String id;
  const LoadAgreementEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class LoadUserAgreementsEvent extends AgreementEvent {
  final String userId;
  const LoadUserAgreementsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class AcceptAgreementEvent extends AgreementEvent {
  final String id;
  const AcceptAgreementEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class DeclineAgreementEvent extends AgreementEvent {
  final String id;
  final String? reason;
  const DeclineAgreementEvent(this.id, {this.reason});
  @override
  List<Object?> get props => [id, reason];
}

class ProposeModificationsEvent extends AgreementEvent {
  final String id;
  final Map<String, dynamic> modifications;
  final String notes;
  const ProposeModificationsEvent(this.id, this.modifications, this.notes);
  @override
  List<Object?> get props => [id, modifications, notes];
}

class AcceptModificationsEvent extends AgreementEvent {
  final String id;
  const AcceptModificationsEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class DeclineModificationsEvent extends AgreementEvent {
  final String id;
  const DeclineModificationsEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class CancelAgreementEvent extends AgreementEvent {
  final String id;
  final String reason;
  const CancelAgreementEvent(this.id, this.reason);
  @override
  List<Object?> get props => [id, reason];
}

class CompleteAgreementEvent extends AgreementEvent {
  final String id;
  const CompleteAgreementEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class WatchAgreementEvent extends AgreementEvent {
  final String id;
  const WatchAgreementEvent(this.id);
  @override
  List<Object?> get props => [id];
}

class WatchUserAgreementsEvent extends AgreementEvent {
  final String userId;
  const WatchUserAgreementsEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

// States
abstract class AgreementState extends Equatable {
  const AgreementState();
  @override
  List<Object?> get props => [];
}

class AgreementInitial extends AgreementState {}

class AgreementLoading extends AgreementState {}

class AgreementLoaded extends AgreementState {
  final AgreementEntity agreement;
  const AgreementLoaded(this.agreement);
  @override
  List<Object?> get props => [agreement];
}

class AgreementsLoaded extends AgreementState {
  final List<AgreementEntity> agreements;
  const AgreementsLoaded(this.agreements);
  @override
  List<Object?> get props => [agreements];
}

class AgreementOperationSuccess extends AgreementState {
  final String message;
  const AgreementOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AgreementError extends AgreementState {
  final String message;
  const AgreementError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class AgreementBloc extends Bloc<AgreementEvent, AgreementState> {
  final CreateAgreementUseCase createAgreement;
  final GetAgreementUseCase getAgreement;
  final GetUserAgreementsUseCase getUserAgreements;
  final AcceptAgreementUseCase acceptAgreement;
  final DeclineAgreementUseCase declineAgreement;
  final ProposeModificationsUseCase proposeModifications;
  final AcceptModificationsUseCase acceptModifications;
  final DeclineModificationsUseCase declineModifications;
  final CancelAgreementUseCase cancelAgreement;
  final CompleteAgreementUseCase completeAgreement;
  final WatchAgreementUseCase watchAgreement;
  final WatchUserAgreementsUseCase watchUserAgreements;

  StreamSubscription? _agreementSubscription;
  StreamSubscription? _userAgreementsSubscription;

  AgreementBloc({
    required this.createAgreement,
    required this.getAgreement,
    required this.getUserAgreements,
    required this.acceptAgreement,
    required this.declineAgreement,
    required this.proposeModifications,
    required this.acceptModifications,
    required this.declineModifications,
    required this.cancelAgreement,
    required this.completeAgreement,
    required this.watchAgreement,
    required this.watchUserAgreements,
  }) : super(AgreementInitial()) {
    on<CreateAgreementEvent>(_onCreateAgreement);
    on<LoadAgreementEvent>(_onLoadAgreement);
    on<LoadUserAgreementsEvent>(_onLoadUserAgreements);
    on<AcceptAgreementEvent>(_onAcceptAgreement);
    on<DeclineAgreementEvent>(_onDeclineAgreement);
    on<ProposeModificationsEvent>(_onProposeModifications);
    on<AcceptModificationsEvent>(_onAcceptModifications);
    on<DeclineModificationsEvent>(_onDeclineModifications);
    on<CancelAgreementEvent>(_onCancelAgreement);
    on<CompleteAgreementEvent>(_onCompleteAgreement);
    on<WatchAgreementEvent>(_onWatchAgreement);
    on<WatchUserAgreementsEvent>(_onWatchUserAgreements);
  }

  Future<void> _onCreateAgreement(CreateAgreementEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await createAgreement(event.agreement);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to create agreement')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onLoadAgreement(LoadAgreementEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await getAgreement(event.id);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to load agreement')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onLoadUserAgreements(LoadUserAgreementsEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await getUserAgreements(event.userId);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to load agreements')),
      (agreements) => emit(AgreementsLoaded(agreements)),
    );
  }

  Future<void> _onAcceptAgreement(AcceptAgreementEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await acceptAgreement(event.id);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to accept agreement')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onDeclineAgreement(DeclineAgreementEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await declineAgreement(event.id, reason: event.reason);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to decline agreement')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onProposeModifications(ProposeModificationsEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await proposeModifications(event.id, event.modifications, event.notes);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to propose modifications')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onAcceptModifications(AcceptModificationsEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await acceptModifications(event.id);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to accept modifications')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onDeclineModifications(DeclineModificationsEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await declineModifications(event.id);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to decline modifications')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onCancelAgreement(CancelAgreementEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await cancelAgreement(event.id, event.reason);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to cancel agreement')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  Future<void> _onCompleteAgreement(CompleteAgreementEvent event, Emitter<AgreementState> emit) async {
    emit(AgreementLoading());
    final result = await completeAgreement(event.id);
    result.fold(
      (failure) => emit(AgreementError(failure.message ?? 'Failed to complete agreement')),
      (agreement) => emit(AgreementLoaded(agreement)),
    );
  }

  void _onWatchAgreement(WatchAgreementEvent event, Emitter<AgreementState> emit) {
    _agreementSubscription?.cancel();
    _agreementSubscription = watchAgreement(event.id).listen(
      (result) => result.fold(
        (failure) => add(AgreementErrorEvent(failure.message ?? 'Watch failed')),
        (agreement) => add(AgreementUpdatedEvent(agreement)),
      ),
    );
  }

  void _onWatchUserAgreements(WatchUserAgreementsEvent event, Emitter<AgreementState> emit) {
    _userAgreementsSubscription?.cancel();
    _userAgreementsSubscription = watchUserAgreements(event.userId).listen(
      (result) => result.fold(
        (failure) => add(AgreementErrorEvent(failure.message ?? 'Watch failed')),
        (agreements) => add(UserAgreementsUpdatedEvent(agreements)),
      ),
    );
  }

  @override
  Future<void> close() {
    _agreementSubscription?.cancel();
    _userAgreementsSubscription?.cancel();
    return super.close();
  }
}

// Helper events/state for real-time updates
class AgreementUpdatedEvent extends AgreementEvent {
  final AgreementEntity agreement;
  const AgreementUpdatedEvent(this.agreement);
}

class UserAgreementsUpdatedEvent extends AgreementEvent {
  final List<AgreementEntity> agreements;
  const UserAgreementsUpdatedEvent(this.agreements);
}

class AgreementErrorEvent extends AgreementEvent {
  final String message;
  const AgreementErrorEvent(this.message);
}