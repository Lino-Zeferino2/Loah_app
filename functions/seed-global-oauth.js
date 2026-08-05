// Script para semear os dados globais do app (reflections, helpCenterCategories,
// helpCenterArticles, appContent) via FIREBASE CLI refresh_token + Firestore REST API.
// O seed.js original usa applicationDefault(), que requer uma service account.
// Este script usa o mesmo mecanismo do upload-app-content.js (OAuth2 com refresh_token
// da sessão do Firebase CLI), por isso funciona sem service account.
//
//   node seed-global-oauth.js

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const PROJECT_ID = 'loahapp';

// Cliente OAuth2 publico usado pelo Firebase CLI para login com o Google.
const OAUTH_CLIENT_ID = '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const OAUTH_CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

// Lê o refresh_token da sessao do Firebase CLI
function getRefreshToken() {
  const candidates = [
    path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json'),
    path.join(os.homedir(), 'AppData', 'Roaming', 'configstore', 'firebase-tools.json'),
  ];
  for (const p of candidates) {
    if (fs.existsSync(p)) {
      try {
        const json = JSON.parse(fs.readFileSync(p, 'utf8'));
        if (json.tokens && json.tokens.refresh_token) {
          return json.tokens.refresh_token;
        }
      } catch (_) {}
    }
  }
  throw new Error('Nao foi possivel obter o refresh_token do Firebase CLI. Execute "firebase login".');
}

// Renova o access_token via OAuth2
function refreshAccessToken() {
  return new Promise((resolve, reject) => {
    const refreshToken = getRefreshToken();
    const data = new URLSearchParams({
      grant_type: 'refresh_token',
      client_id: OAUTH_CLIENT_ID,
      client_secret: OAUTH_CLIENT_SECRET,
      refresh_token: refreshToken,
    });
    const req = https.request(
      {
        method: 'POST',
        hostname: 'oauth2.googleapis.com',
        path: '/token',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      },
      (res) => {
        let raw = '';
        res.on('data', (c) => (raw += c));
        res.on('end', () => {
          const r = JSON.parse(raw);
          if (r.access_token) resolve(r.access_token);
          else reject(new Error('Falha ao obter access_token: ' + (r.error || 'sem resposta')));
        });
      }
    );
    req.on('error', reject);
    req.write(data.toString());
    req.end();
  });
}

// Faz uma chamada HTTP para o Firestore REST API
const V = (v) => ({ stringValue: String(v) });
const B = (v) => ({ booleanValue: !!v });
const N = (v) => ({ integerValue: String(v) });
const I = () => ({ timestampValue: new Date().toISOString() });

