import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/cattle_events/domain/entities/simple_cattle.dart';

class SelectCattleSheet extends StatefulWidget {
  final List<SimpleCattle> items;
  final Set<int> initialSelected;

  const SelectCattleSheet({
    super.key,
    required this.items,
    required this.initialSelected,
  });

  @override
  State<SelectCattleSheet> createState() => _SelectCattleSheetState();
}

class _SelectCattleSheetState extends State<SelectCattleSheet> {
  late Set<int> selected = {...widget.initialSelected};

  void _selectAll() {
    setState(() {
      selected = widget.items.map((e) => e.id).toSet();
    });
  }

  void _clear() {
    setState(() => selected.clear());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Выбор скота',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),
                ),
                Text(
                  'Выбрано: ${selected.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary1,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                TextButton(
                  onPressed: widget.items.isEmpty ? null : _selectAll,
                  child: const Text('Выбрать все'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: selected.isEmpty ? null : _clear,
                  child: const Text(
                    'Очистить',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(selected.toList()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Готово'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            const Divider(height: 1),

            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final c = widget.items[i];
                  final isOn = selected.contains(c.id);

                  return CheckboxListTile(
                    value: isOn,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.primary1,
                    title: Text(
                      c.tagNumber.isEmpty ? 'Без бирки' : c.tagNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    subtitle: Text(
                      (c.name == null || c.name!.trim().isEmpty)
                          ? '-'
                          : c.name!,
                      style: const TextStyle(color: AppColors.additional3),
                    ),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          selected.add(c.id);
                        } else {
                          selected.remove(c.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
