import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/features/skills/domain/usecases/archive_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/clone_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/create_skill_offer_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/save_search_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_saved_search_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/delete_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_saved_searches_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/fetch_user_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/filter_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/restore_skill_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/search_skills_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/suggest_skill_category_usecase.dart';
import 'package:myapp/features/skills/domain/usecases/update_skill_usecase.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_event.dart';
import 'package:myapp/features/skills/presentation/bloc/skill_state.dart';

class SkillBloc extends Bloc<SkillEvent, SkillState> {
  final CreateSkillOfferUseCase createSkillOfferUseCase;
  final UpdateSkillUseCase updateSkillUseCase;
  final DeleteSkillUseCase deleteSkillUseCase;
  final FetchUserSkillsUseCase fetchUserSkillsUseCase;
  final CloneSkillUseCase cloneSkillUseCase;
  final ArchiveSkillUseCase archiveSkillUseCase;
  final RestoreSkillUseCase restoreSkillUseCase;
  final SearchSkillsUseCase searchSkillsUseCase;
  final FilterSkillsUseCase filterSkillsUseCase;
  final GetSkillByIdUseCase getSkillByIdUseCase;
  final SaveSearchUseCase saveSearchUseCase;
  final FetchSavedSearchesUseCase fetchSavedSearchesUseCase;
  final DeleteSavedSearchUseCase deleteSavedSearchUseCase;
  final SuggestSkillCategoryUseCase suggestSkillCategoryUseCase;

  SkillBloc({
    required this.createSkillOfferUseCase,
    required this.updateSkillUseCase,
    required this.deleteSkillUseCase,
    required this.fetchUserSkillsUseCase,
    required this.cloneSkillUseCase,
    required this.archiveSkillUseCase,
    required this.restoreSkillUseCase,
    required this.searchSkillsUseCase,
    required this.filterSkillsUseCase,
    required this.getSkillByIdUseCase,
    required this.saveSearchUseCase,
    required this.fetchSavedSearchesUseCase,
    required this.deleteSavedSearchUseCase,
    required this.suggestSkillCategoryUseCase,
  }) : super(SkillInitial()) {
    on<CreateSkillOfferRequested>(_onCreateSkillOfferRequested);
    on<UpdateSkillRequested>(_onUpdateSkillRequested);
    on<DeleteSkillRequested>(_onDeleteSkillRequested);
    on<FetchUserSkillsRequested>(_onFetchUserSkillsRequested);
    on<CloneSkillRequested>(_onCloneSkillRequested);
    on<ArchiveSkillRequested>(_onArchiveSkillRequested);
    on<RestoreSkillRequested>(_onRestoreSkillRequested);
    on<SearchSkillsRequested>(_onSearchSkillsRequested);
    on<FilterSkillsRequested>(_onFilterSkillsRequested);
    on<BrowseSkillsFeedRequested>(_onBrowseSkillsFeedRequested);
    on<ViewSkillDetailsRequested>(_onViewSkillDetailsRequested);
    on<SaveSearchRequested>(_onSaveSearchRequested);
    on<FetchSavedSearchesRequested>(_onFetchSavedSearchesRequested);
    on<DeleteSavedSearchRequested>(_onDeleteSavedSearchRequested);
    on<SuggestCategoryRequested>(_onSuggestCategoryRequested);
  }

