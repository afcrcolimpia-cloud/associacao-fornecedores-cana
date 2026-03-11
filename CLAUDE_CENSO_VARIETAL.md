# CLAUDE.md — censo_varietal_app
# Sistema de Censo Varietal Agrícola · GESTÃO DE PROPRIEDADES E VARIEDADES

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
| `/analisar` | Roda verificação de erros e corrige automaticamente |
| `/limpar` | Remove arquivos desnecessários (logs, temporários, etc.) |
| `/pendencias` | Lista e resolve as pendências do CLAUDE.md |
| `/testar` | Executa testes e reporta os resultados |
| `/status` | Mostra o que está modificado no projeto (git status resumido) |
| `/pdf-relatorios` | Implementa botões de Gerar PDF nas telas de Variedades, Propriedades e Proprietários |
| `/export-dados` | Exporta dados em Excel/CSV por proprietário ou propriedade |
| `/relatorio-completo` | Gera relatório consolidado de todas as variedades por propriedade em PDF |
| `/graficos` | Implementa gráficos de distribuição de variedades e área plantada |

---

## 🌾 Contexto do Projeto

- **App:** Sistema de Censo Varietal para gestão agrícola — rastreamento de variedades plantadas
- **Organização:** Propriedades Agrícolas / Fornecedores de Culturas
- **Stack:** React + JavaScript (ou Flutter Web se migrar) + Storage Local (ou Supabase)
- **Plataforma alvo:** Web (browser desktop — Chrome/Edge/Firefox)
- **Estado:** `useState` + `useContext` — padrão React funcional
- **Autenticação:** Opcional (Login simples ou sem autenticação)
- **PDF:** Bibliotecas `pdfkit` ou `html2pdf` para relatórios agrícolas

---

## 📁 Estrutura Real do Projeto

```
src/
├── components/
│   ├── HeaderPropriedade.jsx       # Cabeçalho com contexto da propriedade
│   ├── ProprietarioCard.jsx        # Card de exibição de proprietário
│   ├── PropriedadeCard.jsx         # Card de exibição de propriedade
│   ├── VariedadeTable.jsx          # Tabela de variedades plantadas
│   └── NavegacaoBreadcrumb.jsx     # Breadcrumb Proprietário > Propriedade > Variedades
├── pages/
│   ├── ProprietariosPage.jsx       # Lista de proprietários
│   ├── PropriedadesPage.jsx        # Lista de propriedades de um proprietário
│   ├── CensoVarietalPage.jsx       # Detalhes e census de variedades
│   ├── ProprietarioFormPage.jsx    # Form para adicionar proprietário
│   ├── PropriedadeFormPage.jsx     # Form para adicionar propriedade
│   └── VariedadeFormPage.jsx       # Form para adicionar variedade
├── services/
│   ├── proprietarioService.js      # CRUD proprietários
│   ├── propriedadeService.js       # CRUD propriedades
│   ├── variedadeService.js         # CRUD variedades
│   ├── authService.js              # Autenticação (opcional)
│   ├── exportService.js            # Exportação PDF/Excel
│   └── storageService.js           # Persistência de dados
├── models/
│   ├── Proprietario.js             # Model proprietário
│   ├── Propriedade.js              # Model propriedade
│   ├── Variedade.js                # Model variedade
│   └── ContextoPropriedade.js      # Agregador de contexto
├── constants/
│   ├── AppColors.js                # Paleta de cores
│   ├── AppFonts.js                 # Tipografia
│   └── Variedades.js               # Lista de variedades conhecidas
├── contexts/
│   ├── PropriedadeContext.jsx      # Context para compartilhar propriedade ativa
│   └── ProprietarioContext.jsx     # Context para compartilhar proprietário ativo
├── utils/
│   ├── formatters.js               # Formatação de dados (datas, números, áreas)
│   ├── validators.js               # Validação de campos
│   ├── pdfGenerators.js            # Geradores de PDF reutilizáveis
│   └── chartHelpers.js             # Helpers para gráficos
├── App.jsx                          # Componente raiz
├── index.css                        # Estilos globais
└── index.js                         # Entry point
```

