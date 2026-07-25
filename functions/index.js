const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

// ────────────────────────────────────────────────────────────────────
// HELPERS
// ────────────────────────────────────────────────────────────────────

/**
 * Sends an FCM push notification to all devices registered for the
 * given user. Tokens are stored under:
 *   /users/{userId}/fcmTokens/{tokenId}
 */
async function sendFcmToUser(userId, payload) {
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

    const message = {
      notification: {
        title: payload.title,
        body: payload.message,
      },
      data: {
        id: payload.id || '',
        category: payload.category || 'system',
        title: payload.title || '',
        message: payload.message || '',
        relatedId: payload.relatedId || '',
        progress: payload.progress !== undefined ? String(payload.progress) : '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      tokens: tokens,
    };

    const response = await admin.messaging().sendEachForMulticast(message);

    console.log(`[FCM] Sent to ${response.successCount} devices, ${response.failureCount} failures`);

    // Clean up invalid tokens
    if (response.failureCount > 0) {
      for (let i = 0; i < response.responses.length; i++) {
        const resp = response.responses[i];
        if (
          !resp.success &&
          (resp.error.code === 'messaging/invalid-registration-token' ||
            resp.error.code === 'messaging/registration-token-not-registered')
        ) {
          // Remove invalid token
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

  // Avoid duplicates
  const exists = await notificationExists(userId, notificationId);
  if (exists) return;

  // Write to Firestore
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
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

  if (sendPush) {
    await sendFcmToUser(userId, notification);
  }
}

// ────────────────────────────────────────────────────────────────────
// TRIGGER: Send push when a new notification is written to Firestore
// ────────────────────────────────────────────────────────────────────

/**
 * When a notification document is created in Firestore, send a push
 * notification to the user's devices.
 */
exports.sendNotificationOnWrite = functions.firestore
  .document('users/{userId}/notifications/{notificationId}')
  .onCreate(async (snap, context) => {
    const { userId, notificationId } = context.params;
    const data = snap.data();

    // Avoid sending pushes for already-read notifications
    if (data.isRead) return;

    const payload = {
      id: notificationId,
      category: data.category || 'system',
      title: data.title || '',
      message: data.message || '',
      relatedId: data.relatedId || '',
      progress: data.progress,
    };

    await sendFcmToUser(userId, payload);
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

        if (daysSinceLastContact <= desiredFrequency) continue;

        // Check if already notified recently
        const notificationId = `notif_contact_${contactDoc.id}_${now.getFullYear()}_${now.getMonth()}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        const contactName = contact.name || 'Contato';
        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'contacts',
          title: 'Contatos',
          message: `Você não fala com ${contactName} há ${daysSinceLastContact} dias. Que tal ligar para ${contactName.split(' ')[0]}?`,
          relatedId: contactDoc.id,
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

        const label = diffHours < 1 ? 'em menos de 1 hora' : `em ${Math.round(diffHours)} horas`;
        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'tasks',
          title: 'Tarefas',
          message: `Tarefa '${task.title}' vence ${label}.`,
          relatedId: taskDoc.id,
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

        const when = daysUntil === 0 ? 'hoje' : (daysUntil === 1 ? 'amanhã' : `em ${daysUntil} dias`);
        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'finance',
          title: 'Finanças',
          message: `Lembrete: pagamento de '${recurring.title}' vence ${when}.`,
          relatedId: recurringDoc.id,
        });
      }
    }

    console.log('[Scheduler] Recurring bills check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check budgets over limit (runs on the 1st and 15th)
// ────────────────────────────────────────────────────────────────────

/**
 * Twice a month, check if any budget categories have been exceeded.
 */
exports.checkOverBudget = functions.pubsub
  .schedule('0 9 1,15 * *')
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

        if (spent <= monthlyLimit) continue;

        const notificationId = `notif_budget_${budgetDoc.id}_${now.getFullYear()}_${now.getMonth() + 1}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'finance',
          title: 'Finanças',
          message: `Você ultrapassou o orçamento de ${category} este mês. Gastou R$${spent.toFixed(2)} de R$${monthlyLimit.toFixed(2)}.`,
          relatedId: budgetDoc.id,
        });
      }
    }

    console.log('[Scheduler] Budget check complete.');
  });

// ────────────────────────────────────────────────────────────────────
// SCHEDULED: Check goal milestones (runs daily at 10:00)
// ────────────────────────────────────────────────────────────────────

/**
 * Daily check for goals that have reached 50%, 75% or 100% progress.
 */
exports.checkGoalMilestones = functions.pubsub
  .schedule('0 10 * * *')
  .timeZone('America/Sao_Paulo')
  .onRun(async (context) => {
    console.log('[Scheduler] Checking goal milestones...');

    const now = new Date();
    const usersSnapshot = await db.collection('users').get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;

      const goalsSnapshot = await db
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();

      for (const goalDoc of goalsSnapshot.docs) {
        const goal = goalDoc.data();
        
        // Only check manualValue goals with a target
        if (goal.progressMode !== 'manualValue' || !goal.target || goal.target <= 0) continue;

        const current = goal.current || 0;
        const progress = current / goal.target;

        // Only notify at 50% and 75% milestones
        if (progress < 0.5 || progress >= 1.0) continue;

        const milestoneBucket = progress < 0.75 ? '50' : '75';
        const notificationId = `notif_goal_${goalDoc.id}_${milestoneBucket}`;
        const alreadyNotified = await notificationExists(userId, notificationId);
        if (alreadyNotified) continue;

        await createAndSendNotification(userId, {
          id: notificationId,
          category: 'goals',
          title: 'Metas',
          message: `Sua meta '${goal.title}' atingiu ${Math.round(progress * 100)}% de conclusão!`,
          relatedId: goalDoc.id,
          progress: progress,
        });
      }
    }

    console.log('[Scheduler] Goal milestones check complete.');
  });

