import 'package:flutter/material.dart';
import 'locale_controller.dart';

/// Classe de tradução centralizada para a app Loah.
/// Suporta português (pt) e inglês (en) com fallback para português.
///
/// USAGE:
///   AppLocales.of(context).translate('drawer_idioma')
///   ou AppLocales.of(context).drawerIdioma
class AppLocales {
  final Locale locale;

  const AppLocales(this.locale);

  // ── Singleton-like access ──────────────────────────────────────
  static AppLocales of(BuildContext context) {
    final controller = LocaleController.of(context);
    return AppLocales(controller.locale);
  }

  /// Retorna o código curto (ex: 'pt', 'en').
  String get languageCode => locale.languageCode;

  // ── Traduções ──────────────────────────────────────────────────
  static const _strings = <String, Map<String, String>>{
    // ═══════ DRAWER / NAVEGAÇÃO ═══════
    'drawer_dashboard': {
      'pt': 'Dashboard',
      'en': 'Dashboard',
    },
    'drawer_metas': {
      'pt': 'Metas',
      'en': 'Goals',
    },
    'drawer_tarefas': {
      'pt': 'Tarefas',
      'en': 'Tasks',
    },
    'drawer_financas': {
      'pt': 'Finanças',
      'en': 'Finances',
    },
    'drawer_contatos': {
      'pt': 'Contatos',
      'en': 'Contacts',
    },
    'drawer_configuracoes': {
      'pt': 'CONFIGURAÇÕES',
      'en': 'SETTINGS',
    },
    'drawer_tema': {
      'pt': 'Tema',
      'en': 'Theme',
    },
    'drawer_idioma': {
      'pt': 'Idioma',
      'en': 'Language',
    },
    'drawer_suporte': {
      'pt': 'SUPORTE',
      'en': 'SUPPORT',
    },
    'drawer_ajuda': {
      'pt': 'Central de Ajuda',
      'en': 'Help Center',
    },
    'drawer_sobre': {
      'pt': 'Sobre Loah',
      'en': 'About Loah',
    },
    'drawer_termos': {
      'pt': 'Termos e Políticas',
      'en': 'Terms & Policies',
    },
    'drawer_admin': {
      'pt': 'ADMIN',
      'en': 'ADMIN',
    },
    'drawer_gerir_utilizadores': {
      'pt': 'Gerir Utilizadores',
      'en': 'Manage Users',
    },
    'drawer_gerir_reflexoes': {
      'pt': 'Gerir Reflexões do Dia',
      'en': 'Manage Daily Reflections',
    },
    'drawer_gerir_ajuda': {
      'pt': 'Gerir Central de Ajuda',
      'en': 'Manage Help Center',
    },
    'drawer_gerir_sobre': {
      'pt': 'Gerir Sobre Loah',
      'en': 'Manage About Loah',
    },
    'drawer_conta': {
      'pt': 'CONTA',
      'en': 'ACCOUNT',
    },
    'drawer_editar_perfil': {
      'pt': 'Editar Perfil',
      'en': 'Edit Profile',
    },
    'drawer_alterar_senha': {
      'pt': 'Alterar senha',
      'en': 'Change password',
    },
    'drawer_sair': {
      'pt': 'Sair',
      'en': 'Log out',
    },

    // ═══════ LANGUAGE SELECTOR ═══════
    'lang_portugues': {
      'pt': 'Português',
      'en': 'Portuguese',
    },
    'lang_english': {
      'pt': 'Inglês',
      'en': 'English',
    },
    'lang_selecionar': {
      'pt': 'Selecionar Idioma',
      'en': 'Select Language',
    },

    // ═══════ BOTTOM NAV ═══════
    'nav_dashboard': {
      'pt': 'Dashboard',
      'en': 'Dashboard',
    },
    'nav_metas': {
      'pt': 'Metas',
      'en': 'Goals',
    },
    'nav_tarefas': {
      'pt': 'Tarefas',
      'en': 'Tasks',
    },
    'nav_financas': {
      'pt': 'Finanças',
      'en': 'Finances',
    },

    // ═══════ PROFILE SCREEN ═══════
    'profile_titulo': {
      'pt': 'Meu Perfil',
      'en': 'My Profile',
    },
    'profile_alterar_foto': {
      'pt': 'Alterar Foto',
      'en': 'Change Photo',
    },
    'profile_camera': {
      'pt': 'Câmera',
      'en': 'Camera',
    },
    'profile_galeria': {
      'pt': 'Galeria',
      'en': 'Gallery',
    },
    'profile_toque_foto': {
      'pt': 'Toque na foto para alterar',
      'en': 'Tap the photo to change',
    },
    'profile_nome': {
      'pt': 'NOME COMPLETO',
      'en': 'FULL NAME',
    },
    'profile_hint_nome': {
      'pt': 'Seu nome completo',
      'en': 'Your full name',
    },
    'profile_email': {
      'pt': 'E-MAIL',
      'en': 'E-MAIL',
    },
    'profile_hint_email': {
      'pt': 'email@exemplo.com',
      'en': 'email@example.com',
    },
    'profile_telemovel': {
      'pt': 'TELEMÓVEL',
      'en': 'PHONE',
    },
    'profile_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'profile_foto_atualizada': {
      'pt': 'Foto atualizada com sucesso!',
      'en': 'Photo updated successfully!',
    },
    'profile_perfil_atualizado': {
      'pt': 'Perfil atualizado com sucesso!',
      'en': 'Profile updated successfully!',
    },
    'profile_validacao_nome': {
      'pt': 'Informe seu nome',
      'en': 'Enter your name',
    },

