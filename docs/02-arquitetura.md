# 02 · Arquitetura

[← Visão e requisitos](01-visao-e-requisitos.md) · **Arquitetura** · [Planejamento →](03-planejamento.md)

Este documento responde a uma pergunta: **onde eu mexo para alterar isto?**

## 1. Visão geral em camadas

O projeto tem duas partes no mesmo repositório: o **aplicativo Flutter** (`lib/`) e a **API REST em Dart** (`backend/`). Cada camada só conversa com a vizinha: a tela nunca monta requisição HTTP, e a API nunca escreve SQL fora dos repositórios.

```mermaid
flowchart TD
    subgraph App ["App Flutter · lib/"]
        Telas["Telas e componentes<br/>features/*/screens, core/widgets"]
        Nav["Navegação<br/>core/routes/app_routes.dart"]
        Estado["Estado<br/>StatefulWidget + setState + FutureBuilder"]
        Servicos["Serviços<br/>services/event_service.dart, task_service.dart"]
        Rede["Cliente HTTP<br/>core/network/api_client.dart"]
        Modelos["Modelos<br/>models/*.dart (fromJson / toJson)"]
        Telas --> Nav
        Telas --> Estado
        Estado --> Servicos
        Servicos --> Rede
        Servicos -.-> Modelos
    end

    subgraph Backend ["Backend · backend/"]
        Api["Rotas REST<br/>lib/src/api.dart (Shelf Router)"]
        Repos["Repositórios<br/>lib/src/repositories/"]
        Banco[("SQLite<br/>data/agendify.db")]
        Api --> Repos
        Repos --> Banco
    end

    Rede ==>|"HTTP / JSON<br/>API_BASE_URL"| Api
```

| Camada | Onde fica | Responsabilidade |
|---|---|---|
| Telas e componentes | `lib/features/<funcionalidade>/screens/`, `lib/core/widgets/` | Desenhar a interface, validar formulário e mostrar erros. |
| Navegação | `lib/core/routes/app_routes.dart`, `lib/features/home/screens/home_screen.dart` | Rotas nomeadas (`/`, `/home`, `/events/form`, `/events/details`) e troca de abas da Home. |
| Estado | Dentro de cada tela (`State`) e em `lib/app.dart` | Guardar o `Future` da lista e recarregar com `setState`. O tema (claro/escuro) é o único estado global e fica em `AgendifyApp`. |
| Serviços | `lib/services/` | Traduzir operações da tela (`createEvent`, `getTasks`...) em chamadas à API e converter JSON em modelo. |
| Rede | `lib/core/network/`, `lib/core/config/api_config.dart` | Montar a URL, enviar JSON, transformar resposta de erro em `ApiException`. |
| Rotas REST | `backend/lib/src/api.dart`, `backend/bin/server.dart` | Receber a requisição, aplicar CORS e log, devolver o código HTTP certo. |
| Persistência | `backend/lib/src/repositories/`, `backend/lib/src/database/app_database.dart` | Validar dados, gerar UUID e executar SQL. Criar as tabelas na primeira execução. |

Não existe armazenamento local no aparelho: todo dado vem da API. Os serviços `AuthService`, `NotificationService` e `CalendarSyncService` e o arquivo `lib/data/mock_data.dart` existem, mas ainda não são usados por nenhuma tela.

### Onde eu mexo para...

| Quero... | Arquivo |
|---|---|
| Mudar o endereço da API | `.env` (`API_BASE_URL`), lido por `lib/core/config/api_config.dart` |
| Criar uma tela nova com rota própria | `lib/features/<nome>/screens/` e registrar em `lib/core/routes/app_routes.dart` |
| Criar uma aba nova | listas `pages` e `destinations` (e `NavigationRailDestination`) em `home_screen.dart` |
| Adicionar um campo ao evento | `lib/models/event_model.dart`, `event_form_screen.dart`, `backend/lib/src/repositories/event_repository.dart` e a tabela em `app_database.dart` |
| Criar um endpoint | `backend/lib/src/api.dart` + método no repositório |
| Mudar cores e tema | `lib/core/constants/app_colors.dart`, `lib/core/theme/app_theme.dart` |

