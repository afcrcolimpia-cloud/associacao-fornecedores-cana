# ?? RELATÓRIOS DE PRAGAS - MAPA VISUAL DA IMPLEMENTAÇÃO

## ?? Localização no App

```
Home Screen
  ↓
Propriedade Detail
  ↓
Anexos da Propriedade
  ↓
┌────────────────────────────────────────────────────────────┐
│ Anexos da Propriedade                                      │
│ ────────────────────────────────────────────────────────── │
│ [Botão] [Botão] ... [??]  NOVO!                            │
│                                                            │
│ "Gerar Relatórios de Pragas"                               │
└────────────────────────────────────────────────────────────┘
```

## ?? Fluxo de Navegação

```
┌────────────────────────────────────────────────────────────┐
│ Tela: Relatórios de Pragas - AFCRC                         │
├────────────────────────────────────────────────────────────┤
│ ┌──────────────────────┐  ┌──────────────────────┐         │
│ │ ?? SPHENOPHORUS      │  │ ?? BROCA             │         │
│ │ Cupim-de-raiz        │  │ Índice de Infest.    │         │
│ │ [Ícone Besouro]      │  │ [Ícone Lagarta]      │         │
│ └──────────────────────┘  └──────────────────────┘         │
│                                                            │
│ ┌───────────────────────────────┐                          │
│ │ ?? BROCA + CIGARRINHA          │                          │
│ │ Avaliação Combinada            │                          │
│ │ [Ícone Cigarrinha]             │                          │
│ └───────────────────────────────┘                          │
│                                                            │
│ [Voltar]                                                   │
└────────────────────────────────────────────────────────────┘
```

## ?? Estrutura de cada Formulário

### 1?? SPHENOPHORUS (Cupim-de-raiz)

```
┌────────────────────────────────────────────────────────────┐
│ RELATÓRIO DE SPHENOPHORUS (Cupim-de-raiz)        [Voltar]   │
├────────────────────────────────────────────────────────────┤
│ Identificação                                               │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ ? F.A. (Ficha Acompanhamento) * [______________]       │ │
│ │ ? Fornecedor [______________]                          │ │
│ │ ? ID (Número ID) [______________]                      │ │
│ │ ? Propriedade [______________]                         │ │
│ │ ? Data (dd/mm/aaaa) [______________]                   │ │
│ │ ? Técnico(s) [______________]                          │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ Dados de Avaliação (Até 16 linhas)                          │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ TALHÃO | PONTOS | LARVA | PUPA | ADULTO | TOCOS A/S     │ │
│ │ [__]   | [__]   | [__]  | [__] | [__]   | [__]          │ │
│ │ [__]   | [__]   | [__]  | [__] | [__]   | [__]          │ │
│ │ ... (até 16 linhas)                                     │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ Observação                                                  │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ [________________________________]                     │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ [GERAR PDF]                                                 │
└────────────────────────────────────────────────────────────┘
```

### 2?? BROCA - Índice de Intensidade de Infestação

```
┌────────────────────────────────────────────────────────────┐
│ ÍNDICE DE INTENSIDADE DE INFESTAÇÃO - BROCA      [Voltar]   │
├────────────────────────────────────────────────────────────┤
│ Identificação da Avaliação                                  │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ ? Nome [_____________] Data [_______]                  │ │
│ │ ? Propriedade [_____________]                          │ │
│ │ ? Variedade (ex: CV-7870) [_____________]              │ │
│ │ ? F.A. [_______] Nº de Corte (ex: 3º) [______]         │ │
│ │ ? Talhão [_______] Nº Avaliação [_______]              │ │
│ │ ? Bloco [_______] Técnico(s) [_______]                 │ │
│ │ ? Avaliação Final    ? Avaliação Parcial               │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ Análise por Cana (Até 20 linhas)                            │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ CANA | ENTRENÓS TOTAIS | ENTRENÓS BROCADOS             │ │
│ │ [1]  | [___________]   | [_______________]            │ │
│ │ [2]  | [___________]   | [_______________]            │ │
│ │ ... (até 20 linhas)                                     │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ NÍVEL DE INFESTAÇÃO CALCULADO                               │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ NÍVEL: 2.45%  [BAIXO]                                   │ │
│ │ Legenda: ACEITÁVEL(=1,0%) | BAIXO(1,1-3%) | MÉDIO(3,1-6%)│ │
│ │ ALTO(6,1-9%) | INACEITÁVEL(>9%)                         │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ [GERAR PDF]                                                 │
└────────────────────────────────────────────────────────────┘
```

