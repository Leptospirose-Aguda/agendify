# Agendify

Agenda eletrônica cross-platform em **Flutter + Dart**, preparada para Web, Android e iOS. A partir da versão 0.2, o projeto possui também um **backend REST em Dart** e persistência real em **SQLite**.

## Arquitetura atual

```text
Flutter (Web / Android / iOS)
        |
        | HTTP / JSON
        v
Dart + Shelf REST API
        |
        v
SQLite (backend/data/agendify.db)
```

## Estrutura

```text
agendify/
├── lib/                      # aplicativo Flutter
│   ├── core/
│   │   ├── config/           # endereço da API
│   │   ├── network/          # cliente HTTP e erros
│   │   ├── routes/
│   │   └── theme/
│   ├── features/
│   ├── models/
│   └── services/             # EventService / TaskService
├── backend/                  # API REST em Dart
│   ├── bin/server.dart
│   ├── lib/src/
│   │   ├── database/
│   │   └── repositories/
│   └── data/                 # banco criado em runtime
├── assets/
└── test/
```

## 1. Rodar o backend

É necessário ter o Dart SDK disponível (o Flutter já inclui Dart).

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Deixe esse terminal aberto. A API fica em:

```text
http://localhost:8080
```

## 2. Rodar o Flutter Web

Em outro terminal, na raiz:

```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api
```

## 3. Android Emulator

No emulador Android, `localhost` aponta para o próprio emulador. Use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api
```

## 4. Celular físico

Use o IP local do computador que executa o backend, por exemplo:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080/api
```

Celular e computador precisam estar na mesma rede, e a porta 8080 precisa estar liberada no firewall.

## Persistência implementada

- Eventos são salvos no SQLite.
- Tarefas são salvas no SQLite.
- CRUD de eventos disponível pela API.
- CRUD de tarefas disponível pela API.
- Flutter consome a API via HTTP.
- Dashboard, agenda, busca e tarefas deixam de depender dos dados mockados para os dados principais.
- CORS habilitado para desenvolvimento Web.

## Próximas etapas

1. Autenticação real e tabela de usuários.
2. Vincular eventos/tarefas ao usuário autenticado.
3. Categorias persistentes.
4. Recorrência completa.
5. Lembretes e notificações.
6. Sincronização Google/Apple Calendar.
7. Migração opcional para PostgreSQL em produção.