## 2. Mapa de navegação

O app abre no login. O login substitui a tela (`pushReplacementNamed`), então Voltar não retorna a ele. A Home é um conjunto de seis abas que vivem na mesma tela; formulário e detalhes de evento são rotas empilhadas por cima. As telas de evento devolvem `true` ao fechar quando algo mudou, e quem abriu recarrega a lista.

```mermaid
flowchart LR
    Abrir(["Abrir app"]) --> Login

    subgraph Auth ["Autenticação · rota /"]
        Login["Login"]
        CriarConta["Criar conta<br/>(pendente)"]
        Login -.-> CriarConta
    end

    Login ==>|"Entrar"| Dash

    subgraph Abas ["HomeScreen · abas · rota /home"]
        Dash["Início"]
        Agenda["Agenda"]
        Tarefas["Tarefas"]
        Buscar["Buscar"]
        Config["Configurações"]
        Perfil["Perfil"]
        Dash --- Agenda --- Tarefas --- Buscar --- Config --- Perfil
    end

    subgraph Eventos ["Stack de eventos"]
        Form["Novo / Editar evento<br/>rota /events/form"]
        Detalhes["Detalhes do evento<br/>rota /events/details"]
        Detalhes -->|"editar"| Form
    end

    Dash -->|"Novo evento"| Form
    Agenda -->|"botão +"| Form
    Dash -->|"toque no evento"| Detalhes
    Agenda -->|"toque no evento"| Detalhes
    Form -.->|"salvou: volta e recarrega"| Dash
    Detalhes -.->|"excluiu: volta e recarrega"| Agenda
    Perfil -.->|"Sair (limpa a pilha)"| Login
```

Em telas com **900 px ou mais** de largura, as mesmas seis abas aparecem em um menu lateral (`NavigationRail`) em vez da barra inferior. Os resultados da aba Buscar ainda não abrem os detalhes do evento.

## 3. Diagramas de sequência

### 3.1 Criar um evento

Fluxo completo do RF03, da tela até o banco, com os três desfechos possíveis: validação local, erro do servidor (400) e servidor fora do ar.

```mermaid
sequenceDiagram
    actor U as Usuário
    participant F as EventFormScreen
    participant S as EventService
    participant C as ApiClient
    participant API as API Shelf
    participant R as EventRepository
    participant DB as SQLite

    U->>F: Preenche o formulário e toca em Salvar evento
    F->>F: Valida título e horário final depois do inicial
    alt Dados inválidos no app
        F-->>U: Mensagem no campo ou SnackBar
    else Dados válidos
        F->>S: createEvent(evento)
        S->>C: post /events com toJson()
        alt Servidor fora do ar
            C--xS: Falha de conexão (sem resposta)
            S--xF: Exceção de rede
            F-->>U: SnackBar - Não foi possível comunicar com o backend
        else Servidor no ar
            C->>+API: POST /api/events (JSON, datas em UTC)
            API->>R: create(dados)
            R->>R: Valida título, início e fim
            alt Dados válidos no servidor
                R->>+DB: INSERT INTO events com novo UUID
                DB-->>-R: ok
                R-->>API: Evento salvo
                API-->>C: 201 Created + JSON do evento
                C-->>S: Mapa JSON
                S-->>F: EventModel (datas em horário local)
                F-->>U: Fecha o formulário e a lista recarrega
            else Dados inválidos no servidor
                R-->>API: FormatException
                API-->>C: 400 Bad Request + campo error
                C-->>S: lança ApiException(mensagem, 400)
                S-->>F: ApiException
                F-->>U: SnackBar com a mensagem do servidor
            end
            deactivate API
        end
    end
```

### 3.2 Carregar a tela Início

A tela dispara as duas buscas ao mesmo tempo, e cada `FutureBuilder` mostra carregando, erro, lista vazia ou até cinco itens.