### 3?? BROCA + CIGARRINHA

```
┌────────────────────────────────────────────────────────────┐
│ RELATÓRIO DE BROCA E CIGARRINHA                  [Voltar]   │
├────────────────────────────────────────────────────────────┤
│ Identificação da Avaliação                                  │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ ? Data [________] F.A. [________]                      │ │
│ │ ? Nome do Fornecedor [_____________]                   │ │
│ │ ? Propriedade [_____________]                          │ │
│ │ ? Técnico(s) [_____________]                           │ │
│ │ ? Avaliações [_____________]                           │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ Avaliação de Broca e Cigarrinha (Até 12 pontos)             │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ Talhão | CIGARRINHA (4 cols) | BROCA (5 cols) | OBS     │ │
│ │       | Pts | Espuma | Ninfas n/m | Pts | Entrenós | .. │ │
│ │ [__]  | [_] | [___]  | [__]       | [__] | [_] | [__]   │ │
│ │ ... (até 12 linhas)                                     │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ Nível de Controle                                           │
│ ┌────────────────────────────────────────────────────────┐ │
│ │ NÍVEL DE CONTROLE - 2 NINFAS POR METRO (n/m)            │ │
│ └────────────────────────────────────────────────────────┘ │
│                                                            │
│ [GERAR PDF]                                                 │
└────────────────────────────────────────────────────────────┘
```

## ?? Cores Temáticas

```
┌────────────────────────────────────────────────────────────┐
│ SPHENOPHORUS                                                │
│ Cor: MARROM  (Colors.brown)                                 │
│ Ícone: Besouro                                              │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ BROCA                                                       │
│ Cor: LARANJA (Colors.orange[700])                           │
│ Ícone: Lagarta                                              │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ BROCA+CIGARRINHA                                            │
│ Cor: VERDE  (Colors.green[700])                             │
│ Ícone: Cigarrinha                                           │
└────────────────────────────────────────────────────────────┘
```

## ?? Informações Técnicas

### Validações Implementadas
- ? F.A. obrigatório em todos os formulários
- ? Prevenção de PDF vazio
- ? Mensagens de erro claras
- ? Campos numéricos validados

### Cálculos Automáticos
- ? Nível de Infestação (Broca)
  - Fórmula: `(brocados / totais) - 100`
  - Atualiza em tempo real
  - Cor dinâmica baseada em nível

### Elementos UI
- ? Cards com gradientes
- ? Ícones Material Design
- ? Tabelas responsivas (scroll horizontal)
- ? Botão voltar rápido
- ? Organização em seções cardboard

## ?? Responsividade

```
┌────────────────────────────────────────────────────────────┐
│ Desktop (Large)                                             │
│ 1200px+  | Todas as colunas visíveis                        │
│         | Scroll horizontal para tabelas                    │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ Tablet (Medium)                                             │
│ 600px-1200px | Layouts adaptados                            │
│              | Scroll horizontal obrigatório                │
└────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────┐
│ Mobile (Small)                                              │
│ < 600px | Single column                                     │
│        | Scroll vertical e horizontal                       │
└────────────────────────────────────────────────────────────┘
```

## ?? Próximos Passos (Opcional)

### Integração com Banco de Dados
1. Auto-preenchimento de formulários
2. Salvar relatórios em tabela `relatorios_pragas`
3. Histórico de relatórios
4. Exportar para Excel/CSV

### Melhorias Futuras
1. Gráficos de evolução de pragas
2. Comparação entre talhões
3. Alertas automáticos de infestação
4. Integração com WhatsApp para compartilhamento

---

**Status:** ? IMPLEMENTADO E PRONTO PARA USO
**Data:** 20 de Fevereiro de 2026
**Desenvolvido para:** AFCRC (Associação dos Fornecedores de Cana)
