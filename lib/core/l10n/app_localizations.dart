import 'package:flutter/material.dart';
import 'locale_controller.dart';
import '../../models/task_model.dart';
import '../../models/account_model.dart';
import '../../models/asset_model.dart';
import '../../models/transaction_model.dart';

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

    // ═══════ CURRENCY SELECTOR ═══════
    'drawer_moeda': {
      'pt': 'Moeda',
      'en': 'Currency',
    },
    'currency_selecionar': {
      'pt': 'Selecionar Moeda',
      'en': 'Select Currency',
    },
    'currency_pesquisar': {
      'pt': 'Pesquisar moeda...',
      'en': 'Search currency...',
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
    'common_notificacoes': {
      'pt': 'Notificações',
      'en': 'Notifications',
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

    // ═══════ TRANSACTION CATEGORIES ═══════
    'txn_cat_alimentação': {
      'pt': 'Alimentação',
      'en': 'Food',
    },
    'txn_cat_moradia': {
      'pt': 'Moradia',
      'en': 'Housing',
    },
    'txn_cat_transporte': {
      'pt': 'Transporte',
      'en': 'Transport',
    },
    'txn_cat_compras': {
      'pt': 'Compras',
      'en': 'Shopping',
    },
    'txn_cat_saúde': {
      'pt': 'Saúde',
      'en': 'Health',
    },
    'txn_cat_lazer': {
      'pt': 'Lazer',
      'en': 'Leisure',
    },
    'txn_cat_outros': {
      'pt': 'Outros',
      'en': 'Others',
    },
    'txn_cat_salário': {
      'pt': 'Salário',
      'en': 'Salary',
    },
    'txn_cat_freelance': {
      'pt': 'Freelance',
      'en': 'Freelance',
    },
    'txn_cat_investimentos': {
      'pt': 'Investimentos',
      'en': 'Investments',
    },

    // ═══════ ADD TRANSACTION SCREEN ═══════
    'addTxn_editar': {
      'pt': 'Editar Transação',
      'en': 'Edit Transaction',
    },
    'addTxn_novo': {
      'pt': 'Nova Transação',
      'en': 'New Transaction',
    },
    'addTxn_tipo_label': {
      'pt': 'TIPO',
      'en': 'TYPE',
    },
    'addTxn_tipo_despesa': {
      'pt': 'Despesa',
      'en': 'Expense',
    },
    'addTxn_tipo_receita': {
      'pt': 'Receita',
      'en': 'Income',
    },
    'addTxn_valor_label': {
      'pt': 'VALOR',
      'en': 'AMOUNT',
    },
    'addTxn_valor_hint': {
      'pt': '0,00',
      'en': '0.00',
    },
    'addTxn_valor_erro': {
      'pt': 'Informe um valor válido.',
      'en': 'Enter a valid amount.',
    },
    'addTxn_nome_label': {
      'pt': 'NOME',
      'en': 'NAME',
    },
    'addTxn_nome_hint': {
      'pt': 'Ex: Mercado Central',
      'en': 'E.g.: Central Market',
    },
    'addTxn_nome_erro': {
      'pt': 'Dê um nome para a transação.',
      'en': 'Give a name to the transaction.',
    },
    'addTxn_categoria_label': {
      'pt': 'CATEGORIA',
      'en': 'CATEGORY',
    },
    'addTxn_conta_label': {
      'pt': 'CONTA',
      'en': 'ACCOUNT',
    },
    'addTxn_conta_vazia': {
      'pt': 'Nenhuma conta cadastrada — crie uma na tela de Contas antes de lançar transações.',
      'en': 'No accounts yet — create one on the Accounts screen before adding transactions.',
    },
    'addTxn_data_label': {
      'pt': 'DATA',
      'en': 'DATE',
    },
    'addTxn_excluir': {
      'pt': 'Excluir Transação',
      'en': 'Delete Transaction',
    },
    'addTxn_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addTxn_adicionar': {
      'pt': 'Adicionar Transação',
      'en': 'Add Transaction',
    },
    'addTxn_erro_salvar': {
      'pt': 'Erro ao salvar: ',
      'en': 'Error saving: ',
    },
    'addTxn_erro_excluir': {
      'pt': 'Erro ao excluir: ',
      'en': 'Error deleting: ',
    },
    'addTxn_excluir_titulo': {
      'pt': 'Excluir Transação',
      'en': 'Delete Transaction',
    },
    'addTxn_excluir_msg': {
      'pt': 'Tem certeza? Essa ação não pode ser desfeita.',
      'en': 'Are you sure? This action cannot be undone.',
    },
    'addTxn_excluir_confirmar': {
      'pt': 'Excluir',
      'en': 'Delete',
    },
    'addTxn_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'addTxn_sem_conta': {
      'pt': 'Crie uma conta primeiro antes de adicionar transações.',
      'en': 'Create an account first before adding transactions.',
    },

    // ═══════ FINANCES SCREEN ═══════
    'finances_title': {
      'pt': 'Minhas Finanças',
      'en': 'My Finances',
    },
    'finances_patrimonio': {
      'pt': 'Patrimônio',
      'en': 'Assets',
    },
    'finances_orcamento': {
      'pt': 'Orçamento',
      'en': 'Budget',
    },
    'finances_recorrentes': {
      'pt': 'Recorrentes',
      'en': 'Recurring',
    },
    'finances_relatorios': {
      'pt': 'Relatórios',
      'en': 'Reports',
    },
    'finances_ativas': {
      'pt': 'ativas',
      'en': 'active',
    },
    'finances_ver_evolucao': {
      'pt': 'Ver evolução',
      'en': 'See evolution',
    },
    'finances_transacoes_recentes': {
      'pt': 'Transações Recentes',
      'en': 'Recent Transactions',
    },
    'finances_sem_transacoes': {
      'pt': 'Nenhuma transação ainda. Toque no + para adicionar a primeira.',
      'en': 'No transactions yet. Tap + to add your first one.',
    },
    'finances_ver_historico': {
      'pt': 'VER TODO O HISTÓRICO',
      'en': 'VIEW FULL HISTORY',
    },
    'finances_sem_despesas': {
      'pt': 'Nenhuma despesa registrada este mês ainda — a distribuição de gastos aparece aqui assim que você adicionar transações.',
      'en': 'No expenses recorded this month yet — the expense distribution will show up here once you add transactions.',
    },
    'finances_criar_conta_primeiro': {
      'pt': 'Crie uma conta primeiro antes de adicionar transações.',
      'en': 'Create an account first before adding transactions.',
    },
    'finances_total_balance': {
      'pt': 'SALDO TOTAL',
      'en': 'TOTAL BALANCE',
    },
    'finances_income': {
      'pt': 'RECEITAS',
      'en': 'INCOME',
    },
    'finances_expense': {
      'pt': 'DESPESAS',
      'en': 'EXPENSES',
    },

    // ═══════ EXPENSE DISTRIBUTION ═══════
    'expDist_titulo': {
      'pt': 'Distribuição de Gastos',
      'en': 'Expense Distribution',
    },
    'expDist_detalhes': {
      'pt': 'DETALHES',
      'en': 'DETAILS',
    },
    'expDist_mes_vs_anterior': {
      'pt': 'Este mês vs. Anterior',
      'en': 'This month vs. Last month',
    },
    'expDist_gasto_total': {
      'pt': 'gasto total',
      'en': 'total spent',
    },
    'expDist_total_gasto_label': {
      'pt': 'TOTAL GASTO (ESTE MÊS)',
      'en': 'TOTAL SPENT (THIS MONTH)',
    },
    'expDist_categorias': {
      'pt': 'Categorias',
      'en': 'Categories',
    },
    'expDist_detalhamento': {
      'pt': 'Detalhamento por Categoria',
      'en': 'Breakdown by Category',
    },
    'expDist_sem_despesas': {
      'pt': 'Nenhuma despesa registrada este mês ainda.',
      'en': 'No expenses recorded this month yet.',
    },
    'expDist_mais': {
      'pt': 'a mais',
      'en': 'more',
    },
    'expDist_menos': {
      'pt': 'a menos',
      'en': 'less',
    },
    'expDist_que_mes_passado': {
      'pt': 'que o mês passado',
      'en': 'than last month',
    },
    'expDist_pct_total': {
      'pt': '% do total',
      'en': '% of total',
    },

    // ═══════ CATEGORY COMPARISON ═══════
    'catComp_este_mes': {
      'pt': 'Este mês',
      'en': 'This month',
    },
    'catComp_mes_anterior': {
      'pt': 'Mês anterior',
      'en': 'Last month',
    },

    // ═══════ BUDGETS SCREEN ═══════
    'budgets_titulo': {
      'pt': 'Orçamento',
      'en': 'Budget',
    },
    'budgets_gasto_mes': {
      'pt': 'GASTO DO MÊS (CATEGORIAS ORÇADAS)',
      'en': 'MONTHLY SPENDING (BUDGETED CATEGORIES)',
    },
    'budgets_sem_orcamentos': {
      'pt': 'Nenhum orçamento definido ainda. Toque no + para criar o primeiro.',
      'en': 'No budgets defined yet. Tap + to create the first one.',
    },

    // ═══════ BUDGET CARD ═══════
    'budgetCard_acima_limite': {
      'pt': '%s de %s — %s acima do limite',
      'en': '%s of %s — %s over limit',
    },
    'budgetCard_gasto': {
      'pt': '%s de %s',
      'en': '%s of %s',
    },

    // ═══════ ADD BUDGET SCREEN ═══════
    'addBudget_editar': {
      'pt': 'Editar Orçamento',
      'en': 'Edit Budget',
    },
    'addBudget_novo': {
      'pt': 'Novo Orçamento',
      'en': 'New Budget',
    },
    'addBudget_categoria_label': {
      'pt': 'CATEGORIA',
      'en': 'CATEGORY',
    },
    'addBudget_todas_categorias': {
      'pt': 'Todas as categorias de despesa já têm um orçamento definido.',
      'en': 'All expense categories already have a budget set.',
    },
    'addBudget_limite_label': {
      'pt': 'LIMITE MENSAL',
      'en': 'MONTHLY LIMIT',
    },
    'addBudget_excluir': {
      'pt': 'Excluir Orçamento',
      'en': 'Delete Budget',
    },
    'addBudget_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addBudget_criar': {
      'pt': 'Criar Orçamento',
      'en': 'Create Budget',
    },
    'addBudget_erro_salvar': {
      'pt': 'Erro ao salvar: ',
      'en': 'Error saving: ',
    },
    'addBudget_erro_excluir': {
      'pt': 'Erro ao excluir: ',
      'en': 'Error deleting: ',
    },
    'addBudget_erro_valor': {
      'pt': 'Informe um valor válido.',
      'en': 'Enter a valid amount.',
    },
    'addBudget_excluir_titulo': {
      'pt': 'Excluir Orçamento',
      'en': 'Delete Budget',
    },
    'addBudget_excluir_msg': {
      'pt': 'Tem certeza? Essa ação não pode ser desfeita.',
      'en': 'Are you sure? This action cannot be undone.',
    },
    'addBudget_excluir_confirmar': {
      'pt': 'Excluir',
      'en': 'Delete',
    },
    'addBudget_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },

    // ═══════ RECURRING TRANSACTION CARD ═══════
    'recurring_todo_dia': {
      'pt': 'Todo dia %s',
      'en': 'Every day %s',
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
    'tasks_minhas_tarefas': {
      'pt': 'Minhas Tarefas',
      'en': 'My Tasks',
    },
    'tasks_hoje': {
      'pt': 'Hoje',
      'en': 'Today',
    },
    'tasks_proximos_dias': {
      'pt': 'Próximos Dias',
      'en': 'Upcoming Days',
    },
    'tasks_concluidos': {
      'pt': 'Concluídos',
      'en': 'Completed',
    },
    'tasks_nenhuma_hoje': {
      'pt': 'Nenhuma tarefa para hoje.',
      'en': 'No tasks for today.',
    },
    'tasks_nenhuma_futura': {
      'pt': 'Nenhuma tarefa futura.',
      'en': 'No upcoming tasks.',
    },
    'tasks_nenhuma_concluida': {
      'pt': 'Nenhuma tarefa concluída.',
      'en': 'No completed tasks.',
    },
    'tasks_erro_carregar': {
      'pt': 'Erro ao carregar tarefas: ',
      'en': 'Error loading tasks: ',
    },
    'tasks_amanha': {
      'pt': 'Amanhã',
      'en': 'Tomorrow',
    },
    'tasks_esta_semana': {
      'pt': 'Esta Semana',
      'en': 'This Week',
    },
    'tasks_este_mes': {
      'pt': 'Este Mês',
      'en': 'This Month',
    },
    'tasks_limpar': {
      'pt': 'Limpar',
      'en': 'Clear',
    },
    'tasks_limpar_filtros': {
      'pt': 'Limpar Filtros',
      'en': 'Clear Filters',
    },

    // ═══════ WEEKDAYS ═══════
    'weekday_segunda': {'pt': 'Segunda-feira', 'en': 'Monday'},
    'weekday_terca': {'pt': 'Terça-feira', 'en': 'Tuesday'},
    'weekday_quarta': {'pt': 'Quarta-feira', 'en': 'Wednesday'},
    'weekday_quinta': {'pt': 'Quinta-feira', 'en': 'Thursday'},
    'weekday_sexta': {'pt': 'Sexta-feira', 'en': 'Friday'},
    'weekday_sabado': {'pt': 'Sábado', 'en': 'Saturday'},
    'weekday_domingo': {'pt': 'Domingo', 'en': 'Sunday'},

    // ═══════ FULL MONTHS ═══════
    'mes_full_janeiro': {'pt': 'Janeiro', 'en': 'January'},
    'mes_full_fevereiro': {'pt': 'Fevereiro', 'en': 'February'},
    'mes_full_marco': {'pt': 'Março', 'en': 'March'},
    'mes_full_abril': {'pt': 'Abril', 'en': 'April'},
    'mes_full_maio': {'pt': 'Maio', 'en': 'May'},
    'mes_full_junho': {'pt': 'Junho', 'en': 'June'},
    'mes_full_julho': {'pt': 'Julho', 'en': 'July'},
    'mes_full_agosto': {'pt': 'Agosto', 'en': 'August'},
    'mes_full_setembro': {'pt': 'Setembro', 'en': 'September'},
    'mes_full_outubro': {'pt': 'Outubro', 'en': 'October'},
    'mes_full_novembro': {'pt': 'Novembro', 'en': 'November'},
    'mes_full_dezembro': {'pt': 'Dezembro', 'en': 'December'},

    // ═══════ TASK PRIORITY ═══════
    'prio_alta': {'pt': 'Alta Prioridade', 'en': 'High Priority'},
    'prio_media': {'pt': 'Média Prioridade', 'en': 'Medium Priority'},
    'prio_baixa': {'pt': 'Baixa Prioridade', 'en': 'Low Priority'},
    'prio_alta_short': {'pt': 'Alta', 'en': 'High'},
    'prio_media_short': {'pt': 'Média', 'en': 'Medium'},
    'prio_baixa_short': {'pt': 'Baixa', 'en': 'Low'},

    // ═══════ TASK STATUS ═══════
    'status_nao_iniciada': {'pt': 'Não Iniciada', 'en': 'Not Started'},
    'status_em_progresso': {'pt': 'Em Progresso', 'en': 'In Progress'},
    'status_concluida': {'pt': 'Concluída', 'en': 'Completed'},

    // ═══════ ADD TASK SCREEN ═══════
    'addTask_editar': {
      'pt': 'Editar Tarefa',
      'en': 'Edit Task',
    },
    'addTask_adicionar': {
      'pt': 'Adicionar Tarefa',
      'en': 'Add Task',
    },
    'addTask_nome_label': {
      'pt': 'NOME DA TAREFA',
      'en': 'TASK NAME',
    },
    'addTask_nome_hint': {
      'pt': 'Ex: Pesquisar modelos de SUV',
      'en': 'E.g.: Research SUV models',
    },
    'addTask_nome_erro': {
      'pt': 'Dê um nome para a tarefa.',
      'en': 'Give a name to the task.',
    },
    'addTask_meta_label': {
      'pt': 'META RELACIONADA',
      'en': 'RELATED GOAL',
    },
    'addTask_descricao_label': {
      'pt': 'DESCRIÇÃO',
      'en': 'DESCRIPTION',
    },
    'addTask_descricao_hint': {
      'pt': 'Detalhes importantes para esta etapa...',
      'en': 'Important details for this step...',
    },
    'addTask_data_label': {
      'pt': 'DATA DE ENTREGA',
      'en': 'DUE DATE',
    },
    'addTask_data_hint': {
      'pt': 'dd/mm/aaaa',
      'en': 'dd/mm/yyyy',
    },
    'addTask_prioridade_label': {
      'pt': 'PRIORIDADE',
      'en': 'PRIORITY',
    },
    'addTask_dica': {
      'pt': 'Lembre-se: pequenas tarefas são mais fáceis de completar. Tente dividir metas grandes em passos de 15 a 30 minutos.',
      'en': 'Remember: small tasks are easier to complete. Try breaking big goals into 15-30 minute steps.',
    },
    'addTask_excluir': {
      'pt': 'Excluir Tarefa',
      'en': 'Delete Task',
    },
    'addTask_salvar_alteracoes': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addTask_criar': {
      'pt': 'Criar Tarefa',
      'en': 'Create Task',
    },
    'addTask_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'addTask_erro_salvar': {
      'pt': 'Erro ao salvar tarefa: ',
      'en': 'Error saving task: ',
    },
    'addTask_erro_excluir': {
      'pt': 'Erro ao excluir tarefa: ',
      'en': 'Error deleting task: ',
    },
    'addTask_excluir_titulo': {
      'pt': 'Excluir Tarefa',
      'en': 'Delete Task',
    },
    'addTask_excluir_msg': {
      'pt': 'Tem certeza? Essa ação não pode ser desfeita.',
      'en': 'Are you sure? This action cannot be undone.',
    },
    'addTask_excluir_confirmar': {
      'pt': 'Excluir',
      'en': 'Delete',
    },
    'addTask_meta_vincular': {
      'pt': 'Vincular a uma meta',
      'en': 'Link to a goal',
    },

    // ═══════ TASK DATE LABELS ═══════
    'task_completed_label': {
      'pt': 'Concluído em {date}',
      'en': 'Completed on {date}',
    },
    'task_created_label': {
      'pt': 'Criada em {date}',
      'en': 'Created on {date}',
    },
    'due_date_long_label': {
      'pt': '{date}',
      'en': '{date}',
    },

    // ═══════ TASK DETAIL ═══════
    'taskDetail_titulo': {
      'pt': 'Detalhes da Tarefa',
      'en': 'Task Details',
    },
    'taskDetail_meta_label': {
      'pt': 'META RELACIONADA',
      'en': 'RELATED GOAL',
    },
    'taskDetail_descricao_label': {
      'pt': 'DESCRIÇÃO',
      'en': 'DESCRIPTION',
    },
    'taskDetail_data_entrega': {
      'pt': 'Data de Entrega',
      'en': 'Due Date',
    },
    'taskDetail_prioridade': {
      'pt': 'Prioridade',
      'en': 'Priority',
    },
    'taskDetail_status': {
      'pt': 'Status',
      'en': 'Status',
    },
    'taskDetail_alterar_status': {
      'pt': 'Alterar Status',
      'en': 'Change Status',
    },
    'taskDetail_status_pendente_sub': {
      'pt': 'Tarefa ainda não iniciada',
      'en': 'Task not yet started',
    },
    'taskDetail_status_progresso_sub': {
      'pt': 'Tarefa em andamento',
      'en': 'Task in progress',
    },
    'taskDetail_status_concluida_sub': {
      'pt': 'Tarefa finalizada',
      'en': 'Task completed',
    },
    'taskDetail_marcar_concluida': {
      'pt': 'Marcar como Concluída',
      'en': 'Mark as Completed',
    },
    'taskDetail_reabrir': {
      'pt': 'Reabrir Tarefa',
      'en': 'Reopen Task',
    },
    'taskDetail_editar': {
      'pt': 'Editar Tarefa',
      'en': 'Edit Task',
    },
    'taskDetail_erro_atualizar': {
      'pt': 'Erro ao atualizar tarefa: ',
      'en': 'Error updating task: ',
    },
    'taskDetail_erro_status': {
      'pt': 'Erro ao atualizar status: ',
      'en': 'Error updating status: ',
    },
    'taskDetail_criada_em': {
      'pt': 'Criada em ',
      'en': 'Created on ',
    },
    'taskDetail_concluido_em': {
      'pt': 'Concluído em ',
      'en': 'Completed on ',
    },

    // ═══════ TASK FILTER ═══════
    'taskFilter_titulo': {
      'pt': 'Filtrar Tarefas',
      'en': 'Filter Tasks',
    },
    'taskFilter_limpar_tudo': {
      'pt': 'Limpar tudo',
      'en': 'Clear all',
    },
    'taskFilter_status': {
      'pt': 'STATUS',
      'en': 'STATUS',
    },
    'taskFilter_prioridade': {
      'pt': 'PRIORIDADE',
      'en': 'PRIORITY',
    },
    'taskFilter_data': {
      'pt': 'DATA',
      'en': 'DATE',
    },
    'taskFilter_aplicar': {
      'pt': 'Aplicar Filtros',
      'en': 'Apply Filters',
    },

    // ═══════ TASK SEARCH ═══════
    'taskSearch_hint': {
      'pt': 'Buscar tarefas...',
      'en': 'Search tasks...',
    },

    // ═══════ RELATED GOAL ═══════
    'relatedGoal_meta_de': {
      'pt': 'Meta de ',
      'en': 'Goal of ',
    },
    'relatedGoal_nenhuma': {
      'pt': 'Nenhuma meta selecionada (tarefa avulsa)',
      'en': 'No goal selected (standalone task)',
    },

