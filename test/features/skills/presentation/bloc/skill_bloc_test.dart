import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCreateSkillOfferUseCase extends Mock
    implements CreateSkillOfferUseCase {}

class MockUpdateSkillUseCase extends Mock implements UpdateSkillUseCase {}

final tSkill = SkillEntity(
  id: 'skill1',
  title: 'Flutter',
  description: 'Test',
  category: 'Tech',
  level: SkillLevel.beginner,
  format: SkillFormat.online,
  userId: 'user1',
);

void main() {
  late SkillBloc bloc;
  late MockCreateSkillOfferUseCase mockCreateUseCase;
  late MockUpdateSkillUseCase mockUpdateUseCase;

  setUpAll(() {
    registerFallbackValue(CreateSkillOfferParams(
      title: '',
      description: '',
      category: '',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
    ));
    registerFallbackValue(UpdateSkillParams(
      id: '',
      title: '',
      description: '',
      category: '',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
    ));
  });

  setUp(() {
    mockCreateUseCase = MockCreateSkillOfferUseCase();
    mockUpdateUseCase = MockUpdateSkillUseCase();
    bloc = SkillBloc(
      createSkillOfferUseCase: mockCreateUseCase,
      updateSkillUseCase: mockUpdateUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateSkillOfferRequested', () {
    final offerEvent = CreateSkillOfferRequested(
      title: 'Flutter',
      description: 'Test',
      category: 'Tech',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
      tags: ['mobile'],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillOfferCreated] on success',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(offerEvent),
      expect: () => [
        SkillLoading(),
        isA<SkillOfferCreated>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(offerEvent),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to create skill offer'),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'handles SkillType.request correctly',
      build: () {
        when(() => mockCreateUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateSkillOfferRequested(
        title: 'Guitar Lessons',
        description: 'Test',
        category: 'Music',
        type: SkillType.request,
        level: SkillLevel.beginner,
        format: SkillFormat.online,
        tags: ['music'],
      )),
      expect: () => [
        SkillLoading(),
        isA<SkillOfferCreated>(),
      ],
      verify: (_) {
        verify(() => mockCreateUseCase(any())).called(1);
      },
    );
  });

  group('UpdateSkillRequested', () {
    final updateEvent = UpdateSkillRequested(
      id: 'skill1',
      title: 'Flutter Updated',
      description: 'Updated desc',
      category: 'Tech',
      level: SkillLevel.intermediate,
      format: SkillFormat.both,
      tags: ['mobile', 'updated'],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillUpdated] on success',
      build: () {
        when(() => mockUpdateUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(updateEvent),
      expect: () => [
        SkillLoading(),
        isA<SkillUpdated>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockUpdateUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(updateEvent),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to update skill'),
      ],
    );
  });
}
