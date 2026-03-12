# 📋 ANÁLISE DE REQUISITOS vs IMPLEMENTADO
**Data:** 16 de janeiro de 2026  
**Status:** Verificação Completa do Sistema

---

## 📊 RESUMO EXECUTIVO

### ✅ O QUE JÁ EXISTE (70% pronto)
- **6 Telas Principais** implementadas
- **8 Modelos de Dados** definidos
- **8 Services** com CRUD
- **Sistema de Autenticação** básico
- **Dashboard** com métricas
- **Supabase** como backend

### ❌ O QUE AINDA FALTA (30% a completar)
- Refinamentos na **tela de Login**
- Validações de **CPF/CNPJ**
- **Tabelas avançadas** com somatórias
- **Tipos de anexos** expandidos (faltam 5)
- **Compartilhamento WhatsApp**
- **Cálculos automáticos** em operações
- **Comparação gráfica** em produtividade
- **Importação Excel/TXT**

---

## 🔐 INTERFACE 1: LOGIN / USUÁRIOS

### Requisitos:
- [ ] Nome da empresa: "ASSOCIACAO DOS FORNECEDORES DE CANA DA REGIÃO DE CATANDUVA"
- [ ] Logo da empresa visível
- [ ] Login com Email
- [ ] Login com Google
- [ ] Recuperação de senha
- [ ] Desenho de digital (biometria)
- [ ] Tipos de usuário: ADM / Proprietário
- [ ] Salvar senha no Firebase Auth (não no banco)

### Status Atual:
✅ Login com email existe  
✅ Autenticação básica existe  
❌ Google Sign-In não implementado  
❌ Recuperação de senha não implementada  
❌ Biometria não implementada  
❌ Logo/Branding não exibido  
❌ Tipos de usuário não diferenciados (ADM vs Proprietário)  

### Prioridade: 🔴 ALTA
**Recomendação:** Implementar antes de qualquer coisa, é a porta de entrada

---

## 👨‍🌾 INTERFACE 2: CADASTRO

### 2.1 - Cadastro de Proprietário

**Requisitos:**
- [ ] Nome do proprietário
- [ ] CPF ou CNPJ (com validação)
- [ ] Email
- [ ] Data de cadastro (automática)
- [ ] Status: ativo/inativo
- [ ] Botão para excluir proprietário
- [ ] Botão para inativar proprietário

### Status Atual:
✅ Nome existe  
✅ Email existe  
✅ Data de cadastro existe  
✅ Status existe (ativo/inativo)  
✅ Botão excluir existe  
❌ **CPF/CNPJ com validação não existe**  
❌ Botão inativar não implementado  

**Arquivo:** `proprietario.dart`, `proprietarios_screen.dart`  
**Prioridade:** 🟡 MÉDIA-ALTA

---

### 2.2 - Cadastro de Propriedade (F.A)

**Requisitos:**
- [ ] Nome da propriedade
- [ ] Número F.A (identificador único)
- [ ] Vincular ao proprietário específico
- [ ] ADM pode vincular apenas F.A desejados
- [ ] Status: ativa/inativa
- [ ] Botão excluir propriedade
- [ ] Botão inativar propriedade

### Status Atual:
✅ Nome existe  
✅ Número F.A existe  
✅ Vinculação a proprietário existe  
✅ Status existe  
✅ Botão excluir existe  
❌ **Restrição de ADM para vincular F.A não implementada**  
❌ Botão inativar não implementado  

**Arquivo:** `propriedade.dart`, `propriedades_screen.dart`  
**Prioridade:** 🟡 MÉDIA

---

### 2.3 - Tabela de Talhões com Somatória

**Requisitos:**
- [ ] Número dos talhões
- [ ] Área (hectares)
- [ ] Área (alqueires)
- [ ] Variedade
- [ ] Ano de plantio
- [ ] **SOMATÓRIA** de área (ha)
- [ ] **SOMATÓRIA** de área (alq)
- [ ] **Separação:** Reforma vs Produção
- [ ] **Resumo:** Total reforma + Total produção
- [ ] **Comparação gráfica** entre tipos

