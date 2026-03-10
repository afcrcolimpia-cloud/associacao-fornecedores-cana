# ?? Relatórios de Pragas - AFCRC

## ? Implementação Completa

### Alterações Realizadas

#### 1. **Renomeação do Menu** 
- **Antes:** "GERAR FORMULÁRIOS PDF"
- **Depois:** "GERAR RELATÓRIOS DE PRAGAS"
- **Local:** Botão no canto superior direito da tela de Anexos da Propriedade

#### 2. **Renomeação da Tela Principal**
- **Antes:** "Formulários PDF - AFCRC"
- **Depois:** "Relatórios de Pragas - AFCRC"

#### 3. **Nova Interface de Seleção**
A tela agora exibe 3 cards com:
- **Ícone do inseto** (Besouro, Lagarta, Cigarrinha)
- **Título do Relatório** (Sphenophorus, Broca, Broca+Cigarrinha)
- **Descrição** resumida
- **Cores distintas** para cada tipo
- **Botão voltar** para retornar - seleção

#### 4. **Relatório 1: Sphenophorus (Cupim-de-raiz) ??**

**Estrutura:**
```
┌─────────────────────────────────────┐
│ Título: SPHENOPHORUS                │
├─────────────────────────────────────┤
│ Identificação                       │
│ - F.A. (Ficha Acompanhamento) *     │
│ - Fornecedor                        │
│ - ID (Número ID)                    │
│ - Propriedade                       │
│ - Data (dd/mm/aaaa)                 │
│ - Técnico(s)                        │
├─────────────────────────────────────┤
│ Tabela de Avaliação (16 linhas)     │
│ Colunas: TALHÃO | PONTOS | LARVA    │
│          PUPA | ADULTO | TOCOS      │
│          ATACADOS | TOCOS SADIOS    │
├─────────────────────────────────────┤
│ Observação (caixa de texto)         │
├─────────────────────────────────────┤
│ [Gerar PDF]                         │
└─────────────────────────────────────┘
```

#### 5. **Relatório 2: Broca - Índice de Infestação ??**

**Estrutura:**
```
┌─────────────────────────────────────┐
│ Título: ÍNDICE DE INTENSIDADE DE    │
│         INFESTAÇÃO - BROCA          │
├─────────────────────────────────────┤
│ Identificação                       │
│ - Nome | Data                       │
│ - Propriedade                       │
│ - Variedade (ex: CV-7870)           │
│ - F.A. | Nº de Corte (ex: 3º)       │
│ - Talhão | Nº Avaliação             │
│ - Bloco | Técnico(s)                │
│ - Avaliação Final                   │
│ - Avaliação Parcial                 │
├─────────────────────────────────────┤
│ Análise por Cana (20 linhas)        │
│ Colunas: CANA | ENTRENÓS TOTAIS     │
│          ENTRENÓS BROCADOS          │
├─────────────────────────────────────┤
│ Nível de Infestação (Calculado)     │
│ NÍVEL = (total brocados / total)    │
│ Legenda: ACEITÁVEL | BAIXO | MÉDIO  │
│          ALTO | INACEITÁVEL         │
├─────────────────────────────────────┤
│ [Gerar PDF]                         │
└─────────────────────────────────────┘
```

**Cálculo Automático:**
```dart
NÍVEL = (total_brocados / total_entrenoses) - 100
```

#### 6. **Relatório 3: Broca + Cigarrinha ??**

**Estrutura:**
```
┌─────────────────────────────────────┐
│ Título: RELATÓRIO DE BROCA E        │
│         CIGARRINHA                  │
├─────────────────────────────────────┤
│ Identificação                       │
│ - Data (dd/mm/aaaa) | F.A.          │
│ - Nome do Fornecedor                │
│ - Propriedade                       │
│ - Técnico(s)                        │
│ - Avaliações                        │
├─────────────────────────────────────┤
│ Tabela Combinada (12 pontos)        │
│ GRUPO CIGARRINHA (4 colunas):       │
│ - Talhão | Pontos | Espuma | Ninfas │
│ - n/m (ninfas por metro)            │
│ GRUPO BROCA (5 colunas):            │
│ - Pontos | Entrenós brocados        │
│ - Dano | Larva fora | Larva dentro  │
│ OBSERVAÇÕES: Coluna com ID do forn. │
├─────────────────────────────────────┤
│ NÍVEL DE CONTROLE                   │
│ "2 NINFAS POR METRO (n/m)"          │
├─────────────────────────────────────┤
│ [Gerar PDF]                         │
└─────────────────────────────────────┘
```

### ?? Arquivos Modificados

1. **lib/screens/anexos_screen.dart**
   - Alterado: Label do botão de "Gerar Formulários PDF" para "Gerar Relatórios de Pragas"
   - Alterado: Tooltip descritivo

2. **lib/screens/formularios_pdf_screen.dart**
   - Renomeado: Classe principal para refletir novo propósito
   - Adicionado: Interface de seleção com cards visuais
   - Refatorado: Todas 3 classes de formulário
   - Adicionado: Cálculo automático de nível de infestação (Broca)
   - Adicionado: Legenda de cores para níveis
   - Adicionado: Tabelas com 16, 20 e 12 linhas respectivamente
   - Adicionado: Validações de campos obrigatórios
   - Adicionado: Estilização com cores temáticas

### ?? Cores Utilizadas

- **Sphenophorus:** Marrom (`Colors.brown`)
- **Broca:** Laranja (`Colors.orange[700]`)
- **Broca+Cigarrinha:** Verde (`Colors.green[700]`)

### ?? Ícones Material Design

- Sphenophorus: `Icons.pest_control`
- Broca: `Icons.bug_report`
- Broca+Cigarrinha: `Icons.grass`

### ? Recursos Adicionados

1. **Cálculo Automático de Infestação**
   - Percentual calculado em tempo real
   - Cores dinâmicas baseadas no nível
   - Legenda interativa

2. **Tabelas Responsivas**
   - Scroll horizontal para largas datasets
   - Campos numéricos centralizados
   - Validação de entrada de dados

3. **Validação de Campos**
   - F.A. obrigatório em todos os relatórios
   - Mensagens de erro claras
   - Prevenção de PDF vazio

4. **Interface Melhorada**
   - Cards com gradientes
   - Ícones visuais dos insetos
   - Botão voltar rápido
   - Organização em seções

### ?? Próximos Passos (Integração com Banco de Dados)

Para integração completa:

1. **Buscar dados do Supabase** ao abrir a tela
   - Nome do fornecedor
   - Dados da propriedade
   - Talhões e variedades
   - Área total

2. **Auto-preenchimento de campos**
   ```dart
   final propriedade = await _propertiedException.getById(widget.propriedadeId);
   _propriedadeCtrl.text = propriedade.nomePropriedade;
   _fornecedorCtrl.text = propriedade.fornecedorNome;
   ```

3. **Salvar relatórios** na tabela `relatorios_pragas`
   ```sql
   CREATE TABLE relatorios_pragas (
     id UUID PRIMARY KEY,
     propriedade_id UUID REFERENCES propriedades(id),
     tipo_relatorio VARCHAR(50),
     dados_relatorio JSONB,
     criado_em TIMESTAMP DEFAULT now(),
     atualizado_em TIMESTAMP DEFAULT now()
   );
   ```

### ? Checklist de Validação

- [x] Nome do botão alterado para "GERAR RELATÓRIOS DE PRAGAS"
- [x] Título da tela alterado para "Relatórios de Pragas - AFCRC"