// ═══════ GOAL TERM ═══════
    'goalTerm_curto_prazo': {
      'pt': 'Curto Prazo',
      'en': 'Short Term',
    },
    'goalTerm_medio_prazo': {
      'pt': 'Médio Prazo',
      'en': 'Medium Term',
    },
    'goalTerm_longo_prazo': {
      'pt': 'Longo Prazo',
      'en': 'Long Term',
    },
    // Short forms (for chip selectors)
    'goalTerm_curto_short': {
      'pt': 'Curto',
      'en': 'Short',
    },
    'goalTerm_medio_short': {
      'pt': 'Médio',
      'en': 'Medium',
    },
    'goalTerm_longo_short': {
      'pt': 'Longo',
      'en': 'Long',
    },
    'goalTerm_horizon_curto_prazo': {
      'pt': 'Este Mês',
      'en': 'This Month',
    },
    'goalTerm_horizon_medio_prazo': {
      'pt': 'Este Ano',
      'en': 'This Year',
    },
    'goalTerm_horizon_longo_prazo': {
      'pt': '2+ Anos',
      'en': '2+ Years',
    },
    'goalTerm_meta_de': {
      'pt': 'Meta de ',
      'en': 'Goal of ',
    },

    // ═══════ GOALS SCREEN ═══════
    'goals_minhas_metas': {
      'pt': 'Minhas Metas',
      'en': 'My Goals',
    },
    'goals_summary_title': {
      'pt': 'Metas',
      'en': 'Goals',
    },
    'goals_summary_completion': {
      'pt': 'Você completou %s% do seu planejamento trimestral.',
      'en': 'You have completed %s% of your quarterly planning.',
    },

    // ═══════ ADD GOAL SCREEN ═══════
    'category_financeiro': {
      'pt': 'Financeiro',
      'en': 'Financial',
    },
    'category_saúde': {
      'pt': 'Saúde',
      'en': 'Health',
    },
    'category_carreira': {
      'pt': 'Carreira',
      'en': 'Career',
    },
    'category_viagem': {
      'pt': 'Viagem',
      'en': 'Travel',
    },
    'category_investimento': {
      'pt': 'Investimento',
      'en': 'Investment',
    },
    'category_pessoal': {
      'pt': 'Pessoal',
      'en': 'Personal',
    },
    'addGoal_editar': {
      'pt': 'Editar Meta',
      'en': 'Edit Goal',
    },
    'addGoal_novo': {
      'pt': 'Nova Meta',
      'en': 'New Goal',
    },
    'addGoal_subtitle_editar': {
      'pt': 'Ajuste os detalhes da sua meta.',
      'en': 'Adjust the details of your goal.',
    },
    'addGoal_subtitle_novo': {
      'pt': 'Defina seus objetivos e acompanhe sua evolução passo a passo.',
      'en': 'Set your goals and track your progress step by step.',
    },
    'addGoal_nome_label': {
      'pt': 'Nome da Meta',
      'en': 'Goal Name',
    },
    'addGoal_nome_hint': {
      'pt': 'Ex: Comprar um Carro',
      'en': 'E.g.: Buy a Car',
    },
    'addGoal_nome_erro': {
      'pt': 'Dê um nome para a meta.',
      'en': 'Give a name to the goal.',
    },
    'addGoal_foto_label': {
      'pt': 'Foto da Meta (Opcional)',
      'en': 'Goal Photo (Optional)',
    },
    'addGoal_foto_tap': {
      'pt': 'Toque para adicionar uma foto',
      'en': 'Tap to add a photo',
    },
    'addGoal_galeria': {
      'pt': 'Escolher da Galeria',
      'en': 'Choose from Gallery',
    },
    'addGoal_camera': {
      'pt': 'Tirar Foto',
      'en': 'Take Photo',
    },
    'addGoal_categoria_label': {
      'pt': 'Categoria',
      'en': 'Category',
    },
    'addGoal_prazo_label': {
      'pt': 'Prazo',
      'en': 'Term',
    },
    'addGoal_descricao_label': {
      'pt': 'Descrição',
      'en': 'Description',
    },
    'addGoal_descricao_hint': {
      'pt': 'Detalhes sobre sua meta...',
      'en': 'Details about your goal...',
    },
    'addGoal_data_label': {
      'pt': 'Data Alvo',
      'en': 'Target Date',
    },
    'addGoal_data_hint': {
      'pt': 'dd/mm/aaaa',
      'en': 'dd/mm/yyyy',
    },
    'addGoal_valor_label': {
      'pt': 'Valor Alvo (Opcional)',
      'en': 'Target Value (Optional)',
    },
    'addGoal_valor_hint': {
      'pt': '0,00',
      'en': '0.00',
    },
    'addGoal_dica_titulo': {
      'pt': 'Dica de Especialista',
      'en': 'Expert Tip',
    },
    'addGoal_dica_body': {
      'pt': 'Metas claras e com prazos definidos têm 3x mais chances de serem concluídas. Você está no caminho certo!',
      'en': 'Clear goals with defined deadlines are 3x more likely to be completed. You are on the right track!',
    },
    'addGoal_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addGoal_criar': {
      'pt': 'Criar Meta',
      'en': 'Create Goal',
    },
    'addGoal_erro_salvar': {
      'pt': 'Erro ao salvar meta: ',
      'en': 'Error saving goal: ',
    },

    // ═══════ GOAL DETAIL ═══════
    'goalDetail_concluido': {
      'pt': 'CONCLUÍDO',
      'en': 'COMPLETED',
    },
    'goalDetail_editar': {
      'pt': 'Editar Meta',
      'en': 'Edit Goal',
    },
    'goalDetail_adicionar_tarefa': {
      'pt': 'Adicionar Tarefa',
      'en': 'Add Task',
    },
    'goalDetail_marcos_titulo': {
      'pt': 'Marcos & Tarefas',
      'en': 'Milestones & Tasks',
    },
    'goalDetail_marcos_subtitulo': {
      'pt': '%s de %s completas',
      'en': '%s of %s complete',
    },
    'goalDetail_nenhuma_tarefa': {
      'pt': 'Nenhuma tarefa vinculada a esta meta ainda.',
      'en': 'No tasks linked to this goal yet.',
    },
    'goalDetail_atualizar_valor': {
      'pt': 'Atualizar Valor',
      'en': 'Update Value',
    },
    'goalDetail_valor_atual': {
      'pt': '%s de %s',
      'en': '%s of %s',
    },
    'goalDetail_ajustar_titulo': {
      'pt': 'Atualizar Valor',
      'en': 'Update Value',
    },
    'goalDetail_ajustar_hint': {
      'pt': '0,00',
      'en': '0.00',
    },
    'goalDetail_remover': {
      'pt': 'Remover',
      'en': 'Remove',
    },
    'goalDetail_adicionar': {
      'pt': 'Adicionar',
      'en': 'Add',
    },
    'goalDetail_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'goalDetail_erro_tarefa': {
      'pt': 'Erro ao atualizar tarefa: ',
      'en': 'Error updating task: ',
    },
    'goalDetail_erro_progresso': {
      'pt': 'Erro ao atualizar progresso: ',
      'en': 'Error updating progress: ',
    },
    'goalDetail_erro_salvar': {
      'pt': 'Erro ao salvar meta: ',
      'en': 'Error saving goal: ',
    },

    // ═══════ GOAL CARD ═══════
    'goalCard_tarefas_concluidas': {
      'pt': '%s de %s tarefas concluídas',
      'en': '%s of %s tasks completed',
    },

    // ═══════ DASHBOARD GOALS SUMMARY ═══════
    'goals_summary_atuais': {
      'pt': 'Metas Atuais',
      'en': 'Current Goals',
    },
    'goals_summary_ver_todas': {
      'pt': 'Ver todas',
      'en': 'See all',
    },

    // ═══════ GOAL PICKER ═══════
    'goalPicker_titulo': {
      'pt': 'Vincular a uma meta',
      'en': 'Link to a goal',
    },
    'goalPicker_nenhuma': {
      'pt': 'Nenhuma (tarefa avulsa)',
      'en': 'None (standalone task)',
    },

    // ═══════ CONTACTS SCREEN ═══════
    'contacts_titulo': {
      'pt': 'Meus Contactos',
      'en': 'My Contacts',
    },
    'contacts_favoritos': {
      'pt': 'FAVORITOS',
      'en': 'FAVORITES',
    },
    'contacts_sem_contatos': {
      'pt': 'Nenhum contato ainda. Adicione um novo contato!',
      'en': 'No contacts yet. Add a new contact!',
    },
    'contacts_sem_filtros': {
      'pt': 'Nenhum contato encontrado com esses filtros.',
      'en': 'No contacts found with these filters.',
    },
    'contacts_erro_carregar': {
      'pt': 'Erro ao carregar contatos: ',
      'en': 'Error loading contacts: ',
    },
    'contacts_erro_favorito': {
      'pt': 'Erro ao atualizar favorito: ',
      'en': 'Error updating favorite: ',
    },
    'contacts_sem_telefone': {
      'pt': 'Nenhum número de telefone',
      'en': 'No phone number',
    },

    // ═══════ ADD / EDIT CONTACT ═══════
    'addContact_titulo_novo': {
      'pt': 'Novo Contato',
      'en': 'New Contact',
    },
    'addContact_titulo_editar': {
      'pt': 'Editar Contato',
      'en': 'Edit Contact',
    },
    'addContact_salvar': {
      'pt': 'Salvar',
      'en': 'Save',
    },
    'addContact_escolher_galeria': {
      'pt': 'Escolher da Galeria',
      'en': 'Choose from Gallery',
    },
    'addContact_tirar_foto': {
      'pt': 'Tirar Foto',
      'en': 'Take Photo',
    },
    'addContact_toque_foto': {
      'pt': 'Toque para adicionar foto',
      'en': 'Tap to add photo',
    },
    'addContact_nome_label': {
      'pt': 'NOME COMPLETO',
      'en': 'FULL NAME',
    },
    'addContact_nome_hint': {
      'pt': 'Nome completo',
      'en': 'Full name',
    },
    'addContact_nome_erro': {
      'pt': 'Dê um nome para o contato.',
      'en': 'Give a name to the contact.',
    },
    'addContact_email_label': {
      'pt': 'E-MAIL (OPCIONAL)',
      'en': 'EMAIL (OPTIONAL)',
    },
    'addContact_email_hint': {
      'pt': 'email@exemplo.com',
      'en': 'email@example.com',
    },
    'addContact_telefone_label': {
      'pt': 'TELEFONE',
      'en': 'PHONE',
    },
    'addContact_telefone_hint': {
      'pt': '9xxxxxxxx',
      'en': '9xxxxxxxx',
    },
    'addContact_grau_label': {
      'pt': 'GRAU DE CONEXÃO',
      'en': 'CONNECTION DEGREE',
    },
    'addContact_salvar_alteracoes': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addContact_salvar_contato': {
      'pt': 'Salvar Contato',
      'en': 'Save Contact',
    },
    'addContact_erro_salvar': {
      'pt': 'Erro ao salvar contato: ',
      'en': 'Error saving contact: ',
    },

    // ═══════ CONTACT DETAIL ═══════
    'contactDetail_favoritar_titulo': {
      'pt': 'Adicionar aos favoritos',
      'en': 'Add to favorites',
    },
    'contactDetail_desfavoritar_titulo': {
      'pt': 'Remover dos favoritos',
      'en': 'Remove from favorites',
    },
    'contactDetail_favoritar_msg': {
      'pt': 'Deseja adicionar',
      'en': 'Do you want to add',
    },
    'contactDetail_desfavoritar_msg': {
      'pt': 'Deseja remover',
      'en': 'Do you want to remove',
    },
    'contactDetail_aos_favoritos': {
      'pt': 'aos favoritos?',
      'en': 'to favorites?',
    },
    'contactDetail_dos_favoritos': {
      'pt': 'dos favoritos?',
      'en': 'from favorites?',
    },
    'contactDetail_confirmar': {
      'pt': 'Confirmar',
      'en': 'Confirm',
    },
    'contactDetail_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'contactDetail_erro_favorito': {
      'pt': 'Erro ao atualizar favorito: ',
      'en': 'Error updating favorite: ',
    },
    'contactDetail_erro_interacao': {
      'pt': 'Erro ao registrar interação: ',
      'en': 'Error logging interaction: ',
    },
    'contactDetail_erro_remover_interacao': {
      'pt': 'Erro ao remover interação: ',
      'en': 'Error removing interaction: ',
    },
    'contactDetail_erro_remover_contato': {
      'pt': 'Erro ao remover contato: ',
      'en': 'Error removing contact: ',
    },
    'contactDetail_remover_contato_titulo': {
      'pt': 'Remover contato',
      'en': 'Remove contact',
    },
    'contactDetail_remover_contato_msg': {
      'pt': 'Tem certeza que deseja remover',
      'en': 'Are you sure you want to remove',
    },
    'contactDetail_remover_contato_suffix': {
      'pt': 'da sua lista de contatos? Esta ação não pode ser desfeita.',
      'en': 'from your contact list? This action cannot be undone.',
    },
    'contactDetail_remover': {
      'pt': 'Remover',
      'en': 'Remove',
    },
    'contactDetail_ultimo_contato': {
      'pt': 'ÚLTIMO CONTATO',
      'en': 'LAST CONTACT',
    },
    'contactDetail_nenhum_ainda': {
      'pt': 'Nenhum ainda',
      'en': 'None yet',
    },
    'contactDetail_sem_lembrete': {
      'pt': 'Sem lembrete',
      'en': 'No reminder',
    },
    'contactDetail_toda_semana': {
      'pt': 'Toda semana',
      'en': 'Every week',
    },
    'contactDetail_15_dias': {
      'pt': 'A cada 15 dias',
      'en': 'Every 15 days',
    },
    'contactDetail_todo_mes': {
      'pt': 'Todo mês',
      'en': 'Every month',
    },
    'contactDetail_a_cada': {
      'pt': 'A cada',
      'en': 'Every',
    },
    'contactDetail_dias': {
      'pt': 'dias',
      'en': 'days',
    },
    'contactDetail_tipo_interacao': {
      'pt': 'Tipo de Interação',
      'en': 'Interaction Type',
    },
    'contactDetail_presencial': {
      'pt': 'Presencial',
      'en': 'In Person',
    },
    'contactDetail_presencial_sub': {
      'pt': 'Encontrou pessoalmente',
      'en': 'Met in person',
    },
    'contactDetail_redes_sociais': {
      'pt': 'Redes Sociais',
      'en': 'Social Media',
    },
    'contactDetail_redes_sociais_sub': {
      'pt': 'Instagram, WhatsApp, Twitter...',
      'en': 'Instagram, WhatsApp, Twitter...',
    },
    'contactDetail_email_interacao': {
      'pt': 'Email',
      'en': 'Email',
    },
    'contactDetail_email_interacao_sub': {
      'pt': 'Enviou ou respondeu um email',
      'en': 'Sent or replied to an email',
    },
    'contactDetail_presente': {
      'pt': 'Presente',
      'en': 'Gift',
    },
    'contactDetail_presente_sub': {
      'pt': 'Enviou ou recebeu um presente',
      'en': 'Sent or received a gift',
    },
    'contactDetail_outro': {
      'pt': 'Outro',
      'en': 'Other',
    },
    'contactDetail_outro_sub': {
      'pt': 'Outro tipo de interação',
      'en': 'Other type of interaction',
    },
    'contactDetail_sem_telefone': {
      'pt': 'Nenhum número de telefone',
      'en': 'No phone number',
    },
    'contactDetail_registrar_contato': {
      'pt': 'Registrar Contato',
      'en': 'Log Contact',
    },
    'contactDetail_ligacao': {
      'pt': 'Ligação',
      'en': 'Call',
    },
    'contactDetail_mensagem': {
      'pt': 'Mensagem',
      'en': 'Message',
    },
    'contactDetail_historico': {
      'pt': 'Histórico',
      'en': 'History',
    },
    'contactDetail_sem_interacoes': {
      'pt': 'Nenhuma interação registrada ainda.',
      'en': 'No interactions recorded yet.',
    },
    'contactDetail_remover_interacao_titulo': {
      'pt': 'Remover interação',
      'en': 'Remove interaction',
    },
    'contactDetail_remover_interacao_msg': {
      'pt': 'Tem certeza que deseja remover esta interação do histórico?',
      'en': 'Are you sure you want to remove this interaction from history?',
    },
    'contactDetail_editar_contato': {
      'pt': 'Editar Contato',
      'en': 'Edit Contact',
    },
    'contactDetail_remover_contato_btn': {
      'pt': 'Remover Contato',
      'en': 'Remove Contact',
    },
