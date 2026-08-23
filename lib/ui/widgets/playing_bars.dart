import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class PlayingBars extends StatefulWidget {
  const PlayingBars({super.key});

  @override
  State<PlayingBars> createState() => _PlayingBarsState();
}

class _PlayingBarsState extends State<PlayingBars> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          width: 14,
          height: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(4 + 10 * t),
              _bar(14 - 8 * t),
              _bar(7 + 8 * (1 - t)),
            ],
          ),
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: SwColors.secondary,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