### Status Atual:
✅ Campos básicos existem  
✅ Filtro Produção/Reforma existe  
✅ Botões SegmentedButton implementados  
❌ **Somatória de áreas não implementada**  
❌ **Tabela avançada não está em formato table**  
❌ **Resumo comparativo não visual**  

**Arquivo:** `talhao.dart`, `talhoes_screen.dart`  
**Prioridade:** 🔴 ALTA

---

### 2.4 - Anexos (7 tipos de documentos)

**Requisitos:**
- [ ] **Croqui (MAPA):** PDF, KML
- [ ] **Localização (GPS):** UTM + arquivo KML
- [ ] **CCIR:** PDF
- [ ] **CAR:** PDF
- [ ] **Análise de Solo:** PDF (múltiplos)
- [ ] **Relatório de Pragas:** Word/Excel (múltiplos)
  - Tipos: Sphenophorus, Nematoides, Broca, Cigarrinha, Migdolus, Outros
- [ ] **Relatório Ambiental:** PDF/Word/Excel (múltiplos)
- [ ] **Compartilhamento via WhatsApp** em todas as abas

### Status Atual:
✅ Upload de anexos básico  
✅ Download de anexos  
✅ Vinculação a propriedade  
❌ **Não há diferenciação de tipos de documento**  
❌ **Não há validação de extensão por tipo**  
❌ **WhatsApp não integrado**  
❌ **Sem organização visual por categoria**  

**Arquivo:** `anexo.dart`, `anexos_screen.dart`  
**Prioridade:** 🟡 MÉDIA-ALTA

---

## 🌾 INTERFACE 3: TRATOS CULTURAIS

**Requisitos:**
- [ ] Buscador por Proprietário
- [ ] Buscador por F.A
- [ ] Buscador por Ano safra
- [ ] Para cada talhão, colunas com:
  - Adubo (kg/ha) - **até 10 tipos**
  - Herbicidas (kg ou L/ha) - **até 10 tipos**
  - Inseticida (kg ou L/ha) - **até 10 tipos**
  - Maturadores (L/ha) - **até 10 tipos**
  - Calagem (kg/ha)
  - Gessagem (kg/ha)
  - Óxido de Cálcio (kg/ha)
  - **3 campos extras editáveis**
- [ ] Múltiplas abas por insumo para inserir várias opções
- [ ] Interface de digitação para usuários

### Status Atual:
❌ **Tratos culturais NÃO foi implementado**  
❌ Sem buscador  
❌ Sem dados de insumos  
❌ Sem múltiplas abas  

**Arquivo:** Não existe ainda  
**Prioridade:** 🔴 ALTA

---

## 🚜 INTERFACE 4: OPERAÇÃO CULTIVO / QUEBRA-LOMBO

**Requisitos:**
- [ ] Buscador por Proprietário
- [ ] Buscador por F.A
- [ ] Colunas por talhão:
  - Data Plantio / Colheita
  - **Dias Após Plantio / Colheita (CALCULADO AUTOMÁTICO)**
  - Herbicida 1ª Aplicação
  - Data do Cultivo / Quebra Lombo
  - **Dias após Cultivo / Quebra Lombo (CALCULADO AUTOMÁTICO)**
  - Herbicida 2ª Aplicação
- [ ] Cálculo automático de dias entre datas
- [ ] Interface de digitação para usuários

### Status Atual:
✅ Tela existe  
✅ Campos básicos existem  
✅ Vinculação a talhão existe  
❌ **Cálculo automático de dias NÃO implementado**  
❌ **Faltam campos de Herbicida**  
❌ **Sem buscador avançado**  

**Arquivo:** `operacao_cultivo.dart`, `operacoes_cultivo_screen.dart`  
**Prioridade:** 🟡 MÉDIA-ALTA

---

## 📊 INTERFACE 5: PRODUTIVIDADE

