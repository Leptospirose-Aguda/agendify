# 01 · Visão e requisitos

[← README](../README.md) · **Visão e requisitos** · [Arquitetura →](02-arquitetura.md)

## 1. Problema e público

**Problema.** Quem divide o tempo entre aula, trabalho e vida pessoal costuma espalhar compromissos e pendências entre o calendário do celular, anotações e mensagens. Fica difícil responder rapidamente "o que tenho hoje?" e "o que ainda falta fazer?".

**Solução.** O Agendify junta **eventos** (compromissos com data, horário de início e fim, local e categoria) e **tarefas** (itens a concluir, com prazo opcional) em um único app, com os dados salvos em um servidor próprio e acessíveis pelo celular ou pelo navegador.

**Público.** Estudantes universitários e profissionais que organizam a própria rotina e querem uma agenda simples, sem depender de contas de terceiros (Google, Apple).

## 2. Requisitos funcionais

Legenda de status: ✅ implementado · 🟡 parcial · ⏳ pendente.

| Código | Requisito | Status |
|---|---|---|
| RF01 | Entrar no aplicativo | 🟡 |
| RF02 | Ver o resumo da agenda | ✅ |
| RF03 | Criar evento | ✅ |
| RF04 | Ver detalhes de um evento | ✅ |
| RF05 | Editar evento | ✅ |
| RF06 | Excluir evento | ✅ |
| RF07 | Consultar a agenda por dia, semana ou mês | 🟡 |
| RF08 | Buscar eventos | ✅ |
| RF09 | Criar tarefa | ✅ |
| RF10 | Concluir e reabrir tarefa | ✅ |
| RF11 | Escolher o tema do app | ✅ |
| RF12 | Sair da conta | ✅ |
| RF13 | Cadastro e autenticação real | ⏳ |
| RF14 | Prazo e exclusão de tarefa pela interface | ⏳ |
| RF15 | Categorias com cor | ⏳ |
| RF16 | Lembretes de eventos | ⏳ |

### RF01 · Entrar no aplicativo 🟡
Como **usuário**, quero **entrar com e-mail e senha** para **acessar a minha agenda**.

- [x] O app abre na tela de login, com o título "Entre na sua conta".
- [x] Ao tocar em **Entrar**, o usuário vai para a tela Início e não consegue voltar ao login pelo botão Voltar.
- [ ] As credenciais são validadas no servidor; credencial inválida mostra mensagem de erro e mantém o usuário no login. *(Hoje o login é simulado: qualquer valor é aceito. Depende do RF13.)*

### RF02 · Ver o resumo da agenda ✅
Como **usuário**, quero **ver meus próximos compromissos e tarefas ao abrir o app** para **saber o que vem pela frente**.

- A tela Início mostra até **5 eventos** em ordem de data de início e até **5 tarefas**, com as pendentes antes das concluídas.
- Sem eventos ou tarefas, aparece "Nenhum evento cadastrado." / "Nenhuma tarefa cadastrada.".
- Arrastar a lista para baixo recarrega os dados do servidor.
- Com o servidor desligado, aparece a mensagem "Backend indisponível. Inicie o servidor em backend/.".

### RF03 · Criar evento ✅
Como **usuário**, quero **cadastrar um compromisso com data e horário** para **não esquecê-lo**.

- O formulário tem título, descrição, data, horário inicial, horário final, local, categoria, observações e a opção "Evento recorrente".
- Título vazio impede o envio e mostra "Informe o título do evento.".
- Horário final igual ou anterior ao inicial impede o envio e mostra "O horário final deve ser após o inicial.".
- Ao salvar, o servidor responde **201** e o app volta à tela anterior com a lista já atualizada.
- Se o servidor recusar os dados (**400**), a mensagem de erro dele aparece em um aviso na parte inferior da tela; sem conexão, aparece "Não foi possível comunicar com o backend.".

### RF04 · Ver detalhes de um evento ✅
Como **usuário**, quero **abrir um evento** para **ver horário, local, categoria e descrição**.

- Tocar em um evento no Início ou na Agenda abre a tela "Detalhes do evento".
- Campos vazios aparecem como "Não informado", "Não informada" ou "Sem descrição".

### RF05 · Editar evento ✅
Como **usuário**, quero **alterar um evento** para **corrigir dados ou remarcá-lo**.

