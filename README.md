# <img src="assets/images/logo.png" height="60"> Loah App

> **App pessoal inteligente de finanças, metas, tarefas e contactos.**

[![Flutter](https://img.shields.io/badge/Flutter-3.3+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase)](https://firebase.google.com)
[![Dart](https://img.shields.io/badge/Dart-2.0+-00B4AB?logo=dart)](https://dart.dev)

---

## 📸 Preview

<p align="center">
  <img src="assets/images/preview1.jpg" width="45%" />
  <img src="assets/images/preview2.jpg" width="45%" />
</p>

---

## ✨ Sobre o Loah

Loah é uma aplicação **Flutter** multiplataforma (Android, iOS e Web) que centraliza a vida pessoal em um só lugar. Com design moderno, animações suaves e integração total com **Firebase**, permite ao utilizador gerenciar:

- 💰 **Finanças** — gastos, rendimentos, categorias, relatórios
- 🎯 **Metas** — objetivos de longo prazo com progresso visual
- ✅ **Tarefas** — lista inteligente com prioridades e notificações
- 👥 **Contactos** — gestão de contactos com sincronização

---

## 🛠 Stack Tecnológica

<div align="center">

| Categoria | Tecnologia | Badge |
|---|---|---|
| **Frontend** | Flutter & Dart | ![Flutter](https://img.shields.io/badge/Flutter-02569B?logo=flutter) |
| **UI / Design** | Material 3, Google Fonts, FontAwesome | ![Material](https://img.shields.io/badge/Material_3-6200EE) |
| **Backend** | Firebase (Auth, Firestore, Storage, FCM) | ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase) |
| **Notificações** | flutter_local_notifications + FCM | ![Notify](https://img.shields.io/badge/Notifications-4A90E2) |
| **Web** | Flutter Web + PWA (manifest, service worker) | ![Web](https://img.shields.io/badge/Web-PWA-4285F4) |

</div>

---

## 🚀 Funcionalidades

### 💳 Finanças
- Registo de transações com categorias personalizadas
- Gráficos de saldo e evolução mensal
- Orçamento por categoria

### 🎯 Metas
- Criação de objetivos com data limite
- Barras de progresso animadas
- Notificações de marco atingido

### ✅ Tarefas
- Listas com prioridade alta/média/baixa
- Filtros por data, estado e categoria
- Sincronização em tempo real (Firestore)

### 👥 Contactos
- Importação e gestão de contactos
- Pesquisa rápida
- Integração com Firebase Auth

---

## 📁 Estrutura do Projeto

```
loahapp/
├── lib/                  # Código fonte Flutter
│   ├── main.dart
│   ├── screens/
│   ├── widgets/
│   └── services/
├── web/                  # PWA (manifest, service worker)
├── android/ / ios/       # Configurações nativas
├── functions/            # Cloud Functions (Firebase)
├── assets/               # Imagens, fontes, logos
└── firebase.json         # Configuração Firebase
```

---

## 🏃 Como Executar

```bash
# Instalar dependências
flutter pub get

# Executar local (Android / iOS / Web)
flutter run

# Executar web com hot reload
flutter run -d chrome
```

---

## 🖼 Logo & Imagens

<p align="center">
  <img src="assets/images/logo.png" height="80" alt="Loah Logo" />
</p>

---

## 📄 Licença

MIT License — veja [LICENSE](LICENSE) para detalhes.

---

*Feito com ❤️ pela equipa Loah • 2026*
