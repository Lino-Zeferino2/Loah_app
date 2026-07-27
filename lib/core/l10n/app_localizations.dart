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
    'relative_ontem': {
      'pt': 'ontem',
      'en': 'yesterday',
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

