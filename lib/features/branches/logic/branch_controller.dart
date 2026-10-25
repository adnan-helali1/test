import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:e_smart/features/branches/data/branch.dart';
import 'package:e_smart/features/branches/data/branch_repository.dart';

class BranchListController extends AsyncNotifier<List<Branch>> {
  @override
  Future<List<Branch>> build() {
    return ref.watch(branchRepositoryProvider).getBranches();
  }

  Future<void> refresh() async {
    final previous = state.valueOrNull;
    final next = await AsyncValue.guard(
      () => ref.read(branchRepositoryProvider).getBranches(),
    );
    if (next.hasError && previous != null) {
      state = AsyncData(previous);
      return;
    }
    state = next;
  }
}

final branchListProvider =
    AsyncNotifierProvider<BranchListController, List<Branch>>(
      BranchListController.new,
    );

/// First active branch in API order. The list is not sorted.
final activeBranchProvider = Provider<Branch?>((ref) {
  final branches = ref.watch(branchListProvider).valueOrNull;
  if (branches == null) return null;
  for (final branch in branches) {
    if (branch.active) return branch;
  }
  return null;
});
