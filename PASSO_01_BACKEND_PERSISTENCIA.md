# Passo 01 — Persistência e Backend

## Decisão técnica

Para manter o projeto totalmente no ecossistema escolhido, o backend inicial foi desenvolvido em **Dart**. A API usa **Shelf** e a persistência inicial usa **SQLite**.

Essa combinação reduz a configuração necessária durante o desenvolvimento: não é preciso instalar e manter um servidor PostgreSQL apenas para iniciar o projeto. O SQLite fica encapsulado atrás de repositórios, permitindo migrar para PostgreSQL posteriormente.

## Fluxo

```text
Tela Flutter
   -> Service
   -> ApiClient
   -> HTTP/JSON
   -> Shelf API
   -> Repository
   -> SQLite
```

## O que foi implementado

### Flutter
- `ApiConfig` com `--dart-define`.
- `ApiClient` HTTP.
- serialização JSON de `EventModel` e `TaskModel`.
- `EventService` conectado à API.
- `TaskService` conectado à API.
- criação, edição, consulta e exclusão de eventos.
- listagem e atualização de tarefas.
- telas principais buscando dados persistidos.

### Backend
- servidor HTTP Shelf.
- CORS para Flutter Web.
- criação automática do banco SQLite.
- tabela `events`.
- tabela `tasks`.
- índices básicos.
- CRUD REST de eventos.
- CRUD REST de tarefas.
- validação de dados.
- UUID para identificadores.
- health check.

## Limite intencional desta etapa

Autenticação ainda não foi implementada. Portanto, os registros ainda não possuem `user_id`. Isso será incluído junto com login real para evitar uma solução temporária de identificação de usuário.
