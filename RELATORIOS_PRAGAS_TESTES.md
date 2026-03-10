# ?? GUIA DE TESTES - RELATÓRIOS DE PRAGAS

## ? Checklist de Validação Funcional

### 1. Navegação até o Menu

- [ ] Abra uma propriedade
- [ ] Clique em "Anexos"
- [ ] Verifique se o botão no canto superior direito agora diz **"GERAR RELATÓRIOS DE PRAGAS"** (em vez de "GERAR FORMULÁRIOS PDF")
- [ ] Clique no botão

### 2. Tela de Seleção

**Esperado:**
- [ ] Título da tela: "Relatórios de Pragas - AFCRC"
- [ ] 3 cards visóveis com:
  - [ ] Card 1: Ícone besouro (??), título "Sphenophorus", descrição "Cupim-de-raiz", cor marrom
  - [ ] Card 2: Ícone lagarta (??), título "Broca", descrição "Índice de Infestação", cor laranja
  - [ ] Card 3: Ícone cigarrinha (??), título "Broca+Cigarrinha", descrição "Avaliação combinada", cor verde
- [ ] Cada card - clicável
- [ ] Botão voltar (?) funciona

### 3. Formulário SPHENOPHORUS

**Ao clicar no card Sphenophorus:**

- [ ] Título muda para "Relatório de Sphenophorus (Cupim-de-raiz)"
- [ ] Seção de Identificação visóvel com campos:
  - [ ] F.A. (obrigatério) *
  - [ ] Fornecedor
  - [ ] ID (Número ID)
  - [ ] Propriedade
  - [ ] Data (dd/mm/aaaa)
  - [ ] Técnico(s)

- [ ] Seção de Dados de Avaliação com tabela:
  - [ ] 7 colunas: TALHÃO, PONTOS, LARVA, PUPA, ADULTO, TOCOS ATACADOS, TOCOS SADIOS
  - [ ] 16 linhas vazias para preenchimento

- [ ] Seção de Observação com caixa de texto

- [ ] Botão "Gerar PDF" visóvel

**Teste de Validação:**
- [ ] Tente gerar PDF sem preencher F.A. ? Deve exibir "F.A. - obrigatério"
- [ ] Preencha F.A. e tente gerar PDF sem talhões ? Deve exibir "Preencha pelo menos um talhão"

### 4. Formulário BROCA

**Ao clicar no card Broca:**

- [ ] Título muda para "Índice de Intensidade de Infestação - Broca"
- [ ] Seção de Identificação com fields:
  - [ ] Nome | Data
  - [ ] Propriedade
  - [ ] Variedade (ex: CV-7870)
  - [ ] F.A. | Nº de Corte (ex: 3º)
  - [ ] Talhão | Nº Avaliação
  - [ ] Bloco | Técnico(s)
  - [ ] Checkbox: Avaliação Final
  - [ ] Checkbox: Avaliação Parcial

- [ ] Seção de Análise por Cana:
  - [ ] 3 colunas: CANA, ENTRENÓS TOTAIS, ENTRENÓS BROCADOS
  - [ ] 20 linhas para entrada

- [ ] Seção de Nível de Infestação Calculado:
  - [ ] Texto mostrando percentual
  - [ ] Cor dinâmica baseada no nível
  - [ ] Legenda com 5 coloridos:
    - [ ] ?? ACEITÁVEL (= 1,0%)
    - [ ] ?? BAIXO (1,1% até 3%)
    - [ ] ?? MÉDIO (3,1% até 6%)
    - [ ] ?? ALTO (6,1% até 9%)
    - [ ] ? INACEITÁVEL (> 9%)

- [ ] Botão "Gerar PDF"

**Teste de Cálculo:**
- [ ] Preencha:
  - [ ] ENTRENÓS TOTAIS: 100
  - [ ] ENTRENÓS BROCADOS: 1.5 (1.5%)
  - [ ] Deve exibir "NÍVEL DE INFESTAÇÃO: 1.50%" em cor ?? AMARELO
- [ ] Preencha:
  - [ ] ENTRENÓS TOTAIS: 100
  - [ ] ENTRENÓS BROCADOS: 7 (7%)
  - [ ] Deve exibir "NÍVEL DE INFESTAÇÃO: 7.00%" em cor ?? VERMELHO

### 5. Formulário BROCA + CIGARRINHA

**Ao clicar no card Broca+Cigarrinha:**

- [ ] Título muda para "Relatório de Broca e Cigarrinha"
- [ ] Seção de Identificação:
  - [ ] Data (dd/mm/aaaa) | F.A.
  - [ ] Nome do Fornecedor
  - [ ] Propriedade
  - [ ] Técnico(s)
  - [ ] Avaliações

- [ ] Seção de Avaliação (Tabela combinada):
  - [ ] Deve ser scrollável horizontalmente (especialmente em mobile)
  - [ ] GRUPO CIGARRINHA (4 colunas):
    - [ ] Talhão | Pontos | Espuma | Ninfa | n/m
  - [ ] GRUPO BROCA (5 colunas):
    - [ ] Pontos | Entrenós brocados | Dano | L. Fora | L. Dentro
  - [ ] OBSERVAÇÕES (ID do fornecedor)
  - [ ] 12 linhas