**Requisitos:**
- [ ] Buscador por Proprietário
- [ ] Buscador por F.A
- [ ] Buscador por Ano safra
- [ ] Campos para cada F.A:
  - Variedade
  - Estágio (quantos cortes)
  - Mês da colheita
  - Peso Líquido (toneladas)
  - Média ATR
- [ ] **Comparar produtividade:** Ano atual vs Anos anteriores
- [ ] **Apresentar em %**
- [ ] **Gráfico analítico comparativo**

### Status Atual:
✅ Tela existe  
✅ Campos básicos existem  
✅ Vinculação a talhão existe  
❌ **Comparação com anos anteriores NÃO implementada**  
❌ **Cálculo de % não feito**  
❌ **Gráfico comparativo não existe**  

**Arquivo:** `produtividade.dart`, `produtividade_screen.dart`  
**Prioridade:** 🟡 MÉDIA

---

## 🌧️ INTERFACE 6: PRECIPITAÇÃO

**Requisitos:**
- [ ] Calendário com navegação por ano
- [ ] Clicar no dia para digitar quantidade (mm)
- [ ] Somatória de chuva por período (mês/ano)
- [ ] Vincular a cada propriedade
- [ ] Filtrar por mês e ano
- [ ] Opções de atualização e modificação

### Status Atual:
✅ **IMPLEMENTADO COMPLETAMENTE** ✅  
✅ Calendário interativo  
✅ TableCalendar widget  
✅ Seletor de município (São Paulo)  
✅ Seletor de ano (2025+)  
✅ Estatísticas em tempo real  
✅ Cálculos de soma total, mês e dias com chuva  
✅ Delete com confirmação  
✅ Vinculação a propriedade  

**Arquivo:** `precipitacao.dart`, `precipitacao_screen.dart`  
**Prioridade:** ✅ COMPLETO

---

## 📁 FUNCIONALIDADES TRANSVERSAIS

### Importação de Excel/TXT
**Requisitos:**
- [ ] Na aba Cadastro, importar informações via Excel
- [ ] Na aba Cadastro, importar informações via TXT
- [ ] Validar dados antes de importar
- [ ] Mostrar preview antes de salvar

### Status Atual:
❌ **Não implementado**  

**Prioridade:** 🟡 MÉDIA

---

### Integração com Sistema Externo
**Requisitos:**
- [ ] API para conectar com sistema externo
- [ ] Sincronização automática de dados
- [ ] Tratamento de erros de conexão

### Status Atual:
❌ **Não implementado**  

**Prioridade:** 🟠 BAIXA (futuro)

---

## 🎯 MATRIZ DE PRIORIDADES

| Prioridade | Interface | Tarefa | Estimativa |
|-----------|-----------|--------|-----------|
| 🔴 ALTA | Login | Implementar Google Sign-In, Recuperação de Senha, Biometria | 6h |
| 🔴 ALTA | Cadastro | Implementar validação CPF/CNPJ | 4h |
| 🔴 ALTA | Talhões | Implementar tabela com somatória | 8h |
| 🔴 ALTA | Tratos | **Criar interface completa** | 12h |
| 🟡 MÉDIA-ALTA | Anexos | Expandir com 7 tipos de documentos + WhatsApp | 10h |
| 🟡 MÉDIA-ALTA | Operações | Implementar cálculo automático de dias | 6h |
| 🟡 MÉDIA | Produtividade | Implementar comparação com gráfico | 8h |
| 🟡 MÉDIA | Importação | Implementar Excel/TXT | 8h |
| 🟠 BAIXA | Sistema Externo | Integração futura | 10h |

**Total Estimado: 72 horas**

---

## 📋 PLANO DE AÇÃO (próximas semanas)

### SEMANA 1: Melhorias Críticas
1. ✅ **Login:** Google Sign-In + Recuperação de Senha
2. ✅ **Cadastro:** Validação CPF/CNPJ com regex/lib
3. ✅ **Talhões:** Implementar tabela com somatória visual

### SEMANA 2: Novas Funcionalidades
4. ✅ **Tratos Culturais:** Interface completa com múltiplos insumos
5. ✅ **Anexos:** Expandir para 7 tipos + WhatsApp

