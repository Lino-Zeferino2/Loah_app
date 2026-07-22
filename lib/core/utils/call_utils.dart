import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

/// Abre o WhatsApp com o número preenchido usando o esquema WhatsApp.
Future<void> _openWhatsApp(String phoneNumber) async {
  final number = phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceAll('+', '');
  
  // Tenta primeiro o esquema nativo whatsapp://send?phone=
  final whatsappUri = Uri.parse('whatsapp://send?phone=$number');
  try {
    if (await launcher.canLaunchUrl(whatsappUri)) {
      await launcher.launchUrl(whatsappUri);
      return;
    }
  } catch (_) {
    // Ignora se não conseguir
  }
  
  // Fallback para https://wa.me/
  final waMeUri = Uri.parse('https://wa.me/$number');
  try {
    if (await launcher.canLaunchUrl(waMeUri)) {
      await launcher.launchUrl(waMeUri, mode: launcher.LaunchMode.externalApplication);
      return;
    }
  } catch (_) {
    // Ignora
  }
  
  // Último fallback: tenta abrir no browser
  try {
    await launcher.launchUrl(waMeUri, mode: launcher.LaunchMode.platformDefault);
  } catch (_) {
    // Não há como abrir WhatsApp neste dispositivo
  }
}

/// Abre o discador do telefone.
Future<void> _makePhoneCall(String phoneNumber) async {
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
  final uri = Uri.parse('tel:$cleanedNumber');
  try {
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri, mode: launcher.LaunchMode.platformDefault);
    }
  } catch (e) {
    debugPrint('Erro ao fazer chamada telefónica: $e');
  }
}

/// Abre o app de SMS nativo com o número preenchido.
Future<void> _openSms(String phoneNumber) async {
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
  final uri = Uri.parse('sms:$cleanedNumber');
  try {
    if (await launcher.canLaunchUrl(uri)) {
      await launcher.launchUrl(uri);
    }
  } catch (e) {
    debugPrint('Erro ao abrir SMS: $e');
  }
}

/// Mostra um modal bottom sheet com opções de mensagem:
/// - WhatsApp (abre o WhatsApp com o número)
/// - SMS normal (abre o app de SMS nativo)
Future<void> showMessageOptions(BuildContext context, String phoneNumber, {String? contactName}) async {
  final name = contactName ?? phoneNumber;
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

  final result = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enviar mensagem para $name',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              cleanedNumber,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat, color: Colors.green, size: 22),
              ),
              title: const Text(
                'WhatsApp',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Abrir conversa no WhatsApp'),
              onTap: () => Navigator.of(ctx).pop('whatsapp'),
            ),
            const Divider(indent: 72, endIndent: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sms_outlined, color: Colors.blue, size: 22),
              ),
              title: const Text(
                'SMS normal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Abrir aplicativo de SMS'),
              onTap: () => Navigator.of(ctx).pop('sms'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  if (result == null || context.mounted == false) return;

  switch (result) {
    case 'whatsapp':
      await _openWhatsApp(cleanedNumber);
    case 'sms':
      await _openSms(cleanedNumber);
  }
}

/// Mostra um modal bottom sheet com opções de contacto:
/// - WhatsApp (abre o WhatsApp com o número)
/// - Chamada normal (abre o discador do telefone)
Future<void> showCallOptions(BuildContext context, String phoneNumber, {String? contactName}) async {
  final name = contactName ?? phoneNumber;
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');

  final result = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ligar para $name',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              cleanedNumber,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat, color: Colors.green, size: 22),
              ),
              title: const Text(
                'WhatsApp',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Abrir conversa no WhatsApp'),
              onTap: () => Navigator.of(ctx).pop('whatsapp'),
            ),
            const Divider(indent: 72, endIndent: 20),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.phone_in_talk, color: Colors.blue, size: 22),
              ),
              title: const Text(
                'Chamada normal',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Ligar pelo discador do telefone'),
              onTap: () => Navigator.of(ctx).pop('call'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );

  if (result == null || context.mounted == false) return;

  switch (result) {
    case 'whatsapp':
      await _openWhatsApp(cleanedNumber);
    case 'call':
      await _makePhoneCall(cleanedNumber);
  }
}
