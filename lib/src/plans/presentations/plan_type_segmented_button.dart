import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

class PlanTypeSegmentedButton extends ConsumerWidget {
  const PlanTypeSegmentedButton(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return SegmentedButton<ScheduleType>(
      segments: <ButtonSegment<ScheduleType>>[
        ButtonSegment<ScheduleType>(
            value: ScheduleType.chronological,
            label: Text(context.loc.planEditPageChronologicalLabel),
            icon: Icon(Icons.hourglass_empty)),
        ButtonSegment<ScheduleType>(
            value: ScheduleType.sequential,
            label: Text(context.loc.planEditPageSequentialLabel),
            icon: Icon(Icons.menu_book)),
        ButtonSegment<ScheduleType>(
            value: ScheduleType.written,
            label: Text(context.loc.planEditPageAsWrittenLabel),
            icon: Icon(Icons.edit_note)),
      ],
      selected: {plan.scheduleKey.type},
      onSelectionChanged: (Set<ScheduleType> newSelection) {
        planEdit.updateScheduleType(newSelection.single);
      },
    );
  }
}
