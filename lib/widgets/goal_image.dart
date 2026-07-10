import 'dart:io';
import 'package:flutter/material.dart';

/// Renders a goal's cover image regardless of source: a full URL
/// (`https://...`, used by our seeded mock data) or a local file path
/// (`/data/...`, produced by the device's image picker on the Add Goal
/// form). Once Firebase Storage is wired up, locally-picked images get
/// uploaded and this becomes mostly a "just picked, not uploaded yet"
/// preview case — the widget itself won't need to change.
class GoalImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const GoalImage({super.key, required this.path, this.fit = BoxFit.cover});

  bool get _isNetwork => path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return _isNetwork ? Image.network(path, fit: fit) : Image.file(File(path), fit: fit);
  }
}