# CLAUDE.md — gestao_cana_app
# Sistema de Gestão de Cana-de-açúcar · AFCRC Catanduva

> Lido automaticamente pelo Claude Code (VS Code) a cada sessão.
> Contexto completo do projeto para execução autônoma e consistente.

---

## 🌐 Idioma e Comportamento

- **SEMPRE responder em Português do Brasil (PT-BR)** — sem exceções
- Explicar o que está fazendo antes de executar
- Após cada tarefa, resumir o que foi feito em português
- Se houver dúvida sobre o que foi pedido, perguntar em português antes de agir
- Usar termos técnicos em inglês apenas quando não houver tradução adequada (ex: widget, service, model)

---

## ⚡ Comandos Rápidos (Atalhos)

Use estes comandos curtos — o Claude já sabe o que fazer:

| Comando | O que faz |
|---|---|
| `/analisar` | Roda flutter analyze e corrige todos os erros automaticamente |
| `/limpar` | Remove arquivos desnecessários da raiz (errors.txt, update_screen.py, etc.) |
| `/pendencias` | Lista e resolve as pendências do CLAUDE.md |
| `/testar` | Roda flutter test e reporta os resultados |
| `/status` | Mostra o que está modificado no projeto (git status resumido) |
| `/dashboard` | Corrige o dashboard para mostrar apenas dados reais do Supabase, sem valores fictícios ou hardcoded |
| `/pdf-relatorios` | Implementa botões Gerar PDF e Salvar nas telas de Produtividade, Precipitação, Operações de Cultivo, Custo Operacional e Tratos Culturais, seguindo o padrão do relatório de pragas | E uma Aba dentro de Anexo com nome de Relatorio Gestão 360 para gerar o relatorios Produtividade, Precipitação, Operações de Cultivo, Custo Operacional e Tratos Culturais todas em um só pdf puchando por propriedade e talhao
| `/redesign` | Executa o redesign visual completo do app baseado nas telas aprovadas do Stitch — aplica novo Design System, AppShell com sidebar, paleta de cores e tipografia em todas as 11 telas |
| `/implementar-fluxo` | Implementa a arquitetura de contexto de propriedade: cria ContextoPropriedade, HeaderPropriedade, PropriedadeHubScreen e geradores PDF para todas as telas operacionais |

---

## 🌾 Contexto do Projeto

- **App:** Sistema de gestão agrícola para fornecedores de cana-de-açúcar
- **Organização:** AFCRC — Catanduva/SP
- **Stack:** Flutter Web + Supabase (PostgreSQL + Auth + Storage)
- **Plataforma alvo:** Web (browser desktop — Chrome/Edge)
- **Estado:** `StatefulWidget` + `setState` — sem gerenciador externo
- **Autenticação:** Supabase Auth via `AuthService`
- **PDF:** pacotes `pdf` + `printing` para relatórios agrícolas

---

## 📁 Estrutura Real do Projeto

