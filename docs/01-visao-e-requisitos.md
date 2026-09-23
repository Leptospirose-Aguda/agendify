# 01 — Visão e Requisitos

## 1. O Problema e o Público-Alvo

**Problema:** Pequenas equipes e profissionais autônomos perdem produtividade ao gerir compromissos, tarefas e eventos em ferramentas separadas (papel, planilha, apps desconectados). Não existe uma solução simples, unificada e acessível por diferentes dispositivos.

**Público-alvo:** Equipes pequenas (2–15 pessoas), estudantes e profissionais que precisam de uma agenda compartilhada, acessível via navegador Web e celular, sem custo inicial.

---

## 2. Requisitos Funcionais

| ID   | Requisito                                                                 | Critério de Aceitação                                                                                       |
|------|---------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|
| RF01 | O usuário deve conseguir criar uma conta com e-mail e senha               | Ao submeter e-mail e senha válidos pela primeira vez, uma conta é criada no Firebase Auth e o usuário é redirecionado ao dashboard. |
| RF02 | O usuário deve conseguir fazer login com e-mail e senha existentes        | Credenciais corretas redirecionam ao dashboard; credenciais incorretas exibem mensagem de erro.              |
| RF03 | O usuário deve conseguir criar um novo evento com título, data e horário  | O evento aparece no calendário e no dashboard no dia correspondente após ser salvo.                         |
| RF04 | O usuário deve conseguir editar um evento existente                       | As alterações são refletidas imediatamente no calendário e persistem após reiniciar o app.                  |
| RF05 | O usuário deve conseguir excluir um evento                                | O evento desaparece do calendário e do Firestore após confirmação.                                          |
| RF06 | O usuário deve conseguir criar tarefas com título e prazo opcional        | A tarefa aparece na lista de "Pendentes" após ser criada.                                                   |
| RF07 | O usuário deve conseguir marcar uma tarefa como concluída                 | A tarefa move-se da lista "Pendentes" para "Concluídas" com feedback visual.                                |
| RF08 | O usuário deve conseguir excluir uma tarefa                               | A tarefa é removida da lista e do Firestore.                                                                |
| RF09 | O dashboard deve exibir um resumo de eventos do dia e tarefas pendentes  | Ao acessar o dashboard, eventos de hoje e tarefas pendentes aparecem sem ação adicional.                    |
| RF10 | O usuário deve conseguir visualizar eventos em um calendário mensal       | A tela de calendário exibe os dias com eventos marcados e permite navegar entre meses.                      |
| RF11 | Os dados devem ser sincronizados na nuvem via Firebase                    | Um evento criado por um usuário em um dispositivo aparece em outro dispositivo após recarregar o app.       |
| RF12 | O app deve funcionar com fallback offline via cache local                 | Se o Firestore estiver indisponível, o app exibe os dados em cache local sem travar.                        |

---

## 3. O Que Está Fora do Escopo (v1)

- Notificações push (push notifications).
- Sincronização com Google Calendar ou Apple Calendar.
- Compartilhamento de eventos entre múltiplos usuários distintos.
- Upload de arquivos ou imagens em eventos.
- Suporte a múltiplos fusos horários.
- Plano pago / monetização.

---

## 4. Requisitos Não Funcionais

### 4.1 Plataformas e Versões Mínimas

| Plataforma | Versão Mínima      | Observação                          |
|------------|--------------------|-------------------------------------|
| Web        | Chrome 89+         | Necessário suporte a `importmap`     |
| Android    | API 21 (Android 5) | Definição padrão do Flutter         |
| iOS        | iOS 12.0           | Requer Xcode em Mac para compilar   |
| Windows    | Windows 10 (64-bit)| Flutter Desktop                     |

### 4.2 Performance

- O tempo de carregamento inicial (Web) deve ser inferior a **4 segundos** em conexão 3G.
- Operações de CRUD (criar/editar/excluir) devem completar em menos de **2 segundos** com Firebase.

### 4.3 Acessibilidade

- Todos os elementos interativos devem ter `semanticsLabel` para leitores de tela.
- Contraste mínimo de 4.5:1 entre texto e fundo (WCAG 2.1 AA).

### 4.4 Privacidade

- Nenhum dado de usuário é compartilhado com terceiros além do Firebase (Google).
- A senha do usuário nunca é armazenada localmente — somente o token de sessão gerenciado pelo Firebase Auth.
- O arquivo `.env` com chaves de API nunca é versionado no repositório.

### 4.5 Conectividade

- O app deve exibir os dados do último cache local quando estiver sem conexão.
- Operações de escrita realizadas offline devem ser enfileiradas e sincronizadas automaticamente quando a conexão for restaurada (comportamento nativo do Firestore SDK).
