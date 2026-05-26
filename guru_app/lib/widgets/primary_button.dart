import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum ButtonType { filled, outline, text }

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final Color? color;
  final bool isLoading;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.filled,
    this.color,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 0.96);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<CustomThemeExtension>();
    final primaryColor = widget.color ?? ext?.primaryColor ?? theme.primaryColor;

    Widget buttonWidget;

    switch (widget.type) {
      case ButtonType.filled:
        buttonWidget = Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.onPressed != null ? primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(AppSpacing.s8),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.15),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    )
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(AppSpacing.s8),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
        break;

      case ButtonType.outline:
        buttonWidget = Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.onPressed != null ? primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.s8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(AppSpacing.s8),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: TextStyle(
                          color: widget.onPressed != null ? primaryColor : Colors.grey.shade400,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
        break;

      case ButtonType.text:
        buttonWidget = InkWell(
          onTap: widget.isLoading ? null : widget.onPressed,
          borderRadius: BorderRadius.circular(AppSpacing.s8),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            alignment: Alignment.center,
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.onPressed != null ? primaryColor : Colors.grey.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
        break;
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: buttonWidget,
      ),
    );
  }
}
