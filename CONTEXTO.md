# CONTEXTO — agendify_flutter

## Objetivo
- Aplicativo de agendamento e tarefas em Flutter (Agendify) com suporte Web e Mobile, integrado com Firebase (Auth + Firestore).

## Como rodar
- Requisitos: Flutter SDK instalado.
- Comandos:
  - instalar: `flutter pub get`
  - dev: `flutter run -d chrome`
  - build: `flutter build web`
  - testes: `flutter test`

## Arquitetura (alto nível)
- Entrypoints: `lib/main.dart`, `lib/app.dart`
- Pastas principais: `lib/features/`, `lib/core/`, `lib/models/`, `lib/services/`, `assets/`
- Integrações externas: Firebase (Auth + Firestore), ID do projeto: `agendify-ae460`

## Decisões importantes
- Cores da marca aplicadas: `#185286` (Azul Escuro) e `#2CB5C4` (Ciano/Teal).
- Suporte a suporte Web (Chrome/Netlify) ativado.
- Dependências de nuvem adicionadas: `firebase_core`, `firebase_auth`, `cloud_firestore`.

## Checklist de qualidade
- [x] lint/format
- [x] testes
- [x] build web (`agendify_web_build.zip`)
- [x] revisão de mudanças