    // ═══════ COMMON ═══════
    'common_salvar': {
      'pt': 'Salvar',
      'en': 'Save',
    },
    'common_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'common_confirmar': {
      'pt': 'Confirmar',
      'en': 'Confirm',
    },
    'common_carregando': {
      'pt': 'Carregando...',
      'en': 'Loading...',
    },
    'common_erro': {
      'pt': 'Erro',
      'en': 'Error',
    },
    'common_sucesso': {
      'pt': 'Sucesso',
      'en': 'Success',
    },
    'common_voltar': {
      'pt': 'Voltar',
      'en': 'Back',
    },
    'common_pesquisar': {
      'pt': 'Pesquisar',
      'en': 'Search',
    },
    'common_sem_resultados': {
      'pt': 'Sem resultados',
      'en': 'No results',
    },

    // ═══════ LOGIN / AUTH ═══════
    'auth_entrar': {
      'pt': 'Entrar',
      'en': 'Sign In',
    },
    'auth_sair': {
      'pt': 'Sair',
      'en': 'Sign Out',
    },
    'auth_cadastrar': {
      'pt': 'Criar Conta',
      'en': 'Create Account',
    },
    'auth_email': {
      'pt': 'E-mail',
      'en': 'Email',
    },
    'auth_senha': {
      'pt': 'Senha',
      'en': 'Password',
    },
    'auth_recuperar_senha': {
      'pt': 'Recuperar Senha',
      'en': 'Recover Password',
    },

    // ═══════ DASHBOARD ═══════
    'dashboard_resumo': {
      'pt': 'Resumo Financeiro',
      'en': 'Financial Summary',
    },
    'dashboard_saldo': {
      'pt': 'Saldo Total',
      'en': 'Total Balance',
    },
    'dashboard_receitas': {
      'pt': 'Receitas',
      'en': 'Income',
    },
    'dashboard_despesas': {
      'pt': 'Despesas',
      'en': 'Expenses',
    },
    'dashboard_metas_resumo': {
      'pt': 'Metas',
      'en': 'Goals',
    },
    'dashboard_tarefas_resumo': {
      'pt': 'Tarefas',
      'en': 'Tasks',
    },

    // ═══════ FINANCES ═══════
    'financas_titulo': {
      'pt': 'Finanças',
      'en': 'Finances',
    },
    'financas_adicionar': {
      'pt': 'Adicionar Transação',
      'en': 'Add Transaction',
    },
    'financas_contas': {
      'pt': 'Contas',
      'en': 'Accounts',
    },
    'financas_orcamentos': {
      'pt': 'Orçamentos',
      'en': 'Budgets',
    },
    'financas_recorrentes': {
      'pt': 'Recorrentes',
      'en': 'Recurring',
    },
    'financas_relatorios': {
      'pt': 'Relatórios',
      'en': 'Reports',
    },
    'financas_ativos': {
      'pt': 'Ativos',
      'en': 'Assets',
    },

    // ═══════ GOALS ═══════
    'metas_titulo': {
      'pt': 'Metas',
      'en': 'Goals',
    },
    'metas_adicionar': {
      'pt': 'Nova Meta',
      'en': 'New Goal',
    },
    'metas_emergencia': {
      'pt': 'Fundo de Emergência',
      'en': 'Emergency Fund',
    },

    // ═══════ TASKS ═══════
    'tarefas_titulo': {
      'pt': 'Tarefas',
      'en': 'Tasks',
    },
    'tarefas_adicionar': {
      'pt': 'Nova Tarefa',
      'en': 'New Task',
    },
    'tarefas_pendentes': {
      'pt': 'Pendentes',
      'en': 'Pending',
    },
    'tarefas_concluidas': {
      'pt': 'Concluídas',
      'en': 'Completed',
    },
  };

  /// Retorna a string traduzida para a chave fornecida.
  /// Se a chave não existir, retorna a própria chave como fallback.
  String translate(String key) {
    final langMap = _strings[key];
    if (langMap == null) return key;
    return langMap[locale.languageCode] ?? langMap['pt'] ?? key;
  }

  // ── Getters nomeados (conveniência) ────────────────────────────
  String get drawerDashboard => translate('drawer_dashboard');
  String get drawerMetas => translate('drawer_metas');
  String get drawerTarefas => translate('drawer_tarefas');
  String get drawerFinancas => translate('drawer_financas');
  String get drawerContatos => translate('drawer_contatos');
  String get drawerConfiguracoes => translate('drawer_configuracoes');
  String get drawerTema => translate('drawer_tema');
  String get drawerIdioma => translate('drawer_idioma');
  String get drawerSuporte => translate('drawer_suporte');
  String get drawerAjuda => translate('drawer_ajuda');
  String get drawerSobre => translate('drawer_sobre');
  String get drawerTermos => translate('drawer_termos');
  String get drawerAdmin => translate('drawer_admin');
  String get drawerGerirUtilizadores => translate('drawer_gerir_utilizadores');
  String get drawerGerirReflexoes => translate('drawer_gerir_reflexoes');
  String get drawerGerirAjuda => translate('drawer_gerir_ajuda');
  String get drawerGerirSobre => translate('drawer_gerir_sobre');
  String get drawerConta => translate('drawer_conta');
  String get drawerEditarPerfil => translate('drawer_editar_perfil');
  String get drawerAlterarSenha => translate('drawer_alterar_senha');
  String get drawerSair => translate('drawer_sair');

  String get langPortugues => translate('lang_portugues');
  String get langEnglish => translate('lang_english');
  String get langSelecionar => translate('lang_selecionar');
}

