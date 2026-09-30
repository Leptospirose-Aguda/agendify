# Agendify - Software de Agenda

> Aplicativo cross-platform de gestao de agenda, eventos e tarefas, desenvolvido em Flutter com Firebase como backend.

![Logo Agendify](assets/images/agendify_logo.png)

---

## Tecnologias Utilizadas

| Tecnologia          | Versao    | Funcao                          |
|---------------------|-----------|---------------------------------|
| Flutter             | >= 3.3.0  | Framework UI cross-platform     |
| Dart                | >= 3.3.0  | Linguagem de programacao        |
| firebase_core       | 4.15.0    | Inicializacao do Firebase       |
| firebase_auth       | 6.7.0     | Autenticacao de usuarios        |
| cloud_firestore     | 6.10.0    | Banco de dados em nuvem         |
| provider            | 6.1.2     | Gerenciamento de estado         |
| table_calendar      | 3.1.2     | Componente de calendario        |
| shared_preferences  | 2.2.3     | Cache local (fallback offline)  |
| intl                | 0.19.0    | Internacionalizacao e datas     |
| uuid                | 4.4.0     | Geracao de IDs unicos           |

---

## Como Rodar do Zero

### 1. Pre-requisitos

- Flutter SDK instalado e no PATH
- Git instalado
- Google Chrome instalado (para rodar na Web)
- Conta no Firebase Console (projeto agendify-ae460 ja criado)

`ash
flutter doctor
`

### 2. Clonar o Repositorio

`ash
git clone https://github.com/Leptospirose-Aguda/agendify.git
cd agendify
`

### 3. Instalar Dependencias

`ash
flutter pub get
`

### 4. Rodar no Navegador (Web)

`ash
flutter run -d chrome --web-port 8080
`

### 5. Deploy no Firebase Hosting

`ash
flutter build web --release
firebase deploy --only hosting --project agendify-ae460
`

App disponivel em: https://agendify-ae460.web.app

### 6. Gerar APK para Android

`ash
flutter build apk
`

---

## Estrutura do Projeto

`
agendify/
  lib/
    main.dart
    app.dart
    firebase_options.dart
    core/
      providers/
      routes/
      theme/
    features/
      auth/
      home/
      calendar/
      events/
      tasks/
      settings/
      search/
      profile/
    models/
    services/
  backend/
  assets/
  web/
  docs/
  firebase.json
  CONTEXTO.md
  pubspec.yaml
`

---

## Documentacao

| Documento | Descricao |
|-----------|-----------|
| docs/01-visao-e-requisitos.md | Requisitos funcionais e nao funcionais |
| docs/02-arquitetura.md | Arquitetura e diagramas |
| docs/03-planejamento.md | Cronograma e convencao de commits |
| CONTEXTO.md | Contexto tecnico vivo |

---

## Contribuindo

Fluxo de trabalho (GitHub Flow):

1. Crie uma branch: git checkout -b feature/nome
2. Faca commits: feat: descricao da mudanca
3. Abra um Pull Request no GitHub
4. Apos aprovacao, merge em main

---

Licenca: MIT