---

## ⚙️ Regras de Código

### Arquitetura do projeto
- Padrão: **Page → Service → Storage/API** (direto, sem camada extra desnecessária)
- Estado: `useState` + `useContext` — padrão React moderno
- Não adicionar Redux ou MobX sem alinhamento prévio
- Cada entidade tem: `model` + `service` + `page(s)`
- Componentes menores em `components/`, páginas inteiras em `pages/`

### Nomenclatura
- Arquivos: `PascalCase.jsx` para componentes | `camelCase.js` para services
- Services: `[entidade]Service.js` → métodos: `buscar[Entidades]()`, `salvar[Entidade]()`, `deletar[Entidade]()`
- Sempre retornar objetos estruturados — nunca `Map` ou dados crus
- Páginas de formulário: `[Entidade]FormPage.jsx` | Listagens: `[Entidade]sPage.jsx` | Detalhes: `[Entidade]DetailPage.jsx`

### JavaScript/React
- Sempre validar dados de entrada (`validators.js`)
- `const` por padrão — `let` apenas quando houver reatribuição
- Props destruturadasem componentes: `function Card({ titulo, descricao })`
- Usar `useCallback` para funções em deps arrays
- Fechar listeners e timers no `useEffect` cleanup

---

## 💾 Armazenamento de Dados — Regras Obrigatórias

### Storage Local (Browser)
- Usar `localStorage` para persistência entre sessões
- Dados estruturados como JSON
- Sempre fazer parse/stringify com tratamento de erro
- Exemplo: `storageService.js`

```javascript
// lib/services/storageService.js
export const salvarProprietarios = (proprietarios) => {
  localStorage.setItem('proprietarios', JSON.stringify(proprietarios));
};

export const obterProprietarios = () => {
  const dados = localStorage.getItem('proprietarios');
  return dados ? JSON.parse(dados) : [];
};
```

### Validação de Dados
- Campo obrigatório: `validators.validarRequerido(valor)`
- Números positivos: `validators.validarNumero(valor, min, max)`
- Campos de data: `validators.validarAno(ano, min, max)`
- Sempre validar antes de salvar

### Backup de Dados
- Função de export automática
- Opção de download em JSON para backup manual
- Importar de JSON para restaurar

---

## 📊 Domínio Agrícola — Relacionamentos

```
Proprietario (1:N)
  └── Propriedade (1:N)
        └── Variedade (N:1)

Contexto Propriedade = Proprietario + Propriedade (agregador para facilitar exibição)

Dados Calculados:
  ├── Idade da Variedade = Ano Atual - Ano Plantio
  ├── Percentual Ocupação = (Área Variedade / Área Total) × 100
  ├── Área Total Plantada = Σ Áreas das Variedades
  └── Ocupação Total = (Área Total Plantada / Área Propriedade) × 100
```

---

## 📄 PDF e Relatórios

### Padrão Obrigatório de Geração

Todos os PDFs DEVEM incluir:
1. **Cabeçalho Padrão** — Organização, Proprietário, Propriedade, FA/Número
2. **Data e Hora** de geração
3. **Tabela** com dados completos
4. **Totalizações** e cálculos
5. **Rodapé** com assinatura/observações

### Tipos de Relatórios Disponíveis

| Relatório | Acionado em | Dados inclusos |
|---|---|---|
| **Censo Varietal** | CensoVarietalPage | Tabela completa de variedades, áreas, ocupação |
| **Consolidado Propriedade** | PropriedadesPage | Resumo de todas as variedades de uma propriedade |
| **Consolidado Proprietário** | ProprietariosPage | Resumo de todas as propriedades e variedades |
| **Comparativo Variedades** | CensoVarietalPage (filtro) | Análise entre variedades: idade, área, ocupação |

### Implementação de PDF