### SEMANA 3: Cálculos e Análises
6. ✅ **Operações:** Cálculo automático de dias
7. ✅ **Produtividade:** Comparação com gráficos

### SEMANA 4: Integrações
8. ✅ **Importação:** Excel/TXT
9. ✅ **Testes:** QA completo em todas as funcionalidades

---

## ✨ CONCLUSÃO

O aplicativo está **em bom estágio** (~70% funcional), mas precisa de **refinamentos importantes** para atender 100% aos requisitos. As prioridades estão claras, e a equipe deve começar pela **SEMANA 1**, focando em:

1. **Login** melhorado (segurança + usabilidade)
2. **Validação de dados** (CPF/CNPJ)
3. **Tabelas visuais** (talhões com somatória)

Depois disso, seguir com **Tratos Culturais** que é a funcionalidade mais complexa que falta.

---

## 🧪 INTERFACE 7: ANÁLISE DE SOLO — Diagnóstico e Regras

**Data do diagnóstico:** 12 de março de 2026
**Arquivos envolvidos:**
- `lib/screens/analise_solo_screen.dart` — tela principal com 3 abas (Dados, Resultado, Histórico)
- `lib/screens/analise_solo_form_screen.dart` — formulário alternativo (legado)
- `lib/screens/analise_solo_graficos_screen.dart` — gráficos de interpretação
- `lib/models/analise_solo.dart` — model + engine de interpretação Boletim 100
- `lib/services/analise_solo_service.dart` — CRUD Supabase
- `lib/services/pdf_generators/pdf_analise_solo.dart` — geração de PDF
- `lib/sql/002_analises_solo.pgsql` — migration SQL

---

### 7.1 — Estado Atual (O que já funciona)

| Funcionalidade | Status | Detalhes |
|---|---|---|
| Entrada de macronutrientes (pH, MO, P, K, Ca, Mg, S) | ✅ | Controllers com parse decimal |
| Entrada de micronutrientes (B, Cu, Fe, Mn, Zn) | ✅ | Campos opcionais |
| Entrada de acidez (Al, H+Al) | ✅ | Obrigatórios para cálculo |
| Cálculo SB, CTC, V%, m% | ✅ | Engine InterpretacaoBoletim100 |
| Semáforos coloridos (verde/amarelo/vermelho) | ✅ | Para macro, micro, calagem, gessagem |
| Calagem Método 1 (Saturação de Bases) | ✅ | Fórmula B-100 |
| Calagem Método 2 (Neutralização Al) | ✅ | Fórmula B-100 |
| Dose mínima calagem 1,5 t/ha PRNT=100% | ✅ | Para cana-de-açúcar |
| Gessagem (V% < 40% ou m% > 30%) | ✅ | Com dose baseada em argila |
| Fonte de S (S < 15 mg/dm³) | ✅ | Alerta visual amarelo |
| PRNT customizável | ✅ | Controller com default 100 |
| Dropdown de profundidade (5 faixas + custom) | ✅ | ChoiceChips B-100 |
| Calagem condicionada à camada arável | ✅ | Apenas 0-20/0-25 cm |
| Seleção de cultura (11 culturas B-100) | ✅ | ChoiceChips |
| Tipo de Cana (Planta/Soca) | ✅ | Adubação NPK diferenciada |
| Adubação NPK (N, P₂O₅, K₂O) | ✅ | Tabelas B-100 para cana |
| Relações iônicas Ca/Mg, Ca/K, Mg/K | ✅ | Com semáforos |
| Classe textural | ✅ | Baseada em argila % |
| Histórico de análises | ✅ | Lista com cards expandíveis |
| Tela de gráficos | ✅ | Gráficos de barras/semáforos |
| Geração de PDF | ✅ | Individual e todas |
| Seleção de talhão (opcional) | ✅ | Dropdown com "Geral" |
| Datas de coleta e resultado | ✅ | DatePickers |
| Laboratório e nº amostra | ✅ | Campos texto |
| Edição de análise existente | ✅ | Via histórico |
| Exclusão com confirmação | ✅ | Dialog de confirmação |