- [ ] Seção "Nível de Controle":
  - [ ] Caixa destacada em laranja
  - [ ] Texto: "NÍVEL DE CONTROLE - 2 NINFAS POR METRO (n/m)"

- [ ] Botão "Gerar PDF"

### 6. Geração de PDF

**Para cada relatério:**

- [ ] Preencha todos os campos obrigatérios
- [ ] Clique em "Gerar PDF"
- [ ] Deve abrir visualizador de PDF
- [ ] PDF deve conter:
  - [ ] Logo AFCRC (se implementado)
  - [ ] Todos os dados preenchidos
  - [ ] Tabelas com dados
  - [ ] Rodapé com "ASSOCIAÇÃO DOS FORNECEDORES DE CANA DA REGIÃO DE CATANDUVA"

### 7. Navegação e Voltar

- [ ] Clique no botão ? para voltar - seleção
- [ ] Deve retornar para a tela com 3 cards
- [ ] Clique em cada card novamente ? Deve alternar entre formulários
- [ ] Use o botão voltar do navegador do app ? Deve sair da tela de relatérios

## ?? Testes de Responsividade

### Desktop (1200px+)
- [ ] Todos os fields visóveis
- [ ] Tabelas com scroll horizontal
- [ ] Layout limpo

### Tablet (600px-1200px)
- [ ] Cards em 2 colunas (se houver espaço)
- [ ] Tabelas com scroll obrigatério
- [ ] Inputs normais

### Mobile (<600px)
- [ ] Todos elementos em uma coluna
- [ ] Cards empilhados
- [ ] Tabelas com scroll horizontal certamente
- [ ] Botões tocáveis

## ?? Testes de Validação

**Teste 1: Campo Obrigatério**
```
1. Abra qualquer formulário
2. Deixe F.A. vazio
3. Clique "Gerar PDF"
4. ? Esperado: Exibir "F.A. - obrigatério"
```

**Teste 2: Dados Vazios**
```
1. Abra SPHENOPHORUS
2. Nºo preencha nenhum talhão
3. Clique "Gerar PDF"
4. ? Esperado: Exibir "Preencha pelo menos um talhão"
```

**Teste 3: Cálculo de Infestação**
```
1. Abra BROCA
2. Linha 1: total=100, brocados=2
3. Veja o cálculo: NÍVEL DE INFESTAÇÃO: 2.00%
4. ? Esperado: Cor ?? BAIXO
```

**Teste 4: Navegação entre Abas**
```
1. Selecione SPHENOPHORUS
2. Clique voltar
3. Selecione BROCA
4. Clique voltar
5. Selecione BROCA+CIGARRINHA
6. ? Esperado: Funcionar perfeitamente
```

## ?? Testes de Dados

**Teste com dados reais:**
```
SPHENOPHORUS:
+- F.A.: FA-2026-001
+- Fornecedor: João Silva
+- ID: 12345
+- Propriedade: Fazenda Boa Vista
+- Data: 20/02/2026
+- Técnico: Carlos, Maria
+- Talhao 1: [?] Pontos: 5, Larva: 2, Pupa: 1, Adulto: 0, Tocos Atacados: 8, Tocos Sadios: 92

BROCA:
+- Nome: João Silva
+- Data: 20/02/2026
+- Propriedade: Fazenda Boa Vista
+- Variedade: RB867515
+- F.A.: FA-2026-002
+- Nº Corte: 3º
+- Talhão: 5
+- Nº Avaliação: 1
+- Bloco: A
+- Técnico: Carlos
+- Avaliação: ? Final
+- Linha 1: Cana=1, Total=45, Brocados=1 ? 2.22%

BROCA+CIGARRINHA:
+- Data: 20/02/2026
+- F.A.: FA-2026-003
+- Nome: João Silva
+- Propriedade: Fazenda Boa Vista
+- Técnico: Carlos, Maria
+- Linha 1: Talhão=5, Pts_Cig=3, Espuma=2, Ninfa=4, n/m=1.5, Pts_Broca=2, Entrenós=12, ...
```

## ? Checklist Final

- [ ] Menu alterado de "Formulários PDF" para "Relatórios de Pragas"
- [ ] Tela renomeada para "Relatórios de Pragas - AFCRC"
- [ ] 3 cards visóveis com Ícones e cores corretas
- [ ] Navegação funciona perfeitamente
- [ ] Validações de campos obrigatérios funcionam
- [ ] Cálculo de infestação atualiza em tempo real
- [ ] PDFs gerados corretamente
- [ ] Responsóvel em mobile, tablet e desktop
- [ ] Sem erros de compilação
- [ ] UI/UX consistente e intuitiva

## ?? Como Executar os Testes

1. **Inicie o app:**
```bash
cd c:\Users\rafael.vernici\associacaofornecedorescana
flutter run
```

2. **Na aba Anexos:**
   - Procure pelo botão "GERAR RELATÓRIOS DE PRAGAS" no canto superior direito

3. **Execute cada teste** conforme documentado acima

4. **Reporte qualquer problema** ou inconsistência

---

**Documento de Testes:** Relatórios de Pragas - AFCRC  
**Data:** 20 de Fevereiro de 2026  
**Versão:** 1.0  
**Status:** ? Pronto para QA
