import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCreateSkillOfferUseCase extends Mock
    implements CreateSkillOfferUseCase {}

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
  late MockCreateSkillOfferUseCase mockUseCase;

  setUpAll(() {
    registerFallbackValue(CreateSkillOfferParams(
      title: '',
      description: '',
      category: '',
      level: SkillLevel.beginner,
      format: SkillFormat.online,
    ));
  });

  setUp(() {
    mockUseCase = MockCreateSkillOfferUseCase();
    bloc = SkillBloc(createSkillOfferUseCase: mockUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  group('CreateSkillOfferRequested', () {
    final event = CreateSkillOfferRequested(
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
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        SkillLoading(),
        isA<SkillOfferCreated>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(event),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to create skill offer'),
      ],
    );
  });
}
