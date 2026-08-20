import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as device;
import '../../core/l10n/app_localizations.dart';
import '../../core/services/contact_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact_model.dart';

/// "Loah - Importar Contactos": lê os contactos do telemóvel, deixa o
/// usuário selecionar quais quer trazer, e cria todos de uma vez no
/// Firestore com o grau de conexão padrão "Conhecido" (o usuário pode
/// ajustar depois, contacto por contacto, na tela de detalhes).
class ImportContactsScreen extends StatefulWidget {
  const ImportContactsScreen({super.key});

  @override
  State<ImportContactsScreen> createState() => _ImportContactsScreenState();
}

class _ImportContactsScreenState extends State<ImportContactsScreen> {
  final ContactService _contactService = ContactService();

  bool _loading = true;
  bool _permissionDenied = false;
  bool _importing = false;
  String _query = '';

  List<device.Contact> _deviceContacts = [];
  Set<String> _existingNormalizedPhones = {};
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }
  /// Devolve um nome de exibição seguro para o contacto: o nome
  /// guardado, se existir e não estiver vazio; senão o primeiro
  /// telefone; senão o primeiro email; senão um texto genérico.
  /// CORRIGIDO: contact.displayName! rebentava (Null check operator
  /// used on a null value) para contactos sem nome guardado — era
  /// exatamente isso que causava a lista "em branco": a exceção parava
  /// a construção da lista assim que encontrava o primeiro contacto
  /// sem nome.
  String _displayNameFor(device.Contact c) {
    if (c.displayName != null && c.displayName!.trim().isNotEmpty) {
      return c.displayName!;
    }
    if (c.phones.isNotEmpty) return c.phones.first.number;
    if (c.emails.isNotEmpty) return c.emails.first.address;
    return AppLocales.of(context).translate('importContacts_sem_nome');
  }
  /// Remove tudo que não é dígito — usado para comparar números em
  /// formatos diferentes (com/sem espaço, código de país, etc.) sem
  /// falso-negativo por formatação.
  String _normalizePhone(String raw) => raw.replaceAll(RegExp(r'\D'), '');

  Future<void> _loadEverything() async {
    setState(() {
      _loading = true;
      _permissionDenied = false;
    });

    final status = await device.FlutterContacts.permissions.request(
      device.PermissionType.read,
    );
    if (status != device.PermissionStatus.granted) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
      return;
    }

    try {
      final deviceContacts = await device.FlutterContacts.getAll(
        properties: {
          device.ContactProperty.name,
          device.ContactProperty.phone,
          device.ContactProperty.email,
        },
      );

      // Só faz sentido mostrar contactos que têm ID (sempre têm, vindo
      // do telemóvel, mas o tipo é String? — filtramos por segurança)
      // e pelo menos telefone ou email, já que todas as ações rápidas
      // do app dependem de telefone.
      final withData = deviceContacts
          .where((c) => c.id != null && (c.phones.isNotEmpty || c.emails.isNotEmpty))
          .toList()
        ..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));

      // Busca os contactos já existentes no Firestore para marcar
      // duplicados por telefone.
      final existingSnapshot = await _contactService.getContactsStream().first;
      final existingPhones = <String>{};
      for (final doc in existingSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final phone = data['phone'] as String?;
        if (phone != null && phone.isNotEmpty) {
          existingPhones.add(_normalizePhone(phone));
        }
      }

      if (!mounted) return;
      setState(() {
        _deviceContacts = withData;
        _existingNormalizedPhones = existingPhones;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocales.of(context).translate('importContacts_erro')}$e')),
      );
    }
  }
  bool _isAlreadyImported(device.Contact contact) {
    for (final phone in contact.phones) {
      if (_existingNormalizedPhones.contains(_normalizePhone(phone.number))) {
        return true;
      }
    }
    return false;
  }

  List<device.Contact> get _filteredContacts {
    if (_query.isEmpty) return _deviceContacts;
    final q = _query.toLowerCase();
    return _deviceContacts
        .where((c) => _displayNameFor(c).toLowerCase().contains(q))
        .toList();
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

 void _selectAllVisible() {
    setState(() {
      final selectable = _filteredContacts.where((c) => !_isAlreadyImported(c));
      final allSelected = selectable.every((c) => _selectedIds.contains(c.id!));
      if (allSelected) {
        for (final c in selectable) {
          _selectedIds.remove(c.id!);
        }
      } else {
        for (final c in selectable) {
          _selectedIds.add(c.id!);
        }
      }
    });
  }
  Future<void> _importSelected() async {
    if (_selectedIds.isEmpty) return;
    setState(() => _importing = true);

    try {
      final toImport = _deviceContacts.where((c) => _selectedIds.contains(c.id!));
      final newContacts = toImport.map((c) {
        return ContactModel(
          id: _contactService.newContactId(),
          name: _displayNameFor(c),
          email: c.emails.isNotEmpty ? c.emails.first.address : null,
          phone: c.phones.isNotEmpty ? c.phones.first.number : null,
          relationshipTag: 'Conhecido',
        );
      }).toList();

      await _contactService.addContactsBatch(newContacts);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocales.of(context)
                .translate('importContacts_sucesso')
                .replaceFirst('{count}', '${newContacts.length}'),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocales.of(context).translate('importContacts_erro')}$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocales.of(context);
    final colors = context.loahColors;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('importContacts_titulo')),
        actions: [
          if (!_loading && !_permissionDenied && _deviceContacts.isNotEmpty)
            TextButton(
              onPressed: _selectAllVisible,
              child: Text(loc.translate('importContacts_selecionar_todos')),
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _permissionDenied
                ? _PermissionDeniedView(loc: loc)
                : _deviceContacts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            loc.translate('importContacts_sem_contatos'),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                            child: TextField(
                              onChanged: (v) => setState(() => _query = v),
                              decoration: InputDecoration(
                                hintText: loc.translate('importContacts_pesquisar'),
                                prefixIcon: const Icon(Icons.search, size: 20),
                                filled: true,
                                fillColor: colors.cardBackgroundAlt,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _filteredContacts.length,
                              itemBuilder: (context, index) {
                                final contact = _filteredContacts[index];
                                final alreadyImported = _isAlreadyImported(contact);
                                final selected = _selectedIds.contains(contact.id!);
                                final subtitle = contact.phones.isNotEmpty
                                    ? contact.phones.first.number
                                    : (contact.emails.isNotEmpty ? contact.emails.first.address : '');

                                return CheckboxListTile(
                                  value: alreadyImported ? false : selected,
                                  onChanged: alreadyImported
                                      ? null
                                      : (_) => _toggleSelection(contact.id!),
                                  title: Text(
                                    _displayNameFor(contact),
                                    style: TextStyle(
                                      color: alreadyImported ? context.textSecondary : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    alreadyImported
                                        ? loc.translate('importContacts_ja_importado')
                                        : subtitle,
                                    style: TextStyle(
                                      color: alreadyImported ? colors.accentBlue : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _selectedIds.isEmpty || _importing
                                      ? null
                                      : _importSelected,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.accentBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _importing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          loc
                                              .translate('importContacts_importar_btn')
                                              .replaceFirst('{count}', '${_selectedIds.length}'),
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final AppLocales loc;
  const _PermissionDeniedView({required this.loc});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.no_accounts_outlined, size: 48, color: context.textSecondary),
            const SizedBox(height: 16),
            Text(
              loc.translate('importContacts_permissao_negada'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => device.FlutterContacts.permissions.openSettings(),
              child: Text(loc.translate('importContacts_abrir_config')),
            ),
          ],
        ),
      ),
    );
  }
}