---

### 7.2 — Bugs Encontrados e Correções

#### 🔴 BUG 1: profundidadeCm salvo com valor errado
**Problema:** Quando o dropdown de profundidade predefinida está selecionado (ex: '0-20'), o `_profCtrl.text` era definido como '20' (parte final), mas o int.tryParse podia falhar se o controller estivesse em estado inconsistente.
**Correção:** Implementado `_parseProfundidadeFaixa()` que extrai corretamente o valor final da faixa (ex: '0-20' → 20, '25-50' → 50). O `_salvar()` agora usa este método em vez de `int.tryParse(_profCtrl.text)` diretamente.
**Status:** ✅ Corrigido

#### 🔴 BUG 2: Mensagem de erro genérica ao salvar
**Problema:** Qualquer erro do Supabase (RLS, constraint, coluna) era mostrado como "Erro ao salvar: [exception]", sem identificar o tipo de problema.
**Correção:** Implementadas mensagens específicas por tipo de erro: constraint violation → "verifique os dados", network → "verifique internet", policy denied → "verifique login", column missing → "coluna pode não existir". Log detalhado via debugPrint.
**Status:** ✅ Corrigido

#### 🟡 BUG 3: Campos silte e areia não preenchidos pela tela principal
**Problema:** Model tem `silte: double?` e `areia: double?`, service insere essas colunas no banco, mas a tela principal `analise_solo_screen.dart` NÃO tem controllers `_silteCtrl` e `_areiaCtrl`. Sempre salvam como NULL.
**Impacto:** Baixo — classe textural do B-100 para cana usa apenas argila como critério. Silte e areia são dados complementares.
**Ação:** Manter como está. A determinação textural pelo B-100 utiliza apenas o teor de argila (arenoso <15%, média 15-35%, argiloso 35-60%, muito argiloso >60%).
**Status:** ⚠️ Conhecido — não bloqueia funcionalidade

#### 🟡 BUG 4: Análise de Solo Form Screen (legada) desatualizada
**Problema:** `analise_solo_form_screen.dart` é um formulário antigo que NÃO tem as features novas (profundidade dropdown, tipo cana, adubação NPK, relações iônicas). Pode causar confusão se for aberto.
**Ação:** Verificar se ainda é usado no fluxo. Se não, marcar como legado.
**Status:** ⚠️ Pendente verificação

---

### 7.3 — Regras de Negócio do Boletim 100 (Implementadas)

#### Calagem
- **Método 1 — Saturação de Bases:** `NC = (Ve - Vatual) × CTC / (PRNT × 10)`
  - Ve: saturação esperada pela cultura
  - Vatual: V% calculado da amostra
- **Método 2 — Neutralização de Al:** `NC = (mt_max × (Al + H+Al) - X × cmolc) × 2 / (Ca + Mg) / PRNT`
- **Resultado final:** maior dos dois métodos
- **Dose mínima cana:** 1,5 t/ha (PRNT=100%) — se resultado < mínimo, ajusta para cima
- **Camada:** Calagem SÓ se aplica na camada arável (0-20 ou 0-25 cm)
- **Outras camadas:** Resultado = 0, com nota informativa

#### Gessagem
- **Critério B-100:** V% < 40% **OU** m% > 30%
- **Dose:** argila (%) × 10 × 6 / 1000 = t/ha
- **Camada válida:** Arável (0-20/0-25) e Subsuperfície (20-40/25-50)
- **Camada 80-100:** Não se aplica → dose 0 + nota informativa
- **Fonte de S:** Se gessagem NÃO necessária mas S-SO₄²⁻ < 15 mg/dm³ → aplicar 1,0 t/ha de gesso agrícola como fonte de enxofre. Exibe **ALERTA VISUAL AMARELO DESTACADO**.

#### Adubação NPK (Cana-de-açúcar)