'contactDetail_atrasado_prefix': {
      'pt': 'Já se passaram',
      'en': 'It has been',
    },
    'contactDetail_atrasado_dias': {
      'pt': 'dias desde o último contato. Que tal ligar pra',
      'en': 'days since the last contact. How about calling',
    },
    'contactDetail_atrasado_meio': {
      'pt': '',
      'en': '',
    },
    'contactDetail_atrasado_suffix': {
      'pt': '?',
      'en': '?',
    },
    'contactDetail_tooltip_favoritar': {
      'pt': 'Adicionar aos favoritos',
      'en': 'Add to favorites',
    },
    'contactDetail_tooltip_desfavoritar': {
      'pt': 'Remover dos favoritos',
      'en': 'Remove from favorites',
    },
    'contactDetail_erro_frequencia': {
      'pt': 'Erro ao atualizar frequência: ',
      'en': 'Error updating frequency: ',
    },

    // ═══════ CONTACT FILTER ═══════
    'contactFilter_titulo': {
      'pt': 'Filtrar Contatos',
      'en': 'Filter Contacts',
    },
    'contactFilter_limpar': {
      'pt': 'Limpar',
      'en': 'Clear',
    },
    'contactFilter_favoritos': {
      'pt': 'Somente favoritos',
      'en': 'Favorites only',
    },
    'contactFilter_grau': {
      'pt': 'GRAU DE CONEXÃO',
      'en': 'CONNECTION DEGREE',
    },
    'contactFilter_aplicar': {
      'pt': 'Aplicar Filtros',
      'en': 'Apply Filters',
    },

    // ═══════ CONTACT SEARCH ═══════
    'contactSearch_hint': {
      'pt': 'Buscar contatos...',
      'en': 'Search contacts...',
    },

    // ═══════ COUNTRY CODE PICKER ═══════
    'countryPicker_titulo': {
      'pt': 'Código do País',
      'en': 'Country Code',
    },
    'countryPicker_buscar': {
      'pt': 'Buscar país ou código...',
      'en': 'Search country or code...',
    },
