import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myapp/core/error/failures.dart';
import 'package:myapp/features/skills/domain/entity/skill_entity.dart';
import 'package:myapp/features/skills/domain/usecases/archive_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/clone_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_user_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/filter_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/restore_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/search_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/submit_skill_verification_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/suggest_skill_category_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/save_search_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_saved_searches_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_saved_search_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_bloc.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockCreateSkillOfferUseCase extends Mock
    implements CreateSkillOfferUseCase {}

class MockUpdateSkillUseCase extends Mock implements UpdateSkillUseCase {}

class MockDeleteSkillUseCase extends Mock implements DeleteSkillUseCase {}

class MockFetchUserSkillsUseCase extends Mock
    implements FetchUserSkillsUseCase {}

class MockCloneSkillUseCase extends Mock implements CloneSkillUseCase {}

class MockArchiveSkillUseCase extends Mock implements ArchiveSkillUseCase {}

class MockRestoreSkillUseCase extends Mock implements RestoreSkillUseCase {}

class MockSearchSkillsUseCase extends Mock implements SearchSkillsUseCase {}

class MockFilterSkillsUseCase extends Mock implements FilterSkillsUseCase {}

class MockGetSkillByIdUseCase extends Mock implements GetSkillByIdUseCase {}

class MockSaveSearchUseCase extends Mock implements SaveSearchUseCase {}

class MockFetchSavedSearchesUseCase extends Mock
    implements FetchSavedSearchesUseCase {}

class MockDeleteSavedSearchUseCase extends Mock
    implements DeleteSavedSearchUseCase {}

class MockSuggestSkillCategoryUseCase extends Mock
    implements SuggestSkillCategoryUseCase {}

