/**
 * Script de seed para popular o Firestore com dados de demonstração.
 *
 * Este script é executado via Firebase Shell:
 *   firebase functions:shell
 *   seedUserData('USER_UID_AQUI')
 *
 * Ou podes executar localmente:
 *   node seed.js
 */

const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

// Inicializar se não estiver inicializado
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: 'loahapp',
  });
}

const db = admin.firestore();

/**
 * Gera dados de demonstração para um usuário específico.
 * @param {string} uid - O UID do usuário no Firebase Auth
 */
async function seedUserData(uid) {
  console.log(`🌱 Seeding data for user: ${uid}`);
  const now = new Date();
  const batch = db.batch();

  // ─── ACCOUNTS (Contas) ───────────────────────────────────────
  const accounts = [
    { id: 'acc_checking', name: 'Conta Corrente', type: 'corrente', initialBalance: 500 },
    { id: 'acc_savings', name: 'Poupança', type: 'poupanca', initialBalance: 3750 },
    { id: 'acc_credit_card', name: 'Cartão de Crédito', type: 'cartaoCredito', initialBalance: 0 },
    { id: 'acc_wallet', name: 'Carteira', type: 'carteira', initialBalance: 150 },
  ];

  for (const acc of accounts) {
    const ref = db.collection('users').doc(uid).collection('accounts').doc(acc.id);
    batch.set(ref, {
      name: acc.name,
      type: acc.type,
      initialBalance: acc.initialBalance,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── TRANSACTIONS ─────────────────────────────────────────────
  const transactions = [
    { id: 'txn_market', title: 'Mercado Central', category: 'Alimentação', amount: 146.20, type: 'expense', date: new Date(now.getTime() - 3 * 60 * 60 * 1000), accountId: 'acc_checking' },
    { id: 'txn_salary', title: 'Salário Mensal', category: 'Salário', amount: 4200.00, type: 'income', date: new Date(now.getTime() - 24 * 60 * 60 * 1000), accountId: 'acc_checking' },
    { id: 'txn_uber', title: 'Uber', category: 'Transporte', amount: 32.50, type: 'expense', date: new Date(now.getTime() - 4 * 24 * 60 * 60 * 1000), accountId: 'acc_credit_card' },
    { id: 'txn_clothes', title: 'Loja de Roupas', category: 'Compras', amount: 210.00, type: 'expense', date: new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000), accountId: 'acc_credit_card' },
    { id: 'txn_rent', title: 'Aluguel', category: 'Moradia', amount: 1200.00, type: 'expense', date: new Date(now.getTime() - 8 * 24 * 60 * 60 * 1000), accountId: 'acc_checking' },
  ];

  for (const txn of transactions) {
    const ref = db.collection('users').doc(uid).collection('transactions').doc(txn.id);
    batch.set(ref, {
      title: txn.title,
      category: txn.category,
      amount: txn.amount,
      type: txn.type,
      date: admin.firestore.Timestamp.fromDate(txn.date),
      accountId: txn.accountId,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── ASSETS (Ativos) ──────────────────────────────────────────
  const assets = [
    { id: 'asset_emergency_fund', name: 'Reserva de Emergência', type: 'emergencyFund', currentValue: 4250, notes: 'Fundo de emergência', updatedAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000) },
    { id: 'asset_stocks_b3', name: 'Carteira B3', type: 'stocks', currentValue: 8600, notes: 'PETR4, VALE3, ITUB4', updatedAt: new Date(now.getTime() - 5 * 24 * 60 * 60 * 1000) },
    { id: 'asset_apartment', name: 'Apartamento', type: 'realEstate', currentValue: 320000, notes: 'Imóvel residencial, financiado', updatedAt: new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000) },
    { id: 'asset_checking_account', name: 'Conta Corrente', type: 'cash', currentValue: 1850, notes: '', updatedAt: new Date(now.getTime() - 6 * 60 * 60 * 1000) },
  ];

  for (const asset of assets) {
    const ref = db.collection('users').doc(uid).collection('assets').doc(asset.id);
    batch.set(ref, {
      name: asset.name,
      type: asset.type,
      currentValue: asset.currentValue,
      notes: asset.notes,
      updatedAt: admin.firestore.Timestamp.fromDate(asset.updatedAt),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── BUDGETS (Orçamentos) ─────────────────────────────────────
  const budgets = [
    { id: 'budget_food', category: 'Alimentação', monthlyLimit: 800 },
    { id: 'budget_transport', category: 'Transporte', monthlyLimit: 250 },
    { id: 'budget_shopping', category: 'Compras', monthlyLimit: 300 },
    { id: 'budget_housing', category: 'Moradia', monthlyLimit: 1200 },
  ];

  for (const budget of budgets) {
    const ref = db.collection('users').doc(uid).collection('budgets').doc(budget.id);
    batch.set(ref, {
      category: budget.category,
      monthlyLimit: budget.monthlyLimit,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── RECURRING TRANSACTIONS ───────────────────────────────────
  const recurrings = [
    { id: 'recurring_salary', title: 'Salário Mensal', category: 'Salário', amount: 4200, type: 'income', accountId: 'acc_checking', dayOfMonth: 5, active: true },
    { id: 'recurring_rent', title: 'Aluguel', category: 'Moradia', amount: 1200, type: 'expense', accountId: 'acc_checking', dayOfMonth: 10, active: true },
    { id: 'recurring_netflix', title: 'Netflix', category: 'Lazer', amount: 44.90, type: 'expense', accountId: 'acc_credit_card', dayOfMonth: 15, active: true },
    { id: 'recurring_spotify', title: 'Spotify', category: 'Lazer', amount: 21.90, type: 'expense', accountId: 'acc_credit_card', dayOfMonth: 20, active: true },
  ];

  for (const rec of recurrings) {
    const ref = db.collection('users').doc(uid).collection('recurringTransactions').doc(rec.id);
    batch.set(ref, {
      title: rec.title,
      category: rec.category,
      amount: rec.amount,
      type: rec.type,
      accountId: rec.accountId,
      dayOfMonth: rec.dayOfMonth,
      active: rec.active,
      lastGeneratedMonth: null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── GOALS (Metas) ────────────────────────────────────────────
  const goals = [
    { id: 'goal_emergency_fund', title: 'Reserva de Emergência', category: 'Finanças', term: 'curtoPrazo', progressMode: 'manualValue', current: 4250, target: 5000, description: 'Completar reserva de emergência', progressColor: '-10734624' },
    { id: 'goal_daily_workout', title: 'Treino Diário', category: 'Saúde', term: 'curtoPrazo', progressMode: 'manualValue', current: 12, target: 30, description: 'Manter consistência nos treinos', progressColor: null },
    { id: 'goal_eurotrip', title: 'Eurotrip 2024', category: 'Viagem', term: 'medioPrazo', progressMode: 'manualValue', current: 2500, target: 10000, description: 'Poupar para passagens e hospedagem em Paris e Roma.', progressColor: null, imageAsset: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800' },
    { id: 'goal_cloud_certification', title: 'Certificação Cloud', category: 'Carreira', term: 'medioPrazo', progressMode: 'taskChecklist', current: null, target: null, description: 'Obter certificação de cloud computing', progressColor: '-16711936' },
    { id: 'goal_buy_car', title: 'Comprar um Carro', category: 'Financeiro', term: 'medioPrazo', progressMode: 'manualValue', current: 16250, target: 25000, description: 'Meta para adquirir um veículo seminovo.', progressColor: null, targetDate: new Date(2024, 11, 1), imageAsset: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800' },
    { id: 'goal_apartment_downpayment', title: 'Entrada do Apartamento', category: 'Investimento', term: 'longoPrazo', progressMode: 'manualValue', current: 1500, target: 12500, description: 'Investimento de longo prazo.', progressColor: null },
  ];

  for (const goal of goals) {
    const ref = db.collection('users').doc(uid).collection('goals').doc(goal.id);
    const data = {
      title: goal.title,
      category: goal.category,
      term: goal.term,
      progressMode: goal.progressMode,
      current: goal.current ?? null,
      target: goal.target ?? null,
      description: goal.description ?? null,
      progressColor: goal.progressColor ?? null,
      imageAsset: goal.imageAsset ?? null,
      targetDate: goal.targetDate ? admin.firestore.Timestamp.fromDate(goal.targetDate) : null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    batch.set(ref, data);
  }

  // ─── TASKS (Tarefas) ──────────────────────────────────────────
  const tasks = [
    { id: 'task_quarterly_planning_meeting', title: 'Reunião de Planejamento Trimestral', description: 'Preparar apresentação e KPIs do departamento financeiro.', priority: 'alta', isDone: false, goalId: null, dueLabel: '09:00', status: 'pendente' },
    { id: 'task_review_budget_today', title: 'Revisar orçamento mensal', tag: 'Finanças', priority: 'media', isDone: false, goalId: null, dueLabel: 'Hoje', status: 'pendente' },
    { id: 'task_leg_workout', title: 'Treino de pernas (Academia)', description: 'Focar em resistência e alongamento.', priority: null, isDone: false, goalId: null, dueLabel: 'Amanhã', status: 'pendente' },
    { id: 'task_groceries', title: 'Comprar mantimentos', description: 'Lista no app de notas.', priority: null, isDone: false, goalId: null, dueLabel: 'Sáb, 3 Out', status: 'pendente' },
    { id: 'task_reply_emails', title: 'Responder e-mails acumulados', priority: null, isDone: true, goalId: null, dueLabel: null, status: 'concluida', completedAt: new Date(now.getTime() - 1 * 60 * 60 * 1000) },
    { id: 'task_cloud_module_1', title: 'Módulo 1 — Fundamentos', priority: null, isDone: true, goalId: 'goal_cloud_certification', dueLabel: null, status: 'concluida', completedAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000) },
    { id: 'task_cloud_module_2', title: 'Módulo 2 — Redes e Segurança', priority: null, isDone: true, goalId: 'goal_cloud_certification', dueLabel: null, status: 'concluida', completedAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000) },
    { id: 'task_cloud_module_3', title: 'Módulo 3 — Armazenamento', priority: null, isDone: false, goalId: 'goal_cloud_certification', dueLabel: null, status: 'pendente' },
    { id: 'task_cloud_module_4', title: 'Módulo 4 — Simulado final', priority: null, isDone: false, goalId: 'goal_cloud_certification', dueLabel: null, status: 'pendente' },
    { id: 'task_car_down_payment', title: 'Guardar R$ 5.000 de entrada', priority: null, isDone: true, goalId: 'goal_buy_car', dueLabel: null, status: 'concluida', completedAt: new Date(2024, 9, 15) },
    { id: 'task_car_research_suv', title: 'Pesquisar modelos de SUV', description: 'Analisar o consumo, espaço interno e custo-benefício de pelo menos 3 modelos híbridos.', priority: 'media', isDone: false, goalId: 'goal_buy_car', dueLabel: null, status: 'emProgresso', createdAt: new Date(2024, 9, 18), dueDate: new Date(2024, 9, 25) },
    { id: 'task_car_test_drive', title: 'Agendar test-drives', priority: null, isDone: false, goalId: 'goal_buy_car', dueLabel: null, status: 'pendente' },
  ];

  for (const task of tasks) {
    const ref = db.collection('users').doc(uid).collection('tasks').doc(task.id);
    const data = {
      title: task.title,
      description: task.description ?? null,
      tag: task.tag ?? null,
      priority: task.priority ?? null,
      isDone: task.isDone,
      goalId: task.goalId ?? null,
      dueLabel: task.dueLabel ?? null,
      status: task.status ?? 'pendente',
      dueDate: task.dueDate ? admin.firestore.Timestamp.fromDate(task.dueDate) : null,
      completedAt: task.completedAt ? admin.firestore.Timestamp.fromDate(task.completedAt) : null,
      createdAt: task.createdAt ? admin.firestore.Timestamp.fromDate(task.createdAt) : admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    batch.set(ref, data);
  }

  // ─── CONTACTS (Contatos) ──────────────────────────────────────
  const contacts = [
    { id: 'contact_alice', name: 'Alice Ferreira', relationshipTag: 'Namorada', isFavorite: true, desiredContactFrequencyDays: 2, interactions: [
      { date: new Date(now.getTime() - 5 * 60 * 60 * 1000), type: 'message' },
      { date: new Date(now.getTime() - 24 * 60 * 60 * 1000), type: 'call' },
    ]},
    { id: 'contact_bruno', name: 'Bruno Alves', relationshipTag: 'Amigo', isFavorite: true, desiredContactFrequencyDays: null, interactions: [] },
    { id: 'contact_carlos', name: 'Carlos Souza', relationshipTag: 'Pai', isFavorite: true, desiredContactFrequencyDays: 7, interactions: [
      { date: new Date(now.getTime() - 12 * 24 * 60 * 60 * 1000), type: 'call' },
    ]},
    { id: 'contact_diana', name: 'Diana Ferreira', relationshipTag: 'Mãe', isFavorite: true, desiredContactFrequencyDays: null, interactions: [] },
    { id: 'contact_adriana', name: 'Adriana Silva', relationshipTag: 'Colega', isFavorite: false, desiredContactFrequencyDays: null, interactions: [] },
    { id: 'contact_andre', name: 'Andre Martins', relationshipTag: 'Conhecido', isFavorite: false, desiredContactFrequencyDays: null, interactions: [] },
    { id: 'contact_beatriz', name: 'Beatriz Gomes', relationshipTag: 'Amiga', isFavorite: false, desiredContactFrequencyDays: null, interactions: [] },
    { id: 'contact_caio', name: 'Caio Castro', relationshipTag: 'Familiar', isFavorite: false, desiredContactFrequencyDays: null, interactions: [] },
    { id: 'contact_clarice', name: 'Clarice Lispector', relationshipTag: 'Conhecida', isFavorite: false, desiredContactFrequencyDays: null, interactions: [] },
  ];

  for (const contact of contacts) {
    const ref = db.collection('users').doc(uid).collection('contacts').doc(contact.id);
    batch.set(ref, {
      name: contact.name,
      relationshipTag: contact.relationshipTag,
      isFavorite: contact.isFavorite,
      desiredContactFrequencyDays: contact.desiredContactFrequencyDays,
      interactions: contact.interactions.map(i => ({
        date: admin.firestore.Timestamp.fromDate(i.date),
        type: i.type,
      })),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // Commit batch
  await batch.commit();
  console.log(`✅ Seeded successfully for user ${uid}!`);
  console.log('   - Accounts:', accounts.length);
  console.log('   - Transactions:', transactions.length);
  console.log('   - Assets:', assets.length);
  console.log('   - Budgets:', budgets.length);
  console.log('   - Recurring:', recurrings.length);
  console.log('   - Goals:', goals.length);
  console.log('   - Tasks:', tasks.length);
  console.log('   - Contacts:', contacts.length);
}

/**
 * Popula os dados globais do app no Firestore:
 * - Reflexões do dia (reflections)
 * - Categorias da Central de Ajuda (helpCenterCategories)
 * - Artigos FAQ (helpCenterArticles)
 * - Conteúdo do app (appContent: sobre_nos, politica_privacidade, termos_condicoes)
 *
 * Este script é idempotente: usa IDs fixos, então pode ser executado
 * múltiplas vezes sem duplicar dados.
 */
async function seedAppData() {
  console.log('🌱 Seeding global app data...');
  const batch = db.batch();

  // ─── REFLEXÕES DO DIA (reflections) ──────────────────────────
  const reflections = [
    {
      id: 'reflection_1',
      text_pt: 'O que é medido, é gerenciado.',
      text_en: 'What gets measured, gets managed.',
      imageUrl: 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800',
      active: true,
    },
    {
      id: 'reflection_2',
      text_pt: 'Pequenas ações diárias levam a grandes resultados.',
      text_en: 'Small daily actions lead to great results.',
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      active: true,
    },
    {
      id: 'reflection_3',
      text_pt: 'A jornada de mil milhas começa com um único passo.',
      text_en: 'A journey of a thousand miles begins with a single step.',
      imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800',
      active: true,
    },
    {
      id: 'reflection_4',
      text_pt: 'Não espere pelo momento perfeito. Comece onde está, com o que tem.',
      text_en: 'Do not wait for the perfect moment. Start where you are, with what you have.',
      imageUrl: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=800',
      active: true,
    },
    {
      id: 'reflection_5',
      text_pt: 'O sucesso não é final, o fracasso não é fatal: é a coragem de continuar que conta.',
      text_en: 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      imageUrl: 'https://images.unsplash.com/photo-1470071459604-7b8ec44ffd4e?w=800',
      active: true,
    },
    {
      id: 'reflection_6',
      text_pt: 'Invista em você mesmo. É o melhor investimento que você pode fazer.',
      text_en: 'Invest in yourself. It is the best investment you can make.',
      imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
      active: true,
    },
    {
      id: 'reflection_7',
      text_pt: 'A disciplina é a ponte entre metas e realizações.',
      text_en: 'Discipline is the bridge between goals and accomplishments.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
      active: true,
    },
    {
      id: 'reflection_8',
      text_pt: 'Cada centavo economizado é um centavo ganho.',
      text_en: 'Every penny saved is a penny earned.',
      imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800',
      active: true,
    },
    {
      id: 'reflection_9',
      text_pt: 'O melhor momento para plantar uma árvore foi há 20 anos. O segundo melhor momento é agora.',
      text_en: 'The best time to plant a tree was 20 years ago. The second best time is now.',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800',
      active: true,
    },
    {
      id: 'reflection_10',
      text_pt: 'Seu futuro é criado pelo que você faz hoje, não amanhã.',
      text_en: 'Your future is created by what you do today, not tomorrow.',
      imageUrl: 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?w=800',
      active: true,
    },
  ];

  for (const ref of reflections) {
    const refDoc = db.collection('reflections').doc(ref.id);
    batch.set(refDoc, {
      text_pt: ref.text_pt,
      text_en: ref.text_en,
      imageUrl: ref.imageUrl,
      active: ref.active,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── CATEGORIAS DA CENTRAL DE AJUDA (helpCenterCategories) ────
  const helpCategories = [
    { id: 'cat_contas', name_pt: 'Contas e Assinaturas', name_en: 'Accounts & Subscriptions', icon: 'account_balance_wallet', order: 1 },
    { id: 'cat_financas', name_pt: 'Finanças', name_en: 'Finances', icon: 'trending_up', order: 2 },
    { id: 'cat_metas', name_pt: 'Metas', name_en: 'Goals', icon: 'track_changes', order: 3 },
    { id: 'cat_tarefas', name_pt: 'Tarefas', name_en: 'Tasks', icon: 'check_circle', order: 4 },
    { id: 'cat_contatos', name_pt: 'Contatos', name_en: 'Contacts', icon: 'contacts', order: 5 },
    { id: 'cat_conta', name_pt: 'Minha Conta', name_en: 'My Account', icon: 'person', order: 6 },
    { id: 'cat_privacidade', name_pt: 'Privacidade e Segurança', name_en: 'Privacy & Security', icon: 'security', order: 7 },
    { id: 'cat_geral', name_pt: 'Geral', name_en: 'General', icon: 'help_outline', order: 8 },
  ];

  for (const cat of helpCategories) {
    const catDoc = db.collection('helpCenterCategories').doc(cat.id);
    batch.set(catDoc, {
      name_pt: cat.name_pt,
      name_en: cat.name_en,
      icon: cat.icon,
      order: cat.order,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── ARTIGOS FAQ (helpCenterArticles) ─────────────────────────
  const articles = [
    {
      id: 'art_como_criar_conta',
      categoryId: 'cat_conta',
      title_pt: 'Como criar uma conta?',
      title_en: 'How to create an account?',
      content_pt: 'Para criar uma conta no Loah, abra o aplicativo e toque em "Cadastre-se". Preencha seu nome, email e senha. Você também pode usar o Google ou Apple para criar uma conta rapidamente. Após o cadastro, verifique seu email clicando no link enviado para sua caixa de entrada.',
      content_en: 'To create a Loah account, open the app and tap "Sign Up". Fill in your name, email and password. You can also use Google or Apple to quickly create an account. After signing up, verify your email by clicking the link sent to your inbox.',
      views: 0,
    },
    {
      id: 'art_como_adicionar_transacao',
      categoryId: 'cat_financas',
      title_pt: 'Como adicionar uma transação?',
      title_en: 'How to add a transaction?',
      content_pt: 'Para adicionar uma transação, vá até a tela de Finanças e toque no botão "+". Escolha entre Despesa ou Receita, preencha o valor, nome, categoria e conta. Você também pode adicionar transações rapidamente pelo botão "+" no Dashboard.',
      content_en: 'To add a transaction, go to the Finances screen and tap the "+" button. Choose between Expense or Income, fill in the amount, name, category and account. You can also quickly add transactions from the Dashboard "+" button.',
      views: 0,
    },
    {
      id: 'art_como_criar_meta',
      categoryId: 'cat_metas',
      title_pt: 'Como criar uma meta?',
      title_en: 'How to create a goal?',
      content_pt: 'Vá para a tela de Metas e toque em "Nova Meta". Dê um nome à sua meta, escolha uma categoria e prazo. Você pode adicionar um valor alvo e uma foto inspiradora. Depois de criada, vincule tarefas à meta para acompanhar seu progresso.',
      content_en: 'Go to the Goals screen and tap "New Goal". Give your goal a name, choose a category and term. You can add a target value and an inspiring photo. Once created, link tasks to the goal to track your progress.',
      views: 0,
    },
    {
      id: 'art_como_gerenciar_tarefas',
      categoryId: 'cat_tarefas',
      title_pt: 'Como gerenciar tarefas?',
      title_en: 'How to manage tasks?',
      content_pt: 'Na tela de Tarefas, você pode ver suas tarefas organizadas por "Hoje", "Próximos Dias" e "Concluídos". Toque em "+" para adicionar uma nova tarefa com nome, descrição, prioridade e data de entrega. Você pode vincular tarefas a metas específicas.',
      content_en: 'On the Tasks screen, you can see your tasks organized by "Today", "Upcoming Days" and "Completed". Tap "+" to add a new task with name, description, priority and due date. You can link tasks to specific goals.',
      views: 0,
    },
    {
      id: 'art_como_adicionar_contato',
      categoryId: 'cat_contatos',
      title_pt: 'Como adicionar um contato?',
      title_en: 'How to add a contact?',
      content_pt: 'Na tela de Contatos, toque no botão "+" para adicionar um novo contato. Preencha o nome, telefone, email e escolha o grau de conexão. Você pode definir a frequência desejada de contato para receber lembretes.',
      content_en: 'On the Contacts screen, tap the "+" button to add a new contact. Fill in the name, phone, email and choose the connection degree. You can set the desired contact frequency to receive reminders.',
      views: 0,
    },
    {
      id: 'art_como_exportar_dados',
      categoryId: 'cat_financas',
      title_pt: 'Como exportar meus dados financeiros?',
      title_en: 'How to export my financial data?',
      content_pt: 'Na tela de Relatórios, você pode exportar seus dados em formato CSV ou PDF. O CSV é ideal para abrir em Excel ou Google Sheets. O PDF gera um relatório visual com gráficos. Toque em "Exportar CSV" ou "Exportar PDF" na tela de Relatórios.',
      content_en: 'On the Reports screen, you can export your data in CSV or PDF format. CSV is ideal for opening in Excel or Google Sheets. PDF generates a visual report with charts. Tap "Export CSV" or "Export PDF" on the Reports screen.',
      views: 0,
    },
    {
      id: 'art_como_alterar_senha',
      categoryId: 'cat_conta',
      title_pt: 'Como alterar minha senha?',
      title_en: 'How to change my password?',
      content_pt: 'No menu lateral, vá em "Alterar senha" na seção Conta. Informe sua senha atual e a nova senha. A nova senha deve ter pelo menos 6 caracteres.',
      content_en: 'In the side menu, go to "Change password" in the Account section. Enter your current password and the new password. The new password must be at least 6 characters long.',
      views: 0,
    },
    {
      id: 'art_privacidade_dados',
      categoryId: 'cat_privacidade',
      title_pt: 'Como o Loah protege meus dados?',
      title_en: 'How does Loah protect my data?',
      content_pt: 'O Loah utiliza criptografia em trânsito e em repouso para proteger seus dados. Seus dados são armazenados no Firebase (Google Cloud Platform) com segurança. Você pode solicitar a exclusão dos seus dados a qualquer momento. Consulte nossa Política de Privacidade para mais detalhes.',
      content_en: 'Loah uses encryption in transit and at rest to protect your data. Your data is stored securely on Firebase (Google Cloud Platform). You can request data deletion at any time. See our Privacy Policy for more details.',
      views: 0,
    },
    {
      id: 'art_contas_recorrentes',
      categoryId: 'cat_contas',
      title_pt: 'Como funcionam as contas recorrentes?',
      title_en: 'How do recurring transactions work?',
      content_pt: 'As contas recorrentes geram transações automáticas todo mês no dia escolhido. Você pode ativar ou pausar uma recorrência. O Loah também envia lembretes 3 dias antes do vencimento.',
      content_en: 'Recurring transactions generate automatic transactions every month on the chosen day. You can activate or pause a recurrence. Loah also sends reminders 3 days before the due date.',
      views: 0,
    },
    {
      id: 'art_orcamentos',
      categoryId: 'cat_financas',
      title_pt: 'Como criar orçamentos?',
      title_en: 'How to create budgets?',
      content_pt: 'Na tela de Orçamentos, toque em "+" para criar um orçamento para uma categoria. Defina o limite mensal. O Loah avisará quando você estiver próximo de ultrapassar o limite e criará notificações se o orçamento for excedido.',
      content_en: 'On the Budgets screen, tap "+" to create a budget for a category. Set the monthly limit. Loah will warn you when you are close to exceeding the limit and create notifications if the budget is exceeded.',
      views: 0,
    },
  ];

  for (const article of articles) {
    const artDoc = db.collection('helpCenterArticles').doc(article.id);
    batch.set(artDoc, {
      categoryId: article.categoryId,
      title_pt: article.title_pt,
      title_en: article.title_en,
      content_pt: article.content_pt,
      content_en: article.content_en,
      views: article.views,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── CONTEÚDO DO APP (appContent) ─────────────────────────────
  const appContent = [
    {
      id: 'sobre_nos',
      content_pt: `SOBRE A LOAH

A Loah nasceu da convicção de que todos merecem ter clareza e controlo sobre a sua vida financeira e pessoal. Somos uma plataforma intuitiva e completa que combina gestão financeira, produtividade e bem-estar digital numa única experiência.

A nossa missão é capacitar cada pessoa a organizar as suas finanças, definir metas significativas e manter o foco no que realmente importa. Acreditamos que a organização financeira não precisa ser complicada — pelo contrário, deve ser simples, acessível e motivadora.

O QUE OFERECEMOS

• Finanças com visão clara — Acompanhe as suas contas, transações, orçamentos e ativos com relatórios inteligentes que lhe dão uma visão completa da sua saúde financeira.

• Metas que inspiram — Defina objetivos financeiros e acompanhe o seu progresso com ferramentas visuais e motivacionais que o mantêm no caminho certo.

• Tarefas para manter o ritmo — Organize o seu dia-a-dia com um gestor de tarefas integrado que o ajuda a manter a produtividade alinhada com os seus objetivos.

• Contactos organizados — Mantenha a sua rede de contactos sempre à mão, com sincronização inteligente e acesso rápido.

• Reflexões diárias — Comece cada dia com uma reflexão inspiradora que o ajuda a manter uma mentalidade positiva e focada.

A nossa equipa está comprometida em evoluir continuamente o Loah, ouvindo os nossos utilizadores e incorporando novas funcionalidades que fazem a diferença no dia-a-dia.

O Loah é mais do que um aplicativo — é um companheiro na sua jornada rumo a uma vida mais organizada, equilibrada e realizada.

Versão atual: 1.0.0`,
      content_en: `ABOUT LOAH

Loah was born from the conviction that everyone deserves clarity and control over their financial and personal life. We are an intuitive and complete platform that combines financial management, productivity and digital well-being in a single experience.

Our mission is to empower each person to organize their finances, set meaningful goals and stay focused on what truly matters. We believe that financial organization does not have to be complicated — on the contrary, it should be simple, accessible and motivating.

WHAT WE OFFER

• Finances with clear vision — Track your accounts, transactions, budgets and assets with smart reports that give you a complete view of your financial health.

• Goals that inspire — Set financial objectives and track your progress with visual and motivational tools that keep you on track.

• Tasks to keep the pace — Organize your day-to-day with an integrated task manager that helps you keep productivity aligned with your goals.

• Organized contacts — Keep your network of contacts always at hand, with smart synchronization and quick access.

• Daily reflections — Start each day with an inspiring reflection that helps you maintain a positive and focused mindset.

Our team is committed to continuously evolving Loah, listening to our users and incorporating new features that make a difference in everyday life.

Loah is more than an app — it is a companion on your journey towards a more organized, balanced and fulfilled life.

Current version: 1.0.0`,
    },
    {
      id: 'politica_privacidade',
      content_pt: `POLÍTICA DE PRIVACIDADE – LOAH

Última atualização: Janeiro de 2025

1. INTRODUÇÃO

A sua privacidade é importante para nós. Esta Política de Privacidade descreve como o Loah recolhe, utiliza, armazena e protege os seus dados pessoais quando utiliza o nosso aplicativo.

2. DADOS QUE RECOLHEMOS

2.1. Dados fornecidos pelo utilizador:
- Nome completo
- Endereço de e-mail
- Número de telefone (opcional)
- Foto de perfil (opcional)

2.2. Dados gerados pela utilização do App:
- Informações financeiras (transações, contas, orçamentos, ativos, metas)
- Tarefas e lembretes criados
- Contactos sincronizados ou adicionados manualmente
- Reflexões e mensagens enviadas ao suporte
- Preferências de configuração (tema, notificações, etc.)

2.3. Dados técnicos:
- Tipo de dispositivo e sistema operativo
- Versão do App
- Identificadores de dispositivo
- Dados de navegação e interação com o App

3. FINALIDADE DO TRATAMENTO DOS DADOS

Os seus dados são utilizados para:

- Fornecer, manter e melhorar as funcionalidades do App;
- Processar transações e gerar relatórios financeiros;
- Personalizar a sua experiência no App;
- Enviar notificações relevantes (metas, lembretes, reflexões);
- Responder a pedidos de suporte e mensagens;
- Cumprir obrigações legais e regulamentares;
- Detetar e prevenir atividades fraudulentas ou abusivas.

4. COMPARTILHAMENTO DE DADOS

O Loah não vende, aluga ou partilha dados pessoais com terceiros para fins de marketing, exceto:

- Com prestadores de serviços essenciais ao funcionamento do App (ex.: Firebase/Firestore para armazenamento de dados e autenticação);
- Por obrigação legal, ordem judicial ou solicitação de autoridade competente;
- Para proteger os direitos, propriedade ou segurança do Loah, dos utilizadores ou do público.

5. ARMAZENAMENTO E SEGURANÇA DOS DADOS

5.1. Os seus dados são armazenados de forma segura nos servidores do Firebase (Google Cloud Platform), com criptografia em trânsito e em repouso.
5.2. Implementamos medidas técnicas e organizacionais adequadas para proteger os seus dados contra acesso não autorizado, perda, destruição ou divulgação.
5.3. Recomendamos que mantenha o seu dispositivo seguro e o App atualizado.

6. OS SEUS DIREITOS

Nos termos da legislação aplicável, nomeadamente o Regulamento Geral de Proteção de Dados (RGPD), você tem direito a:

- Aceder aos seus dados pessoais;
- Solicitar a correção de dados inexatos;
- Solicitar a eliminação dos seus dados;
- Solicitar a limitação do tratamento dos seus dados;
- Solicitar a portabilidade dos seus dados;
- Opor-se ao tratamento dos seus dados para determinadas finalidades;
- Retirar o consentimento a qualquer momento.

Para exercer estes direitos, utilize a secção de Suporte no App ou contacte-nos através dos canais indicados.

7. RETENÇÃO DE DADOS

Conservamos os seus dados pessoais apenas pelo período necessário para cumprir as finalidades descritas nesta política. Ao eliminar a sua conta, os seus dados serão removidos dos nossos servidores no prazo máximo de 30 dias.

8. TRANSFERÊNCIA INTERNACIONAL DE DADOS

Os seus dados poderão ser processados em servidores localizados fora do seu país de residência, em conformidade com a legislação aplicável.

9. ALTERAÇÕES A ESTA POLÍTICA

O Loah poderá atualizar esta Política de Privacidade periodicamente. Notificaremos os utilizadores sobre alterações significativas através do App ou por e-mail.

10. CONTACTO

Para qualquer questão relacionada com a proteção dos seus dados pessoais, entre em contacto connosco através da Central de Ajuda no App.`,
      content_en: `PRIVACY POLICY – LOAH

Last updated: January 2025

1. INTRODUCTION

Your privacy is important to us. This Privacy Policy describes how Loah collects, uses, stores and protects your personal data when you use our application.

2. DATA WE COLLECT

2.1. Data provided by the user:
- Full name
- Email address
- Phone number (optional)
- Profile photo (optional)

2.2. Data generated by using the App:
- Financial information (transactions, accounts, budgets, assets, goals)
- Created tasks and reminders
- Contacts synced or manually added
- Reflections and messages sent to support
- Configuration preferences (theme, notifications, etc.)

2.3. Technical data:
- Device type and operating system
- App version
- Device identifiers
- Navigation and interaction data with the App

3. PURPOSE OF DATA PROCESSING

Your data is used to:

- Provide, maintain and improve App features;
- Process transactions and generate financial reports;
- Personalize your experience in the App;
- Send relevant notifications (goals, reminders, reflections);
- Respond to support requests and messages;
- Comply with legal and regulatory obligations;
- Detect and prevent fraudulent or abusive activity.

4. DATA SHARING

Loah does not sell, rent or share personal data with third parties for marketing purposes, except:

- With essential service providers for App operation (e.g., Firebase/Firestore for data storage and authentication);
- By legal obligation, court order or request from competent authority;
- To protect the rights, property or safety of Loah, users or the public.

5. DATA STORAGE AND SECURITY

5.1. Your data is securely stored on Firebase (Google Cloud Platform) servers, with encryption in transit and at rest.
5.2. We implement appropriate technical and organizational measures to protect your data against unauthorized access, loss, destruction or disclosure.

6. YOUR RIGHTS

Under applicable law, including the General Data Protection Regulation (GDPR), you have the right to:

- Access your personal data;
- Request correction of inaccurate data;
- Request deletion of your data;
- Request restriction of processing;
- Request data portability;
- Object to processing for certain purposes;
- Withdraw consent at any time.

To exercise these rights, use the Support section in the App.

7. DATA RETENTION

We retain your personal data only for the period necessary to fulfill the purposes described in this policy. When you delete your account, your data will be removed from our servers within 30 days.

8. INTERNATIONAL DATA TRANSFER

Your data may be processed on servers located outside your country of residence, in compliance with applicable law.

9. CHANGES TO THIS POLICY

Loah may update this Privacy Policy periodically. We will notify users of significant changes through the App or by email.

10. CONTACT

For any questions regarding the protection of your personal data, please contact us through the Help Center in the App.`,
    },
    {
      id: 'termos_condicoes',
      content_pt: `TERMOS E CONDIÇÕES DE USO – LOAH

Última atualização: Janeiro de 2025

1. ACEITAÇÃO DOS TERMOS

Ao baixar, aceder ou utilizar o aplicativo Loah, você concorda em cumprir e ficar vinculado aos presentes Termos e Condições de Uso.

2. DESCRIÇÃO DO SERVIÇO

O Loah é uma plataforma de organização financeira e produtividade pessoal que oferece:

- Gestão de finanças pessoais (contas, transações, orçamentos, ativos e relatórios);
- Definição e acompanhamento de metas financeiras;
- Gestão de tarefas e produtividade;
- Gestão de contactos;
- Reflexões diárias e notificações inteligentes;
- Central de Ajuda e suporte ao utilizador.

3. CADASTRO E CONTA DO UTILIZADOR

3.1. Para utilizar o App, é necessário criar uma conta fornecendo informações verdadeiras e completas.
3.2. O utilizador é responsável pela confidencialidade das suas credenciais de acesso.
3.3. O Loah reserva-se ao direito de suspender ou cancelar contas que violem estes Termos.

4. PRIVACIDADE E PROTEÇÃO DE DADOS

O tratamento dos dados pessoais dos utilizadores é realizado nos termos da nossa Política de Privacidade.

5. OBRIGAÇÕES DO UTILIZADOR

O utilizador compromete-se a não utilizar o App para fins ilegais, não interferir com o funcionamento do App e manter os seus dados de conta atualizados.

6. PROPRIEDADE INTELECTUAL

Todos os direitos relativos ao App são propriedade exclusiva do Loah ou dos seus licenciadores.

7. LIMITAÇÃO DE RESPONSABILIDADE

O Loah é fornecido "como está". As ferramentas de gestão financeira são meramente informativas e não constituem aconselhamento financeiro profissional.

8. CANCELAMENTO E RESCISÃO

O utilizador pode cancelar a sua conta a qualquer momento através das configurações do App.

9. ALTERAÇÕES AOS TERMOS

O Loah poderá modificar estes Termos a qualquer momento. As alterações serão comunicadas através do App.

10. LEI APLICÁVEL

Estes Termos são regidos pela legislação aplicável.

11. CONTACTO

Para questões relacionadas com estes Termos, entre em contacto através da Central de Ajuda no App.`,
      content_en: `TERMS AND CONDITIONS OF USE – LOAH

Last updated: January 2025

1. ACCEPTANCE OF TERMS

By downloading, accessing or using the Loah application, you agree to comply with and be bound by these Terms and Conditions of Use.

2. DESCRIPTION OF SERVICE

Loah is a personal finance and productivity organization platform that offers:

- Personal finance management (accounts, transactions, budgets, assets and reports);
- Goal setting and tracking;
- Task and productivity management;
- Contact management;
- Daily reflections and smart notifications;
- Help Center and user support.

3. USER REGISTRATION AND ACCOUNT

3.1. To use the App, you must create an account providing true and complete information.
3.2. The user is responsible for the confidentiality of their access credentials.
3.3. Loah reserves the right to suspend or cancel accounts that violate these Terms.

4. PRIVACY AND DATA PROTECTION

The processing of users' personal data is carried out in accordance with our Privacy Policy.

5. USER OBLIGATIONS

The user agrees not to use the App for illegal purposes, not to interfere with the App's operation and to keep their account data updated.

6. INTELLECTUAL PROPERTY

All rights related to the App are the exclusive property of Loah or its licensors.

7. LIMITATION OF LIABILITY

Loah is provided "as is". Financial management tools are for informational purposes only and do not constitute professional financial advice.

8. CANCELLATION AND TERMINATION

The user may cancel their account at any time through the App settings.

9. CHANGES TO TERMS

Loah may modify these Terms at any time. Changes will be communicated through the App.

10. APPLICABLE LAW

These Terms are governed by applicable law.

11. CONTACT

For questions regarding these Terms, please contact us through the Help Center in the App.`,
    },
  ];

for (const content of appContent) {
    const contentDoc = db.collection('appContent').doc(content.id);
    batch.set(contentDoc, {
      content_pt: content.content_pt,
      content_en: content.content_en,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  // ─── CONTEUDO DO APP - documento aboutLoah (formato usado pelo app) ──
  // O app Flutter (HelpCenterService.getAboutLoahContent) lê o documento
  // `appContent/aboutLoah` com os campos terms/privacyPolicy/aboutUs.
  // Este documento é o que alimenta as telas TermosPrivacyScreen e
  // AboutLoahScreen. Usa o mesmo conteudo dos ficheiros assets/content.
  const aboutLoah = {
    id: 'aboutLoah',
    terms: appContent.find(c => c.id === 'termos_condicoes')?.content_pt || '',
    privacyPolicy: appContent.find(c => c.id === 'politica_privacidade')?.content_pt || '',
    aboutUs: appContent.find(c => c.id === 'sobre_nos')?.content_pt || '',
  };
  const aboutLoahDoc = db.collection('appContent').doc(aboutLoah.id);
  batch.set(aboutLoahDoc, {
    terms: aboutLoah.terms,
    privacyPolicy: aboutLoah.privacyPolicy,
    aboutUs: aboutLoah.aboutUs,
    lastUpdatedBy: 'seed',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await batch.commit();
  console.log('✅ App data seeded successfully!');
  console.log('   - Reflections:', reflections.length);
  console.log('   - Help Center Categories:', helpCategories.length);
  console.log('   - Help Center Articles:', articles.length);
  console.log('   - App Content:', appContent.length);
}

// ─── CLI: permitir executar seedAppData ─────────────────────────
// node seed.js --app
// node seed.js <USER_UID> --app

const args = process.argv.slice(2);
const isAppSeed = args.includes('--app');
const userUid = args.find(a => a !== '--app');

if (userUid && isAppSeed) {
  seedUserData(userUid).then(() => seedAppData()).then(() => process.exit(0)).catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
} else if (userUid) {
  seedUserData(userUid).then(() => process.exit(0)).catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
} else if (isAppSeed) {
  seedAppData().then(() => process.exit(0)).catch(err => {
    console.error('❌ Error:', err);
    process.exit(1);
  });
} else {
  console.log('Usage:');
  console.log('  node seed.js <USER_UID>           # Seed user data');
  console.log('  node seed.js --app                # Seed global app data');
  console.log('  node seed.js <USER_UID> --app     # Seed both');
  console.log('');
  console.log('Example:');
  console.log('  node seed.js abc123...');
  console.log('  node seed.js --app');
  console.log('  node seed.js abc123... --app');
}

module.exports = { seedUserData, seedAppData };
