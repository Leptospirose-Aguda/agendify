# 03 — Planejamento

## 1. Cronograma do Projeto

```mermaid
gantt
    title Cronograma — Agendify v1
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m

    section Fundação
    Estrutura base do projeto Flutter     :done,    s1, 2026-09-16, 1d
    Telas, tema e navegação               :done,    s2, after s1,   1d

    section MVP Funcional
    Providers e persistência local        :done,    m1, 2026-09-16, 1d
    CRUD de eventos e tarefas             :done,    m2, after m1,   1d

    section Backend Firebase
    Integração Firebase Auth              :done,    f1, 2026-09-16, 1d
    Integração Cloud Firestore            :done,    f2, after f1,   1d
    Correção index.html (importmap)       :done,    f3, 2026-09-23, 1d

    section Documentação
    README, LICENSE, .env.example         :done,    d1, 2026-09-23, 1d
    docs/ (visão, arquitetura, plano)     :done,    d2, after d1,   1d

    section Entrega e Testes
    Build Web e deploy Netlify            :active,  e1, 2026-09-23, 2d
    Testes em equipe (QA)                 :         e2, after e1,   3d
    Correções de bugs pós-QA              :         e3, after e2,   2d
    Geração APK Android                   :         e4, after e3,   1d
```

---

## 2. Estratégia de Branches

O projeto adota o modelo **GitHub Flow** (simplificado), adequado para equipes pequenas:

```mermaid
gitGraph
   commit id: "Initial commit"
   commit id: "feat: MVP V1"

   branch feature/firebase-integration
   checkout feature/firebase-integration
   commit id: "feat: firebase_options.dart"
   commit id: "feat: AuthProvider com Firebase Auth"
   commit id: "feat: EventService + TaskService no Firestore"
   commit id: "fix: importmap no index.html"

   checkout main
   merge feature/firebase-integration id: "merge: Firebase integrado"

   branch docs/estrutura-completa
   checkout docs/estrutura-completa
   commit id: "docs: README, LICENSE, .env.example"
   commit id: "docs: 01-visao-e-requisitos"
   commit id: "docs: 02-arquitetura"
   commit id: "docs: 03-planejamento"

   checkout main
   merge docs/estrutura-completa id: "merge: Documentação completa"

   branch release/netlify-v1
   checkout release/netlify-v1
   commit id: "build: flutter build web"
```

### Regras de Branch

| Branch             | Propósito                                                           |
|--------------------|---------------------------------------------------------------------|
| `main`             | Código estável, sempre deployável. Merge somente via Pull Request.  |
| `feature/<nome>`   | Nova funcionalidade. Ex: `feature/notificacoes-push`               |
| `fix/<nome>`       | Correção de bug. Ex: `fix/logo-quebrada-netlify`                   |
| `docs/<nome>`      | Atualização de documentação pura.                                  |
| `release/<versao>` | Preparação de release. Ex: `release/v1.0.0`                        |

---

## 3. Convenção de Mensagens de Commit

O projeto segue o padrão **Conventional Commits** ([spec](https://www.conventionalcommits.org)):

```
<tipo>(<escopo opcional>): <descrição curta em minúsculas>

[corpo opcional — explica o "por quê", não o "o quê"]

[rodapé opcional — ex: BREAKING CHANGE, Closes #123]
```

### Tipos Permitidos

| Tipo       | Quando usar                                                   |
|------------|---------------------------------------------------------------|
| `feat`     | Nova funcionalidade para o usuário                           |
| `fix`      | Correção de bug que afeta o usuário                          |
| `docs`     | Alteração exclusiva em documentação                          |
| `style`    | Formatação, espaços, ponto-e-vírgula (sem lógica)           |
| `refactor` | Refatoração de código sem mudar comportamento                |
| `test`     | Adição ou correção de testes                                 |
| `build`    | Mudanças no build system ou dependências (pubspec, gradle)   |
| `chore`    | Tarefas de manutenção que não afetam produção                |

### Exemplos Corretos

```
feat(auth): adicionar login com google via firebase
fix(calendar): corrigir exibição de eventos em dias com múltiplos fusos
docs(readme): atualizar passo-a-passo de como rodar do zero
build(pubspec): adicionar cloud_firestore 6.10.0
refactor(event_service): extrair lógica de cache para método privado
```

### Exemplos Incorretos ❌

```
update                          # sem tipo e sem descrição
fix bug                         # sem escopo e vago
feat: Added new feature         # capitalizado e em inglês desnecessário
```

---

## 4. Definition of Done (Critério de Conclusão)

Uma tarefa só está **concluída** quando **todos** os itens abaixo estão marcados:

- [ ] O código foi implementado e está funcional.
- [ ] `flutter analyze` retorna **0 erros e 0 warnings**.
- [ ] O comportamento foi testado manualmente (Web + Android quando aplicável).
- [ ] A documentação relevante em `docs/` foi atualizada no **mesmo commit**.
- [ ] O `CONTEXTO.md` foi atualizado se houve mudança de arquitetura, dependência ou comando.
- [ ] O commit segue a convenção **Conventional Commits**.
- [ ] O Pull Request foi revisado por pelo menos **1 membro da equipe** antes do merge em `main`.