class MockSubmitSkillVerificationUseCase extends Mock
    implements SubmitSkillVerificationUseCase {}

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
  late MockDeleteSkillUseCase mockDeleteUseCase;
  late MockFetchUserSkillsUseCase mockFetchUseCase;
  late MockCloneSkillUseCase mockCloneUseCase;
  late MockArchiveSkillUseCase mockArchiveUseCase;
  late MockRestoreSkillUseCase mockRestoreUseCase;
  late MockSearchSkillsUseCase mockSearchUseCase;
  late MockFilterSkillsUseCase mockFilterUseCase;
  late MockGetSkillByIdUseCase mockGetByIdUseCase;
  late MockSaveSearchUseCase mockSaveSearchUseCase;
  late MockFetchSavedSearchesUseCase mockFetchSavedSearchesUseCase;
  late MockDeleteSavedSearchUseCase mockDeleteSavedSearchUseCase;
  late MockSuggestSkillCategoryUseCase mockSuggestSkillCategoryUseCase;
  late MockSubmitSkillVerificationUseCase mockSubmitSkillVerificationUseCase;

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
    registerFallbackValue(DeleteSkillParams(id: ''));
    registerFallbackValue(FetchUserSkillsParams(uid: ''));
    registerFallbackValue(CloneSkillParams(skillId: ''));
    registerFallbackValue(ArchiveSkillParams(id: ''));
    registerFallbackValue(RestoreSkillParams(id: ''));
    registerFallbackValue(SearchSkillsParams(query: ''));
    registerFallbackValue(FilterSkillsParams());
    registerFallbackValue(GetSkillByIdParams(id: ''));
    registerFallbackValue(SaveSearchParams(userId: '', query: ''));
    registerFallbackValue(FetchSavedSearchesParams(uid: ''));
    registerFallbackValue(DeleteSavedSearchParams(id: ''));
    registerFallbackValue(SuggestSkillCategoryParams(
      title: '',
      description: '',
    ));
    registerFallbackValue(SubmitSkillVerificationParams(
      skillId: '',
    ));
  });

  setUp(() {
    mockCreateUseCase = MockCreateSkillOfferUseCase();
    mockUpdateUseCase = MockUpdateSkillUseCase();
    mockDeleteUseCase = MockDeleteSkillUseCase();
    mockFetchUseCase = MockFetchUserSkillsUseCase();
    mockCloneUseCase = MockCloneSkillUseCase();
    mockArchiveUseCase = MockArchiveSkillUseCase();
    mockRestoreUseCase = MockRestoreSkillUseCase();
    mockSearchUseCase = MockSearchSkillsUseCase();
    mockFilterUseCase = MockFilterSkillsUseCase();
    mockGetByIdUseCase = MockGetSkillByIdUseCase();
    mockSaveSearchUseCase = MockSaveSearchUseCase();
    mockFetchSavedSearchesUseCase = MockFetchSavedSearchesUseCase();
    mockDeleteSavedSearchUseCase = MockDeleteSavedSearchUseCase();
    mockSuggestSkillCategoryUseCase = MockSuggestSkillCategoryUseCase();
    mockSubmitSkillVerificationUseCase = MockSubmitSkillVerificationUseCase();
    bloc = SkillBloc(
      createSkillOfferUseCase: mockCreateUseCase,
      updateSkillUseCase: mockUpdateUseCase,
      deleteSkillUseCase: mockDeleteUseCase,
      fetchUserSkillsUseCase: mockFetchUseCase,
      cloneSkillUseCase: mockCloneUseCase,
      archiveSkillUseCase: mockArchiveUseCase,
      restoreSkillUseCase: mockRestoreUseCase,
      searchSkillsUseCase: mockSearchUseCase,
      filterSkillsUseCase: mockFilterUseCase,
      getSkillByIdUseCase: mockGetByIdUseCase,
      saveSearchUseCase: mockSaveSearchUseCase,
      fetchSavedSearchesUseCase: mockFetchSavedSearchesUseCase,
      deleteSavedSearchUseCase: mockDeleteSavedSearchUseCase,
      suggestSkillCategoryUseCase: mockSuggestSkillCategoryUseCase,
      submitSkillVerificationUseCase: mockSubmitSkillVerificationUseCase,
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

  group('DeleteSkillRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillDeleted] on success',
      build: () {
        when(() => mockDeleteUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteSkillRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        isA<SkillDeleted>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockDeleteUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteSkillRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to delete skill'),
      ],
    );
  });

  group('FetchUserSkillsRequested', () {
    final tSkills = [tSkill];

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, UserSkillsFetched] on success',
      build: () {
        when(() => mockFetchUseCase(any()))
            .thenAnswer((_) async => Right(tSkills));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchUserSkillsRequested(uid: 'user1')),
      expect: () => [
        SkillLoading(),
        isA<UserSkillsFetched>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockFetchUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchUserSkillsRequested(uid: 'user1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to fetch skills'),
      ],
    );
  });

  group('CloneSkillRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillCloned] on success',
      build: () {
        when(() => mockCloneUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(CloneSkillRequested(skillId: 'skill1')),
      expect: () => [
        SkillLoading(),
        isA<SkillCloned>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockCloneUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(CloneSkillRequested(skillId: 'skill1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to clone skill'),
      ],
    );
  });

  group('ArchiveSkillRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillArchived] on success',
      build: () {
        when(() => mockArchiveUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(ArchiveSkillRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        isA<SkillArchived>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockArchiveUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ArchiveSkillRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to archive skill'),
      ],
    );
  });

  group('RestoreSkillRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillRestored] on success',
      build: () {
        when(() => mockRestoreUseCase(any()))
            .thenAnswer((_) async => Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(RestoreSkillRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        isA<SkillRestored>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockRestoreUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(RestoreSkillRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to restore skill'),
      ],
    );
  });

  group('SearchSkillsRequested', () {
    final tSkills = [tSkill];

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillsSearchCompleted] on success',
      build: () {
        when(() => mockSearchUseCase(any()))
            .thenAnswer((_) async => Right(tSkills));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchSkillsRequested(query: 'flutter')),
      expect: () => [
        SkillLoading(),
        isA<SkillsSearchCompleted>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockSearchUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchSkillsRequested(query: 'flutter')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to search skills'),
      ],
    );
  });

  group('FilterSkillsRequested', () {
    final tSkills = [tSkill];

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillsFiltered] on success',
      build: () {
        when(() => mockFilterUseCase(any()))
            .thenAnswer((_) async => Right(tSkills));
        return bloc;
      },
      act: (bloc) => bloc.add(FilterSkillsRequested(category: 'Tech')),
      expect: () => [
        SkillLoading(),
        isA<SkillsFiltered>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockFilterUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FilterSkillsRequested(category: 'Tech')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to filter skills'),
      ],
    );
  });

  group('BrowseSkillsFeedRequested', () {
    final tSkills = [tSkill];

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillsFeedLoaded] on success',
      build: () {
        when(() => mockFilterUseCase(any()))
            .thenAnswer((_) async => Right(tSkills));
        return bloc;
      },
      act: (bloc) => bloc.add(BrowseSkillsFeedRequested()),
      expect: () => [
        SkillLoading(),
        isA<SkillsFeedLoaded>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockFilterUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(BrowseSkillsFeedRequested()),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to load skills feed'),
      ],
    );
  });

  group('ViewSkillDetailsRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillDetailsLoaded] on success',
      build: () {
        when(() => mockGetByIdUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(ViewSkillDetailsRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        isA<SkillDetailsLoaded>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockGetByIdUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(ViewSkillDetailsRequested(id: 'skill1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to load skill details'),
      ],
    );
  });

  group('SaveSearchRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SearchSaved] on success',
      build: () {
        when(() => mockSaveSearchUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SaveSearchRequested(userId: 'user1', query: 'flutter'),
      ),
      expect: () => [
        SkillLoading(),
        isA<SearchSaved>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockSaveSearchUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SaveSearchRequested(userId: 'user1', query: 'flutter'),
      ),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to save search'),
      ],
    );
  });

  group('FetchSavedSearchesRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SavedSearchesFetched] on success',
      build: () {
        when(() => mockFetchSavedSearchesUseCase(any()))
            .thenAnswer((_) async => Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchSavedSearchesRequested(uid: 'user1')),
      expect: () => [
        SkillLoading(),
        isA<SavedSearchesFetched>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockFetchSavedSearchesUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(FetchSavedSearchesRequested(uid: 'user1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to fetch saved searches'),
      ],
    );
  });

  group('DeleteSavedSearchRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SavedSearchDeleted] on success',
      build: () {
        when(() => mockDeleteSavedSearchUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteSavedSearchRequested(id: 'search1')),
      expect: () => [
        SkillLoading(),
        isA<SavedSearchDeleted>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockDeleteSavedSearchUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(DeleteSavedSearchRequested(id: 'search1')),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to delete saved search'),
      ],
    );
  });

  group('SuggestCategoryRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [CategoriesSuggested] with suggestions on match',
      build: () {
        when(() => mockSuggestSkillCategoryUseCase(any()))
            .thenReturn(['Technology', 'Music']);
        return bloc;
      },
      act: (bloc) => bloc.add(
        SuggestCategoryRequested(
          title: 'Flutter App',
          description: 'Mobile development',
        ),
      ),
      expect: () => [
        isA<CategoriesSuggested>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [CategoriesSuggested] with empty list on no match',
      build: () {
        when(() => mockSuggestSkillCategoryUseCase(any()))
            .thenReturn(<String>[]);
        return bloc;
      },
      act: (bloc) => bloc.add(
        SuggestCategoryRequested(
          title: 'Xyzabc',
          description: 'Qwerty',
        ),
      ),
      expect: () => [
        CategoriesSuggested(suggestions: []),
      ],
    );
  });

  group('SubmitVerificationRequested', () {
    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, VerificationSubmitted] on success',
      build: () {
        when(() => mockSubmitSkillVerificationUseCase(any()))
            .thenAnswer((_) async => Right(tSkill));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SubmitVerificationRequested(
          skillId: 'skill1',
          portfolioUrls: ['https://example.com/portfolio'],
        ),
      ),
      expect: () => [
        SkillLoading(),
        isA<VerificationSubmitted>(),
      ],
    );

    blocTest<SkillBloc, SkillState>(
      'emits [SkillLoading, SkillError] on failure',
      build: () {
        when(() => mockSubmitSkillVerificationUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(
        SubmitVerificationRequested(skillId: 'skill1'),
      ),
      expect: () => [
        SkillLoading(),
        SkillError(message: 'Failed to submit verification'),
      ],
    );
  });
}
