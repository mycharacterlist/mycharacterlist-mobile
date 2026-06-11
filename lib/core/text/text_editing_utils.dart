import 'package:flutter/widgets.dart';

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
