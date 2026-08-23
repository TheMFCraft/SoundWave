import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding,
    this.color,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color ?? const Color(0xB31E1E1E),
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

class NeonPlayButton extends StatelessWidget {
  const NeonPlayButton({
    super.key,
    required this.playing,
    required this.onPressed,
    this.size = 80,
  });

  final bool playing;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: size * 0.5,
            color: scheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
