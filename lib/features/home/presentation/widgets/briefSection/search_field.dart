import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import '../../../../../core/theme/app_colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.additional2, width: 1),
      ),
      child: TextField(
        textAlignVertical: TextAlignVertical.center,

        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,

          prefixIcon: Padding(
            padding: EdgeInsets.all(12),
            child: AppIcons.svg('search', size: 20)
          ),

          prefixIconConstraints: BoxConstraints(minWidth: 44, minHeight: 44),

          hintText: 'Поиск скота',
          border: InputBorder.none,
        ),
      ),
    );
  }
}
