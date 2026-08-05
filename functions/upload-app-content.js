// Script para fazer upload do conteudo legal do app
// (politica de privacidade, termos e condicoes, sobre nos)
// para o Firestore, no documento `appContent/aboutLoah`,
// no formato que o app Flutter espera:
//   - terms          -> termos_condicoes.txt
//   - privacyPolicy  -> politica_privacidade.txt
//   - aboutUs        -> sobre_nos.txt
//
// Usa o refresh_token da sessao do Firebase CLI (firebase login)
// para obter um access_token valido via OAuth2 e depois escreve
// no Firestore REST API.
//
//   node upload-app-content.js [lastUpdatedBy]

const fs = require('fs');
const path = require('path');
const os = require('os');
const https = require('https');

const PROJECT_ID = 'loahapp';

// Cliente OAuth2 publico usado pelo Firebase CLI para login com o Google.
const OAUTH_CLIENT_ID = '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const OAUTH_CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

const CONTENT_DIR = path.join(__dirname, '..', 'assets', 'content');

const sources = [
  { field: 'terms', file: 'termos_condicoes.txt', label: 'Termos e Condicoes' },
  { field: 'privacyPolicy', file: 'politica_privacidade.txt', label: 'Politica de Privacidade' },
  { field: 'aboutUs', file: 'sobre_nos.txt', label: 'Sobre Nos' },
];

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

// Faz upload do conteudo para appContent/aboutLoah
async function uploadAppContent(lastUpdatedBy = 'firebase-cli') {
  console.log('A obter token de acesso...');
  const token = await refreshAccessToken();

  console.log('A ler ficheiros de conteudo...');
  const payload = {};
  for (const src of sources) {
    const filePath = path.join(CONTENT_DIR, src.file);
    if (!fs.existsSync(filePath)) {
      throw new Error('Ficheiro nao encontrado: ' + filePath);
    }
    const content = fs.readFileSync(filePath, 'utf8').trim();
    payload[src.field] = content;
    console.log('   - ' + src.label + ': ' + src.file + ' (' + content.length + ' caracteres)');
  }

payload.lastUpdatedBy = lastUpdatedBy;
  payload.updatedAt = new Date().toISOString();

  // Converte payload num documento Firestore (Fields)
  // updatedAt e createdAt são timestamps (a app chama .toDate())
  const fields = {};
  for (const [k, v] of Object.entries(payload)) {
    if (k === 'updatedAt') {
      fields[k] = { timestampValue: v };
    } else {
      fields[k] = { stringValue: v };
    }
  }

  const baseUrl = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/appContent`;

  console.log('A guardar em appContent/aboutLoah...');

  // Tenta atualizar o documento existente (merge)
  try {
    const updateUrl = baseUrl + '/aboutLoah?currentDocument.exists=true';
    const resp = await firestoreRequest({
      method: 'PATCH',
      url: updateUrl,
      token,
      body: { fields },
    });
    console.log('Documento atualizado. name:', resp.name);
  } catch (err) {
    // Se o documento nao existe (404), tenta criar
    if (String(err).includes('404')) {
      const createUrl = baseUrl + '?documentId=aboutLoah';
      const resp = await firestoreRequest({
        method: 'POST',
        url: createUrl,
        token,
        body: { fields },
      });
      console.log('Documento criado. name:', resp.name);
    } else {
      throw err;
    }
  }

  console.log('Conteudo guardado com sucesso em appContent/aboutLoah!');
  console.log('   - terms: ' + payload.terms.length + ' caracteres');
  console.log('   - privacyPolicy: ' + payload.privacyPolicy.length + ' caracteres');
  console.log('   - aboutUs: ' + payload.aboutUs.length + ' caracteres');
}

// CLI
const args = process.argv.slice(2);
const lastUpdatedBy = args[0] || 'firebase-cli';

uploadAppContent(lastUpdatedBy)
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('Erro no upload: ' + err.message);
    process.exit(1);
  });

module.exports = { uploadAppContent };