```
lib/
├── config/
│   ├── database_config.dart         # Credenciais Supabase (NÃO commitar — .gitignore)
│   └── database_config.example.dart # Template público (commitar)
├── constants/
│   └── app_colors.dart
├── models/
│   ├── models.dart                  # Barrel export — atualizar ao criar model novo
│   ├── proprietario.dart
│   ├── propriedade.dart
│   ├── talhao.dart
│   ├── variedade.dart
│   ├── produtividade.dart
│   ├── precipitacao.dart
│   ├── operacao_cultivo.dart
│   ├── operacao_custos.dart
│   ├── tratos_culturais.dart
│   └── anexo.dart
├── screens/                         # Uma screen por funcionalidade
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── dashboard_screen.dart
│   ├── gestao_agricola_dashboard_screen.dart
│   ├── proprietarios_screen.dart / proprietario_form_screen.dart / proprietario_detail_screen.dart
│   ├── propriedades_screen.dart / propriedade_form_screen.dart / propriedade_detalhes_screen.dart
│   ├── talhoes_screen.dart / talhao_form_screen.dart
│   ├── produtividade_screen.dart / produtividade_form_screen.dart
│   ├── precipitacao_screen.dart / precipitacao_por_municipios_screen.dart
│   ├── operacoes_cultivo_screen.dart / operacao_form_screen.dart / operacoes_detalhes_screen.dart
│   ├── custo_operacional_screen.dart / custo_operacional_form_screen.dart
│   ├── custo_operacional_lancamentos_screen.dart / custo_operacional_lancamento_screen.dart
│   ├── historico_custo_operacional_screen.dart
│   ├── tratos_culturais_screen.dart / tratos_culturais_form_screen.dart
│   ├── anexos_screen.dart / anexo_upload_screen.dart
│   ├── graficos_comparativo_screen.dart
│   ├── matriz_sensibilidade_screen.dart
│   ├── projecao_financeira_screen.dart
│   └── formularios_pdf_screen.dart
├── services/
│   ├── auth_service.dart
│   ├── proprietario_service.dart
│   ├── propriedade_service.dart
│   ├── talhao_service.dart
│   ├── variedade_service.dart
│   ├── produtividade_service.dart
│   ├── precipitacao_service.dart
│   ├── precipitacao_agregada_service.dart
│   ├── operacao_cultivo_service.dart
│   ├── custo_operacional_service.dart
│   ├── custo_operacional_repository.dart
│   ├── custo_operacional_analise.dart
│   ├── dados_custo_operacional.dart
│   ├── anexo_service.dart
│   ├── exportacao_pdf_service.dart
│   └── pdf_generators/
│       ├── pdf_broca_cigarrinha.dart
│       ├── pdf_broca_infestacao.dart
│       └── pdf_sphenophorus.dart
├── sql/
│   └── custo_operacional_supabase.pgsql   # Migrations SQL versionadas aqui
├── utils/
│   ├── formatters.dart
│   ├── validators.dart
│   ├── file_utils.dart
│   └── municipios_sp.dart               # Lista de municípios SP para precipitação
├── widgets/
│   ├── empresa_header.dart
│   ├── operacao_card.dart
│   ├── produtividade_card.dart
│   ├── propriedade_card.dart
│   └── variedade_dropdown_widget.dart
└── main.dart
```

---

## ⚙️ Regras de Código

### Arquitetura do projeto
- Padrão: **Screen → Service → Supabase** (direto, sem camada extra)
- Estado: `StatefulWidget` + `setState` — manter este padrão
- Não adicionar Riverpod, Provider ou Bloc sem alinhamento prévio
- Cada entidade tem: `model` + `service` + `screen(s)`

### Nomenclatura
- Arquivos: `snake_case` | Classes: `PascalCase`
- Services: `[Entidade]Service` → métodos: `buscar[Entidades]()`, `salvar[Entidade]()`, `deletar[Entidade]()`
- Sempre retornar `List<Model>` ou `Model` nos services — nunca `Map` cru
- Screens de formulário: `_form_screen.dart` | Listagens: `_screen.dart` | Detalhes: `_detalhes_screen.dart`

### Dart
- Null safety obrigatório — sem `!` sem verificação prévia
- `const` sempre que possível, `final` por padrão
- Imports: dart → flutter → packages externos → arquivos locais

### Campos numéricos (TextFormField / TextField)
- Campos que aceitam valores decimais (R$/ha, t/ha, kg/t, %, etc.) DEVEM usar `TextInputType.numberWithOptions(decimal: true)` — **nunca** `TextInputType.number` sozinho
- `TextInputType.number` (sem decimal) SOMENTE para campos inteiros puros: ano da safra, longevidade (safras), CPF/CNPJ, telefone
- `FilteringTextInputFormatter.digitsOnly` SOMENTE para campos inteiros puros — nunca em campos que aceitam decimal
- Para campos decimais com filtro, usar `FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))`
- Exemplos de campos que DEVEM ter decimal: Produtividade, ATR, Dose de Muda, Preço do Diesel, Custo Administrativo, Arrendamento, Área (ha), profundidade (cm)

### Seleção e cópia de texto
- `SelectionArea` está implementado no `AppShell` — envolve o conteúdo de TODAS as telas automaticamente
- NUNCA usar `enableInteractiveSelection: false` em campos de texto
- NUNCA remover o `SelectionArea` do `AppShell`
- Toda nova tela que usar `AppShell` já herda a seleção de texto — não precisa de configuração extra
- Se criar uma tela SEM `AppShell`, envolver o conteúdo em `SelectionArea` manualmente

