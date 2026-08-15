import 'package:flutter/widgets.dart';

String normalizeSearchText(String value) {
  return value.trim().toLowerCase().replaceAll('ё', 'е');
}

bool matchesSearchQuery(String query, String text) {
  final normalizedQuery = normalizeSearchText(query);
  if (normalizedQuery.isEmpty) {
    return false;
  }

  return normalizeSearchText(text).contains(normalizedQuery);
}

void setCollapsedControllerText(TextEditingController controller, String text) {
  controller.value = TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

void syncControllerValue(
  TextEditingController target,
  TextEditingValue value,
) {
  if (target.value == value) {
    return;
  }

  target.value = value;
}