function firestoreRequest({ method, url, token, body }) {
  return new Promise((resolve, reject) => {
    const u = new URL(url);
    const data = body ? JSON.stringify(body) : null;
    const req = https.request(
      {
        method,
        hostname: u.hostname,
        path: u.pathname + u.search,
        headers: {
          Authorization: 'Bearer ' + token,
          'Content-Type': 'application/json',
          ...(data ? { 'Content-Length': Buffer.byteLength(data) } : {}),
        },
      },
      (res) => {
        let raw = '';
        res.on('data', (c) => (raw += c));
        res.on('end', () => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            resolve(raw ? JSON.parse(raw) : {});
          } else {
            reject(new Error('HTTP ' + res.statusCode + ': ' + raw));
          }
        });
      }
    );
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

async function upsertDoc(token, collection, docId, fields) {
  const baseUrl = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collection}`;
  try {
    const updateUrl = `${baseUrl}/${docId}?currentDocument.exists=true`;
    await firestoreRequest({ method: 'PATCH', url: updateUrl, token, body: { fields } });
  } catch (err) {
    if (String(err).includes('404')) {
      const createUrl = `${baseUrl}?documentId=${docId}`;
      await firestoreRequest({ method: 'POST', url: createUrl, token, body: { fields } });
    } else {
      throw err;
    }
  }
}

// ── DADOS ──────────────────────────────────────────────────────────

const reflections = [
  { id: 'reflection_1', text_pt: 'O que é medido, é gerenciado.', text_en: 'What gets measured, gets managed.', imageUrl: 'https://images.unsplash.com/photo-1483728642387-6c3bdd6c93e5?w=800', active: true },
  { id: 'reflection_2', text_pt: 'Pequenas ações diárias levam a grandes resultados.', text_en: 'Small daily actions lead to great results.', imageUrl: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800', active: true },
  { id: 'reflection_3', text_pt: 'A jornada de mil milhas começa com um único passo.', text_en: 'A journey of a thousand miles begins with a single step.', imageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800', active: true },
  { id: 'reflection_4', text_pt: 'Não espere pelo momento perfeito. Comece onde está, com o que tem.', text_en: 'Do not wait for the perfect moment. Start where you are, with what you have.', imageUrl: 'https://images.unsplash.com/photo-1500534623283-312aade485b7?w=800', active: true },
  { id: 'reflection_5', text_pt: 'O sucesso não é final, o fracasso não é fatal: é a coragem de continuar que conta.', text_en: 'Success is not final, failure is not fatal: it is the courage to continue that counts.', imageUrl: 'https://images.unsplash.com/photo-1470071459604-7b8ec44ffd4e?w=800', active: true },
  { id: 'reflection_6', text_pt: 'Invista em você mesmo. É o melhor investimento que você pode fazer.', text_en: 'Invest in yourself. It is the best investment you can make.', imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800', active: true },
  { id: 'reflection_7', text_pt: 'A disciplina é a ponte entre metas e realizações.', text_en: 'Discipline is the bridge between goals and accomplishments.', imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800', active: true },
  { id: 'reflection_8', text_pt: 'Cada centavo economizado é um centavo ganho.', text_en: 'Every penny saved is a penny earned.', imageUrl: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=800', active: true },
  { id: 'reflection_9', text_pt: 'O melhor momento para plantar uma árvore foi há 20 anos. O segundo melhor momento é agora.', text_en: 'The best time to plant a tree was 20 years ago. The second best time is now.', imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800', active: true },
  { id: 'reflection_10', text_pt: 'Seu futuro é criado pelo que você faz hoje, não amanhã.', text_en: 'Your future is created by what you do today, not tomorrow.', imageUrl: 'https://images.unsplash.com/photo-1517486808906-6ca8b3f04846?w=800', active: true },
];

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

const articles = [
  { id: 'art_como_criar_conta', categoryId: 'cat_conta', title_pt: 'Como criar uma conta?', title_en: 'How to create an account?', content_pt: 'Para criar uma conta no Loah, abra o aplicativo e toque em "Cadastre-se". Preencha seu nome, email e senha. Você também pode usar o Google ou Apple. Após o cadastro, verifique seu email.', content_en: 'To create a Loah account, open the app and tap "Sign Up". Fill in your name, email and password. You can also use Google or Apple. After signing up, verify your email.', views: 0 },
  { id: 'art_como_adicionar_transacao', categoryId: 'cat_financas', title_pt: 'Como adicionar uma transação?', title_en: 'How to add a transaction?', content_pt: 'Vá até a tela de Finanças e toque no botão "+". Escolha entre Despesa ou Receita, preencha o valor, nome, categoria e conta.', content_en: 'Go to the Finances screen and tap the "+" button. Choose between Expense or Income, fill in the amount, name, category and account.', views: 0 },
  { id: 'art_como_criar_meta', categoryId: 'cat_metas', title_pt: 'Como criar uma meta?', title_en: 'How to create a goal?', content_pt: 'Vá para a tela de Metas e toque em "Nova Meta". Dê um nome, escolha categoria e prazo. Você pode adicionar valor alvo e foto inspiradora.', content_en: 'Go to the Goals screen and tap "New Goal". Give it a name, choose category and term. You can add a target value and an inspiring photo.', views: 0 },
  { id: 'art_como_gerenciar_tarefas', categoryId: 'cat_tarefas', title_pt: 'Como gerenciar tarefas?', title_en: 'How to manage tasks?', content_pt: 'Na tela de Tarefas, veja suas tarefas por "Hoje", "Próximos Dias" e "Concluídos". Toque em "+" para adicionar uma nova tarefa.', content_en: 'On the Tasks screen, see your tasks by "Today", "Upcoming Days" and "Completed". Tap "+" to add a new task.', views: 0 },
  { id: 'art_como_adicionar_contato', categoryId: 'cat_contatos', title_pt: 'Como adicionar um contato?', title_en: 'How to add a contact?', content_pt: 'Na tela de Contatos, toque em "+" para adicionar um novo contato. Preencha nome, telefone, email e grau de conexão.', content_en: 'On the Contacts screen, tap "+" to add a new contact. Fill in name, phone, email and connection degree.', views: 0 },
  { id: 'art_como_exportar_dados', categoryId: 'cat_financas', title_pt: 'Como exportar meus dados financeiros?', title_en: 'How to export my financial data?', content_pt: 'Na tela de Relatórios, exporte seus dados em CSV ou PDF. CSV para Excel/Sheets, PDF para relatório visual com gráficos.', content_en: 'On the Reports screen, export your data in CSV or PDF. CSV for Excel/Sheets, PDF for a visual report with charts.', views: 0 },
  { id: 'art_como_alterar_senha', categoryId: 'cat_conta', title_pt: 'Como alterar minha senha?', title_en: 'How to change my password?', content_pt: 'No menu lateral, vá em "Alterar senha". Informe sua senha atual e a nova senha (mínimo 6 caracteres).', content_en: 'In the side menu, go to "Change password". Enter your current password and the new one (min 6 chars).', views: 0 },
  { id: 'art_privacidade_dados', categoryId: 'cat_privacidade', title_pt: 'Como o Loah protege meus dados?', title_en: 'How does Loah protect my data?', content_pt: 'O Loah utiliza criptografia em trânsito e em repouso. Seus dados são armazenados no Firebase com segurança.', content_en: 'Loah uses encryption in transit and at rest. Your data is stored securely on Firebase.', views: 0 },
  { id: 'art_contas_recorrentes', categoryId: 'cat_contas', title_pt: 'Como funcionam as contas recorrentes?', title_en: 'How do recurring transactions work?', content_pt: 'As contas recorrentes geram transações automáticas todo mês no dia escolhido. O Loah envia lembretes 3 dias antes.', content_en: 'Recurring transactions generate automatic transactions every month on the chosen day. Loah sends reminders 3 days before.', views: 0 },
  { id: 'art_orcamentos', categoryId: 'cat_financas', title_pt: 'Como criar orçamentos?', title_en: 'How to create budgets?', content_pt: 'Na tela de Orçamentos, toque em "+" para criar um orçamento para uma categoria e defina o limite mensal.', content_en: 'On the Budgets screen, tap "+" to create a budget for a category and set the monthly limit.', views: 0 },
];

function fieldsForReflection(r) {
  return {
    text_pt: V(r.text_pt),
    text_en: V(r.text_en),
    imageUrl: V(r.imageUrl),
    active: B(r.active),
    createdAt: I(),
    updatedAt: I(),
  };
}

function fieldsForCategory(c) {
  return {
    name_pt: V(c.name_pt),
    name_en: V(c.name_en),
    icon: V(c.icon),
    order: N(c.order),
    createdAt: I(),
    updatedAt: I(),
  };
}

function fieldsForArticle(a) {
  return {
    categoryId: V(a.categoryId),
    title_pt: V(a.title_pt),
    title_en: V(a.title_en),
    content_pt: V(a.content_pt),
    content_en: V(a.content_en),
    views: N(a.views),
    createdAt: I(),
    updatedAt: I(),
  };
}

async function main() {
  console.log('A obter token de acesso...');
  const token = await refreshAccessToken();

  console.log('A semear reflections...');
  for (const r of reflections) {
    await upsertDoc(token, 'reflections', r.id, fieldsForReflection(r));
  }

  console.log('A semear helpCenterCategories...');
  for (const c of helpCategories) {
    await upsertDoc(token, 'helpCenterCategories', c.id, fieldsForCategory(c));
  }

  console.log('A semear helpCenterArticles...');
  for (const a of articles) {
    await upsertDoc(token, 'helpCenterArticles', a.id, fieldsForArticle(a));
  }

  console.log('✅ Seed global concluído!');
  console.log('   - Reflections:', reflections.length);
  console.log('   - Help Center Categories:', helpCategories.length);
  console.log('   - Help Center Articles:', articles.length);
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Erro no seed: ' + err.message);
    process.exit(1);
  });