'countryPicker_nao_encontrei': {
      'pt': 'Não encontrei — digitar código',
      'en': 'Not found — type code',
    },
    'countryPicker_digitar': {
      'pt': 'Não encontrei — digitar código',
      'en': 'Not found — type code',
    },
    'countryPicker_usar_codigo': {
      'pt': 'Usar este código',
      'en': 'Use this code',
    },
    'countryPicker_digitar_manualmente': {
      'pt': 'Digitar código manualmente',
      'en': 'Type code manually',
    },

    // ═══════ INTERACTION TYPES ═══════
    'interaction_ligacao': {
      'pt': 'Ligação',
      'en': 'Call',
    },
    'interaction_mensagem': {
      'pt': 'Mensagem',
      'en': 'Message',
    },
    'interaction_encontro': {
      'pt': 'Encontro',
      'en': 'Meeting',
    },
    'interaction_outro': {
      'pt': 'Outro',
      'en': 'Other',
    },

// ═══════ RELATIONSHIP TAGS (Grau de Conexão) ═══════
    'rel_familiar': {
      'pt': 'Familiar',
      'en': 'Family',
    },
    'rel_amigo': {
      'pt': 'Amigo',
      'en': 'Friend',
    },
    'rel_namorada': {
      'pt': 'Namorada',
      'en': 'Girlfriend',
    },
    'rel_pai': {
      'pt': 'Pai',
      'en': 'Father',
    },
    'rel_mae': {
      'pt': 'Mãe',
      'en': 'Mother',
    },
    'rel_conhecido': {
      'pt': 'Conhecido',
      'en': 'Acquaintance',
    },
    'rel_colega': {
      'pt': 'Colega',
      'en': 'Colleague',
    },

