import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/contact_model.dart';
import '../../../widgets/goal_image.dart'; // generic network-or-file image renderer

/// One item in the horizontal "Favoritos" carousel: a ringed circular
/// avatar (or colored initials fallback), the contact's first name and
/// a small relationship tag chip underneath.
class FavoriteContactAvatar extends StatelessWidget {
  final ContactModel contact;
  final Color ringColor;
  final VoidCallback? onTap;

  const FavoriteContactAvatar({
    super.key,
    required this.contact,
    required this.ringColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final firstName = contact.name.split(' ').first;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 130,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2),
              ),
              child: ClipOval(
                child: Container(
                  width: 52,
                  height: 52,
                  color: colors.cardBackgroundAlt,
                  child: contact.avatarUrl == null
                      ? Center(
                          child: Text(contact.initials,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                        )
                      : GoalImage(path: contact.avatarUrl!),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              firstName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ringColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                contact.relationshipTag,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: ringColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}