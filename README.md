# Loah — App Flutter (Dashboard, Metas, Tarefas, Finanças, Contactos)

Aplicação **Loah**, em Flutter/Dart, com arquitetura modular, widgets
reutilizáveis, suporte a **tema claro/escuro**, **i18n (PT/EN)** e
**backend Firebase** (Auth, Firestore, Storage, Functions, Messaging).

## Como rodar

```bash
flutter pub get
flutter run
```

Requer Flutter 3.x (Dart >= 3.3).

Para usar o backend Firebase, é preciso ter o `google-services.json`
(Android) e/ou `GoogleService-Info.plist` (iOS) configurados no projeto
(ver `firebase.json`), além de aplicar as regras de segurança:

```bash
firebase deploy --only firestore:rules,storage:rules,functions
```

## Arquitetura

```
lib/
├── main.dart                     # Root: ThemeMode + navegação + Firebase init
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Paleta de cores central
│   │   ├── app_theme.dart        # ThemeData claro/escuro + LoahColors (ThemeExtension)
│   │   └── app_colors.dart
│   ├── l10n/
│   │   ├── app_localizations.dart# Tradução centralizada PT/EN (AppLocales)
│   │   └── locale_controller.dart# InheritedWidget do idioma atual
│   ├── services/                 # Camada de acesso a dados (Firebase)
│   │   ├── auth_service.dart     # Firebase Auth (email, Google, Apple)
│   │   ├── user_service.dart     # Perfis de utilizador
│   │   ├── finance_service.dart  # Transações, contas, orçamentos, ativos
│   │   ├── goal_service.dart     # Metas
│   │   ├── task_service.dart     # Tarefas
│   │   ├── contact_service.dart  # Contactos
│   │   ├── notification_service.dart / notification_scheduler.dart
│   │   └── ...
│   ├── utils/                    # Helpers (currency_formatter, csv/pdf_export, ...)
│   └── constants/app_spacing.dart# Escala de espaçamento e raios
├── models/                       # Entidades puras (sem lógica de UI)
│   ├── transaction_model.dart
│   ├── goal_model.dart
│   ├── task_model.dart
│   ├── contact_model.dart
│   └── ...
├── widgets/                      # Componentes compartilhados entre telas
│   ├── loah_app_bar.dart
│   ├── loah_bottom_nav.dart
│   ├── loah_drawer.dart
│   ├── section_header.dart
│   └── ...
└── screens/                      # Telas por feature
    ├── auth/                     # Login, Signup, Email Verification, Password Recovery/Reset
    ├── splash/                   # Splash screen
    ├── onboarding/               # Onboarding (primeira vez)
    ├── dashboard/                # Tela "Dashboard"
    ├── finances/                 # Tela "Finanças"
    ├── goals/                    # Tela "Metas"
    ├── tasks/                    # Tela "Tarefas"
    ├── contacts/                 # Tela "Contactos"
    ├── notifications/            # Notificações
    ├── support/                  # Central de Ajuda, Sobre Loah, Termos
    ├── profile/                  # Perfil do utilizador
    └── admin/                    # Gestão admin (utilizadores, reflexões, ajuda)
functions/                        # Cloud Functions (Node.js) — seed/upload de conteúdo
firestore.rules                   # Regras de segurança do Firestore
storage.rules                     # Regras de segurança do Firebase Storage
```

### Firebase / Firestore

A app usa o **Firebase** como backend:

- **Firebase Auth** — login com email/senha, Google e Apple (com
  verificação de email e recuperação/redefinição de senha por deep link).
- **Cloud Firestore** — armazenamento de todos os dados do utilizador
  (metas, tarefas, transações, contas, orçamentos, ativos, recorrências,
  contactos, reflexões, notificações, conteúdo da Central de Ajuda).
- **Firebase Storage** — fotos de perfil e imagens de metas/contactos.
- **Firebase Cloud Functions** (`functions/`) — scripts de seed e upload
  de conteúdo inicial (ex.: `seed.js`, `upload-app-content.js`).
- **Firebase Messaging** — notificações push (com exibição em foreground
  via `flutter_local_notifications`).
- **Firebase Analytics / Crashlytics** — métricas e monitorização.

As **regras de segurança** estão em `firestore.rules` e `storage.rules`
e devem ser implantadas com `firebase deploy` antes de usar a app em
produção (senão os utilizadores recebem erros de permissão).

### Princípios aplicados

- **Modularização por feature**: cada tela tem sua própria pasta
  `widgets/` com componentes que só fazem sentido ali (ex.:
  `BalanceCard` só existe no Dashboard). Componentes usados em 2+ telas
  vivem em `lib/widgets/`.
- **Separação de dados e UI**: `models/` não importa nada de Flutter
  Material além do essencial (`Color`/`IconData`), então podem ser
  testados isoladamente. O acesso a dados fica em `core/services/`.
- **Tema via `ThemeExtension`**: cores específicas do produto
  (`LoahColors.positive`, `.negative`, `.accentBlue`, etc.) ficam fora
  do `ColorScheme` padrão, evitando "cores mágicas" espalhadas pelo
  código. Acesse com `context.loahColors.accentBlue`.
- **i18n centralizada**: todas as strings estão em
  `core/l10n/app_localizations.dart` e são acedidas via
  `AppLocales.of(context).translate('chave')`, suportando PT e EN.
- **Widgets pequenos e nomeados**: cada card do design (saldo, meta em
  destaque, distribuição de gastos, item de tarefa...) é seu próprio
  `StatelessWidget`, testável e reaproveitável.
- **Zero “números mágicos” de estilo**: espaçamento e raios usam
  `AppSpacing`/`AppRadius`.

### Alternando o tema

Um botão de sol/lua no app bar chama
`LoahThemeController.of(context).toggleTheme()` — um `InheritedWidget`
simples que evita passar callbacks por múltiplos níveis de widgets.
Para produção, isso pode ser trocado por um `ChangeNotifier`/Riverpod
sem alterar as telas, já que elas dependem apenas do `BuildContext`.

### Alternando o idioma

O idioma atual é gerido pelo `LocaleController` (um `InheritedWidget`).
Para obter uma string traduzida, use no `build`:

```dart
final loc = AppLocales.of(context);
Text(loc.translate('dashboard_saldo'));
```

### Dados

Os dados são persistidos no **Cloud Firestore** por utilizador
(autenticado via Firebase Auth). As telas consomem os dados através dos
serviços em `lib/core/services/` (ex.: `FinanceService`, `GoalService`,
`TaskService`, `ContactService`), que fazem CRUD no Firestore e
reagem em tempo real às alterações.
