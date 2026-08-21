const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
// ────────────────────────────────────────────────────────────────────
// SERVER-SIDE TRANSLATION (mirrors app_localizations.dart's notif_* keys)
// Usado só para montar o texto do push do sistema (o que aparece
// quando a app está fechada), no idioma guardado no perfil do
// utilizador (users/{uid}.locale, default 'pt').
// ────────────────────────────────────────────────────────────────────

const NOTIF_STRINGS = {
  notif_cat_contatos: { pt: 'Contatos', en: 'Contacts' },
  notif_cat_tarefas: { pt: 'Tarefas', en: 'Tasks' },
  notif_cat_metas: { pt: 'Metas', en: 'Goals' },
  notif_cat_financas: { pt: 'Finanças', en: 'Finances' },
  notif_cat_sistema: { pt: 'Sistema', en: 'System' },
  notif_title_central_ajuda: { pt: 'Central de Ajuda', en: 'Help Center' },

  notif_msg_contact_overdue_days: {
    pt: 'Você não fala com {name} há {days} dias. Que tal ligar para {firstName}?',
    en: "You haven't talked to {name} in {days} days. How about calling {firstName}?",
  },
  notif_msg_contact_overdue_long: {
    pt: 'Você não fala com {name} há muito tempo. Que tal ligar para {firstName}?',
    en: "You haven't talked to {name} in a long time. How about calling {firstName}?",
  },
  notif_msg_task_upcoming_soon: {
    pt: "Tarefa '{title}' vence em menos de 1 hora.",
    en: "Task '{title}' is due in less than 1 hour.",
  },
  notif_msg_task_upcoming_hours: {
    pt: "Tarefa '{title}' vence em {hours} horas.",
    en: "Task '{title}' is due in {hours} hours.",
  },
  notif_msg_task_overdue_today: {
    pt: "Tarefa '{title}' venceu hoje e ainda não foi concluída.",
    en: "Task '{title}' was due today and hasn't been completed yet.",
  },
  notif_msg_task_overdue_1day: {
    pt: "Tarefa '{title}' venceu há 1 dia e ainda não foi concluída.",
    en: "Task '{title}' was due 1 day ago and hasn't been completed yet.",
  },
  notif_msg_task_overdue_days: {
    pt: "Tarefa '{title}' venceu há {days} dias e ainda não foi concluída.",
    en: "Task '{title}' was due {days} days ago and hasn't been completed yet.",
  },
  notif_msg_goal_milestone: {
    pt: "Sua meta '{title}' atingiu {pct}% de conclusão!",
    en: "Your goal '{title}' reached {pct}% completion!",
  },
  notif_msg_goal_completed: {
    pt: "Parabéns! Você concluiu a meta '{title}'! 🎉",
    en: "Congratulations! You completed the goal '{title}'! 🎉",
  },
  notif_msg_recurring_today: {
    pt: "Lembrete: pagamento de '{title}' vence hoje.",
    en: "Reminder: payment for '{title}' is due today.",
  },
  notif_msg_recurring_tomorrow: {
    pt: "Lembrete: pagamento de '{title}' vence amanhã.",
    en: "Reminder: payment for '{title}' is due tomorrow.",
  },
  notif_msg_recurring_days: {
    pt: "Lembrete: pagamento de '{title}' vence em {days} dias.",
    en: "Reminder: payment for '{title}' is due in {days} days.",
  },
  notif_msg_budget_over: {
    pt: 'Você ultrapassou o orçamento de {category} este mês. Gastou {spent} de {limit}.',
    en: 'You went over the {category} budget this month. You spent {spent} of {limit}.',
  },
  notif_msg_budget_warn: {
    pt: 'Está perto do limite do orçamento de {category} este mês ({pct}% usado).',
    en: "You're close to the {category} budget limit this month ({pct}% used).",
  },
  notif_msg_balance_negative: {
    pt: "A conta '{name}' está com saldo negativo: {amount}.",
    en: "Account '{name}' has a negative balance: {amount}.",
  },
  notif_msg_balance_low: {
    pt: "A conta '{name}' está com saldo baixo: {amount}.",
    en: "Account '{name}' has a low balance: {amount}.",
  },
  notif_msg_stale_asset: {
    pt: "O valor de '{name}' não é atualizado há {days} dias. Vale a pena confirmar se ainda está correto.",
    en: "The value of '{name}' hasn't been updated in {days} days. It may be worth confirming it's still accurate.",
  },
  notif_msg_support_new: {
    pt: '{userName} enviou: "{subject}"',
    en: '{userName} sent: "{subject}"',
  },
  notif_title_support_new: {
    pt: 'Nova mensagem de suporte',
    en: 'New support message',
  },
  notif_title_support_reply: {
    pt: 'Resposta do Suporte',
    en: 'Support Reply',
  },
  notif_msg_support_reply: {
    pt: 'Sua mensagem "{subject}" foi respondida.{replySuffix}',
    en: 'Your message "{subject}" has been answered.{replySuffix}',
  },
};

