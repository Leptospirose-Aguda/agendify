# Agendify

Esqueleto inicial do projeto **Agendify**, uma agenda eletrônica cross-platform
desenvolvida com **Flutter + Dart**, preparada para Web, Android e iOS.

## Estrutura principal

```text
lib/
├── core/
│   ├── constants/
│   ├── routes/
│   ├── theme/
│   └── widgets/
├── data/
├── models/
├── services/
└── features/
    ├── auth/
    ├── calendar/
    ├── events/
    ├── home/
    ├── profile/
    ├── search/
    ├── settings/
    └── tasks/
```

## Funcionalidades já representadas no esqueleto

- Login
- Dashboard
- Agenda/calendário
- Criação de eventos
- Busca
- Lista de tarefas
- Configurações
- Perfil
- Modo claro/escuro preparado no tema
- Serviços preparados para:
  - autenticação;
  - eventos;
  - notificações;
  - sincronização com calendários externos.

## Como preparar o projeto

Como este pacote contém o código-fonte e a estrutura do aplicativo, gere as
pastas nativas do Flutter dentro da pasta do projeto:

```bash
flutter create . --platforms=android,ios,web
flutter pub get
flutter run
```

Para rodar no navegador:

```bash
flutter run -d chrome
```

## Próximas etapas sugeridas

1. Implementar persistência local ou backend.
2. Criar autenticação real.
3. Implementar CRUD de eventos.
4. Implementar recorrência.
5. Configurar notificações.
6. Integrar Google Calendar / Apple Calendar.
7. Implementar anexos.
8. Implementar compartilhamento de eventos.
9. Criar relatórios de produtividade.

O código contém comentários `TODO` indicando pontos preparados para implementação.