---

## 🔐 Supabase — Regras Obrigatórias

### Credenciais
- `lib/config/database_config.dart` está no `.gitignore` — **NUNCA commitar**
- Sempre usar `database_config.example.dart` como referência para novos devs

### Queries
- Sempre `.select('col1, col2')` — **nunca** `.select('*')`
- Paginação com `.range(from, to)` em listagens grandes
- Fechar streams e subscriptions no `dispose()`

### RLS (Row Level Security)
- Toda tabela nova deve ter RLS ativa
- Policy mínima: usuário autenticado acessa apenas seus próprios dados

### Migrations
- SQL fica em `lib/sql/` — nomear: `[numero]_[descricao].pgsql`
- Ex: `002_tabela_pragas.pgsql`
- **Nunca** alterar tabelas direto no Dashboard em produção
- **SQL SEMPRE seguro e idempotente** — toda migration DEVE poder ser executada mais de uma vez sem erro:
  - `ADD COLUMN IF NOT EXISTS` — nunca `ADD COLUMN` direto
  - `DROP COLUMN IF EXISTS` — nunca `DROP COLUMN` direto
  - `DROP POLICY IF EXISTS` antes de `CREATE POLICY`
  - `INSERT ... ON CONFLICT DO UPDATE` — nunca `DELETE + INSERT` para seed data
  - Verificar existência de colunas via `information_schema.columns` antes de referenciar colunas que podem não existir (ex: migração de dados entre colunas)
  - Criar constraints (`UNIQUE`, `FK`) dentro de `DO $$ ... IF NOT EXISTS ... $$` para evitar erro de duplicata
  - Comentar no topo do arquivo: `-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.`

### Storage (Anexos)
- Usar sempre `AnexoService` para uploads
- Gerar URLs assinadas — nunca expor bucket público
- Tipos aceitos: PDF, JPG, PNG, WORD, EXCEL, TXT

---

## 📊 Domínio Agrícola — Relacionamentos

```
Proprietario
  └── Propriedade (1:N)
        └── Talhao (1:N)
              ├── Produtividade (1:N)
              ├── OperacaoCultivo (1:N)
              │     └── TratoCultural (1:N)
              └── Precipitacao (via municipio)

CustoOperacional
  ├── OperacaoCustos (lançamentos)
  └── Analises / Projeções / MatrizSensibilidade

Anexo      → vinculado a qualquer entidade
Variedade  → tabela de referência (variedades de cana)
Municipio  → lista em utils/municipios_sp.dart
```

---

## 📄 PDF e Relatórios

- Base: `ExportacaoPdfService`
- Relatórios de pragas em `services/pdf_generators/`:
  - `pdf_broca_cigarrinha.dart`
  - `pdf_broca_infestacao.dart`
  - `pdf_sphenophorus.dart`
- Novos relatórios: criar em `services/pdf_generators/` seguindo padrão existente
- Preview/impressão no browser: usar `Printing.layoutPdf()`

---

## 🌐 Flutter Web — Atenção

- Target: browser desktop — responsividade mobile é secundária
- Evitar widgets exclusivos mobile (`CupertinoActionSheet`, etc.)
- `file_picker` no web: usar `.bytes` do `FilePickerResult`
- `path_provider`: limitado no web — evitar; usar `printing` para downloads PDF
- Downloads de PDF: `Printing.layoutPdf()` funciona no browser

---

## 🚫 Nunca fazer

- Commitar `database_config.dart` com credenciais
- Usar `.select('*')` em qualquer query
- Criar service sem o model correspondente
- Colocar lógica de negócio dentro das screens — pertence ao service
- Usar `dynamic` como tipo de retorno
- Alterar schema do banco direto no Dashboard em produção

---

## ✅ Checklist antes de qualquer alteração

- [ ] `flutter analyze` sem erros
- [ ] Credenciais fora do código
- [ ] RLS ativa em tabelas novas
- [ ] Migration SQL salva em `lib/sql/`
- [ ] Novos PDFs em `services/pdf_generators/`
- [ ] Novo model exportado em `models/models.dart`

