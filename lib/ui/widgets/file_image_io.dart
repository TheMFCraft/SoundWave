import 'dart:io';

import 'package:flutter/material.dart';

Widget? tryFileImage(String path, {int? cacheSize, Widget? fallback}) {
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    gaplessPlayback: true,
    filterQuality: FilterQuality.medium,
    cacheWidth: cacheSize,
    cacheHeight: cacheSize,
    errorBuilder: fallback == null ? null : (_, _, _) => fallback,
  );
}

ImageProvider? tryFileImageProvider(String path) {
  return FileImage(File(path));
}
