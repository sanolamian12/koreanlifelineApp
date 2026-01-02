// lib/core/widgets/highlight_button.dart (예시 경로)

import 'package:flutter/material.dart';

class HighlightButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Gradient defaultGradient;
  final Gradient highlightGradient;
  final ShapeBorder shape;
  final List<BoxShadow>? shadows; // 그림자 추가

  const HighlightButton({
    super.key,
    required this.child,
    this.onTap,
    required this.defaultGradient,
    required this.highlightGradient,
    required this.shape,
    this.shadows, // 선택 사항으로 추가
  });

  @override
  State<HighlightButton> createState() => _HighlightButtonState();
}

class _HighlightButtonState extends State<HighlightButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: ShapeDecoration(
          // 클릭 시 노란색, 아닐 시 기본색
          gradient: _isPressed ? widget.highlightGradient : widget.defaultGradient,
          shape: widget.shape,
          shadows: widget.shadows, // 주입받은 그림자 적용
        ),
        child: widget.child,
      ),
    );
  }
}