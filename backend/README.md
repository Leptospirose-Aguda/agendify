# Agendify Backend

API REST escrita em **Dart**, usando **Shelf** e **SQLite**. O banco é criado automaticamente em `data/agendify.db` na primeira execução.

## Executar

```bash
cd backend
dart pub get
dart run bin/server.dart
```

Servidor padrão: `http://localhost:8080`.

Teste rápido:

```text
GET http://localhost:8080/health
```

Resposta:

```json
{"status":"ok"}
```

## Rotas implementadas

| Método | Rota | Função |
|---|---|---|
| GET | `/api/events` | listar eventos |
| GET | `/api/events/:id` | consultar evento |
| POST | `/api/events` | criar evento |
| PUT | `/api/events/:id` | editar evento |
| DELETE | `/api/events/:id` | excluir evento |
| GET | `/api/tasks` | listar tarefas |
| GET | `/api/tasks/:id` | consultar tarefa |
| POST | `/api/tasks` | criar tarefa |
| PUT | `/api/tasks/:id` | editar tarefa |
| DELETE | `/api/tasks/:id` | excluir tarefa |

## Variáveis opcionais

- `PORT`: porta HTTP, padrão `8080`.
- `AGENDIFY_DB_PATH`: caminho do arquivo SQLite, padrão `data/agendify.db`.

## Próxima evolução

Quando autenticação e múltiplos usuários forem implementados, o schema receberá usuários e relacionamentos. Para produção em maior escala, a camada de repositório permite substituir SQLite por PostgreSQL sem alterar a interface Flutter.
