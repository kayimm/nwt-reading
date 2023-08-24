import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final planEditProviderFamily =
    AutoDisposeNotifierProviderFamily<PlanEdit, Plan, String?>(PlanEdit.new,
        name: 'planEditProviderFamily');

class PlanEdit extends AutoDisposeFamilyNotifier<Plan, String?> {
  @override
  Plan build(arg) => _getPlan(arg ?? _uuid.v4());

  Plan _getPlan(String planId) =>
      ref.read(plansProvider).getPlan(planId) ??
      ref.read(plansProvider.notifier).getNewPlan(planId);

  void updateLanguage(String language) {
    if (language != state.language) {
      state = state.copyWith(language: language);
    }
  }

  void updateScheduleDuration(ScheduleDuration scheduleDuration) {
    if (scheduleDuration != state.scheduleKey.duration) {
      state = state.copyWith(
        scheduleKey: state.scheduleKey.copyWith(duration: scheduleDuration),
        bookmark: const Bookmark(dayIndex: 0, sectionIndex: -1),
      );
    }
  }

  void updateScheduleType(ScheduleType scheduleType) {
    if (scheduleType != state.scheduleKey.type) {
      state = state.copyWith(
        name: toBeginningOfSentenceCase(scheduleType.name),
        scheduleKey: state.scheduleKey.copyWith(type: scheduleType),
        bookmark: const Bookmark(dayIndex: 0, sectionIndex: -1),
      );
    }
  }

  void updateWithTargetDate(bool withTargetDate) {
    if (withTargetDate != state.withTargetDate) {
      state = state.copyWith(withTargetDate: withTargetDate);
    }
  }

  void reset() => state = build(state.id);

  void save() {
    final notifier = ref.read(plansProvider.notifier);
    notifier.existPlan(state.id)
        ? notifier.updatePlan(state)
        : notifier.addPlan(state);
  }

  void delete() => ref.read(plansProvider.notifier).removePlan(state.id);
}