  Future _onCreateSkillOfferRequested(
    CreateSkillOfferRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await createSkillOfferUseCase(
      CreateSkillOfferParams(
        title: event.title,
        description: event.description,
        category: event.category,
        type: event.type,
        level: event.level,
        format: event.format,
        tags: event.tags,
      ),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to create skill offer'));
      },
      (right) async {
        emit(SkillOfferCreated(skill: right));
      },
    );
  }

  Future _onUpdateSkillRequested(
    UpdateSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await updateSkillUseCase(
      UpdateSkillParams(
        id: event.id,
        title: event.title,
        description: event.description,
        category: event.category,
        type: event.type,
        level: event.level,
        format: event.format,
        tags: event.tags,
      ),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to update skill'));
      },
      (right) async {
        emit(SkillUpdated(skill: right));
      },
    );
  }

  Future _onDeleteSkillRequested(
    DeleteSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await deleteSkillUseCase(
      DeleteSkillParams(id: event.id),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to delete skill'));
      },
      (right) async {
        emit(SkillDeleted(id: event.id));
      },
    );
  }

  Future _onFetchUserSkillsRequested(
    FetchUserSkillsRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await fetchUserSkillsUseCase(
      FetchUserSkillsParams(uid: event.uid),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to fetch skills'));
      },
      (right) async {
        emit(UserSkillsFetched(skills: right));
      },
    );
  }

  Future _onCloneSkillRequested(
    CloneSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await cloneSkillUseCase(
      CloneSkillParams(skillId: event.skillId),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to clone skill'));
      },
      (right) async {
        emit(SkillCloned(skill: right));
      },
    );
  }

  Future _onArchiveSkillRequested(
    ArchiveSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await archiveSkillUseCase(
      ArchiveSkillParams(id: event.id),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to archive skill'));
      },
      (right) async {
        emit(SkillArchived(id: event.id));
      },
    );
  }

  Future _onRestoreSkillRequested(
    RestoreSkillRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await restoreSkillUseCase(
      RestoreSkillParams(id: event.id),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to restore skill'));
      },
      (right) async {
        emit(SkillRestored(id: event.id));
      },
    );
  }

  Future _onSearchSkillsRequested(
    SearchSkillsRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await searchSkillsUseCase(
      SearchSkillsParams(query: event.query),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to search skills'));
      },
      (right) async {
        emit(SkillsSearchCompleted(query: event.query, skills: right));
      },
    );
  }

  Future _onFilterSkillsRequested(
    FilterSkillsRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await filterSkillsUseCase(
      FilterSkillsParams(
        category: event.category,
        level: event.level,
        format: event.format,
        type: event.type,
      ),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to filter skills'));
      },
      (right) async {
        emit(SkillsFiltered(
          skills: right,
          category: event.category,
          level: event.level,
          format: event.format,
          type: event.type,
        ));
      },
    );
  }

  Future _onBrowseSkillsFeedRequested(
    BrowseSkillsFeedRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await filterSkillsUseCase(
      const FilterSkillsParams(),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to load skills feed'));
      },
      (right) async {
        emit(SkillsFeedLoaded(skills: right));
      },
    );
  }

  Future _onViewSkillDetailsRequested(
    ViewSkillDetailsRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await getSkillByIdUseCase(
      GetSkillByIdParams(id: event.id),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to load skill details'));
      },
      (right) async {
        emit(SkillDetailsLoaded(skill: right));
      },
    );
  }

  Future _onSaveSearchRequested(
    SaveSearchRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await saveSearchUseCase(
      SaveSearchParams(
        userId: event.userId,
        query: event.query,
      ),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to save search'));
      },
      (right) async {
        emit(SearchSaved(query: event.query));
      },
    );
  }

  Future _onFetchSavedSearchesRequested(
    FetchSavedSearchesRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await fetchSavedSearchesUseCase(
      FetchSavedSearchesParams(uid: event.uid),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to fetch saved searches'));
      },
      (right) async {
        emit(SavedSearchesFetched(searches: right));
      },
    );
  }

  Future _onDeleteSavedSearchRequested(
    DeleteSavedSearchRequested event,
    Emitter<SkillState> emit,
  ) async {
    emit(SkillLoading());
    final result = await deleteSavedSearchUseCase(
      DeleteSavedSearchParams(id: event.id),
    );

    await result.fold(
      (left) async {
        emit(SkillError(message: 'Failed to delete saved search'));
      },
      (right) async {
        emit(SavedSearchDeleted(id: event.id));
      },
    );
  }

  void _onSuggestCategoryRequested(
    SuggestCategoryRequested event,
    Emitter<SkillState> emit,
  ) {
    final suggestions = suggestSkillCategoryUseCase(
      SuggestSkillCategoryParams(
        title: event.title,
        description: event.description,
      ),
    );
    emit(CategoriesSuggested(suggestions: suggestions));
  }
}