// ═══════ RELATIVE TIME ═══════
    'relative_ha': {
      'pt': 'há',
      'en': '',
    },
    'relative_min': {
      'pt': 'min',
      'en': 'min',
    },
    'relative_hoje': {
      'pt': 'Hoje',
      'en': 'Today',
    },
    'relative_ontem': {
      'pt': 'Ontem',
      'en': 'Yesterday',
    },
    'relative_dias': {
      'pt': 'dias',
      'en': 'days',
    },

    // ═══════ MONTH ABBREVIATIONS ═══════
    'mes_jan': {'pt': 'Jan', 'en': 'Jan'},
    'mes_fev': {'pt': 'Fev', 'en': 'Feb'},
    'mes_mar': {'pt': 'Mar', 'en': 'Mar'},
    'mes_abr': {'pt': 'Abr', 'en': 'Apr'},
    'mes_mai': {'pt': 'Mai', 'en': 'May'},
    'mes_jun': {'pt': 'Jun', 'en': 'Jun'},
    'mes_jul': {'pt': 'Jul', 'en': 'Jul'},
    'mes_ago': {'pt': 'Ago', 'en': 'Aug'},
    'mes_set': {'pt': 'Set', 'en': 'Sep'},
    'mes_out': {'pt': 'Out', 'en': 'Oct'},
    'mes_nov': {'pt': 'Nov', 'en': 'Nov'},
    'mes_dez': {'pt': 'Dez', 'en': 'Dec'},

    // ═══════ ACCOUNT TYPE LABELS ═══════
    'accType_corrente': {
      'pt': 'Conta Corrente',
      'en': 'Checking Account',
    },
    'accType_poupanca': {
      'pt': 'Poupança',
      'en': 'Savings',
    },
    'accType_cartao_credito': {
      'pt': 'Cartão de Crédito',
      'en': 'Credit Card',
    },
    'accType_carteira': {
      'pt': 'Carteira',
      'en': 'Wallet',
    },
    'accType_investimento': {
      'pt': 'Investimento',
      'en': 'Investment',
    },
    'accType_outro': {
      'pt': 'Outro',
      'en': 'Other',
    },

    // ═══════ ASSET TYPE LABELS ═══════
    'assetType_emergency_fund': {
      'pt': 'Reserva de Emergência',
      'en': 'Emergency Fund',
    },
    'assetType_stocks': {
      'pt': 'Ações',
      'en': 'Stocks',
    },
    'assetType_real_estate': {
      'pt': 'Imóveis',
      'en': 'Real Estate',
    },
    'assetType_cash': {
      'pt': 'Dinheiro em Conta',
      'en': 'Cash in Account',
    },
    'assetType_other': {
      'pt': 'Outro',
      'en': 'Other',
    },

    // ═══════ ADD ACCOUNT SCREEN ═══════
    'addAcc_novo': {
      'pt': 'Nova Conta',
      'en': 'New Account',
    },
    'addAcc_editar': {
      'pt': 'Editar Conta',
      'en': 'Edit Account',
    },
    'addAcc_nome_label': {
      'pt': 'NOME',
      'en': 'NAME',
    },
    'addAcc_nome_hint': {
      'pt': 'Ex: Cartão Nubank',
      'en': 'E.g.: Nubank Card',
    },
    'addAcc_nome_erro': {
      'pt': 'Dê um nome para a conta.',
      'en': 'Give a name to the account.',
    },
    'addAcc_tipo_label': {
      'pt': 'TIPO',
      'en': 'TYPE',
    },
    'addAcc_saldo_label': {
      'pt': 'SALDO INICIAL',
      'en': 'INITIAL BALANCE',
    },
    'addAcc_saldo_helper': {
      'pt': 'O saldo antes de qualquer transação lançada no app.',
      'en': 'The balance before any transactions logged in the app.',
    },
    'addAcc_excluir': {
      'pt': 'Excluir Conta',
      'en': 'Delete Account',
    },
    'addAcc_excluir_titulo': {
      'pt': 'Excluir Conta',
      'en': 'Delete Account',
    },
    'addAcc_excluir_msg': {
      'pt': 'As transações já lançadas nessa conta não serão apagadas, mas ficarão sem conta vinculada. Tem certeza?',
      'en': 'Transactions already posted to this account will not be deleted, but will become unlinked. Are you sure?',
    },
    'addAcc_excluir_confirmar': {
      'pt': 'Excluir',
      'en': 'Delete',
    },
    'addAcc_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'addAcc_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addAcc_adicionar': {
      'pt': 'Adicionar Conta',
      'en': 'Add Account',
    },
    'addAcc_erro_salvar': {
      'pt': 'Erro ao salvar: ',
      'en': 'Error saving: ',
    },
    'addAcc_erro_excluir': {
      'pt': 'Erro ao excluir: ',
      'en': 'Error deleting: ',
    },

    // ═══════ ACCOUNTS SCREEN ═══════
    'accounts_titulo': {
      'pt': 'Contas',
      'en': 'Accounts',
    },
    'accounts_saldo_total': {
      'pt': 'SALDO TOTAL (TODAS AS CONTAS)',
      'en': 'TOTAL BALANCE (ALL ACCOUNTS)',
    },
    'accounts_sem_contas': {
      'pt': 'Nenhuma conta cadastrada ainda. Toque no + para adicionar a primeira.',
      'en': 'No accounts yet. Tap + to add your first one.',
    },

    // ═══════ ADD ASSET SCREEN ═══════
    'addAsset_novo': {
      'pt': 'Novo Ativo',
      'en': 'New Asset',
    },
    'addAsset_editar': {
      'pt': 'Editar Ativo',
      'en': 'Edit Asset',
    },
    'addAsset_nome_label': {
      'pt': 'NOME',
      'en': 'NAME',
    },
    'addAsset_nome_hint': {
      'pt': 'Ex: Carteira B3',
      'en': 'E.g.: B3 Portfolio',
    },
    'addAsset_nome_erro': {
      'pt': 'Dê um nome para o ativo.',
      'en': 'Give a name to the asset.',
    },
    'addAsset_tipo_label': {
      'pt': 'TIPO',
      'en': 'TYPE',
    },
    'addAsset_valor_label': {
      'pt': 'VALOR ATUAL',
      'en': 'CURRENT VALUE',
    },
    'addAsset_valor_erro': {
      'pt': 'Informe um valor válido.',
      'en': 'Enter a valid amount.',
    },
    'addAsset_notas_label': {
      'pt': 'NOTAS (OPCIONAL)',
      'en': 'NOTES (OPTIONAL)',
    },
    'addAsset_notas_hint': {
      'pt': 'Ex: PETR4, VALE3 — ou detalhes do imóvel...',
      'en': 'E.g.: PETR4, VALE3 — or property details...',
    },
    'addAsset_excluir': {
      'pt': 'Excluir Ativo',
      'en': 'Delete Asset',
    },
    'addAsset_excluir_titulo': {
      'pt': 'Excluir Ativo',
      'en': 'Delete Asset',
    },
    'addAsset_excluir_msg': {
      'pt': 'Tem certeza? Essa ação não pode ser desfeita.',
      'en': 'Are you sure? This action cannot be undone.',
    },
    'addAsset_excluir_confirmar': {
      'pt': 'Excluir',
      'en': 'Delete',
    },
    'addAsset_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'addAsset_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addAsset_adicionar': {
      'pt': 'Adicionar Ativo',
      'en': 'Add Asset',
    },
    'addAsset_erro_salvar': {
      'pt': 'Erro ao salvar: ',
      'en': 'Error saving: ',
    },
    'addAsset_erro_excluir': {
      'pt': 'Erro ao excluir: ',
      'en': 'Error deleting: ',
    },
    'addAsset_quick_titulo': {
      'pt': 'Atualizar Valor',
      'en': 'Update Value',
    },
    'addAsset_quick_salvar': {
      'pt': 'Salvar',
      'en': 'Save',
    },
    'addAsset_quick_erro': {
      'pt': 'Erro ao atualizar: ',
      'en': 'Error updating: ',
    },

    // ═══════ ASSETS SCREEN ═══════
    'assets_titulo': {
      'pt': 'Patrimônio',
      'en': 'Assets',
    },
    'assets_total': {
      'pt': 'PATRIMÔNIO TOTAL',
      'en': 'TOTAL NET WORTH',
    },
    'assets_sem_ativos': {
      'pt': 'Nenhum ativo cadastrado ainda. Toque no + para adicionar o primeiro.',
      'en': 'No assets yet. Tap + to add your first one.',
    },

    // ═══════ ADD RECURRING SCREEN ═══════
    'addRec_novo': {
      'pt': 'Nova Recorrência',
      'en': 'New Recurring',
    },
    'addRec_editar': {
      'pt': 'Editar Recorrência',
      'en': 'Edit Recurring',
    },
    'addRec_tipo_label': {
      'pt': 'TIPO',
      'en': 'TYPE',
    },
    'addRec_tipo_despesa': {
      'pt': 'Despesa',
      'en': 'Expense',
    },
    'addRec_tipo_receita': {
      'pt': 'Receita',
      'en': 'Income',
    },
    'addRec_nome_label': {
      'pt': 'NOME',
      'en': 'NAME',
    },
    'addRec_nome_hint': {
      'pt': 'Ex: Netflix',
      'en': 'E.g.: Netflix',
    },
    'addRec_nome_erro': {
      'pt': 'Dê um nome para a recorrência.',
      'en': 'Give a name to the recurring transaction.',
    },
    'addRec_valor_label': {
      'pt': 'VALOR',
      'en': 'AMOUNT',
    },
    'addRec_valor_erro': {
      'pt': 'Informe um valor válido.',
      'en': 'Enter a valid amount.',
    },
    'addRec_categoria_label': {
      'pt': 'CATEGORIA',
      'en': 'CATEGORY',
    },
    'addRec_conta_label': {
      'pt': 'CONTA',
      'en': 'ACCOUNT',
    },
    'addRec_conta_vazia': {
      'pt': 'Nenhuma conta cadastrada — crie uma na tela de Contas primeiro.',
      'en': 'No accounts yet — create one on the Accounts screen first.',
    },
    'addRec_dia_label': {
      'pt': 'DIA DO MÊS',
      'en': 'DAY OF MONTH',
    },
    'addRec_dia_valor': {
      'pt': 'Dia %s',
      'en': 'Day %s',
    },
    'addRec_ativa_label': {
      'pt': 'Ativa',
      'en': 'Active',
    },
    'addRec_ativa_sub_on': {
      'pt': 'Gera a transação automaticamente todo mês.',
      'en': 'Automatically generates the transaction every month.',
    },
    'addRec_ativa_sub_off': {
      'pt': 'Pausada — não gera transações até ser reativada.',
      'en': 'Paused — no transactions until reactivated.',
    },
    'addRec_excluir': {
      'pt': 'Excluir Recorrência',
      'en': 'Delete Recurring',
    },
    'addRec_excluir_titulo': {
      'pt': 'Excluir Recorrência',
      'en': 'Delete Recurring',
    },
    'addRec_excluir_msg': {
      'pt': 'As transações já geradas por ela não serão apagadas. Tem certeza?',
      'en': 'Transactions already generated will not be deleted. Are you sure?',
    },
    'addRec_excluir_confirmar': {
      'pt': 'Excluir',
      'en': 'Delete',
    },
    'addRec_cancelar': {
      'pt': 'Cancelar',
      'en': 'Cancel',
    },
    'addRec_salvar': {
      'pt': 'Salvar Alterações',
      'en': 'Save Changes',
    },
    'addRec_criar': {
      'pt': 'Criar Recorrência',
      'en': 'Create Recurring',
    },
    'addRec_erro_salvar': {
      'pt': 'Erro ao salvar: ',
      'en': 'Error saving: ',
    },
    'addRec_erro_excluir': {
      'pt': 'Erro ao excluir: ',
      'en': 'Error deleting: ',
    },

    // ═══════ RECURRING SCREEN ═══════
    'recurring_titulo': {
      'pt': 'Recorrentes',
      'en': 'Recurring',
    },
    'recurring_receitas_mes': {
      'pt': 'RECEITAS/MÊS',
      'en': 'INCOME/MONTH',
    },
    'recurring_despesas_mes': {
      'pt': 'DESPESAS/MÊS',
      'en': 'EXPENSES/MONTH',
    },
    'recurring_sem_itens': {
      'pt': 'Nenhuma recorrência cadastrada ainda. Toque no + para adicionar a primeira.',
      'en': 'No recurring transactions yet. Tap + to add your first one.',
    },
    'recurring_erro_atualizar': {
      'pt': 'Erro ao atualizar: ',
      'en': 'Error updating: ',
    },

    // ═══════ REPORTS SCREEN ═══════
    'reports_titulo': {
      'pt': 'Relatórios',
      'en': 'Reports',
    },
    'reports_evolucao_saldo': {
      'pt': 'Evolução do Saldo (6 meses)',
      'en': 'Balance Evolution (6 months)',
    },
    'reports_evolucao_desc': {
      'pt': 'Soma do saldo de todas as contas, reconstruído a partir das transações lançadas.',
      'en': 'Sum of all account balances, rebuilt from logged transactions.',
    },
    'reports_tendencia': {
      'pt': 'Linha tracejada = tendência linear',
      'en': 'Dashed line = linear trend',
    },
    'reports_distribuicao': {
      'pt': 'Distribuição de Gastos (este mês)',
      'en': 'Expense Distribution (this month)',
    },
    'reports_total': {
      'pt': 'Total',
      'en': 'Total',
    },
    'reports_gasto_categoria': {
      'pt': 'Gasto por Categoria',
      'en': 'Spending by Category',
    },
    'reports_gasto_categoria_desc': {
      'pt': 'Este mês comparado ao mês anterior.',
      'en': 'This month compared to last month.',
    },
    'reports_sem_despesas': {
      'pt': 'Sem despesas suficientes ainda para comparar períodos.',
      'en': 'Not enough expenses yet to compare periods.',
    },
    'reports_nota': {
      'pt': 'Nota: o Patrimônio (ações, imóveis) ainda não tem histórico ao longo do tempo — hoje só guardamos o valor atual de cada ativo. Esse gráfico usa apenas o saldo das Contas, que já tem histórico real via as transações.',
      'en': 'Note: Assets (stocks, real estate) do not have historical tracking yet — we only store the current value. This chart uses only Account balances, which have real history via transactions.',
    },
    'reports_export_csv': {
      'pt': 'Exportar CSV',
      'en': 'Export CSV',
    },
    'reports_export_pdf': {
      'pt': 'Exportar PDF',
      'en': 'Export PDF',
    },
    'reports_erro_csv': {
      'pt': 'Erro ao exportar CSV: ',
      'en': 'Error exporting CSV: ',
    },
    'reports_erro_pdf': {
      'pt': 'Erro ao exportar PDF: ',
      'en': 'Error exporting PDF: ',
    },

    // ═══════ TRANSACTION FILTER SHEET ═══════
    'txnFilter_titulo': {
      'pt': 'Filtrar Transações',
      'en': 'Filter Transactions',
    },
    'txnFilter_limpar': {
      'pt': 'Limpar',
      'en': 'Clear',
    },
    'txnFilter_tipo': {
      'pt': 'TIPO',
      'en': 'TYPE',
    },
    'txnFilter_todas': {
      'pt': 'Todas',
      'en': 'All',
    },
    'txnFilter_receitas': {
      'pt': 'Receitas',
      'en': 'Income',
    },
    'txnFilter_despesas': {
      'pt': 'Despesas',
      'en': 'Expenses',
    },
    'txnFilter_categoria': {
      'pt': 'CATEGORIA',
      'en': 'CATEGORY',
    },
    'txnFilter_conta': {
      'pt': 'CONTA',
      'en': 'ACCOUNT',
    },
    'txnFilter_aplicar': {
      'pt': 'Aplicar Filtros',
      'en': 'Apply Filters',
    },

    // ═══════ TRANSACTION HISTORY ═══════
    'txnHistory_titulo': {
      'pt': 'Histórico',
      'en': 'History',
    },
    'txnHistory_buscar': {
      'pt': 'Buscar transações...',
      'en': 'Search transactions...',
    },
    'txnHistory_sem_resultados': {
      'pt': 'Nenhuma transação encontrada.',
      'en': 'No transactions found.',
    },
    'txnHistory_exportar': {
      'pt': 'Exportar CSV',
      'en': 'Export CSV',
    },
    'txnHistory_erro_exportar': {
      'pt': 'Erro ao exportar: ',
      'en': 'Error exporting: ',
    },

    // ═══════ DASHBOARD ═══════
    'dashboard_ola': {
      'pt': 'Olá, %s',
      'en': 'Hello, %s',
    },
    'dashboard_subtitulo': {
      'pt': 'Seu cérebro auxiliar está pronto. Aqui está o resumo financeiro.',
      'en': 'Your second brain is ready. Here is your financial overview.',
    },
    'dashboard_contas': {
      'pt': 'Contas',
      'en': 'Accounts',
    },
    'dashboard_patrimonio': {
      'pt': 'Patrimônio',
      'en': 'Net Worth',
    },
    'dashboard_orcamento': {
      'pt': 'Orçamento',
      'en': 'Budget',
    },
    'dashboard_recorrentes': {
      'pt': 'Recorrentes',
      'en': 'Recurring',
    },
    'dashboard_relatorios': {
      'pt': 'Relatórios',
      'en': 'Reports',
    },
    'dashboard_ver_historico': {
      'pt': 'VER TODO O HISTÓRICO',
      'en': 'VIEW FULL HISTORY',
    },
    'dashboard_sem_transacoes': {
      'pt': 'Nenhuma transação ainda. Toque no + para adicionar a primeira.',
      'en': 'No transactions yet. Tap + to add your first one.',
    },
    'dashboard_total_patrimonio': {
      'pt': 'PATRIMÔNIO TOTAL',
      'en': 'TOTAL NET WORTH',
    },
    'dashboard_meta_mensal': {
      'pt': '%s% da meta mensal',
      'en': '%s% of monthly goal',
    },
    'dashboard_sem_contas_resumo': {
      'pt': 'Nenhuma conta cadastrada.',
      'en': 'No accounts registered.',
    },
    'dashboard_sem_ativos_resumo': {
      'pt': 'Nenhum ativo cadastrado.',
      'en': 'No assets registered.',
    },
    'dashboard_sem_orcamentos_resumo': {
      'pt': 'Nenhum orçamento definido.',
      'en': 'No budgets defined.',
    },
    'dashboard_sem_recorrentes_resumo': {
      'pt': 'Nenhuma recorrência ativa.',
      'en': 'No active recurring transactions.',
    },
    'dashboard_contas_titulo': {
      'pt': 'Contas',
      'en': 'Accounts',
    },
    'dashboard_ativos_titulo': {
      'pt': 'Ativos',
      'en': 'Assets',
    },
    'dashboard_orcamentos_titulo': {
      'pt': 'Orçamentos',
      'en': 'Budgets',
    },
    'dashboard_recorrentes_titulo': {
      'pt': 'Recorrentes Ativos',
      'en': 'Active Recurring',
    },
    'dashboard_transacoes_recentes': {
      'pt': 'Transações Recentes',
      'en': 'Recent Transactions',
    },
    'dashboard_financas': {
      'pt': 'Finanças',
      'en': 'Finances',
    },
    'dashboard_adicionar': {
      'pt': 'Adicionar',
      'en': 'Add',
    },
    'dashboard_ver_tudo': {
      'pt': 'Ver Tudo',
      'en': 'View All',
    },

    // ═══════ DASHBOARD WIDGETS (Balance, Tasks, New Item, Reflection, Modal) ═══════
    'dashboard_utilizador': {
      'pt': 'Utilizador',
      'en': 'User',
    },
    'reflection_fallback_quote': {
      'pt': 'O que é medido, é gerenciado.',
      'en': 'What gets measured, gets managed.',
    },
    'tasks_pendentes_titulo': {
      'pt': 'Tarefas Pendentes',
      'en': 'Pending Tasks',
    },
    'tasks_pendentes_count': {
      'pt': '%s pendentes',
      'en': '%s pending',
    },
    'newItem_titulo': {
      'pt': 'Novo Item',
      'en': 'New Item',
    },
    'newItem_descricao': {
      'pt': 'Adicione uma tarefa, meta ou transação rapidamente.',
      'en': 'Quickly add a task, goal or transaction.',
    },
    'newItem_criar': {
      'pt': 'Criar',
      'en': 'Create',
    },
    'reflection_do_dia': {
      'pt': 'REFLEXÃO DO DIA',
      'en': 'DAILY REFLECTION',
    },
    'newItemModal_criar_novo': {
      'pt': 'Criar novo',
      'en': 'Create new',
    },
    'newItemModal_escolha_tipo': {
      'pt': 'Escolha o tipo de item que você deseja adicionar.',
      'en': 'Choose the type of item you want to add.',
    },
    'newItemModal_meta': {
      'pt': 'Meta',
      'en': 'Goal',
    },
    'newItemModal_tarefa': {
      'pt': 'Tarefa',
      'en': 'Task',
    },
    'newItemModal_transacao': {
      'pt': 'Transação',
      'en': 'Transaction',
    },
    'newItemModal_conta': {
      'pt': 'Conta',
      'en': 'Account',
    },
    'newItemModal_ativo': {
      'pt': 'Ativo',
      'en': 'Asset',
    },
    'newItemModal_orcamento': {
      'pt': 'Orçamento',
      'en': 'Budget',
    },
    'newItemModal_recorrente': {
      'pt': 'Recorrente',
      'en': 'Recurring',
    },
    'newItemModal_contato': {
      'pt': 'Contato',
      'en': 'Contact',
    },

};

  /// Retorna a string traduzida para a chave fornecida.
  /// Se a chave não existir, retorna a própria chave como fallback.
  String translate(String key) {
    final langMap = _strings[key];
    if (langMap == null) return key;
    return langMap[locale.languageCode] ?? langMap['pt'] ?? key;
  }