```javascript
// lib/utils/pdfGenerators.js
export const gerarPDFVariedades = (propriedade, variedades, proprietario) => {
  const doc = new PDFDocument();
  
  // Cabeçalho padrão
  doc.fontSize(14).text('CENSO VARIETAL', 100, 50);
  doc.fontSize(10).text(`Proprietário: ${proprietario.nome}`);
  doc.text(`Propriedade: ${propriedade.nome}`);
  doc.text(`Município: ${propriedade.municipio}`);
  doc.text(`Área Total: ${propriedade.areaTotalHa} ha`);
  
  // Tabela de variedades
  const tableData = variedades.map(v => [
    v.nome,
    v.anoplantio,
    v.areaHa,
    ((v.areaHa / propriedade.areaTotalHa) * 100).toFixed(1) + '%'
  ]);
  
  doc.table(tableData, {
    headers: ['Variedade', 'Ano Plantio', 'Área (ha)', '% Propriedade'],
    ...tabelaOpcoes
  });
  
  doc.pipe(fs.createWriteStream(`censo_${propriedade.nome}.pdf`));
  doc.end();
};
```

---

## 🏗️ Fluxo de Navegação Padrão

```
LOGIN (se implementado)
  ↓
HOME / DASHBOARD
  ↓
PROPRIETÁRIOS PAGE (lista todos)
  ↓ (clica em um)
PROPRIEDADES PAGE (lista propriedades do proprietário)
  ↓ (clica em uma)
CENSO VARIETAL PAGE (detalhe completo com variedades)
  ├── Formulário Inline para adicionar variedade
  ├── Tabela com todas as variedades
  ├── Botão "Gerar PDF"
  ├── Botão "Voltar"
  └── Métricas calculadas (total área, ocupação, etc)
```

---

## 📈 Entidades Principais

### Proprietario
```javascript
class Proprietario {
  constructor(id, nome) {
    this.id = id;
    this.nome = nome; // String: nome completo
  }
}
```

### Propriedade
```javascript
class Propriedade {
  constructor(id, proprietarioId, nome, municipio, areaTotalHa) {
    this.id = id;
    this.proprietarioId = proprietarioId;
    this.nome = nome;              // String: nome da propriedade
    this.municipio = municipio;    // String: "Município - Estado"
    this.areaTotalHa = areaTotalHa; // Number: área em hectares
  }
}
```

### Variedade
```javascript
class Variedade {
  constructor(id, propriedadeId, nome, anoplantio, areaHa) {
    this.id = id;
    this.propriedadeId = propriedadeId;
    this.nome = nome;           // String: código/nome (ex: IACSP94-2094)
    this.anoplantio = anoplantio; // Number: ano (ex: 2020)
    this.areaHa = areaHa;       // Number: área em ha
  }

  get idade() {
    return new Date().getFullYear() - this.anoplantio;
  }

  getPercentualOcupacao(areaTotalPropriedade) {
    return (this.areaHa / areaTotalPropriedade) * 100;
  }
}
```

### ContextoPropriedade
```javascript
class ContextoPropriedade {
  constructor(proprietario, propriedade) {
    this.proprietario = proprietario;
    this.propriedade = propriedade;
  }

  get nomeProprietario() { return this.proprietario.nome; }
  get nomePropriedade() { return this.propriedade.nome; }
  get municipio() { return this.propriedade.municipio; }
  get areaHa() { return `${this.propriedade.areaTotalHa} ha`; }
}
```

---

## 🎨 Design System

### Paleta de Cores
```javascript
// constants/AppColors.js
const AppColors = {
  primary: '#2E7D32',       // Verde AFCRC
  secondary: '#43A047',     // Verde claro
  accent: '#1B5E20',        // Verde escuro
  warning: '#FBC02D',       // Amarelo
  danger: '#D32F2F',        // Vermelho
  success: '#388E3C',       // Verde sucesso
  neutral: '#FAFAFA',       // Cinza claro (fundo)
  text: '#212121',          // Preto texto
  textLight: '#757575',     // Cinza texto
  border: '#E0E0E0',        // Cinza borda
};
```