/** Translates a key+params to plain text in the given locale (default 'pt'). */
function translateServer(key, params, locale) {
  const lang = locale === 'en' ? 'en' : 'pt';
  const entry = NOTIF_STRINGS[key];
  if (!entry) return key;
  let text = entry[lang] || entry.pt || key;
  if (params) {
    for (const [k, v] of Object.entries(params)) {
      text = text.split(`{${k}}`).join(v);
    }
  }
  return text;
}

/** Fetches the user's stored locale preference (default 'pt'). */
async function getUserLocale(userId) {
  try {
    const doc = await db.collection('users').doc(userId).get();
    const locale = doc.data()?.locale;
    return locale === 'en' ? 'en' : 'pt';
  } catch (e) {
    return 'pt';
  }
}
// ────────────────────────────────────────────────────────────────────
// HELPERS
// ────────────────────────────────────────────────────────────────────

/**
 * Sends an FCM push notification to all devices registered for the
 * given user. Tokens are stored under:
 *   /users/{userId}/fcmTokens/{tokenId}
 */
async function sendFcmToUser(userId, payload, localizedTitle, localizedBody) {
  try {
    const tokensSnapshot = await db
      .collection('users')
      .doc(userId)
      .collection('fcmTokens')
      .get();

    if (tokensSnapshot.empty) {
      console.log(`[FCM] No tokens for user ${userId}`);
      return;
    }

    const tokens = tokensSnapshot.docs.map((doc) => doc.data().token).filter(Boolean);
    if (tokens.length === 0) return;

    // NOVO: usa o texto já traduzido (se fornecido) para o banner do
    // sistema; senão cai no title/message gravado (fallback).
    const title = localizedTitle || payload.title;
    const body = localizedBody || payload.message;

    const message = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        id: payload.id || '',
        category: payload.category || 'system',
        title: title || '',
        message: body || '',
        relatedId: payload.relatedId || '',
        progress: payload.progress !== undefined ? String(payload.progress) : '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`[FCM] Sent to ${response.successCount} devices, ${response.failureCount} failures`);

    if (response.failureCount > 0) {
      for (let i = 0; i < response.responses.length; i++) {
        const resp = response.responses[i];
        if (
          !resp.success &&
          (resp.error.code === 'messaging/invalid-registration-token' ||
            resp.error.code === 'messaging/registration-token-not-registered')
        ) {
          const tokenDoc = tokensSnapshot.docs[i];
          if (tokenDoc) {
            await tokenDoc.ref.delete();
            console.log(`[FCM] Removed invalid token: ${tokens[i]}`);
          }
        }
      }
    }
  } catch (error) {
    console.error(`[FCM] Error sending to user ${userId}:`, error);
  }
}

/**
 * Checks if a notification with the same ID already exists in Firestore.
 * This helps avoid duplicate notifications.
 */
async function notificationExists(userId, notificationId) {
  const doc = await db
    .collection('users')
    .doc(userId)
    .collection('notifications')
    .doc(notificationId)
    .get();

  return doc.exists;
}

/**
 * Writes a notification to Firestore and sends an FCM push.
 */