---

## 🔄 Sincronização Obrigatória — Supabase + GitHub

### Regras de sincronização (SEMPRE cumprir)

1. **Supabase e código SEMPRE andam juntos** — toda alteração no banco (tabelas, colunas, RLS, functions) DEVE ter a migration SQL correspondente em `lib/sql/`
2. **GitHub é a fonte da verdade** — todo código e migration SQL DEVE estar commitado no repositório
3. **Após cada tarefa concluída:**
   - Rodar `flutter analyze` — corrigir se houver erros
   - Criar migration SQL se houve alteração no banco
   - Fazer `git add` + `git commit` com mensagem descritiva em português
   - Fazer `git push` para manter o repositório remoto atualizado
4. **NUNCA alterar o banco Supabase sem:**
   - Criar o arquivo `.pgsql` correspondente em `lib/sql/`
   - Commitar e pushar a migration
5. **NUNCA fazer mudanças no código sem commitar** — cada funcionalidade ou correção é um commit separado
6. **Ordem obrigatória após qualquer alteração:**
   ```
   flutter clean → flutter pub get → flutter analyze → corrigir erros → verificar Supabase (migration SQL se necessário) → git add . → git commit -m "descrição" → git push
   ```

### Fórmulas de Custo Operacional — Referência Oficial

Estas são as fórmulas corretas do sistema. NUNCA alterar sem validação:

```
Custo Anualizado R$/ha = (Formação ÷ Longevidade) + Manutenção + Colheita + Admin + Arrendamento
Custo R$/t = Custo Anualizado R$/ha ÷ Produtividade (t/ha)
Preço Recebido R$/t = ATR × Preço ATR
Margem R$/t = Preço Recebido R$/t − Custo R$/t
Margem % = (Margem R$/t ÷ Preço Recebido R$/t) × 100

Exemplo AFCRC 2026:
  Formação = Conservação + Preparo + Plantio ≈ R$ 9.005/ha
  Longevidade = 5 cortes
  Formação amortizada = 9.005 / 5 = R$ 1.801/ha
  Custo anualizado = 1.801 + 5.418 + 2.858 + 1.224 + 750 = R$ 12.051/ha
  R$/t = 12.051 / 84,6 = R$ 142,45/t
  Preço recebido = 138 × 1,1945 = R$ 164,84/t
  Margem = 164,84 − 142,45 = R$ 22,39/t
  Margem % = 22,39 / 164,84 × 100 = 13,6%
```

IMPORTANTE: `totalOperacional.rHa` SEMPRE armazena o **custo anualizado** (com formação amortizada), NUNCA o custo bruto total.

---

## ⚠️ Pendências identificadas no projeto

- `lib/assets/config/` é duplicata de `lib/config/` → consolidar e remover
- `firebase.json` e `google-services.json` na raiz → verificar se ainda são usados (projeto usa Supabase)
- `errors.txt`, `errors_gestao.txt`, `errors_utf8.txt` na raiz → limpar após resolver os erros
- `update_screen.py` na raiz → mover para `tool/` ou remover se não for mais necessário
- `lib/services/## Chat Customization Diagnostics.md` → arquivo indevido na pasta services, remover

---

## 📋 Definição dos Comandos Rápidos

### /analisar
Rodar `flutter analyze`, listar todos os erros encontrados e corrigi-los um por um, mantendo a arquitetura Screen → Service → Supabase do projeto.

### /limpar
Remover da raiz do projeto: `errors.txt`, `errors_gestao.txt`, `errors_utf8.txt`, `update_screen.py`. Remover também `lib/assets/config/` (duplicata) e `lib/services/## Chat Customization Diagnostics.md`.

---

### ⚠️ PADRÃO OBRIGATÓRIO APÓS CADA TAREFA COMPLETADA
1. Rodar `flutter clean` para limpar cache de build
2. Rodar `flutter pub get` para garantir dependências atualizadas
3. Rodar `flutter analyze` para verificar se há problemas
4. Se houver erros/warnings: SEMPRE corrigi-los antes de continuar
5. Verificar Supabase para TODA operação com banco de dados:
   - Se criou/alterou tabela, coluna, RLS ou function → criar migration SQL em `lib/sql/`
   - Se criou/alterou service com queries → conferir `.select('col1, col2')` (nunca `*`)
   - Se criou tabela nova → garantir RLS ativa + policy
   - Se alterou model → garantir que o service reflete os mesmos campos do banco
   - Se houve qualquer mudança no schema → migration SQL obrigatória antes do commit
