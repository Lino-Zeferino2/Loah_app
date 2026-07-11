import 'package:flutter/material.dart';
import 'package:loah_app/core/mock/country_codes.dart';
import '../../../core/theme/app_theme.dart';

/// Bottom sheet for picking a phone country code: a searchable list of
/// [countryCodes], plus a "Não encontrei / digitar código" option at
/// the top for anything missing from the list.
class CountryCodePickerSheet extends StatefulWidget {
  const CountryCodePickerSheet({super.key});

  @override
  State<CountryCodePickerSheet> createState() => _CountryCodePickerSheetState();
}

class _CountryCodePickerSheetState extends State<CountryCodePickerSheet> {
  String _query = '';
  List<CountryCode> get _filtered {
    if (_query.isEmpty) return countryCodes;
    final q = _query.toLowerCase();
    return countryCodes
        .where((c) => c.name.toLowerCase().contains(q) || c.dialCode.contains(q))
        .toList();
  }

  Future<void> _enterManually(BuildContext context) async {
    final controller = TextEditingController();
    final custom = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Digitar código manualmente',
              style: Theme.of(sheetContext)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+000',
                filled: true,
                fillColor: context.loahColors.cardBackgroundAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  var code = controller.text.trim();
                  if (code.isEmpty) return;
                  if (!code.startsWith('+')) code = '+$code';
                  Navigator.of(sheetContext).pop(code);
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Usar este código'),
              ),
            ),
          ],
        ),
      ),
    );
    if (custom != null && context.mounted) Navigator.of(context).pop(custom);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    final colors = context.loahColors;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Código do País',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: false,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Buscar país ou código...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: colors.cardBackgroundAlt,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined, color: colors.accentBlue),
                    title: Text(
                      'Não encontrei — digitar código',
                      style: TextStyle(color: colors.accentBlue, fontWeight: FontWeight.w600),
                    ),
                    onTap: () => _enterManually(context),
                  ),
                  const Divider(height: 1),
                  for (final country in _filtered)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(country.flag, style: const TextStyle(fontSize: 22)),
                      title: Text(country.name),
                      trailing: Text(
                        country.dialCode,
                        style: TextStyle(fontWeight: FontWeight.w700, color: colors.accentBlue),
                      ),
                      onTap: () => Navigator.of(context).pop('${country.flag}|${country.dialCode}'),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}