- O ícone de lápis abre o formulário já preenchido, com o título "Editar evento".
- Ao salvar, a tela de detalhes mostra os dados novos, buscados de novo no servidor.

### RF06 · Excluir evento ✅
Como **usuário**, quero **remover um evento** que não vai mais acontecer.

- O ícone de lixeira pede confirmação ("Excluir evento?") antes de apagar.
- Confirmada a exclusão, o evento some das listas; cancelada, nada muda.
- A exclusão é definitiva (não há lixeira).

### RF07 · Consultar a agenda por dia, semana ou mês 🟡
Como **usuário**, quero **escolher um dia no calendário** para **ver só os compromissos daquele período**.

- [x] A tela Agenda tem o seletor Dia / Semana / Mês e um calendário mensal.
- [x] Abaixo do calendário aparece a lista de compromissos com a categoria de cada um.
- [ ] A lista mostra apenas os eventos do dia, da semana ou do mês selecionado. *(Hoje a lista mostra todos os eventos, e o seletor muda só o botão marcado.)*

### RF08 · Buscar eventos ✅
Como **usuário**, quero **procurar um compromisso por uma palavra** para **encontrá-lo sem rolar a agenda**.

- A busca considera título, descrição, local e categoria, sem diferenciar maiúsculas de minúsculas.
- O resultado é filtrado a cada letra digitada.

### RF09 · Criar tarefa ✅
Como **usuário**, quero **anotar algo que preciso fazer** para **acompanhar minhas pendências**.

- O botão **+** na tela Tarefas abre uma caixa com o campo Título.
- Título vazio não cria tarefa. Ao confirmar, a tarefa aparece na lista como pendente e "Sem prazo".

### RF10 · Concluir e reabrir tarefa ✅
Como **usuário**, quero **marcar uma tarefa como feita** para **saber o que ainda falta**.

- Marcar a caixa salva a alteração no servidor e mostra o título riscado.
- Desmarcar volta a tarefa para pendente.
- A lista mostra as pendentes primeiro, depois por prazo.

### RF11 · Escolher o tema do app ✅
Como **usuário**, quero **alternar entre modo claro, escuro ou seguir o sistema**.

- Em Configurações › Aparência, a escolha é aplicada na hora em todas as telas.
- A escolha vale até o app ser fechado (ainda não é salva no aparelho).

### RF12 · Sair da conta ✅
- Em Perfil, o botão **Sair** leva à tela de login e limpa a pilha de telas (Voltar não retorna ao app).

### RF13 · Cadastro e autenticação real ⏳
- O botão "Criar conta" abre um cadastro com e-mail e senha.
- O servidor guarda a senha apenas como hash e devolve um token de sessão.
- Cada evento e tarefa pertence a um usuário, e um usuário não vê os dados de outro.

### RF14 · Prazo e exclusão de tarefa pela interface ⏳
- Ao criar ou editar uma tarefa, é possível definir um prazo (data).
- É possível excluir uma tarefa com confirmação. *(A API já aceita prazo e exclusão; falta a interface.)*

### RF15 · Categorias com cor ⏳
- O usuário cria categorias com nome e cor em Configurações › Categorias e cores.
- No formulário de evento, a categoria é escolhida de uma lista, e a cor aparece na agenda.

### RF16 · Lembretes de eventos ⏳
- Ao criar um evento, o usuário escolhe um lembrete (por exemplo, 15 minutos antes).
- No horário, o aparelho mostra uma notificação local com o título do evento.

## 3. Fora do escopo

Nesta entrega o Agendify **não** faz:

- Sincronização com Google Calendar ou Apple Calendar (as telas e o `CalendarSyncService` existem apenas como marcação).
- Regras de recorrência (diária, semanal, até tal data). A opção "Evento recorrente" só registra um sim/não.
- Funcionamento sem internet e sincronização posterior.
- Compartilhar eventos, convidar pessoas ou agendas em grupo.
- Anexos, fotos ou arquivos em eventos e tarefas.
- Login social (Google, Apple, Facebook) e recuperação de senha.
- Publicação nas lojas (Play Store e App Store) e hospedagem do backend em nuvem.
- Migração do banco para PostgreSQL.

## 4. Requisitos não funcionais

