import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabState {
  final List<String> activityTypes;
  final int tabIndex;

  TabState({
    required this.activityTypes,
    required this.tabIndex,
  });

  bool get isScrollable => activityTypes.length > 4;

  TabState copyWith({
    List<String>? activityTypes,
    int? tabIndex,
  }) {
    return TabState(
      activityTypes: activityTypes ?? this.activityTypes,
      tabIndex: tabIndex ?? this.tabIndex,
    );
  }
}

class TabStateNotifier extends StateNotifier<TabState> {
  TabStateNotifier() : super(TabState(activityTypes: [], tabIndex: 0));

  void inicializar(List<String> types) {
    state = state.copyWith(activityTypes: List.from(types));
  }

  void newTab(String text) {
    final updated = List<String>.from(state.activityTypes)..add(text);
    state = state.copyWith(activityTypes: updated);
  }

  void removeTab(String text) {
    final updated = List<String>.from(state.activityTypes)..remove(text);
    state = state.copyWith(activityTypes: updated);
  }

  void editTab(String oldText, String newText) {
    final updated = List<String>.from(state.activityTypes);
    final index = updated.indexOf(oldText);
    if (index != -1) {
      updated[index] = newText;
      state = state.copyWith(activityTypes: updated);
    }
  }
}

final tabStateProvider = StateNotifierProvider<TabStateNotifier, TabState>(
  (ref) => TabStateNotifier(),
);
