<!DOCTYPE html>
<html lang="pt">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Loah — App Flutter</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@300;600;900&family=Inter:wght@300;400;600&display=swap');
  :root{--bg:#0b0c15;--card:#12142b;--text:#f0f0f8;--muted:#a0a3ba;--accent:#8b5cf6;--accent2:#f472b6;--accent3:#22d3ee;--radius:24px;}
  *{box-sizing:border-box}
  body{margin:0;font-family:'Inter',sans-serif;background:var(--bg);color:var(--text);line-height:1.6}
  header{position:relative;overflow:hidden;padding:120px 24px 80px;text-align:center;background:linear-gradient(135deg,#0b0c15 0%,#1a1030 60%,#2d1b4e 100%);}
  header::before{content:"";position:absolute;inset:0;background:url('https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=2070&auto=format&fit=crop') center/cover;opacity:.15;mix-blend-mode:overlay;}
  header img{position:relative;z-index:2;width:140px;height:140px;border-radius:50%;object-fit:cover;border:4px solid rgba(139,92,246,.6);box-shadow:0 0 60px rgba(139,92,246,.3);margin-bottom:24px}
  h1{font-family:'Outfit',sans-serif;font-weight:900;font-size:clamp(3rem,8vw,6rem);margin:0;letter-spacing:-.05em;background:linear-gradient(135deg,var(--accent),var(--accent2),var(--accent3));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;filter:drop-shadow(0 10px 30px rgba(139,92,246,.4));}
  .subtitle{font-size:1.25rem;color:var(--muted);max-width:640px;margin:20px auto 0}
  .badges{display:flex;flex-wrap:wrap;justify-content:center;gap:10px;margin-top:28px;position:relative;z-index:2}
  .badge{padding:8px 16px;border-radius:999px;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.1);font-size:.85rem;font-weight:600;color:#fff;letter-spacing:.02em;}
  main{max-width:980px;margin:0 auto;padding:60px 24px}
  section{background:var(--card);border:1px solid rgba(255,255,255,.06);border-radius:var(--radius);padding:48px;margin-bottom:36px;box-shadow:0 20px 60px rgba(0,0,0,.3);}
  h2{font-family:'Outfit',sans-serif;font-weight:600;font-size:1.8rem;margin-top:0;color:#fff;display:flex;align-items:center;gap:12px}
  h2 span{display:inline-block;width:8px;height:8px;border-radius:50%;background:linear-gradient(135deg,var(--accent),var(--accent2));box-shadow:0 0 12px var(--accent)}
  code{font-family:'Fira Code',monospace;background:rgba(139,92,246,.12);padding:2px 8px;border-radius:6px;color:#c4b5fd;font-size:.95em}
  pre{background:#0b0c15;border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:20px;overflow-x:auto;color:#e2e8f0;font-size:.95rem}
  .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:20px}
  .card{background:linear-gradient(160deg,#14163a,#1a1030);border:1px solid rgba(255,255,255,.08);border-radius:16px;padding:24px;transition:transform .2s}
  .card:hover{transform:translateY(-4px)}
  .card h3{margin:0 0 8px;font-family:'Outfit';font-weight:600;font-size:1.15rem;color:#fff}
  .card p{margin:0;color:var(--muted);font-size:.95rem}
  .highlight{color:var(--accent3);font-weight:600}
  footer{text-align:center;padding:60px 24px;color:var(--muted);font-size:.9rem}
  a{color:var(--accent2);text-decoration:none}
  @media(max-width:640px){header{padding:80px 20px 60px};section{padding:28px}}
</style>
</head>
<body>
<header>
  <img src="https://images.unsplash.com/photo-1498050108023-c5249f4df085?q=80&w=2072&auto=format&fit=crop" alt="Loah App">
  <h1>Loah</h1>
  <p class="subtitle">App Flutter moderno com Dashboard, Metas, Tarefas, Finanças e Contactos — arquitetura limpa, tema claro/escuro e backend Firebase.</p>
  <div class="badges"><span class="badge">Flutter 3.x</span><span class="badge">Firebase</span><span class="badge">i18n PT / EN</span><span class="badge">Tema Escuro</span></div>
</header>

<main>
  <section>
    <h2><span></span>Sobre o projeto</h2>
    <p><strong>Loah</strong> é uma aplicação modular em <span class="highlight">Flutter/Dart</span> criada para organizar a vida pessoal e profissional. Com uma arquitetura baseada em serviços reutilizáveis, widgets limpos e consumo de dados em tempo real via <strong>Cloud Firestore</strong>, oferece uma experiência fluida em qualquer tela.</p>
  </section>

  <section>
    <h2><span></span>Como rodar</h2>
    <pre>flutter pub get
flutter run</pre>
    <p>Requer Flutter 3.x (Dart ≥ 3.3). Para o backend Firebase, configure <code>google-services.json</code> (Android) e/ou <code>GoogleService-Info.plist</code> (iOS), além das regras de segurança em <code>firebase.json</code>.</p>
  </section>

  <section>
    <h2><span></span>Recursos</h2>
    <div class="grid">
      <div class="card"><h3>🎨 Tema Dinâmico</h3><p>Alternância claro/escuro via LoahThemeController (InheritedWidget), sem propagar callbacks.</p></div>
      <div class="card"><h3>🌍 i18n</h3><p>Tradução PT/EN via LocaleController com uso simples: AppLocales.of(context).</p></div>
      <div class="card"><h3>📊 Dashboard</h3><p>Visão consolidada de metas, tarefas, saldos e contactos.</p></div>
      <div class="card"><h3>⚡ Firebase</h3><p>Auth, Firestore, Storage, Functions e Messaging integrados.</p></div>
    </div>
  </section>

  <section>
    <h2><span></span>Arquitetura</h2>
    <p>Os dados são persistidos no <strong>Cloud Firestore</strong> por utilizador autenticado. As telas consomem os dados através dos serviços em <code>lib/core/services/</code> (<code>FinanceService</code>, <code>GoalService</code>, <code>TaskService</code>, <code>ContactService</code>), que fazem CRUD e reagem em tempo real às alterações.</p>
  </section>
</main>

<footer>Loah — App Flutter • Design moderno, modular e profissional</footer>
</body>
</html>