### RNF01 · Plataformas e versões mínimas
- **Android:** mínimo técnico definido pelo template do Flutter 3.27 (`minSdkVersion` 21, Android 5.0). Alvo de teste da equipe: **Android 8+**.
- **iOS:** mínimo técnico iOS 12 (Flutter 3.27). Alvo de teste: **iOS 15+**. Compilar para iOS exige macOS com Xcode.
- **Web:** versões atuais de Chrome, Edge, Firefox e Safari.
- **Orientação:** retrato e paisagem. Com largura de **900 px ou mais** (tablet, navegador), a barra inferior vira um menu lateral (`NavigationRail`), expandido a partir de 1180 px.
- **Ambiente de desenvolvimento:** Flutter **3.27+** e Dart **3.3+**.

### RNF02 · Funcionamento offline
- O app **depende do backend** para ler e gravar qualquer evento ou tarefa; não há cópia local dos dados.
- Sem conexão, cada tela mostra uma mensagem de indisponibilidade no lugar da lista, e a Agenda e a tela Tarefas oferecem o botão **Tentar novamente**.
- Continuam funcionando sem rede: navegação entre telas, troca de tema e o formulário (que só falha ao salvar, com aviso).
- **Ponto de atenção:** criar ou marcar tarefa sem conexão hoje gera uma exceção não tratada (a tela não mostra aviso). Tratar com `try/catch` e `SnackBar`, como já é feito no formulário de evento.

### RNF03 · Permissões do dispositivo

| Permissão | Plataforma | Quando | Motivo |
|---|---|---|---|
| `INTERNET` | Android | Hoje | Comunicar com a API REST. Vem só nos manifests de *debug* e *profile* gerados pelo `flutter create`; para gerar APK de *release*, adicionar em `android/app/src/main/AndroidManifest.xml`. |
| Notificações (`POST_NOTIFICATIONS` no Android 13+; autorização no iOS) | Android / iOS | RF16 | Exibir lembretes de eventos. Pedir só quando o usuário ativar o primeiro lembrete. |
| Calendário | Android / iOS | Fora do escopo | Só seria necessária para sincronizar com a agenda do sistema. |

O app **não** usa câmera, localização, microfone nem contatos. O campo "Local" do evento é texto digitado, não GPS.

### RNF04 · Acessibilidade
- **Toque:** botões e itens de lista usam componentes Material 3, com área de toque mínima de **48 × 48 dp**.
- **Contraste:** cores geradas por `ColorScheme.fromSeed` (Material 3) nos temas claro e escuro, que seguem contraste mínimo de **4,5:1** para texto; o modo escuro atende quem tem sensibilidade à luz.
- **Tamanho de fonte:** o app respeita o tamanho de texto configurado no sistema; as telas usam listas roláveis para não cortar conteúdo com fonte grande.
- **Leitor de tela (TalkBack / VoiceOver):** campos têm rótulo (`labelText`) e a barra de navegação tem nome em cada aba. **Pendência:** os botões de editar e excluir em "Detalhes do evento" e o botão **+** das telas Agenda e Tarefas não têm `tooltip`, então o leitor anuncia só "botão". Adicionar `tooltip: 'Editar evento'`, `'Excluir evento'`, `'Novo evento'` e `'Nova tarefa'`.

### RNF05 · Privacidade e LGPD
- **Dados guardados:** título, descrição, local, categoria e observações dos eventos; título, prazo e situação das tarefas; datas de criação e alteração. Esses campos são texto livre e podem conter dados pessoais (nomes, endereços, informações de saúde em uma consulta médica, por exemplo).
- **E-mail e senha** digitados no login **não são enviados nem guardados** na versão atual.
- **Onde:** em um único arquivo SQLite (`backend/data/agendify.db`) na máquina que roda o servidor, sem criptografia. O arquivo está no `.gitignore` e não vai para o repositório. O app não guarda nada no aparelho.
- **Por quanto tempo:** até o usuário excluir. A exclusão de evento remove o registro de forma definitiva. Não há expiração automática.
- **Riscos atuais:** sem autenticação, a API responde a qualquer pessoa que alcance a porta 8080 na mesma rede, e o CORS está aberto (`*`). A comunicação é HTTP sem TLS. Por isso o backend deve rodar só em rede confiável e **com dados de teste** até o RF13.
- **Antes de uso real:** autenticação e vínculo dos dados ao usuário (RF13), HTTPS, senha com hash, opção de exportar e apagar todos os dados da conta (direitos de acesso e eliminação da LGPD) e um aviso de privacidade explicando a finalidade do tratamento.
