# PROMPT — Redesign Visual Flutter baseado no Stitch
# Cole este prompt no Claude Code quando tiver créditos disponíveis

---

Vou fazer o redesign visual completo do app gestao_cana_app baseado em 23 telas criadas no Google Stitch. O design já foi aprovado. Sua tarefa é recriar cada tela em Flutter mantendo toda a arquitetura, lógica e dados existentes — apenas o visual muda.

## REGRAS OBRIGATÓRIAS ANTES DE COMEÇAR

1. Ler este arquivo completo antes de tocar em qualquer código
2. Nunca quebrar a arquitetura Screen → Service → Supabase
3. Nunca inventar dados ou hardcodar valores
4. Nunca remover funcionalidades existentes
5. Após cada tela, rodar `flutter analyze` antes de passar para a próxima
6. Reportar progresso em Português do Brasil

---

## DESIGN SYSTEM — Aplicar em TODO o app

### Paleta de Cores (criar em `constants/app_colors.dart`)

```dart
// Fundo
static const bgDark = Color(0xFF0F1117);
static const surfaceDark = Color(0xFF1C2333);
static const borderDark = Color(0xFF2A3347);

// Primária (verde vibrante)
static const primary = Color(0xFF0DF28F);
static const primaryMuted = Color(0x1A0DF28F); // primary com 10% opacidade

// Texto
static const textPrimary = Color(0xFFE2E8F0);   // slate-100
static const textSecondary = Color(0xFF94A3B8); // slate-400
static const textMuted = Color(0xFF64748B);     // slate-500

// Status
static const success = Color(0xFF0DF28F);
static const warning = Color(0xFFF59E0B);
static const danger = Color(0xFFEF4444);
static const info = Color(0xFF3B82F6);
```

### Tipografia
- Títulos e corpo: **Inter** (`google_fonts: ^6.0.0` — adicionar ao pubspec.yaml)
- Números e métricas: **JetBrains Mono** (mesmo pacote google_fonts)
- Tamanhos: display=32, h1=24, h2=20, h3=16, body=14, caption=12

### Componentes Padrão (criar em `widgets/`)

