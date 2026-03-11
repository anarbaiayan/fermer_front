import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';

import '../../../../../core/theme/app_colors.dart';

class SummaryTabs extends StatefulWidget {
  const SummaryTabs({super.key, this.onTabChanged});

  final ValueChanged<int>? onTabChanged;

  @override
  State<SummaryTabs> createState() => _SummaryTabsState();
}

class _SummaryTabsState extends State<SummaryTabs> {
  int _currentIndex = 0;

  final List<GlobalKey> _keys = List.generate(6, (_) => GlobalKey());

  double _underlineWidth = 0;

  void _measureTextWidth(int index) {
    final context = _keys[index].currentContext;
    if (context == null) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    setState(() {
      _underlineWidth = box.size.width;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureTextWidth(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tabs = [
      l10n.summaryTabBrief,
      l10n.summaryTabQuantity,
      l10n.summaryTabCondition,
      l10n.summaryTabIncome,
      l10n.summaryTabMilk,
      l10n.summaryTabRation,
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.additional2, width: 1),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isActive = index == _currentIndex;

              return InkWell(
                onTap: () {
                  setState(() => _currentIndex = index);
                  _measureTextWidth(index);
                  widget.onTabChanged?.call(index);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          key: _keys[index],
                          alignment: Alignment.center,
                          child: Text(
                            tabs[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isActive
                                  ? AppColors.primary1
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2,
                        width: isActive ? _underlineWidth : 0,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary1
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
