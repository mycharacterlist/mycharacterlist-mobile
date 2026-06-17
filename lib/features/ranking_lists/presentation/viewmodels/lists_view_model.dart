import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';
import 'package:mycharacterlist/core/errors/error_mapper.dart';

class ListsState {
  const ListsState({
    this.lists = const [],
    this.isLoading = false,
    this.isEditMode = false,
    this.errorMessage,
  });

  final List<RankingList> lists;
  final bool isLoading;
  final bool isEditMode;
  final String? errorMessage;

  ListsState copyWith({
    List<RankingList>? lists,
    bool? isLoading,
    bool? isEditMode,
    String? errorMessage,
  }) {
    return ListsState(
      lists: lists ?? this.lists,
      isLoading: isLoading ?? this.isLoading,
      isEditMode: isEditMode ?? this.isEditMode,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  RankingList? findById(String id) {
    for (final list in lists) {
      if (list.id == id) {
        return list;
      }
    }

    return null;
  }
}

class ListsViewModel extends StateNotifier<ListsState> {
  ListsViewModel({required RankingListRepository repository})
    : _repository = repository,
      super(const ListsState(isLoading: true)) {
    loadLists();
  }

  final RankingListRepository _repository;

  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  void exitEditMode() {
    state = state.copyWith(isEditMode: false);
  }

  Future<void> loadLists() async {
    state = state.copyWith(isLoading: true);

    try {
      final lists = await _repository.getLists();

      state = state.copyWith(lists: lists, isLoading: false);
    } catch (error) {
      state = ListsState(
        lists: state.lists,
        isEditMode: state.isEditMode,
        errorMessage: ErrorMapper.userMessage(error),
      );
    }
  }

  Future<bool> createList({required String name, required Color color}) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'List name cannot be empty.');
      return false;
    }

    final now = DateTime.now();
    final list = RankingList(
      id: 'list_${now.microsecondsSinceEpoch}',
      name: trimmedName,
      colorValue: color.toARGB32(),
      createdAt: now,
      updatedAt: now,
    );

    try {
      await _repository.saveList(list);

      state = state.copyWith(lists: [...state.lists, list]);
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: ErrorMapper.userMessage(error));
      return false;
    }
  }

  Future<bool> updateList({
    required RankingList list,
    required String name,
    required Color color,
  }) async {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      state = state.copyWith(errorMessage: 'List name cannot be empty.');
      return false;
    }

    final updatedList = list.copyWith(
      name: trimmedName,
      colorValue: color.toARGB32(),
      updatedAt: DateTime.now(),
    );

    try {
      await _repository.saveList(updatedList);

      state = state.copyWith(
        lists: state.lists
            .map((item) => item.id == list.id ? updatedList : item)
            .toList(),
      );
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: ErrorMapper.userMessage(error));
      return false;
    }
  }

  Future<bool> deleteList(String id) async {
    try {
      await _repository.deleteList(id);
      state = state.copyWith(
        lists: state.lists.where((list) => list.id != id).toList(),
      );
      return true;
    } catch (error) {
      state = state.copyWith(errorMessage: ErrorMapper.userMessage(error));
      return false;
    }
  }

  void clearError() {
    state = ListsState(
      lists: state.lists,
      isLoading: state.isLoading,
      isEditMode: state.isEditMode,
    );
  }
}