**Card padrão:**
- Background: `surfaceDark` (#1C2333)
- Border: 1px `borderDark` (#2A3347)
- Border radius: 12px
- Padding: 20px

**Botão primário:**
- Background: `primary` (#0DF28F)
- Texto: preto (#000000), peso 600
- Height: 40px, padding horizontal: 16px
- Border radius: 8px

**Botão secundário:**
- Background: transparente
- Border: 1px `primary`
- Texto: `primary`

**Campo de texto:**
- Background: `bgDark` (#0F1117)
- Border: 1px `borderDark`
- Border radius: 8px
- Label acima do campo, cor `textSecondary`
- Focus: border `primary`

**Badge de status:**
- Border radius: 4px
- Padding: 2px 8px
- Fonte: 11px, peso 600

---

## LAYOUT BASE — Criar widget `AppShell` em `widgets/app_shell.dart`

Todas as telas devem usar este layout base:

```
┌─────────────────────────────────────────────────┐
│  HEADER (60px) — Logo + Breadcrumb + Perfil      │
├──────────┬──────────────────────────────────────┤
│ SIDEBAR  │                                       │
│ (240px)  │   CONTEÚDO DA TELA                   │
│          │   padding: 24px                       │
│          │                                       │
└──────────┴──────────────────────────────────────┘
```

**Sidebar — itens de navegação:**
| Ícone Material | Label | Rota |
|---|---|---|
| dashboard | Dashboard | /dashboard |
| group | Proprietários | /proprietarios |
| map | Propriedades | /propriedades |
| grid_view | Talhões | /talhoes |
| trending_up | Produtividade | /produtividade |
| rainy | Precipitação | /precipitacao |
| agriculture | Operações de Cultivo | /operacoes |
| monetization_on | Custo Operacional | /custo-operacional |
| eco | Tratos Culturais | /tratos-culturais |
| attach_file | Anexos | /anexos |
| picture_as_pdf | Relatórios PDF | /relatorios |
| settings | Configurações | /configuracoes |

**Item ativo na sidebar:**
- Background: `primary` com 10% opacidade
- Texto e ícone: cor `primary`
- Barra lateral esquerda: 3px sólido `primary`

---

## TELAS A REDESENHAR — Uma por vez, nesta ordem

### TELA 1 — Login (`login_screen.dart`)
**Layout:** Duas colunas — esquerda com info da AFCRC, direita com formulário
- Coluna esquerda (40%): fundo `primary`, logo AFCRC, texto "Gestão Agrícola Inteligente", descrição
- Coluna direita (60%): fundo `bgDark`, formulário centralizado
- Campos: E-mail/CPF + Senha
- Botão: "Entrar" primário, largura total
- Link: "Esqueci minha senha"
- Manter lógica do `AuthService` intacta

### TELA 2 — Dashboard Principal (`dashboard_screen.dart`)
**Layout:** AppShell + grade de cards
- 4 cards de KPI no topo (grid 4 colunas):
  - Total de Proprietários → buscar `ProprietarioService`
  - Total de Propriedades → buscar `PropriedadeService`
  - Total de Talhões → buscar `TalhaoService`
  - Área Total (ha) → buscar `TalhaoService` (soma das áreas)
- Card KPI: ícone colorido + número grande (JetBrains Mono) + label + variação
- Gráfico de produtividade (fl_chart — LineChart) — buscar `ProdutividadeService`
- Tabela de últimas operações — buscar `OperacaoCultivoService`
- Cards de acesso rápido para telas principais

### TELA 3 — Listagem de Proprietários (`proprietarios_screen.dart`)
**Layout:** AppShell + tabela moderna
- Header da tela: título + botão "+ Novo Proprietário" (primário)
- Barra de busca + filtros
- Tabela com colunas: Nome, CPF/CNPJ, Município, Nº Propriedades, Área Total, Ações
- Ações por linha (aparecem no hover): Editar (ícone lápis) | Ver detalhes (ícone olho) | Deletar (ícone lixeira vermelho)
- Paginação na base: 20 itens por página com `.range()`
- Loading skeleton enquanto carrega

### TELA 4 — Formulário de Propriedade (`propriedade_form_screen.dart`)
**Layout:** AppShell + formulário em seções
- Breadcrumb: Propriedades > Nova Propriedade
- Seção "Dados Gerais": Nome, Município (dropdown municipios_sp.dart), Área (ha)
- Seção "Localização": campos de coordenadas (opcional)
- Seção "Proprietário": dropdown buscando `ProprietarioService`
- Botões no rodapé: "Cancelar" (secundário) + "Salvar Propriedade" (primário)
- Validação com `validators.dart`

### TELA 5 — Dashboard Gestão Agrícola (`gestao_agricola_dashboard_screen.dart`)
**Layout:** AppShell + cards e gráficos
- Cards de resumo: Talhões ativos, Área total, Última precipitação, Variedade mais plantada
- Gráfico de precipitação (BarChart — fl_chart) — buscar `PrecipitacaoService`
- Censo varietal: gráfico pizza por variedade — buscar `VariedadeService`
- Lista de talhões com status — buscar `TalhaoService`
- APENAS dados reais — ocultar seção se não houver dados

### TELA 6 — Custo Operacional (`custo_operacional_screen.dart`)
**Layout:** AppShell + cards + tabela
- Cards: Custo Total, Custo por Hectare, Maior categoria de custo
- Filtros: período (safra), propriedade, categoria
- Tabela de lançamentos com colunas: Data, Operação, Categoria, Valor (R$), Propriedade
- Botão "Gerar Relatório PDF" + "Novo Lançamento"
- Gráfico de custos por categoria (PieChart — fl_chart)

### TELA 7 — Relatório de Custos (`historico_custo_operacional_screen.dart`)
**Layout:** AppShell + layout de relatório imprimível
- Header do relatório: logo AFCRC + título + data de geração
- Sumário executivo com totais
- Tabela detalhada de custos
- Gráficos de evolução
- Botão "Exportar PDF" usando `ExportacaoPdfService`

### TELA 8 — Operações de Cultivo (`operacoes_cultivo_screen.dart` + `operacao_form_screen.dart`)
**Layout:** AppShell + formulário estruturado
- Formulário com seções:
  - "Identificação": Propriedade, Talhão, Data
  - "Operação": Tipo de operação, Descrição
  - "Recursos": Maquinário, Insumos utilizados
- Botões: "Salvar" + "Gerar PDF da Operação"
- Histórico de operações em tabela abaixo do formulário

### TELA 9 — Precipitação (`precipitacao_screen.dart`)
**Layout:** AppShell + dashboard pluviométrico
- Header: "Monitoramento Pluviométrico — Catanduva/SP"
- Filtro de safra e município (dropdown `municipios_sp.dart`)
- Gráfico de barras mensal (BarChart — fl_chart)
- Cards: Total anual (mm), Média mensal, Mês mais chuvoso, Mês mais seco
- Tabela por município — buscar `PrecipitacaoAgregadaService`
- Botão "Exportar PDF"

### TELA 10 — Produtividade (`produtividade_screen.dart`)
**Layout:** AppShell + análise por talhão
- Header: "Análise de Produtividade — Safra [ano]"
- Filtros: safra, propriedade
- Cards: Produção total (t), Produtividade média (t/ha), Melhor talhão, Pior talhão
- Tabela por talhão: Talhão, Variedade, Área, Produção, Produtividade (t/ha)
- Gráfico comparativo entre talhões (BarChart)
- Botões: "Novo Registro" + "Exportar PDF"

### TELA 11 — Anexos (`anexos_screen.dart` + `anexo_upload_screen.dart`)
**Layout:** AppShell + grid de documentos
- Filtros: tipo de documento, propriedade
- Grid de cards de documentos: ícone tipo + nome + data + tamanho + ações
- Área de upload: drag-and-drop estilizado
- Botão "Fazer Upload"
- Usar `AnexoService` para todas operações

---

## ORDEM DE EXECUÇÃO

Execute nesta ordem exata:
1. Atualizar `pubspec.yaml` — adicionar `google_fonts`
2. Atualizar `constants/app_colors.dart` com nova paleta
3. Criar `widgets/app_shell.dart` — layout base com sidebar e header
4. Criar `widgets/kpi_card.dart` — card de métrica reutilizável
5. Criar `widgets/data_table_widget.dart` — tabela moderna reutilizável
6. Tela Login
7. Tela Dashboard Principal
8. Tela Proprietários
9. Tela Formulário Propriedade
10. Tela Gestão Agrícola Dashboard
11. Tela Custo Operacional
12. Tela Relatório de Custos
13. Tela Operações de Cultivo
14. Tela Precipitação
15. Tela Produtividade
16. Tela Anexos
17. Rodar `flutter analyze` final e corrigir todos os erros
18. Reportar resumo completo do que foi alterado

---

## CHECKLIST FINAL

Após terminar todas as telas verificar:
- [ ] `flutter analyze` sem erros
- [ ] Todas as telas usam `AppShell`
- [ ] Nenhum valor hardcoded
- [ ] Paleta de cores aplicada consistentemente
- [ ] Tipografia Inter + JetBrains Mono aplicada
- [ ] Todos os botões seguem o padrão (primário/secundário)
- [ ] Loading indicators em todas as telas com dados assíncronos
- [ ] Mensagem "Nenhum dado disponível" onde não há dados