```mermaid
sequenceDiagram
    participant D as DashboardScreen
    participant ES as EventService
    participant TS as TaskService
    participant API as API Shelf
    participant DB as SQLite

    D->>ES: getEvents()
    D->>TS: getTasks()
    par Eventos
        ES->>API: GET /api/events
        API->>DB: SELECT eventos ordenados por start_at
        DB-->>API: Linhas
        API-->>ES: 200 OK + lista JSON
        loop Para cada item da lista
            ES->>ES: EventModel.fromJson (UTC para horário local)
        end
        ES-->>D: Lista de eventos
    and Tarefas
        TS->>API: GET /api/tasks
        API->>DB: SELECT tarefas (pendentes primeiro, depois prazo)
        DB-->>API: Linhas
        API-->>TS: 200 OK + lista JSON
        TS-->>D: Lista de tarefas
    end
    D->>D: FutureBuilder exibe até 5 eventos e 5 tarefas
    opt Usuário puxa a lista para baixo
        D->>D: setState(_reload) e repete as duas buscas
    end
```

## 4. Modelo de dados

Duas tabelas independentes, criadas por `AppDatabase._migrate()`. Datas são texto ISO 8601 em UTC; booleanos são `INTEGER` 0/1. Ainda não há coluna de usuário (entra com o RF13).

```mermaid
erDiagram
    EVENTS {
        TEXT id PK "UUID v4"
        TEXT title "obrigatório"
        TEXT description
        TEXT start_at "ISO 8601 UTC, indexado"
        TEXT end_at "posterior a start_at"
        TEXT location
        TEXT category
        TEXT notes
        INTEGER is_recurring "0 ou 1"
        TEXT created_at
        TEXT updated_at
    }
    TASKS {
        TEXT id PK "UUID v4"
        TEXT title "obrigatório"
        TEXT deadline "opcional, indexado"
        INTEGER is_completed "0 ou 1"
        TEXT created_at
        TEXT updated_at
    }
```

As rotas da API (`GET/POST /api/events`, `GET/PUT/DELETE /api/events/:id`, o mesmo para `/api/tasks`, e `GET /health`) estão detalhadas em [backend/README.md](../backend/README.md).

## 5. Papel das bibliotecas

| Biblioteca | Onde | Papel no projeto |
|---|---|---|
| Flutter (Material 3) | App | Toda a interface: `NavigationBar`/`NavigationRail` na Home, `CalendarDatePicker` na Agenda, `showDatePicker`/`showTimePicker` no formulário, `SnackBar` para erros, tema claro e escuro com `ColorScheme.fromSeed`. |
| `Navigator` (Flutter) | App | Navegação por rotas nomeadas em `AppRoutes.onGenerateRoute`, passando o `EventModel` como argumento e recebendo `true` de volta quando a lista precisa recarregar. |
| `http` | App | Único ponto de saída de rede, encapsulado em `ApiClient`. Recebe um `http.Client` opcional no construtor, o que permite trocar por um cliente falso nos testes. |
| `cupertino_icons` | App | Fonte de ícones do estilo iOS (dependência padrão do template). |
| `flutter_test` | App | Teste de widget em `test/widget_test.dart`, que confere se o app abre no login. |
| `flutter_lints` | App | Regras de análise estática; o projeto acrescenta `prefer_single_quotes`. |
| `shelf` | Backend | Servidor HTTP e o `Pipeline` com os middlewares de log (`logRequests`) e de CORS, necessário para o app rodando no navegador. |
| `shelf_router` | Backend | Associa método e caminho (`/api/events/<id>`) à função que atende a requisição. |
| `sqlite3` | Backend | Abre o arquivo do banco, cria tabelas e índices e executa SQL com parâmetros (`?`), o que evita injeção de SQL. Liga `foreign_keys` e o modo `WAL`. |
| `uuid` | Backend | Gera o `id` (UUID v4) de cada evento e tarefa no servidor. |
| `lints` / `test` | Backend | Análise estática e base para testes do backend (ainda sem testes escritos). |

Não há biblioteca de gerenciamento de estado (Provider, Riverpod, Bloc) nem de armazenamento local (`shared_preferences`, `sqflite`). Se o app ganhar modo offline ou tema salvo, é nessas duas categorias que as novas dependências vão entrar.
