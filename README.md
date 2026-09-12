# Loah — App Flutter

> Aplicação modular em **Flutter/Dart** para gestão pessoal: Dashboard, Metas, Tarefas, Finanças e Contactos. Arquitetura limpa, tema claro/escuro, i18n e backend Firebase.

---

## 🚀 Como rodar

```bash
flutter pub get
flutter run
```

Requer **Flutter 3.x** (Dart >= 3.3).

Para backend Firebase configure `google-services.json` / `GoogleService-Info.plist` e aplique regras:

```bash
firebase deploy --only firestore:rules,storage:rules,functions
```

---

## 📱 Funcionalidades

| Módulo | Descrição |
|--------|-----------|
| **Dashboard** | Visão consolidada de metas, tarefas e saldos |
| **Metas** | Definição e acompanhamento de objetivos |
| **Tarefas** | Lista de tarefas com prioridades e prazos |
| **Finanças** | Controle de receitas e despesas |
| **Contactos** | Gestão de contactos |
| **Notificações** | Push via Firebase Messaging |

---

## 🎨 Design

- Tema dinâmico claro/escuro (`LoahThemeController`)
- i18n PT / EN (`LocaleController`)
- Widgets reutilizáveis e arquitetura modular

---

## 🏗 Arquitetura

Dados persistidos no **Cloud Firestore** (por utilizador autenticado). Serviços em `lib/core/services/` (`FinanceService`, `GoalService`, `TaskService`, `ContactService`) fazem CRUD e reagem em tempo real.

---

## 🖼 Capturas / Screenshots

Interface responsiva com tema escuro, dashboard consolidado e navegação por módulos.

## 👤 Créditos

- **Desenvolvimento:** ZefCorp / Lino Zeferino
- **Tech:** Flutter 3.x, Firebase (Auth, Firestore, Storage, Functions, Messaging)
- **Arquitetura:** Serviços modulares (`lib/core/services/`)

## 🏷 Versão

`main` — Versão web estável (Dashboard, Metas, Tarefas, Login/Signup, Notificações).

---

## 📄 Licença

Projeto privado — Lino Zeferino.
