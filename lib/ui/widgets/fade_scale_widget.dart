import 'package:flutter/material.dart';

class FadeScaleWidget extends StatefulWidget {
  final Widget child;
  final Curve curve;
  final Duration duration;

  const FadeScaleWidget({
    required this.child,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  _FadeScaleWidgetState createState() => _FadeScaleWidgetState();
}

class _FadeScaleWidgetState extends State<FadeScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(0, 0.5, curve: widget.curve),
        ));
    _scaleAnimation =
        Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(0.5, 1.0, curve: widget.curve),
        ));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
