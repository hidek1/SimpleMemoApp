import 'package:flutter/material.dart';

/// 複数画面で利用可能なカテゴリ選択用ドロップダウンウィジェット
class CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final String labelText;
  final bool showAllOption;

  const CategoryDropdown({
    Key? key,
    required this.categories,
    this.value,
    this.onChanged,
    this.labelText = 'カテゴリ選択',
    this.showAllOption = false,   // trueなら"すべて"を追加
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // "すべて"を先頭に追加する判定
    final dropdownItems = showAllOption
        ? ['すべて', ...categories]
        : categories;
    return DropdownButtonFormField<String>(
      value: value,
      items: dropdownItems
          .map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      isExpanded: true,
    );
  }
}
