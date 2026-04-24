import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/usecase/agreements/agreement_viewmodel.dart';
import 'package:myapp/core/repositories/agreement_repository.dart';
import 'package:myapp/core/models/agreement_model.dart';

class MockAgreementRepository extends Mock implements AgreementRepository {}

class FakeAgreementModel extends Fake implements AgreementModel {}

void main() {
  late AgreementViewModel viewModel;
  late MockAgreementRepository mockRepo;

  final agreement = AgreementModel(
    id: 'a1',
    learnerId: 'l1',
    mentorId: 'm1',
    learnerSkill: 'Java',
    mentorSkill: 'Python',
    frequency: 'Weekly',
    duration: 1.0,
    status: AgreementStatus.pending,
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRepo = MockAgreementRepository();
    viewModel = AgreementViewModel(mockRepo);
    
    registerFallbackValue(AgreementStatus.accepted);
    registerFallbackValue(AgreementStatus.declined);
    registerFallbackValue(AgreementStatus.canceled);
    registerFallbackValue(FakeAgreementModel());
  });

  test('acceptAgreement updates status to accepted', () async {
    when(() => mockRepo.updateAgreementStatus(any(), any())).thenAnswer((_) async => {});
    
    // Inject agreement manually
    when(() => mockRepo.getAgreementsForUser(any())).thenAnswer((_) async => [agreement]);
    await viewModel.loadAgreements('l1');

    await viewModel.acceptAgreement('a1');

    verify(() => mockRepo.updateAgreementStatus('a1', AgreementStatus.accepted)).called(1);
    expect(viewModel.agreements.first.status, AgreementStatus.accepted);
  });

  test('declineAgreement updates status to declined', () async {
    when(() => mockRepo.updateAgreementStatus(any(), any())).thenAnswer((_) async => {});
    
    // Inject agreement manually
    when(() => mockRepo.getAgreementsForUser(any())).thenAnswer((_) async => [agreement]);
    await viewModel.loadAgreements('l1');

    await viewModel.declineAgreement('a1');

    verify(() => mockRepo.updateAgreementStatus('a1', AgreementStatus.declined)).called(1);
    expect(viewModel.agreements.first.status, AgreementStatus.declined);
  });

  test('cancelAgreement updates status to canceled', () async {
    when(() => mockRepo.updateAgreementStatus(any(), any())).thenAnswer((_) async => {});
    
    // Inject agreement manually
    when(() => mockRepo.getAgreementsForUser(any())).thenAnswer((_) async => [agreement]);
    await viewModel.loadAgreements('l1');

    await viewModel.cancelAgreement('a1');

    verify(() => mockRepo.updateAgreementStatus('a1', AgreementStatus.canceled)).called(1);
    expect(viewModel.agreements.first.status, AgreementStatus.canceled);
  });

  test('loadHistory fetches agreement chain', () async {
    when(() => mockRepo.getAgreementHistory(any())).thenAnswer((_) async => [agreement]);
    
    await viewModel.loadHistory('a1');

    expect(viewModel.history.length, 1);
    expect(viewModel.history.first.id, 'a1');
  });

  test('createCounterOffer declines old and creates new agreement', () async {
    when(() => mockRepo.updateAgreementStatus(any(), any())).thenAnswer((_) async => {});
    when(() => mockRepo.createAgreement(any())).thenAnswer((_) async => {});
    when(() => mockRepo.getAgreementsForUser(any())).thenAnswer((_) async => [agreement]);
    await viewModel.loadAgreements('l1');

    final success = await viewModel.createCounterOffer(
      originalAgreement: agreement,
      learnerSkill: 'Go',
      mentorSkill: 'Rust',
      frequency: 'Daily',
      duration: 2.0,
    );

    expect(success, true);
    verify(() => mockRepo.updateAgreementStatus('a1', AgreementStatus.declined)).called(1);
    verify(() => mockRepo.createAgreement(any(that: isA<AgreementModel>()))).called(1);
  });
}