6. Rodar `/limpar` se houver arquivos temporários
7. Fazer `git add .` para adicionar todas as alterações
8. Fazer `git commit -m "descrição da tarefa"` com mensagem descritiva em português
9. Fazer `git push` para enviar ao GitHub
10. Verificar no GitHub se o commit aparece corretamente
11. **SOMENTE DEPOIS** passar para a próxima etapa
12. Reportar resumo do progresso em Português

---

### /pendencias
Listar todas as pendências do CLAUDE.md e perguntar quais resolver.

### /testar
Rodar `flutter test`, mostrar resultados em português e sugerir correções.

### /status
Rodar `git status`, resumir em português o que foi modificado, adicionado e deletado.

### /redesign
Executar o redesign visual completo do app conforme o arquivo `prompt_redesign_flutter.md` na raiz do projeto. Seguir a ordem de execução definida no arquivo, tela por tela, sem pular etapas.

---

### /pdf-relatorios
Implementar botões "Gerar PDF" e "Salvar" nas telas abaixo, seguindo EXATAMENTE o padrão já existente nos relatórios de pragas (`pdf_broca_cigarrinha.dart`, `pdf_broca_infestacao.dart`, `pdf_sphenophorus.dart`).

**Telas a implementar:**
1. `produtividade_screen.dart` e `produtividade_form_screen.dart`
2. `precipitacao_screen.dart` e `precipitacao_por_municipios_screen.dart`
3. `operacoes_cultivo_screen.dart` e `operacao_form_screen.dart`
4. `custo_operacional_screen.dart` e `custo_operacional_lancamentos_screen.dart`
5. `tratos_culturais_screen.dart` e `tratos_culturais_form_screen.dart`

**Regras obrigatórias:**
- Analisar PRIMEIRO o código de `pdf_broca_cigarrinha.dart` para entender o padrão existente
- Criar um gerador PDF em `services/pdf_generators/` para cada tela (ex: `pdf_produtividade.dart`)
- Botão "Gerar PDF": gera e abre preview para impressão usando `Printing.layoutPdf()`
- Botão "Salvar": salva os dados no Supabase via service correspondente
- NUNCA inventar dados — usar apenas dados reais dos services existentes
- Manter o visual e posicionamento igual ao padrão das telas de pragas
- Cabeçalho do PDF deve conter: logo AFCRC, nome da associação, data de geração, nome do relatório
- Rodapé do PDF: número de página e "AFCRC Catanduva — Sistema de Gestão"
- Todos os textos do PDF em Português do Brasil

**Ordem de execução:**
1. Ler e entender o padrão atual dos pdf_generators existentes
2. Criar os novos geradores PDF um por um
3. Adicionar os botões nas screens correspondentes
4. Rodar flutter analyze para verificar erros
5. Reportar em português o que foi feito em cada tela

---

### /dashboard
Analisar o código atual da `gestao_agricola_dashboard_screen.dart` e corrigir o layout para seguir estas regras obrigatórias:
- Manter o layout/design moderno que foi criado
- Mostrar APENAS dados que vêm do Supabase via services existentes
- NUNCA usar dados hardcoded ou valores fictícios (ex: "450 ha", "24 talhões")
- Se um dado ainda não foi desenvolvido, ocultar o card/seção completamente
- Todos os números devem vir de consultas reais aos services do projeto
- Se o dado estiver carregando, mostrar indicador de loading
- Se não houver dados, mostrar mensagem "Nenhum dado disponível"
- Verificar: Total de área → TalhaoService | Total talhões → TalhaoService | Censo Varietal → VariedadeService | Análise de Solo → ocultar se sem dados | Relatórios de Pragas → AnexoService | Produtividade → ProdutividadeService

---

## 💬 Exemplos de comandos para o Claude Code

