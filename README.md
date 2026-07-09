# Loah — App Flutter (Dashboard, Metas, Tarefas, Finanças)

Implementação fiel dos 4 telas do design **Loah**, em Flutter/Dart, com
arquitetura modular, widgets reutilizáveis e suporte a **tema claro e
escuro**.

## Como rodar

```bash
flutter pub get
flutter run
```

Requer Flutter 3.x (Dart >= 3.3).

## Arquitetura

```
lib/
├── main.dart                     # Root: ThemeMode + navegação (bottom nav)
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Paleta de cores central
│   │   └── app_theme.dart        # ThemeData claro/escuro + LoahColors (ThemeExtension)
│   ├── constants/app_spacing.dart# Escala de espaçamento e raios
│   └── utils/currency_formatter.dart
├── models/                       # Entidades puras (sem lógica de UI)
│   ├── transaction_model.dart
│   ├── goal_model.dart
│   └── task_model.dart
├── widgets/                      # Componentes compartilhados entre telas
│   ├── loah_app_bar.dart
│   ├── loah_bottom_nav.dart
│   ├── loah_card.dart
│   ├── loah_avatar_action.dart
│   ├── section_header.dart
│   └── labeled_progress_bar.dart
└── screens/
    ├── dashboard/                # Tela "Dashboard"
    │   ├── dashboard_screen.dart
    │   └── widgets/              # Widgets exclusivos desta tela
    ├── finances/                 # Tela "Finanças"
    ├── goals/                    # Tela "Metas"
    └── tasks/                    # Tela "Tarefas"
```

### Princípios aplicados

- **Modularização por feature**: cada tela tem sua própria pasta
  `widgets/` com componentes que só fazem sentido ali (ex.:
  `BalanceCard` só existe no Dashboard). Componentes usados em 2+ telas
  vivem em `lib/widgets/`.
- **Separação de dados e UI**: `models/` não importa nada de Flutter
  Material além do essencial (`Color`/`IconData`), então podem ser
  testados isoladamente.
- **Tema via `ThemeExtension`**: cores específicas do produto
  (`LoahColors.positive`, `.negative`, `.accentBlue`, etc.) ficam fora
  do `ColorScheme` padrão, evitando "cores mágicas" espalhadas pelo
  código. Acesse com `context.loahColors.accentBlue`.
- **Widgets pequenos e nomeados**: cada card do design (saldo, meta em
  destaque, distribuição de gastos, item de tarefa...) é seu próprio
  `StatelessWidget`, testável e reaproveitável.
- **Zero “números mágicos” de estilo**: espaçamento e raios usam
  `AppSpacing`/`AppRadius`.

### Alternando o tema

Um botão de sol/lua no app bar do Dashboard chama
`LoahThemeController.of(context).toggleTheme()` — um `InheritedWidget`
simples que evita passar callbacks por múltiplos níveis de widgets.
Para produção, isso pode ser trocado por um `ChangeNotifier`/Riverpod
sem alterar as telas, já que elas dependem apenas do `BuildContext`.

### Dados

Todos os dados são mocks locais (`const`/`static final` nas telas) —
não há chamada de rede ou persistência. Para integrar com uma API,
troque as listas estáticas por um `FutureBuilder`/repository sem
alterar os widgets de apresentação.