##### Nitrogênio (N)
| Tipo | Dose |
|---|---|
| Cana Planta | 30 kg/ha N (fixo B-100) |
| Cana Soca (prod <100t) | 100 kg/ha N |
| Cana Soca (prod 100-150t) | 120 kg/ha N |
| Cana Soca (prod >150t) | 150 kg/ha N |

##### Fósforo (P₂O₅)
| P resina (mg/dm³) | Cana Planta | Cana Soca |
|---|---|---|
| 0-6 (muito baixo) | 180 | 100 |
| 7-15 (baixo) | 140 | 80 |
| 16-40 (médio) | 100 | 50 |
| 41-80 (alto) | 60 | 30 |
| >80 (muito alto) | 40 | 0 |

##### Potássio (K₂O)
| K mmolc/dm³ | Cana Planta | Cana Soca |
|---|---|---|
| 0-0.7 (muito baixo) | 150 | 150 |
| 0.8-1.5 (baixo) | 120 | 120 |
| 1.6-3.0 (médio) | 80 | 100 |
| 3.1-6.0 (alto) | 40 | 60 |
| >6.0 (muito alto) | 0 | 0 |

#### Relações Iônicas
| Relação | Faixa Ideal |
|---|---|
| Ca/Mg | 1,0 a 4,0 |
| Ca/K | 12 a 20 |
| Mg/K | 3 a 8 |

#### Profundidades B-100
| Faixa (cm) | Tipo | Aplicação |
|---|---|---|
| 0-20 | Camada arável | Calagem + Adubação |
| 0-25 | Camada arável | Calagem + Adubação |
| 20-40 | Subsuperfície | Gessagem (avaliação) |
| 25-50 | Subsuperfície | Gessagem (avaliação) |
| 80-100 | Profunda | Diagnóstico de restrições |

#### Classe Textural (por argila %)
| Teor argila (%) | Classificação |
|---|---|
| < 15% | Arenoso |
| 15-35% | Textura Média |
| 35-60% | Argiloso |
| > 60% | Muito Argiloso |

---

### 7.4 — Fluxo de Uso

```
1. Usuário seleciona CULTURA (Cana-de-açúcar, Milho, etc.)
   ↓
2. Se Cana: seleciona TIPO (Planta ou Soca)
   ↓
3. Preenche DADOS DO LABORATÓRIO (lab, nº amostra, datas)
   ↓
4. Seleciona PROFUNDIDADE (0-20, 20-40, 0-25, 25-50, 80-100 ou custom)
   ↓
5. Preenche MACRONUTRIENTES (pH, MO, P, K, Ca, Mg)
   ↓
6. Preenche ACIDEZ (Al, H+Al, S)
   ↓
7. Preenche MICRONUTRIENTES (B, Cu, Fe, Mn, Zn) — opcionais
   ↓
8. Preenche FÍSICOS (Argila %, PRNT, Produtividade esperada)
   ↓
9. Clica CALCULAR INTERPRETAÇÃO
   ↓
10. Aba RESULTADO mostra:
    - Valores calculados (SB, CTC, V%, m%, textura)
    - Semáforos macro e micro
    - Calagem (2 métodos + final)
    - Gessagem (+ alerta Fonte de S)
    - Adubação NPK (se cana)
    - Relações iônicas
   ↓
11. Botões: GRÁFICOS | SALVAR/ATUALIZAR
   ↓
12. Aba HISTÓRICO mostra análises salvas com ações (editar, PDF, excluir)
```

---

### 7.5 — Estrutura de Dados (DB ↔ Model ↔ Service)

