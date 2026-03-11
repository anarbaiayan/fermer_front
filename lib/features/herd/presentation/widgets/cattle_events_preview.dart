import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/cattle_events/application/cattle_events_providers.dart';
import 'package:frontend/features/cattle_events/domain/entities/cattle_event.dart';

class CattleEventsPreview extends ConsumerStatefulWidget {
  final int cattleId;
  final VoidCallback onAddPressed;

  const CattleEventsPreview({
    super.key,
    required this.cattleId,
    required this.onAddPressed,
  });

  @override
  ConsumerState<CattleEventsPreview> createState() =>
      _CattleEventsPreviewState();
}

class _CattleEventsPreviewState extends ConsumerState<CattleEventsPreview> {
  // по умолчанию показываем ВСЕ (значит collapsed = false)
  bool _collapsed = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final async = ref.watch(cattleEventsPreviewProvider(widget.cattleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              child: AppIcons.svg('clock', size: 34),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.eventsTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              icon: AppIcons.svg('add_event', size: 30),
              onPressed: widget.onAddPressed,
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.additional2),
        const SizedBox(height: 8),

        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.errorLoadingData('$e'),
                style: const TextStyle(fontSize: 12, color: AppColors.error),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => ref.invalidate(
                  cattleEventsPreviewProvider(widget.cattleId),
                ),
                child: Text(l10n.retry),
              ),
            ],
          ),
          data: (items) {
            final visible = items
                .where((e) => !e.eventType.startsWith('SYSTEM_'))
                .toList();

            if (visible.isEmpty) {
              return Text(
                l10n.eventsNone,
                style: TextStyle(fontSize: 14, color: AppColors.additional3),
              );
            }

            const collapsedCount = 1;
            final canToggle = visible.length > collapsedCount;

            final shown = _collapsed
                ? visible.take(collapsedCount).toList()
                : visible;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...shown.map(_EventRow.new),

                if (canToggle)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _collapsed = !_collapsed),
                      child: Text(
                        _collapsed
                            ? l10n.showAllCount(visible.length)
                            : l10n.hideText,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  final CattleEvent e;
  const _EventRow(this.e);

  @override
  Widget build(BuildContext context) {
    final title = _eventTitle(e.eventType, context.l10n);
    final dateText = DateFormat('dd.MM.yyyy').format(e.eventDate);
    final info = _buildInfoText(e);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _eventIcon(e.eventType),
          const SizedBox(width: 10),

          // центр - всегда занимает остаток
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                if (info.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    info,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary3,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // дата справа (фикс)
          Text(
            dateText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.additional3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _eventTitle(String eventType, dynamic l10n) {
    switch (eventType) {
      case 'CALVING':
        return l10n.eventActionCalving;
      case 'INSEMINATION':
        return l10n.eventActionInsemination;
      case 'MATING':
        return l10n.eventActionMating;
      case 'SYNCHRONIZATION':
        return l10n.eventActionSynchronization;
      case 'PREGNANCY_CONFIRMATION':
        return l10n.eventActionPregnancy;
      case 'PREGNANCY_NOT_CONFIRMED':
        return l10n.eventActionPregnancyNotConfirmed;
      case 'DRY_PERIOD':
        return l10n.eventActionDryPeriod;
      case 'HEAT_PERIOD':
        return l10n.eventActionHeat;
      case 'VACCINATION':
        return l10n.eventActionVaccination;
      case 'ILLNESS_TREATMENT':
        return l10n.eventActionIllness;
      case 'WEIGHING':
        return l10n.eventActionWeighing;
      case 'HOOF_TRIMMING':
        return l10n.eventActionHoof;
      case 'HORN_PROCESSING':
        return l10n.eventActionHornProcessing;
      case 'ANTIPARASITIC_TREATMENT':
        return l10n.eventActionAntiparasitic;
      case 'WEANING':
        return l10n.eventActionWeaning;
      case 'OTHER':
      default:
        return l10n.eventActionDefault;
    }
  }

  String _buildInfoText(CattleEvent e) {
    // приоритет: description -> title -> notes
    final d = (e.description ?? '').trim();
    if (d.isNotEmpty) return d;

    final t = (e.title ?? '').trim();
    if (t.isNotEmpty) return t;

    // если WEIGHING и ты пишешь вес в notes - можно красиво форматнуть
    final n = (e.notes ?? '').trim();
    if (n.isNotEmpty) return n;

    return '';
  }

  Widget _eventIcon(String type) {
    // TODO: поменяй на реальные названия svg которые у тебя есть
    // switch (type) {
    //   case 'WEIGHING':
    //     return AppIcons.svg('cow', size: 26);
    //   case 'VACCINATION':
    //     return AppIcons.svg('cow', size: 26);
    //   case 'ILLNESS_TREATMENT':
    //     return AppIcons.svg('cow', size: 26);
    //   case 'CALVING':
    //     return AppIcons.svg('cow', size: 26);
    //   default:
    //     return AppIcons.svg('cow', size: 26);
    // }

    IconData icon;
    switch (type) {
      case 'WEIGHING':
        icon = Icons.monitor_weight;
        break;
      case 'VACCINATION':
        icon = Icons.vaccines;
        break;
      case 'ILLNESS_TREATMENT':
        icon = Icons.medical_services;
        break;
      case 'CALVING':
        icon = Icons.pets;
        break;
      default:
        icon = Icons.event_note;
    }

    return SizedBox(
      width: 26,
      height: 26,
      child: Icon(icon, size: 22, color: AppColors.primary3),
    );
  }
}
