import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mycharacterlist/core/text/text_editing_utils.dart';

class RankingPositionField extends StatefulWidget {
  const RankingPositionField({
    super.key,
    required this.position,
    required this.maxPosition,
    required this.onSubmitted,
  });

  final int position;
  final int maxPosition;
  final ValueChanged<int> onSubmitted;

  @override
  State<RankingPositionField> createState() => _RankingPositionFieldState();
}

class _RankingPositionFieldState extends State<RankingPositionField> {
  static const _textStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    fontFamily: 'JosefinSans',
    color: Colors.black,
    height: 1.0,
  );

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.position}');
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant RankingPositionField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.position != widget.position && !_focusNode.hasFocus) {
      setCollapsedControllerText(_controller, '${widget.position}');
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _submit();
    }
  }

  void _submit() {
    final parsed = int.tryParse(_controller.text.trim());

    if (parsed == null) {
      setCollapsedControllerText(_controller, '${widget.position}');
      return;
    }

    final targetPosition = parsed.clamp(1, widget.maxPosition);
    setCollapsedControllerText(_controller, '$targetPosition');

    if (targetPosition != widget.position) {
      widget.onSubmitted(targetPosition);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digitCount = widget.maxPosition.toString().length;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('#', style: _textStyle),
          SizedBox(
            width: digitCount * 16.0,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.left,
              maxLength: digitCount,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: _textStyle,
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                contentPadding: const EdgeInsets.only(bottom: 2),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black45, width: 1.5),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black38, width: 1.5),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black87, width: 2),
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ],
      ),
    );
  }
}