/// Traduz uma relationshipTag armazenada em português (ex: "Amigo", "Familiar")
  /// para o idioma atualmente selecionado.
  String translateRelationshipTag(String tag) {
    final key = 'rel_${tag.toLowerCase()}';
    return translate(key);
  }

  /// Traduz o nome de uma categoria de transação armazenada em português
  /// (ex: "Alimentação", "Salário") para o idioma atualmente selecionado.
  /// Retorna a categoria original se não encontrar tradução.
  String translateCategory(String category) {
    final key = 'txn_cat_${category.toLowerCase()}';
    final translation = translate(key);
    // Se a chave não foi encontrada, translate() retorna a própria chave.
    // Nesse caso devolvemos a categoria original (em pt) como fallback.
    return translation == key ? category : translation;
  }

  /// Traduz o rótulo relativo de uma transação (ex: "Hoje, 14:20",
  /// "Ontem, 09:00", ou "02 Mai" para datas mais antigas) para o idioma
  /// atualmente selecionado.
  String translateRelativeDate(TransactionModel transaction) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(
      transaction.date.year,
      transaction.date.month,
      transaction.date.day,
    );
    final diff = today.difference(day).inDays;

    final hm = '${transaction.date.hour.toString().padLeft(2, '0')}:'
        '${transaction.date.minute.toString().padLeft(2, '0')}';

    if (diff == 0) return '${translate('relative_hoje')}, $hm';
    if (diff == 1) return '${translate('relative_ontem')}, $hm';
    final monthAbbrev = [
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
    ];
    return '${transaction.date.day.toString().padLeft(2, '0')} '
        '${translate('mes_${monthAbbrev[transaction.date.month - 1].toLowerCase()}')}';
  }

  /// Traduz a prioridade de uma tarefa (TaskPriority) para o idioma
  /// atualmente selecionado, usando a forma curta (ex: "Alta", "Média", "Baixa").
  String translatePriorityShort(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.alta => translate('prio_alta_short'),
      TaskPriority.media => translate('prio_media_short'),
      TaskPriority.baixa => translate('prio_baixa_short'),
    };
  }

  /// Traduz a prioridade de uma tarefa (TaskPriority) para o idioma
  /// atualmente selecionado, usando a forma longa (ex: "Alta Prioridade").
  String translatePriorityLong(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.alta => translate('prio_alta'),
      TaskPriority.media => translate('prio_media'),
      TaskPriority.baixa => translate('prio_baixa'),
    };
  }

  /// Traduz o status de uma tarefa (TaskStatus) para o idioma
  /// atualmente selecionado.
  String translateStatus(TaskStatus status) {
    return switch (status) {
      TaskStatus.pendente => translate('status_nao_iniciada'),
      TaskStatus.emProgresso => translate('status_em_progresso'),
      TaskStatus.concluida => translate('status_concluida'),
    };
  }

  /// Traduz o nome de um tipo de conta (AccountType) para o idioma
  /// atualmente selecionado.
  String translateAccountType(AccountType type) {
    return switch (type) {
      AccountType.corrente => translate('accType_corrente'),
      AccountType.poupanca => translate('accType_poupanca'),
      AccountType.cartaoCredito => translate('accType_cartao_credito'),
      AccountType.carteira => translate('accType_carteira'),
      AccountType.investimento => translate('accType_investimento'),
      AccountType.outro => translate('accType_outro'),
    };
  }

  /// Traduz o nome de um tipo de ativo (AssetType) para o idioma
  /// atualmente selecionado.
  String translateAssetType(AssetType type) {
    return switch (type) {
      AssetType.emergencyFund => translate('assetType_emergency_fund'),
      AssetType.stocks => translate('assetType_stocks'),
      AssetType.realEstate => translate('assetType_real_estate'),
      AssetType.cash => translate('assetType_cash'),
      AssetType.other => translate('assetType_other'),
    };
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

