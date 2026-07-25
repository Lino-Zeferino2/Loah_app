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

// ─── CLI: permite executar com node seed.js <UID> ──────────────
const uid = process.argv[2];
if (uid) {
  seedUserData(uid).then(() => process.exit(0)).catch(err => {
    console.error('❌ Error seeding data:', err);
    process.exit(1);
  });
} else {
  console.log('Usage: node seed.js <USER_UID>');
  console.log('Example: node seed.js abc123...');
  console.log('(You can find your UID in Firebase Console > Authentication > Users)');
}

module.exports = { seedUserData };
