import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

/// Tipos de deep link reconhecidos pela aplicação.
enum DeepLinkType { passwordReset, unknown }

/// Resultado da análise de um deep link recebido.
class DeepLinkData {
  final DeepLinkType type;
  final String? oobCode;

  const DeepLinkData({required this.type, this.oobCode});

  bool get isPasswordReset => type == DeepLinkType.passwordReset;
}

/// Serviço centralizado para captura de deep links / universal links.
///
/// - [getInitialLink]: link que abriu a aplicação (cold start).
/// - [uriLinkStream]: links recebidos enquanto a app está aberta (warm start).
///
/// O fluxo de recovery de senha usa links com o parâmetro `mode=resetPassword`
/// e `oobCode` gerado pelo Firebase Auth (por exemplo, via `authAction`).
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// Callback registado pela camada de navegação (main.dart) para
  /// apresentar a tela de definição de nova senha.
  void Function(String oobCode)? onPasswordReset;

  /// Inicia a escuta de links (warm start) e devolve o link inicial
  /// que abriu a app (cold start), se existir.
  Future<Uri?> initialize() async {
    try {
      _sub = _appLinks.uriLinkStream.listen((uri) {
        _handleUri(uri);
      });

      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        // Pequeno delay para garantir que o navigator já está montado.
        Future.delayed(const Duration(milliseconds: 600), () {
          _handleUri(initial);
        });
      }
      return initial;
    } catch (e) {
      debugPrint('[DeepLinkService] Falha ao inicializar: $e');
      return null;
    }
  }

  void _handleUri(Uri uri) {
    debugPrint('[DeepLinkService] Link recebido: $uri');
    final data = parse(uri);
    if (data.isPasswordReset && data.oobCode != null) {
      onPasswordReset?.call(data.oobCode!);
    }
  }

  /// Analisa o URI e extrai o tipo de link + parâmetros relevantes.
  static DeepLinkData parse(Uri uri) {
    // Firebase Auth app links costumam usar `link` no query param, ex.:
    //   https://loahapp.firebaseapp.com/__/auth/action?mode=resetPassword&oobCode=...
    // ou custom scheme, ex.:
    //   loahapp://reset-password?oobCode=...
    final rawLink = uri.queryParameters['link'] ?? uri.toString();

    Uri resolved;
    try {
      resolved = Uri.parse(rawLink);
    } catch (_) {
      resolved = uri;
    }

    final mode = resolved.queryParameters['mode'];
    final oobCode = resolved.queryParameters['oobCode'];

    if (mode == 'resetPassword' && oobCode != null && oobCode.isNotEmpty) {
      return DeepLinkData(type: DeepLinkType.passwordReset, oobCode: oobCode);
    }

    // Suporte ao custom scheme direto: loahapp://reset-password?oobCode=...
    if (resolved.host == 'reset-password' && oobCode != null && oobCode.isNotEmpty) {
      return DeepLinkData(type: DeepLinkType.passwordReset, oobCode: oobCode);
    }

    return const DeepLinkData(type: DeepLinkType.unknown);
  }

  /// Liberta a subscrição do stream de links.
  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}

