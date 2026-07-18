# TODO

- [ ] Ler e localizar como a `HelpCenterScreen` é referenciada no app (rotas/nav) e confirmar arquivo atual.
- [ ] Criar novo diretório `lib/screens/support/widgets/` com componentes:
  - [ ] `help_center_header.dart`
  - [ ] `help_center_categories.dart`
  - [ ] `help_center_popular_articles.dart`
  - [ ] `help_center_contact_section.dart`
  - [ ] `help_center_newsletter.dart`
- [ ] Atualizar `lib/screens/support/help_center_screen.dart` para usar os novos componentes.
- [ ] Remover uso de cores hardcoded (ex: `Colors.green`) e trocar por cores do `theme` (`Theme.of(context).colorScheme` / `textTheme`) ou `LoahColors` via extension.
- [ ] Garantir que toda a estrutura/estilos mantém o mesmo padrão visual.
- [ ] Rodar `flutter analyze` e `flutter test` (se aplicável) para validar build.

