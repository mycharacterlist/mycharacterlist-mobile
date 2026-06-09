import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

class ListsState {
  const ListsState({
    this.lists = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<RankingList> lists;
  final bool isLoading;
  final String? errorMessage;

  ListsState copyWith({
    List<RankingList>? lists,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ListsState(
      lists: lists ?? this.lists,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ListsViewModel extends StateNotifier<ListsState> {
  ListsViewModel({required RankingListRepository repository})
    : _repository = repository,
      super(const ListsState(isLoading: true)) {
    loadLists();
  }

  final RankingListRepository _repository;

  Future<void> loadLists() async {
    state = state.copyWith(isLoading: true);

    try {
      final lists = await _repository.getLists();

      state = state.copyWith(lists: lists, isLoading: false);
    } catch (error) {
      state = ListsState(
        lists: state.lists,
        errorMessage: _messageFromError(error),
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
      state = state.copyWith(errorMessage: _messageFromError(error));
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
      state = state.copyWith(errorMessage: _messageFromError(error));
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
      state = state.copyWith(errorMessage: _messageFromError(error));
      return false;
    }
  }

  void clearError() {
    state = ListsState(lists: state.lists, isLoading: state.isLoading);
  }

  String _messageFromError(Object error) {
    if (error is StateError) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