```
Crie o model e service para a entidade 'Praga' seguindo o padrão de ProprietarioService

Adicione paginação na PropriedadesScreen com .range() — 20 itens por página

Crie gerador PDF para relatório de pragas em services/pdf_generators/ seguindo o padrão existente

Corrija todos os erros do flutter analyze mantendo a arquitetura atual

Crie a migration SQL para a tabela 'pragas' com RLS e salve como lib/sql/002_pragas.pgsql

Refatore a TalhaoFormScreen para usar validators.dart em todos os campos de texto
```

---

## 🏗️ Arquitetura de Contexto de Propriedade — PADRÃO OBRIGATÓRIO

Este é o padrão central do app. Toda tela operacional (Tratos, Operações, Produtividade, Precipitação, Custo, Anexos) DEVE receber e exibir o contexto da propriedade selecionada.

### Hierarquia de navegação obrigatória

```
LOGIN
  ↓
HOME (Dashboard | Gestão)
  ↓
PROPRIETÁRIOS → PROPRIEDADES
  ↓ (ao clicar numa propriedade)
PAINEL HUB DA PROPRIEDADE  (PropriedadeHubScreen)
  ├── Talhões
  ├── Tratos Culturais      + PDF
  ├── Operações de Cultivo  + PDF
  ├── Produtividade         + PDF
  ├── Precipitação          + PDF
  ├── Custo Operacional     + PDF
  ├── Anexos
  └── Relatórios de Pragas  + PDF
```

### Arquivos do padrão (criar se não existirem)

| Arquivo | Tipo | Função |
|---|---|---|
| `lib/models/contexto_propriedade.dart` | Model | Agrupa Proprietario + Propriedade com atalhos |
| `lib/widgets/header_propriedade.dart` | Widget | Cabeçalho verde fixo no topo de cada tela operacional |
| `lib/screens/propriedade_hub_screen.dart` | Screen | Lista vertical com todos os módulos da propriedade (layout tipo lista, NÃO grid/quadrado) |
| `lib/services/pdf_generators/pdf_cabecalho.dart` | Service | Cabeçalho AFCRC compartilhado por todos os PDFs |

### ContextoPropriedade — estrutura obrigatória

```dart
// lib/models/contexto_propriedade.dart
class ContextoPropriedade {
  final Proprietario proprietario;
  final Propriedade  propriedade;

  const ContextoPropriedade({
    required this.proprietario,
    required this.propriedade,
  });

  String get nomeProprietario => proprietario.nome;
  String get nomePropriedade  => propriedade.nomePropriedade;
  String get numeroFA         => propriedade.numeroFA;
  String get municipio        => propriedade.cidade ?? '';
  String get areaHa           => propriedade.areaHa != null
                                   ? '${propriedade.areaHa!.toStringAsFixed(1)} ha'
                                   : 'Não informado';
}
```

### HeaderPropriedade — widget obrigatório em toda tela operacional

```dart
// lib/widgets/header_propriedade.dart
class HeaderPropriedade extends StatelessWidget {
  final ContextoPropriedade contexto;
  const HeaderPropriedade({super.key, required this.contexto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primary,  // Color(0xFF2E7D32)
      child: Wrap(
        spacing: 24, runSpacing: 4,
        children: [
          _info('Proprietário', contexto.nomeProprietario),
          _info('Propriedade',  contexto.nomePropriedade),
          _info('FA',           contexto.numeroFA),
          _info('Município',    contexto.municipio),
          _info('Área',         contexto.areaHa),
        ],
      ),
    );
  }

  Widget _info(String label, String valor) => RichText(
    text: TextSpan(children: [
      TextSpan(text: '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 12)),
      TextSpan(text: valor,
          style: const TextStyle(color: Colors.white,
              fontSize: 12, fontWeight: FontWeight.bold)),
    ]),
  );
}
```

### Como usar o HeaderPropriedade em qualquer tela

```dart
// Padrão obrigatório em TODAS as telas operacionais:
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Nome da Tela')),
    body: Column(
      children: [
        HeaderPropriedade(contexto: contexto),  // ← sempre a primeira linha do body
        Expanded(child: _conteudoPrincipal()),
      ],
    ),
  );
}
```

### Como abrir o Hub ao clicar em uma propriedade

