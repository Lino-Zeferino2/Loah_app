import 'dart:io';
import 'package:flutter/material.dart';

/// Renders an image from either a network URL (http/https) or a local
/// file path, picking the right ImageProvider automatically.
///
/// IMPORTANTE: sempre com errorBuilder — um caminho local (ex: vindo
/// do image_picker) pode deixar de existir entre sessões da app (o
/// iOS limpa a pasta temporária), e sem tratamento de erro isso
/// derruba a app inteira com PathNotFoundException sempre que a
/// imagem for desenhada. Com o errorBuilder, mostra um placeholder
/// silencioso em vez de crashar.
class GoalImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const GoalImage({super.key, required this.path, this.fit = BoxFit.cover});

  bool get _isNetwork => path.startsWith('http://') || path.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _Placeholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
      );
    }

    return Image.file(
      File(path),
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: scheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}