### Tipografia
```javascript
// constants/AppFonts.js
const AppFonts = {
  display: "'Inter', sans-serif",  // Títulos grandes
  body: "'Roboto', sans-serif",    // Texto corpo
  mono: "'Courier New', monospace", // Dados técnicos
};

const FontSizes = {
  h1: '32px',
  h2: '24px',
  h3: '20px',
  body: '14px',
  small: '12px',
};
```

### Componentes Padrão
- Card com sombra e hover
- Button com estados (normal, hover, active, disabled)
- Input com validação em tempo real
- Table com alternância de cores
- Modal para confirmações

---

## ✅ Checklist de Implementação

### Fase 1: Estrutura Base
- [ ] Criar estrutura de pastas conforme `📁 Estrutura Real do Projeto`
- [ ] Implementar `Proprietario`, `Propriedade`, `Variedade` models
- [ ] Criar `ProprietarioService`, `PropriedadeService`, `VariedadeService`
- [ ] Implementar `storageService` com `localStorage`
- [ ] Criar `validators.js` e `formatters.js`

### Fase 2: Componentes
- [ ] Criar `ProprietarioCard` com resumo de dados
- [ ] Criar `PropriedadeCard` com resumo de dados
- [ ] Criar `VariedadeTable` para listar variedades
- [ ] Criar `HeaderPropriedade` para exibir contexto
- [ ] Criar `NavegacaoBreadcrumb` para navegar entre níveis

### Fase 3: Páginas
- [ ] ProprietariosPage (listagem com CRUD)
- [ ] PropriedadesPage (listagem com CRUD)
- [ ] CensoVarietalPage (detalhes e CRUD de variedades)
- [ ] Formulários de entrada (Proprietário, Propriedade, Variedade)

### Fase 4: Funcionalidades Avançadas
- [ ] Gerar PDF de Censo Varietal
- [ ] Exportar dados em JSON/CSV
- [ ] Gráficos de distribuição
- [ ] Filtros e buscas
- [ ] Contextos React (`PropriedadeContext`, `ProprietarioContext`)

### Fase 5: Polimento
- [ ] Testes unitários dos services
- [ ] Validação de todos os campos
- [ ] Responsividade em mobile
- [ ] Acessibilidade (ARIA labels, contrast)
- [ ] Documentação de componentes

---

## 🐛 Pendências Conhecidas

```
PADRÃO: [STATUS] TAREFA
  └─ Descrição e contexto
  └─ Bloqueado por: [se aplicável]
  
[TODO] Implementar autenticação opcional
  └─ Login simples com localStorage
  └─ Token de sessão (30 dias)
  
[TODO] Adicionar gráficos de variedades
  └─ Gráfico de pizza: distribuição de área por variedade
  └─ Gráfico de barras: variedades por idade
  └─ Usar biblioteca: Chart.js ou Recharts
  
[TODO] Exportação em Excel
  └─ Usar SheetJS (xlsx)
  └─ Arquivo por propriedade ou consolidado
  
[TODO] Upload de anexos
  └─ Imagens, documentos, planilhas
  └─ Vincular a propriedade ou variedade
  
[TODO] Busca e filtros avançados
  └─ Filtrar por município
  └─ Filtrar por ano de plantio
  └─ Buscar por nome de variedade
```

---

## 📝 Como Atualizar Este Documento

1. Quando criar novo serviço: adicione na seção "📁 Estrutura"
2. Quando alterar arquitetura: atualize "📁 Estrutura Real do Projeto"
3. Quando encontrar bug: adicione em "🐛 Pendências Conhecidas"
4. Quando concluir tarefa: mude [TODO] para [DONE] e mova para fim da seção
5. **NUNCA deletar itens** — apenas marcar como [DONE] ou [DEPRECATED]

---

## 🚀 Para Começar

```bash
# 1. Clonar/configurar projeto
npm install

# 2. Iniciar servidor de desenvolvimento
npm start

# 3. Acessar em navegador
http://localhost:3000

# 4. Dados de exemplo já estão em localStorage na primeira execução
```

---

**Versão:** 1.0  
**Data:** 2024  
**Status:** ✅ Ativo  
**Mantido por:** Equipe de Desenvolvimento Agrícola
