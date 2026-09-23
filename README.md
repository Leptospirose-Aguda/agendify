# Agendify — Software de Agenda

> Aplicativo cross-platform de gestão de agenda, eventos e tarefas, desenvolvido em Flutter com Firebase como backend.

![Tela de login Agendify](assets/images/agendify_logo.png)

---

## 🚀 Tecnologias Utilizadas

| Tecnologia          | Versão    | Função                          |
|---------------------|-----------|---------------------------------|
| Flutter             | ≥ 3.3.0   | Framework UI cross-platform     |
| Dart                | ≥ 3.3.0   | Linguagem de programação        |
| firebase_core       | 4.15.0    | Inicialização do Firebase       |
| firebase_auth       | 6.7.0     | Autenticação de usuários        |
| cloud_firestore     | 6.10.0    | Banco de dados em nuvem         |
| provider            | 6.1.2     | Gerenciamento de estado         |
| table_calendar      | 3.1.2     | Componente de calendário        |
| shared_preferences  | 2.2.3     | Cache local (fallback offline)  |
| intl                | 0.19.0    | Internacionalização e datas     |
| uuid                | 4.4.0     | Geração de IDs únicos           |

---

## ⚙️ Como Rodar do Zero

Siga os passos abaixo em ordem para executar o projeto em qualquer máquina:

### 1. Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e no `PATH`
- [Git](https://git-scm.com/) instalado
- [Google Chrome](https://www.google.com/chrome/) instalado (para rodar na Web)
- Conta no [Firebase Console](https://console.firebase.google.com/) (projeto `agendify-ae460` já criado)

Verifique se o Flutter está OK:
```bash
flutter doctor
```

### 2. Clonar o Repositório

```bash
git clone <URL_DO_REPOSITORIO>
cd agendify_flutter
```

### 3. Configurar Variáveis de Ambiente

Copie o arquivo de exemplo e preencha com as chaves reais do projeto Firebase:

```bash
cp .env.example .env
```

> ⚠️ **Nunca** commite o arquivo `.env` com chaves reais. Ele já está no `.gitignore`.

### 4. Instalar Dependências

```bash
flutter pub get
```

### 5. Rodar no Navegador (Web)

```bash
flutter run -d chrome --web-port 8080
```

### 6. Gerar Build de Produção (Netlify)

```bash
flutter build web
```
O output estará em `build/web/`. Arraste essa pasta (ou o `.zip` gerado) no [Netlify Drop](https://app.netlify.com/drop).

### 7. Gerar APK para Android

```bash
flutter build apk
```
O arquivo `.apk` estará em `build/app/outputs/flutter-apk/app-release.apk`.

---

## 📁 Estrutura do Projeto

```
agendify_flutter/
├── lib/
│   ├── main.dart                  # Entrypoint — inicializa Firebase e providers
│   ├── app.dart                   # MaterialApp e ThemeData
│   ├── firebase_options.dart      # Credenciais do Firebase por plataforma
│   ├── core/
│   │   ├── constants/             # Cores, strings e constantes globais
│   │   ├── providers/             # AuthProvider, EventProvider, TaskProvider
│   │   ├── routes/                # Definição de rotas nomeadas
│   │   ├── theme/                 # AppTheme (dark theme com cores da marca)
│   │   └── widgets/               # Widgets reutilizáveis
│   ├── features/
│   │   ├── auth/                  # Tela de login
│   │   ├── home/                  # Dashboard principal
│   │   ├── calendar/              # Calendário com table_calendar
│   │   ├── events/                # Formulário e detalhes de eventos
│   │   ├── tasks/                 # Lista e gestão de tarefas
│   │   ├── settings/              # Configurações do usuário
│   │   └── search/                # Busca global
│   ├── models/                    # EventModel, TaskModel, CategoryModel
│   └── services/                  # EventService, TaskService, AuthService (Firestore)
├── assets/
│   └── images/agendify_logo.png
├── web/
│   └── index.html                 # Inclui importmap do Firebase JS SDK
├── docs/
│   ├── 01-visao-e-requisitos.md
│   ├── 02-arquitetura.md
│   └── 03-planejamento.md
├── .env.example
├── .gitignore
├── CONTEXTO.md
└── pubspec.yaml
```

---

## 📋 Documentação

| Documento | Descrição |
|-----------|-----------|
| [docs/01-visao-e-requisitos.md](docs/01-visao-e-requisitos.md) | Problema, público-alvo, requisitos funcionais e não funcionais |
| [docs/02-arquitetura.md](docs/02-arquitetura.md) | Arquitetura, diagramas de navegação e sequência |
| [docs/03-planejamento.md](docs/03-planejamento.md) | Cronograma, estratégia de branches e convenção de commits |
| [CONTEXTO.md](CONTEXTO.md) | Contexto técnico vivo — decisões, comandos e checklist |

---

## 📜 Histórico de Commits

| Commit    | Data       | O que foi feito |
|-----------|------------|-----------------|
| `7877767` | 16/09/2026 | **Commit inicial:** Criação da estrutura base do projeto Flutter com todas as telas (login, dashboard, calendário, eventos, tarefas, configurações), modelos de dados, serviços stub, tema escuro com cores da marca (#185286 e #2CB5C4) e `CONTEXTO.md`. |
| `095ec82` | 16/09/2026 | **V1 MVP funcional:** Integração do `Provider` para gerenciamento de estado (AuthProvider, EventProvider, TaskProvider), persistência local com `SharedPreferences`, lógica real de criação/edição/exclusão de eventos e tarefas nas telas e adição das dependências `provider`, `shared_preferences`, `uuid`, `table_calendar` e `intl`. |

> **Commits pós-MVP** (não versionados ainda — pendente `git commit`):
> - Integração Firebase Auth + Cloud Firestore (auth_provider, event_service, task_service reescritos)
> - Criação de `firebase_options.dart` com credenciais da plataforma Web
> - Correção do `web/index.html` com `importmap` do Firebase JS SDK 11.x
> - Estrutura de documentação completa (`docs/`, `README.md`, `.env.example`, `LICENSE`)

---

## 🤝 Contribuindo

Consulte o [docs/03-planejamento.md](docs/03-planejamento.md) para a convenção de commits e estratégia de branches adotada no projeto.

---

*Licença: MIT — veja [LICENSE](LICENSE)*
