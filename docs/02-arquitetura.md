# 02 — Arquitetura

## 1. Visão Geral

O Agendify segue a arquitetura **Feature-First** com gerenciamento de estado via **Provider** (padrão ChangeNotifier). A separação de responsabilidades é organizada em camadas:

| Camada          | Responsabilidade                                                      | Localização               |
|-----------------|-----------------------------------------------------------------------|---------------------------|
| **UI (Screens)**| Renderizar dados e capturar ações do usuário                          | `lib/features/*/screens/` |
| **State**       | Manter e notificar estado da aplicação (ChangeNotifier)              | `lib/core/providers/`     |
| **Services**    | Comunicar com Firestore e SharedPreferences (I/O)                     | `lib/services/`           |
| **Models**      | Estruturas de dados puras com `toJson`/`fromJson`                     | `lib/models/`             |
| **Core**        | Tema, rotas, cores e widgets reutilizáveis                            | `lib/core/`               |

### Paleta da Marca

| Token       | Hex       | Uso                            |
|-------------|-----------|--------------------------------|
| Primary     | `#185286` | AppBar, botões principais      |
| Secondary   | `#2CB5C4` | Destaques, ícones ativos       |
| Background  | `#121212` | Fundo geral (dark theme)       |
| Surface     | `#1E1E1E` | Cards e painéis                |

---

## 2. Fluxo de Navegação entre Telas

```mermaid
flowchart TD
    A([App Start]) --> B{Usuário\nautenticado?}
    B -- Não --> C[LoginScreen]
    B -- Sim --> D[HomeScreen]

    C -- Login / Cadastro --> D

    D --> E[DashboardScreen]
    D --> F[CalendarScreen]
    D --> G[TasksScreen]
    D --> H[SettingsScreen]

    E --> I[EventFormScreen\nnovo evento]
    F --> I
    F --> J[EventDetailsScreen]
    J --> I

    G --> K[TaskFormDialog\nnova tarefa]

    H --> L[Logout]
    L --> C
```

---

## 3. Diagrama de Sequência — Criação de Evento

Fluxo completo desde o clique do usuário até a confirmação de persistência no Firestore:

```mermaid
sequenceDiagram
    actor U as Usuário
    participant UI as EventFormScreen
    participant EP as EventProvider
    participant ES as EventService
    participant FS as Cloud Firestore
    participant SP as SharedPreferences

    U->>UI: Preenche formulário e clica "Salvar"
    UI->>EP: addEvent(EventModel)
    EP->>ES: createEvent(EventModel)

    ES->>FS: collection('events').doc(id).set(data)
    FS-->>ES: Confirmação (ou erro de rede)

    alt Firestore disponível
        ES-->>EP: Sucesso
    else Firestore indisponível
        ES->>SP: setString('events_v1', jsonEncoded)
        SP-->>ES: Gravado no cache local
        ES-->>EP: Sucesso (cache)
    end

    EP->>ES: getEvents() — recarrega lista
    ES->>FS: collection('events').get()
    FS-->>ES: Lista atualizada
    ES-->>EP: List<EventModel>
    EP-->>UI: notifyListeners()
    UI-->>U: Calendário atualizado com novo evento
```

---

## 4. Diagrama de Sequência — Login / Autenticação

```mermaid
sequenceDiagram
    actor U as Usuário
    participant UI as LoginScreen
    participant AP as AuthProvider
    participant FA as Firebase Auth
    participant FS as Cloud Firestore
    participant SP as SharedPreferences

    U->>UI: Informa e-mail e senha, clica "Entrar"
    UI->>AP: login(email, password)
    AP->>FA: signInWithEmailAndPassword(email, password)

    alt Usuário existe
        FA-->>AP: UserCredential
    else Usuário não existe
        AP->>FA: createUserWithEmailAndPassword(email, password)
        FA-->>AP: UserCredential (novo usuário)
    end

    AP->>FS: collection('users').doc(uid).set({uid, email, lastLogin})
    FS-->>AP: OK

    AP->>SP: setBool('isLoggedIn', true)
    AP-->>UI: notifyListeners() — isLoggedIn = true
    UI-->>U: Redireciona para DashboardScreen
```

---

## 5. Estrutura de Dados no Firestore

```
Firestore/
├── users/
│   └── {uid}/
│       ├── uid: String
│       ├── email: String
│       ├── username: String
│       └── lastLogin: Timestamp
│
├── events/
│   └── {eventId}/
│       ├── id: String (UUID)
│       ├── title: String
│       ├── start: String (ISO 8601)
│       ├── end: String (ISO 8601)
│       ├── description: String?
│       ├── location: String?
│       ├── category: String?
│       ├── notes: String?
│       └── isRecurring: Boolean
│
└── tasks/
    └── {taskId}/
        ├── id: String (UUID)
        ├── title: String
        ├── deadline: String? (ISO 8601)
        └── isCompleted: Boolean
```
