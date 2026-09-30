# 01 — Visão e Requisitos

[← README](../README.md) · **Visão e requisitos** · [Arquitetura →](02-arquitetura.md)

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
| RF12 | O app deve continuar utilizável sem conexão                               | Sem internet, o app não trava: os dados já carregados continuam visíveis e as alterações feitas são enviadas quando a conexão volta (cache offline do Firestore). |

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

- **Orientação de tela:** retrato e paisagem. Em telas com 900 px ou mais de largura (tablet, navegador), a barra de abas inferior é substituída por um menu lateral.
- **Ambiente de desenvolvimento:** Flutter 3.27 ou superior.

### 4.2 Performance

- O tempo de carregamento inicial (Web) deve ser inferior a **4 segundos** em conexão 3G.
- Operações de CRUD (criar/editar/excluir) devem completar em menos de **2 segundos** com Firebase.

### 4.3 Acessibilidade

- Todos os elementos interativos devem ter `semanticsLabel` para leitores de tela.
- Contraste mínimo de 4.5:1 entre texto e fundo (WCAG 2.1 AA), nos temas claro e escuro.
- Área de toque mínima de **48 × 48 dp** em botões e itens de lista (padrão dos componentes Material 3).
- Botões só com ícone (editar, excluir, adicionar, sair) devem ter `tooltip`, que também é lido pelo leitor de tela (TalkBack / VoiceOver).
- O app deve respeitar o tamanho de fonte configurado no sistema, sem cortar texto.

### 4.4 Privacidade e LGPD

**Quais dados pessoais são guardados**

| Dado | Origem | Onde fica |
|---|---|---|
| E-mail e senha | Cadastro | Firebase Authentication. A senha é guardada pelo Google só como hash; o app nunca a armazena. |
| E-mail, nome de exibição e data de atualização | Perfil | Cloud Firestore, em `users/{uid}` |
| Eventos (título, datas, local, categoria, descrição, observações) | Usuário | Cloud Firestore, em `users/{uid}/events` |
| Tarefas e categorias | Usuário | Cloud Firestore, em `users/{uid}/tasks` e `users/{uid}/categories` |
| Indicador de sessão, nome e e-mail | Login | No próprio dispositivo (SharedPreferences), para manter a sessão |

Descrição e observações de eventos são texto livre e podem conter dados sensíveis (por exemplo, uma consulta médica).

**Onde:** servidores do Google (Firebase), projeto `agendify-ae460`. Nenhum dado é compartilhado com terceiros além do Firebase. Os dados de cada usuário ficam organizados sob o seu `uid`, e as regras de segurança do Firestore devem garantir que cada usuário leia e escreva só os próprios dados.

**Por quanto tempo:** enquanto a conta existir. Eventos, tarefas e categorias apagados pelo usuário são removidos do Firestore na hora. Os dados locais de sessão são apagados no logout.

**Direitos do titular (LGPD):** o usuário pode corrigir o nome no Perfil e apagar eventos e tarefas. A exclusão completa da conta e dos dados, e a exportação dos dados, ainda não estão disponíveis no app e estão previstas para uma versão futura.

**Segredos:** o arquivo `.env` nunca é versionado (está no `.gitignore`). A `apiKey` presente em `lib/firebase_options.dart` é um identificador público do projeto web, e não um segredo: o acesso aos dados é controlado pelas regras de segurança do Firestore.

### 4.5 Permissões do Dispositivo

| Permissão | Plataforma | Motivo |
|---|---|---|
| Internet | Android, iOS, Web, Windows | Comunicação com o Firebase Auth e o Cloud Firestore. É a única permissão usada. |
| Câmera | — | Não utilizada. |
| Localização | — | Não utilizada. O campo "local" do evento é texto digitado. |
| Notificações | — | Não utilizada na v1 (notificações push estão fora do escopo). Se forem implementadas, o pedido será feito só quando o usuário ativar o primeiro lembrete. |

### 4.6 Conectividade

- Sem conexão, o app deve exibir os dados já carregados, usando o cache offline do Firestore (ativo por padrão no Android e no iOS; na Web, precisa ser habilitado).
- Login e cadastro exigem conexão; sem internet, o app mostra "Sem conexão com internet."
- Operações de escrita realizadas offline devem ser enfileiradas e sincronizadas automaticamente quando a conexão for restaurada (comportamento nativo do Firestore SDK).