```dart
// Em PropriedadesScreen, PropriedadeDetailScreen e PropriedadesPorProprietarioScreen:
Future<void> _abrirHub(Propriedade propriedade) async {
  final proprietario = await ProprietarioService()
      .getProprietario(propriedade.proprietarioId);
  if (proprietario != null && mounted) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => PropriedadeHubScreen(
        contexto: ContextoPropriedade(
          proprietario: proprietario,
          propriedade: propriedade,
        ),
      ),
    ));
  }
}
```

### Cabeçalho universal de PDF — NUNCA duplicar

```dart
// lib/services/pdf_generators/pdf_cabecalho.dart
// Importar em TODOS os geradores de PDF — nunca recriar este cabeçalho:
pw.Widget cabecalhoPDF(ContextoPropriedade ctx, String titulo) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('Associação dos Fornecedores de Cana da Região de Catanduva',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
      pw.Text('AFCRC — Catanduva/SP'),
      pw.Divider(),
      pw.Row(children: [
        pw.Expanded(child: pw.Text('Proprietário: ${ctx.nomeProprietario}')),
        pw.Expanded(child: pw.Text('FA: ${ctx.numeroFA}')),
      ]),
      pw.Row(children: [
        pw.Expanded(child: pw.Text('Propriedade: ${ctx.nomePropriedade}')),
        pw.Expanded(child: pw.Text('Município: ${ctx.municipio}')),
      ]),
      pw.Row(children: [
        pw.Expanded(child: pw.Text('Área: ${ctx.areaHa}')),
        pw.Expanded(child: pw.Text('Data: ${DateTime.now().toString().substring(0,10)}')),
      ]),
      pw.Divider(),
      pw.Text(titulo,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
      pw.SizedBox(height: 12),
    ],
  );
}
```

### Regras do padrão — NUNCA violar

- Toda tela operacional DEVE mostrar `HeaderPropriedade` no topo do body
- `ContextoPropriedade` é passado por parâmetro de tela em tela — sem gerenciador de estado global
- Novos módulos adicionados ao Hub herdam o contexto automaticamente
- PDFs novos SEMPRE importam `cabecalhoPDF()` — nunca recriar o cabeçalho
- `ContextoPropriedade` deve ser exportado em `models/models.dart`
- NUNCA inventar dados — usar apenas dados reais dos services existentes
- `PropriedadeHubScreen` DEVE usar layout de LISTA vertical (ListTile com ícone, título, subtítulo e seta) — NUNCA usar grid/quadrado

Implementar a arquitetura de contexto de propriedade conforme os padrões definidos neste CLAUDE.md (seção "Arquitetura de Contexto de Propriedade").

**Ordem obrigatória de execução:**
1. Criar `lib/models/contexto_propriedade.dart`
2. Exportar em `lib/models/models.dart`
3. Criar `lib/widgets/header_propriedade.dart`
4. Criar `lib/screens/propriedade_hub_screen.dart`
5. Adaptar `propriedades_screen.dart` para abrir o Hub ao clicar
6. Criar `lib/services/pdf_generators/pdf_cabecalho.dart`
7. Criar `pdf_tratos.dart` + adicionar botão PDF em `tratos_culturais_screen.dart`
8. Criar `pdf_operacoes.dart` + adicionar botão PDF em `operacoes_cultivo_screen.dart`
9. Criar `pdf_produtividade.dart` + adicionar botão PDF em `produtividade_screen.dart`
10. Criar `pdf_precipitacao.dart` + adicionar botão PDF em `precipitacao_screen.dart`
11. Criar `pdf_custo.dart` + adicionar botão PDF em `custo_operacional_screen.dart`
12. Rodar `flutter analyze` e corrigir todos os erros

**Regras obrigatórias:**
- NUNCA deletar arquivos existentes
- NUNCA inventar dados — usar apenas dados dos services existentes
- Rodar `flutter analyze` após cada etapa
- Reportar progresso em PT-BR

**Arquivos que NÃO mudam:** `login_screen`, `home_screen`, `dashboard_screen`, `proprietarios_screen`, todos os `_form_screen`, todos os services, todos os models existentes, `empresa_header.dart`.
