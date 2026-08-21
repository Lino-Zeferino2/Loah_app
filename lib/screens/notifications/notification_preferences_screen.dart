import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/notification_preferences_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/notification_preferences.dart';

/// Screen where the user toggles which notification categories they
/// want, and configures the lead time for task reminders.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  final _service = NotificationPreferencesService();
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _loading = true;
  bool _saving = false;

  static const _leadHourOptions = [1, 3, 6, 12, 24, 48];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await _service.getPreferences();
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _loading = false;
      });
    }
  }

  Future<void> _update(NotificationPreferences newPrefs) async {
    setState(() {
      _prefs = newPrefs;
      _saving = true;
    });
    await _service.updatePreferences(newPrefs);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final loc = AppLocales.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('notifPrefs_titulo')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  loc.translate('notifPrefs_categorias_titulo'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                _PrefSwitch(
                  icon: Icons.people_outline,
                  title: loc.translate('notif_cat_contatos'),
                  value: _prefs.contactsEnabled,
                  onChanged: (v) =>
                      _update(_prefs.copyWith(contactsEnabled: v)),
                ),
                _PrefSwitch(
                  icon: Icons.checklist_outlined,
                  title: loc.translate('notif_cat_tarefas'),
                  value: _prefs.tasksEnabled,
                  onChanged: (v) =>
                      _update(_prefs.copyWith(tasksEnabled: v)),
                ),
                _PrefSwitch(
                  icon: Icons.flag_outlined,
                  title: loc.translate('notif_cat_metas'),
                  value: _prefs.goalsEnabled,
                  onChanged: (v) =>
                      _update(_prefs.copyWith(goalsEnabled: v)),
                ),
                _PrefSwitch(
                  icon: Icons.account_balance_wallet_outlined,
                  title: loc.translate('notif_cat_financas'),
                  value: _prefs.financeEnabled,
                  onChanged: (v) =>
                      _update(_prefs.copyWith(financeEnabled: v)),
                ),
                _PrefSwitch(
                  icon: Icons.notifications_outlined,
                  title: loc.translate('notif_cat_sistema'),
                  value: _prefs.systemEnabled,
                  onChanged: (v) =>
                      _update(_prefs.copyWith(systemEnabled: v)),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.translate('notifPrefs_antecedencia_titulo'),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: context.textSecondary,
                    fontSize: 12,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('notifPrefs_antecedencia_desc'),
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _leadHourOptions.map((hours) {
                    final selected = _prefs.taskReminderLeadHours == hours;
                    return GestureDetector(
                      onTap: () => _update(
                          _prefs.copyWith(taskReminderLeadHours: hours)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.accentBlue
                              : colors.cardBackgroundAlt,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: selected
                                ? colors.accentBlue
                                : colors.border,
                          ),
                        ),
                        child: Text(
                          hours < 24
                              ? loc
                                  .translate('notifPrefs_horas_label')
                                  .replaceAll('{n}', '$hours')
                              : loc
                                  .translate('notifPrefs_dias_label')
                                  .replaceAll('{n}', '${hours ~/ 24}'),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : context.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_saving) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: colors.accentBlue),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _PrefSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrefSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: colors.cardBackgroundAlt,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: colors.accentBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        activeThumbColor: colors.accentBlue,
        onChanged: onChanged,
      ),
    );
  }
}