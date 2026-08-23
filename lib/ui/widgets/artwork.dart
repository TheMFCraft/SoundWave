import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../state/library_controller.dart';
import '../../theme/colors.dart';
import 'file_image.dart';

class Artwork extends StatefulWidget {
  const Artwork({
    super.key,
    this.track,
    this.path,
    this.size,
    this.borderRadius = 8,
    this.circle = false,
    this.loadMissingArtwork = true,
    this.showFile = true,
    this.decodeSize,
  });

  final Track? track;
  final String? path;
  final double? size;
  final double borderRadius;
  final bool circle;
  final bool loadMissingArtwork;
  final bool showFile;
  final int? decodeSize;

  @override
  State<Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<Artwork> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeLoadArtwork();
  }

  @override
  void didUpdateWidget(covariant Artwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLoadArtwork();
  }

  void _maybeLoadArtwork() {
    if (!widget.loadMissingArtwork) return;
    final track = widget.track;
    if (track == null || track.artworkPath != null || track.albumId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LibraryController>().ensureArtwork(track.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resolved = widget.showFile ? (widget.path ?? widget.track?.artworkPath) : null;
    final radius = widget.circle ? 999.0 : widget.borderRadius;
    final placeholder = _placeholder(widget.track);
    final cacheSize = widget.decodeSize ??
        (widget.size == null
            ? null
            : ((widget.size! * (MediaQuery.maybeDevicePixelRatioOf(context) ?? 2)).round().clamp(64, 720)));
    final fileImage = resolved == null
        ? null
        : tryFileImage(resolved, cacheSize: cacheSize, fallback: placeholder);
    final child = fileImage ?? placeholder;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AspectRatio(aspectRatio: 1, child: child),
      ),
    );
  }

  Widget _placeholder(Track? track) {
    final seed = (track?.album.isNotEmpty == true ? track!.album : track?.title ?? 'S').hashCode;
    final hue = (seed % 360).toDouble();
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSVColor.fromAHSV(1, hue, 0.35, 0.35).toColor(),
            SwColors.surfaceContainerHigh,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.graphic_eq_rounded, color: SwColors.primary, size: 28),
      ),
    );
  }
}
