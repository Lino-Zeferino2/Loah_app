import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/contact_model.dart';
import '../../../widgets/goal_image.dart'; // generic network-or-file image renderer

/// One row inside an alphabetical section: avatar (or colored initials
/// fallback), name, email/phone, a relationship tag chip, and trailing
/// message/call icon buttons. Tap the row (outside the icons) to open
/// the contact's detail screen.
class ContactListTile extends StatelessWidget {
  final ContactModel contact;
  final Color avatarColor;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onCall;

  const ContactListTile({
    super.key,
    required this.contact,
    required this.avatarColor,
    this.onTap,
    this.onMessage,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final subtitle = contact.email ?? contact.phone ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipOval(
                  child: Container(
                    width: 44,
                    height: 44,
                    color: avatarColor.withValues(alpha: 0.18),
                    child: contact.avatarUrl == null
                        ? Center(
                            child: Text(contact.initials,
                                style: TextStyle(fontWeight: FontWeight.w700, color: avatarColor)),
                          )
                        : GoalImage(path: contact.avatarUrl!),
                  ),
                ),
                if (contact.isOverdue)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.negative,
                        shape: BoxShape.circle,
                        border: Border.all(color: colors.cardBackground, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: colors.accentBlue),
                    ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.cardBackgroundAlt,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      contact.relationshipTag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
            // Tight constraints keep both icons comfortably on-screen even
            // on narrow phones (~320dp wide), instead of relying on the
            // default 48x48 IconButton tap target for each.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onMessage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: Icon(Icons.chat_bubble_outline, size: 19, color: colors.accentBlue),
                ),
                if (contact.phone != null)
                  IconButton(
                    onPressed: onCall,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(Icons.call_outlined, size: 19, color: colors.accentBlue),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}