| Campo DB | Tipo DB | Campo Model | Tipo Dart | No Service | Na UI |
|---|---|---|---|---|---|
| id | UUID | id | String | ✅ | auto |
| propriedade_id | UUID | propriedadeId | String | ✅ | auto |
| talhao_id | UUID? | talhaoId | String? | ✅ | ✅ dropdown |
| laboratorio | TEXT | laboratorio | String? | ✅ | ✅ texto |
| numero_amostra | TEXT | numeroAmostra | String? | ✅ | ✅ texto |
| data_coleta | DATE | dataColeta | DateTime? | ✅ | ✅ datePicker |
| data_resultado | DATE | dataResultado | DateTime? | ✅ | ✅ datePicker |
| profundidade_cm | INTEGER | profundidadeCm | int? | ✅ | ✅ chips |
| ph | NUMERIC(4,2) | ph | double? | ✅ | ✅ |
| materia_organica | NUMERIC(6,2) | materiaOrganica | double? | ✅ | ✅ |
| fosforo | NUMERIC(8,2) | fosforo | double? | ✅ | ✅ |
| potassio | NUMERIC(6,2) | potassio | double? | ✅ | ✅ |
| calcio | NUMERIC(6,2) | calcio | double? | ✅ | ✅ |
| magnesio | NUMERIC(6,2) | magnesio | double? | ✅ | ✅ |
| enxofre | NUMERIC(6,2) | enxofre | double? | ✅ | ✅ |
| acidez_potencial | NUMERIC(6,2) | acidezPotencial | double? | ✅ | ✅ |
| aluminio | NUMERIC(6,2) | aluminio | double? | ✅ | ✅ |
| somas_bases | NUMERIC(8,2) | somasBases | double? | ✅ | calculado |
| ctc | NUMERIC(8,2) | ctc | double? | ✅ | calculado |
| saturacao_bases | NUMERIC(5,2) | saturacaoBases | double? | ✅ | calculado |
| boro | NUMERIC(6,3) | boro | double? | ✅ | ✅ |
| cobre | NUMERIC(6,3) | cobre | double? | ✅ | ✅ |
| ferro | NUMERIC(8,2) | ferro | double? | ✅ | ✅ |
| manganes | NUMERIC(6,3) | manganes | double? | ✅ | ✅ |
| zinco | NUMERIC(6,3) | zinco | double? | ✅ | ✅ |
| argila | NUMERIC(6,1) | argila | double? | ✅ | ✅ |
| silte | NUMERIC(6,1) | silte | double? | ✅ | ❌ sem UI |
| areia | NUMERIC(6,1) | areia | double? | ✅ | ❌ sem UI |
| observacoes | TEXT | observacoes | String? | ✅ | ✅ |
| cultura | TEXT | cultura | String? | ✅ | ✅ chips |
| prnt | NUMERIC(5,1) | prnt | double? | ✅ | ✅ |
| produtividade_esperada | NUMERIC(8,1) | produtividadeEsperada | double? | ✅ | ✅ |
| criado_em | TIMESTAMPTZ | criadoEm | DateTime? | ✅ select | auto |
| atualizado_em | TIMESTAMPTZ | atualizadoEm | DateTime? | ✅ select | auto |

**Conclusão:** Model, Service e DB estão 100% sincronizados. Silte/areia existem no DB mas sem campos na UI (decisão de design — classe textural B-100 usa apenas argila).

---

### 7.6 — Melhorias Futuras (Não bloqueantes)

| # | Melhoria | Prioridade | Impacto |
|---|---|---|---|
| 1 | Campos UI para silte e areia (complementar) | 🟢 Baixa | Dados mais completos |
| 2 | Validação de faixas de valores (pH 3-9, K 0-20, etc.) | 🟡 Média | Previne dados absurdos |
| 3 | PDF com semáforos coloridos na interpretação | 🟡 Média | PDF mais informativo |
| 4 | Comparação temporal (última vs anterior) com ΔV | 🟡 Média | Valor analítico |
| 5 | Triângulo textural interativo (argila+silte+areia) | 🟢 Baixa | Visual educativo |
| 6 | Exportar resultado como imagem/compartilhar | 🟢 Baixa | UX |
| 7 | Recomendações de produto comercial (calcário, gesso) | 🟡 Média | Prático para produtor |
| 8 | Mapa de variabilidade (análises por talhão) | 🟠 Alta | Agricultura de precisão |

---

**Próximo Passo:** Confirmar com o usuário a ordem de prioridade e começar com **Login**.
