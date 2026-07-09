import 'package:flutter/material.dart';
import 'loah_app_bar.dart';

/// Wraps [LoahAvatar] with the padding/tap target expected of an
/// AppBar action, so screens can drop it straight into `actions: []`.
class LoahAvatarAction extends StatelessWidget {
  final VoidCallback? onTap;
  const LoahAvatarAction({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: const Center(child: LoahAvatar()),
      ),
    );
  }
}