async function createAndSendNotification(userId, notification, sendPush = true) {
  const notificationId = notification.id;

  const exists = await notificationExists(userId, notificationId);
  if (exists) return;

  await db
    .collection('users')
    .doc(userId)
    .collection('notifications')
    .doc(notificationId)
    .set({
      category: notification.category,
      title: notification.title,
      message: notification.message,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      relatedId: notification.relatedId || null,
      progress: notification.progress || null,
      isRead: false,
      // NOVO: chave+params para o cliente traduzir na hora de mostrar.
      titleKey: notification.titleKey || null,
      messageKey: notification.messageKey || null,
      params: notification.params || null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  if (sendPush) {
    // NOVO: traduz o texto do push (banner do sistema) para o idioma
    // guardado no perfil do utilizador.
    let localizedTitle = null;
    let localizedBody = null;
    if (notification.titleKey || notification.messageKey) {
      const locale = await getUserLocale(userId);
      localizedTitle = notification.titleKey
        ? translateServer(notification.titleKey, notification.params, locale)
        : null;
      localizedBody = notification.messageKey
        ? translateServer(notification.messageKey, notification.params, locale)
        : null;
    }
    await sendFcmToUser(userId, notification, localizedTitle, localizedBody);
  }
}

// ────────────────────────────────────────────────────────────────────
// TRIGGER: Send push when a new notification is written to Firestore
// ────────────────────────────────────────────────────────────────────

/**
 * When a notification document is created in Firestore, send a push
 * notification to the user's devices.
 */
// CORRIGIDO: era "eexports" (erro de digitação com "e" duplicado) —
// isto quebrava o deploy inteiro com erro de sintaxe.
exports.sendNotificationOnWrite = functions.firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const { userId, notificationId } = context.params;
    const data = snap.data();

    if (data.isRead) return;

    const payload = {
      id: notificationId,
      category: data.category || 'system',
      title: data.title || '',
      message: data.message || '',
      relatedId: data.relatedId || '',
      progress: data.progress,
    };

    // NOVO: se a notificação (escrita pelo cliente, via
    // NotificationScheduler) já tem titleKey/messageKey, traduz o
    // texto do push para o idioma guardado no perfil do utilizador.
    let localizedTitle = null;
    let localizedBody = null;
    if (data.titleKey || data.messageKey) {
      const locale = await getUserLocale(userId);
      localizedTitle = data.titleKey
        ? translateServer(data.titleKey, data.params, locale)
        : null;
      localizedBody = data.messageKey
        ? translateServer(data.messageKey, data.params, locale)
        : null;
    }

    await sendFcmToUser(userId, payload, localizedTitle, localizedBody);
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check overdue contacts (runs daily at 08:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Every day at 08:00, scan all users and check for contacts that
 * haven't been interacted with beyond their desired frequency.
 */
exports.checkOverdueContacts = functions.pubsub
  .schedule('0 8 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking overdue contacts...');

    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const contactsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('contacts')
        .get();

      for (const contactDoc of contactsSnapshot.docs) {
        const contact = contactDoc.data();
        const desiredFrequency = contact.desiredContactFrequencyDays;
        if (!desiredFrequency) continue;

        const interactions = contact.interactions || [];
        const lastInteraction = interactions.length > 0
          ? interactions[interactions.length - 1].date.toDate()
          : null;

        const now = new Date();
        const daysSinceLastContact = lastInteraction
          ? Math.floor((now - lastInteraction) / (1000 * 60 * 60 * 24))
          : 999;

        // Use < (not <=) so that "Toda semana" (7 dias) fires on the
        // 7th day, not the 8th — matching the client-side fix.
        if (daysSinceLastContact < desiredFrequency) continue;

        // Build a deterministic period-based ID so we can notify
        // weekly for "Toda semana", bi-weekly for "A cada 15 dias",
        // monthly for "Todo mês", etc.
        // Calculate which "period bucket" we're in:
        //   week  -> isoWeek number (1-52)
        //   15d   -> bi-weekly bucket
        //   30d   -> month number
        let periodKey;
        if (desiredFrequency <= 7) {
          // Weekly — use ISO week number
          const startOfYear = new Date(now.getFullYear(), 0, 1);
          const diffDays = Math.floor((now - startOfYear) / (24 * 60 * 60 * 1000));
          const isoWeek = Math.ceil((diffDays + startOfYear.getDay() + 1) / 7);
          periodKey = `${now.getFullYear()}_W${String(isoWeek).padStart(2, '0')}`;
        } else if (desiredFrequency <= 15) {
          // Bi-weekly — use fortnight number
          const dayOfYear = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / (24 * 60 * 60 * 1000));
          const fortnight = Math.ceil(dayOfYear / 14);
          periodKey = `${now.getFullYear()}_F${fortnight}`;
        } else {
          // Monthly
          periodKey = `${now.getFullYear()}_${now.getMonth() + 1}`;
        }
        const notificationId = `notif_contact_${contactDoc.id}_${periodKey}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const contactName = contact.name || 'Contato';
        const firstName = contactName.split(' ')[0];
        const isLong = daysSinceLastContact >= 999;
        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'contacts',
          title: 'Contatos',
          message: isLong
            ? `Você não fala com ${contactName} há muito tempo. Que tal ligar para ${firstName}?`
            : `Você não fala com ${contactName} há ${daysSinceLastContact} dias. Que tal ligar para ${firstName}?`,
          relatedId: contactDoc.id,
          titleKey: 'notif_cat_contatos',
          messageKey: isLong ? 'notif_msg_contact_overdue_long' : 'notif_msg_contact_overdue_days',
          params: { name: contactName, firstName, ...(isLong ? {} : { days: String(daysSinceLastContact) }) },
        });
      }
    }

    console.log('[Scheduler] Overdue contacts check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check upcoming tasks (runs daily at 07:00 and 19:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Twice a day, check for tasks due within the next 24 hours.
 */
exports.checkUpcomingTasks = functions.pubsub
  .schedule('0 7,19 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking upcoming tasks...');

    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const tasksSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();

      for (const taskDoc of tasksSnapshot.docs) {
        const task = taskDoc.data();
        if (task.isDone || !task.dueDate) continue;

        const dueDate = task.dueDate.toDate();
        const diffHours = (dueDate - now) / (1000 * 60 * 60);

        if (diffHours < 0 || diffHours > 24) continue;

        const notificationId = `notif_task_${taskDoc.id}_${now.getFullYear()}_${now.getMonth()}_${now.getDate()}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const isSoon = diffHours < 1;
        const label = isSoon ? 'em menos de 1 hora' : `em ${Math.round(diffHours)} horas`;
        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'tasks',
          title: 'Tarefas',
          message: `Tarefa '${task.title}' vence ${label}.`,
          relatedId: taskDoc.id,
          titleKey: 'notif_cat_tarefas',
          messageKey: isSoon ? 'notif_msg_task_upcoming_soon' : 'notif_msg_task_upcoming_hours',
          params: { title: task.title, ...(isSoon ? {} : { hours: String(Math.round(diffHours)) }) },
        });
      }
    }

    console.log('[Scheduler] Upcoming tasks check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check recurring bills (runs daily at 06:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Every day at 06:00, check for recurring transactions due within
 * the next 3 days.
 */
exports.checkRecurringBills = functions.pubsub
  .schedule('0 6 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking recurring bills...');

    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const recurringSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('recurringTransactions')
        .get();

      for (const recurringDoc of recurringSnapshot.docs) {
        const recurring = recurringDoc.data();
        if (!recurring.active) continue;

        const dayOfMonth = recurring.dayOfMonth || 1;
        let dueThisMonth = new Date(now.getFullYear(), now.getMonth(), dayOfMonth);

        if (dueThisMonth < new Date(now.getFullYear(), now.getMonth(), now.getDate())) {
          dueThisMonth = new Date(now.getFullYear(), now.getMonth() + 1, dayOfMonth);
        }

        const daysUntil = Math.ceil(
          (dueThisMonth - new Date(now.getFullYear(), now.getMonth(), now.getDate())) / (1000 * 60 * 60 * 24)
        );

        if (daysUntil < 0 || daysUntil > 3) continue;

        const notificationId = `notif_recurring_${recurringDoc.id}_${dueThisMonth.getFullYear()}_${dueThisMonth.getMonth() + 1}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        // CORRIGIDO: "when" tinha deixado de ser declarado mas ainda
        // era usado no texto de fallback abaixo — causava
        // "ReferenceError: when is not defined" em runtime.
        const when = daysUntil === 0 ? 'hoje' : (daysUntil === 1 ? 'amanhã' : `em ${daysUntil} dias`);
        const messageKey = daysUntil === 0
          ? 'notif_msg_recurring_today'
          : (daysUntil === 1 ? 'notif_msg_recurring_tomorrow' : 'notif_msg_recurring_days');

        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'finance',
          title: 'Finanças',
          message: `Lembrete: pagamento de '${recurring.title}' vence ${when}.`,
          relatedId: recurringDoc.id,
          titleKey: 'notif_cat_financas',
          messageKey: messageKey,
          params: { title: recurring.title, ...(daysUntil > 1 ? { days: String(daysUntil) } : {}) },
        });
      }
    }

    console.log('[Scheduler] Recurring bills check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check overdue tasks (runs daily at 09:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Every day, check for tasks whose due date has already passed and
 * that are still not marked as done. Re-notifies once per day while
 * the task remains overdue.
 */
exports.checkOverdueTasks = functions.pubsub
  .schedule('0 9 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking overdue tasks...');

    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const tasksSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();

      for (const taskDoc of tasksSnapshot.docs) {
        const task = taskDoc.data();
        if (task.isDone || !task.dueDate) continue;

        const dueDate = task.dueDate.toDate();
        if (dueDate >= now) continue;

        const dayKey = `${now.getFullYear()}_${now.getMonth() + 1}_${now.getDate()}`;
        const notificationId = `notif_task_overdue_${taskDoc.id}_${dayKey}`;

        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const daysLate = Math.floor((now - dueDate) / (1000 * 60 * 60 * 24));
        const label = daysLate <= 0 ? 'hoje' : (daysLate === 1 ? 'há 1 dia' : `há ${daysLate} dias`);

        const messageKey = daysLate <= 0
          ? 'notif_msg_task_overdue_today'
          : (daysLate === 1 ? 'notif_msg_task_overdue_1day' : 'notif_msg_task_overdue_days');

        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'tasks',
          title: 'Tarefas',
          message: `Tarefa '${task.title}' venceu ${label} e ainda não foi concluída.`,
          relatedId: taskDoc.id,
          titleKey: 'notif_cat_tarefas',
          messageKey: messageKey,
          params: { title: task.title, ...(daysLate > 1 ? { days: String(daysLate) } : {}) },
        });
      }
    }

    console.log('[Scheduler] Overdue tasks check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check budgets over limit (runs daily at 09:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Daily check for budget categories at 80%+ (warning) or 100%+
 * (over) of their monthly limit.
 */
exports.checkOverBudget = functions.pubsub
  .schedule('0 9 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking budgets over limit...');

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);
    const endOfMonth = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);

    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      // Fetch budgets
      const budgetsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .get();

      // Fetch this month's expenses
      const transactionsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('date', '>=', startOfMonth)
        .where('date', '<=', endOfMonth)
        .where('type', '==', 'expense')
        .get();

      // Group expenses by category
      const categoryExpenses = {};
      transactionsSnapshot.forEach((doc) => {
        const data = doc.data();
        const category = data.category || 'Outros';
        const amount = data.amount || 0;
        categoryExpenses[category] = (categoryExpenses[category] || 0) + amount;
      });

      for (const budgetDoc of budgetsSnapshot.docs) {
        const budget = budgetDoc.data();
        const category = budget.category || '';
        const monthlyLimit = budget.monthlyLimit || 0;
        const spent = categoryExpenses[category] || 0;

        if (monthlyLimit <= 0) continue;
        const ratio = spent / monthlyLimit;

        if (ratio >= 1.0) {
          const notificationId = `notif_budget_over_${budgetDoc.id}_${now.getFullYear()}_${now.getMonth() + 1}`;
          const alreadyNotified = await notificationExists(userId, notificationId);
          if (alreadyNotified) continue;

          await createAndSendNotification(userId, {
            id: notificationId,
            category: 'finance',
            title: 'Finanças',
            message: `Você ultrapassou o orçamento de ${category} este mês. Gastou R$${spent.toFixed(2)} de R$${monthlyLimit.toFixed(2)}.`,
            relatedId: budgetDoc.id,
            titleKey: 'notif_cat_financas',
            messageKey: 'notif_msg_budget_over',
            params: { category, spent: `R$${spent.toFixed(2)}`, limit: `R$${monthlyLimit.toFixed(2)}` },
          });
        } else if (ratio >= 0.8) {
          const notificationId = `notif_budget_warn_${budgetDoc.id}_${now.getFullYear()}_${now.getMonth() + 1}`;
          const alreadyNotified = await notificationExists(userId, notificationId);
          if (alreadyNotified) continue;

          const pct = Math.round(ratio * 100);
          await createAndSendNotification(userId, {
            id: notificationId,
            category: 'finance',
            title: 'Finanças',
            message: `Está perto do limite do orçamento de ${category} este mês (${pct}% usado).`,
            relatedId: budgetDoc.id,
            titleKey: 'notif_cat_financas',
            messageKey: 'notif_msg_budget_warn',
            params: { category, pct: String(pct) },
          });
        }
      }
    }

    console.log('[Scheduler] Budget check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// TRIGGER: Notify admins when a user sends a support message
// ────────────────────────────────────────────────────────────────────

/**
 * When a new document is created in `helpCenterMessages`, find all
 * admin users and send them a push notification with the message details.
 */
exports.onSupportMessageCreated = functions.firestore
  .document('helpCenterMessages/{messageId}')
  .onCreate(async (snap, context) => {
    const { messageId } = context.params;
    const data = snap.data();

    console.log(`[SupportMessage] New message created: ${messageId}`);

    const userName = data.userName || 'Utilizador';
    const subject = data.subject || 'Sem assunto';
    const messagePreview = data.message || '';

    // Find all admin users
    const adminsSnapshot = await db
      .collection('users')
      .where('role', '==', 'admin')
      .get();

    if (adminsSnapshot.empty) {
      console.log('[SupportMessage] No admin users found to notify.');
      return;
    }

    const notificationId = `notif_support_msg_${messageId}`;

    for (const adminDoc of adminsSnapshot.docs) {
      const adminId = adminDoc.id;

      // Check if already notified (avoid duplicates on re-runs)
      const alreadyNotified = await notificationExists(adminId, notificationId);
      if (alreadyNotified) continue;

      await createAndSendNotification(adminId, {
        id: notificationId,
        category: 'system',
        title: 'Nova mensagem de suporte',
        message: `${userName} enviou: "${subject}"`,
        relatedId: messageId,
        titleKey: 'notif_title_support_new',
        messageKey: 'notif_msg_support_new',
        params: { userName, subject },
      });
    }

    console.log(`[SupportMessage] Notified ${adminsSnapshot.docs.length} admin(s) about message ${messageId}.`);
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check low/negative account balance (runs daily at 08:30)
// ────────────────────────────────────────────────────────────────────

/**
 * Every day, compute each account's current balance
 * (initialBalance + sum of linked transactions) and notify if it's
 * negative or below a low threshold.
 */
exports.checkLowAccountBalance = functions.pubsub
  .schedule('30 8 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking low account balances...');

    const LOW_BALANCE_THRESHOLD = 50.0;
    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const accountsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('accounts')
        .get();

      if (accountsSnapshot.empty) continue;

      const transactionsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

      const balanceDeltaByAccount = {};
      transactionsSnapshot.forEach((doc) => {
        const data = doc.data();
        const accountId = data.accountId;
        if (!accountId) return;
        const amount = data.amount || 0;
        const isIncome = data.type === 'income';
        balanceDeltaByAccount[accountId] =
          (balanceDeltaByAccount[accountId] || 0) + (isIncome ? amount : -amount);
      });

      for (const accountDoc of accountsSnapshot.docs) {
        const account = accountDoc.data();
        const initialBalance = account.initialBalance || 0;
        const delta = balanceDeltaByAccount[accountDoc.id] || 0;
        const currentBalance = initialBalance + delta;

        if (currentBalance >= LOW_BALANCE_THRESHOLD) continue;

        const name = account.name || '';
        const isNegative = currentBalance < 0;
        const dayKey = `${now.getFullYear()}_${now.getMonth() + 1}_${now.getDate()}`;
        const notificationId = `notif_low_balance_${accountDoc.id}_${dayKey}`;

        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const amountLabel = `R$${currentBalance.toFixed(2)}`;
        const message = isNegative
          ? `A conta '${name}' está com saldo negativo: ${amountLabel}.`
          : `A conta '${name}' está com saldo baixo: ${amountLabel}.`;

        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'finance',
          title: 'Finanças',
          message: message,
          relatedId: accountDoc.id,
          titleKey: 'notif_cat_financas',
          messageKey: isNegative ? 'notif_msg_balance_negative' : 'notif_msg_balance_low',
          params: { name, amount: amountLabel },
        });
      }
    }

    console.log('[Scheduler] Low account balance check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check stale assets (runs weekly, Mondays at 09:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Weekly check for assets that haven't had their value updated in
 * 30+ days, so the user's net worth stays realistic.
 */
exports.checkStaleAssets = functions.pubsub
  .schedule('0 9 * * 1')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking stale assets...');

    const STALE_DAYS_THRESHOLD = 30;
    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const assetsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('assets')
        .get();

      for (const assetDoc of assetsSnapshot.docs) {
        const asset = assetDoc.data();
        if (!asset.updatedAt) continue;

        const updatedAt = asset.updatedAt.toDate();
        const daysSinceUpdate = Math.floor((now - updatedAt) / (1000 * 60 * 60 * 24));

        if (daysSinceUpdate < STALE_DAYS_THRESHOLD) continue;

        const bucket = Math.floor(daysSinceUpdate / 30);
        const notificationId = `notif_stale_asset_${assetDoc.id}_${bucket}`;

        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const name = asset.name || '';
        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'finance',
          title: 'Finanças',
          message: `O valor de '${name}' não é atualizado há ${daysSinceUpdate} dias. Vale a pena confirmar se ainda está correto.`,
          relatedId: assetDoc.id,
          titleKey: 'notif_cat_financas',
          messageKey: 'notif_msg_stale_asset',
          params: { name, days: String(daysSinceUpdate) },
        });
      }
    }

    console.log('[Scheduler] Stale assets check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// TRIGGER: Notify user when admin replies to their support message
// ────────────────────────────────────────────────────────────────────

/**
 * When a `helpCenterMessages` document is updated, check if the
 * `adminReply` field was set (or changed). If so, send a push
 * notification to the original message author.
 */
exports.onSupportMessageReplied = functions.firestore
  .document('helpCenterMessages/{messageId}')
  .onUpdate(async (change, context) => {
    const { messageId } = context.params;
    const before = change.before.data();
    const after = change.after.data();

    const previousReply = before.adminReply || null;
    const currentReply = after.adminReply || null;

    // Only trigger if adminReply was just added (or changed)
    if (previousReply === currentReply) {
      return;
    }

    console.log(`[SupportMessage] Admin replied to message: ${messageId}`);

    const userId = after.userId;
    const subject = after.subject || 'Mensagem';
    const replyPreview = currentReply
      ? currentReply.substring(0, 120)
      : '';

    if (!userId) {
      console.log(`[SupportMessage] No userId found for message ${messageId}.`);
      return;
    }

    const notificationId = `notif_support_reply_${messageId}`;

    // Check if already notified (avoid duplicates on re-runs)
    const alreadyNotified = await notificationExists(userId, notificationId);
    if (alreadyNotified) return;

    const replySuffix = replyPreview ? ` "${replyPreview}..."` : '';
    await createAndSendNotification(userId, {
      id: notificationId,
      category: 'system',
      title: 'Resposta do Suporte',
      message: `Sua mensagem "${subject}" foi respondida.${replySuffix}`,
      relatedId: messageId,
      titleKey: 'notif_title_support_reply',
      messageKey: 'notif_msg_support_reply',
      params: { subject, replySuffix },
    });

    console.log(`[SupportMessage] Notified user ${userId} about reply to message ${messageId}.`);
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check goal milestones (runs daily at 10:00)
// ────────────────────────────────────────────────────────────────────

exports.checkGoalMilestones = functions.pubsub
  .schedule('0 10 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking goal milestones...');

    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    const milestoneThresholds = [1.0, 0.9, 0.75, 0.5, 0.25];
    const milestoneKeys = ['100', '90', '75', '50', '25'];

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const goalsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();

      for (const goalDoc of goalsSnapshot.docs) {
        const goal = goalDoc.data();

        if (goal.progressMode !== 'manualValue' || !goal.target || goal.target <= 0) continue;

        const current = goal.current || 0;
        const rawProgress = current / goal.target;
        const progress = Math.min(rawProgress, 1.5);

        let bucket = null;
        for (let i = 0; i < milestoneThresholds.length; i++) {
          if (progress >= milestoneThresholds[i]) {
            bucket = milestoneKeys[i];
            break;
          }
        }
        if (!bucket) continue;

        const notificationId = `notif_goal_${goalDoc.id}_${bucket}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const isCompleted = bucket === '100';
        const message = isCompleted
          ? `Parabéns! Você concluiu a meta '${goal.title}'! 🎉`
          : `Sua meta '${goal.title}' atingiu ${bucket}% de conclusão!`;

        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'goals',
          title: 'Metas',
          message: message,
          relatedId: goalDoc.id,
          progress: Math.min(progress, 1.0),
          titleKey: 'notif_cat_metas',
          messageKey: isCompleted ? 'notif_msg_goal_completed' : 'notif_msg_goal_milestone',
          params: { title: goal.title, ...(isCompleted ? {} : { pct: bucket }) },
        });
      }
    }

    console.log('[Scheduler] Goal milestones check complete.');
  });