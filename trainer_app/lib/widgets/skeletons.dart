import 'package:flutter/material.dart';
import '../theme/theme.dart';

class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonWidget({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = AppSpacing.s8,
  }) : super(key: key);

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.4,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class SkeletonListLoader extends StatelessWidget {
  final int count;
  final double itemHeight;

  const SkeletonListLoader({
    Key? key,
    this.count = 4,
    this.itemHeight = 72,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, __) => AppSpacing.v12,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const SkeletonWidget(width: 48, height: 48, borderRadius: 24),
            AppSpacing.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidget(width: MediaQuery.of(context).size.width * 0.4, height: 16),
                  AppSpacing.v8,
                  SkeletonWidget(width: MediaQuery.of(context).size.width * 0.6, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
