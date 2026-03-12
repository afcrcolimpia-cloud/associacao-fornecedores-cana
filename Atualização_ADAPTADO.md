# 🎯 ROADMAP ESTRATÉGICO - Evolução do App de Gestão de Cana
# AFCRC Catanduva - Análise Real + Plano de Melhoramento

> Documento adaptado à estrutura REAL do seu projeto Flutter
> Transformar de "App de Registro" → "Sistema Inteligente de Gestão de Cana"

**Versão:** 2.0 | **Data:** 12 de Março de 2025 | **Status:** ✅ Baseado em Análise Técnica Real

---

## 📊 Situação Atual (Análise Técnica)

### O Que Seu Projeto Tem ✅

**Estrutura base excelente:**
```
lib/models/
├─ proprietario.dart         ✅ Cadastro de proprietários
├─ propriedade.dart          ✅ Cadastro de propriedades
├─ talhao.dart               ✅ Divisão em talhões
├─ operacao_cultivo.dart     ✅ Registro de operações
├─ tratos_culturais.dart     ✅ Registro de tratos
├─ produtividade.dart        ✅ Colheita e TCH
├─ precipitacao.dart         ✅ Dados climáticos
└─ anexo.dart                ✅ Documentos

lib/screens/ (30+ telas)
├─ login, dashboard, home
├─ Cadastro de proprietários/propriedades/talhões
├─ Produção (produtividade, precipitação, operações)
├─ Tratos culturais
├─ Documentos
└─ Relatórios

lib/services/
├─ auth_service.dart
├─ operacao_cultivo_service.dart
├─ precipitacao_agregada_service.dart
├─ anexo_service.dart
└─ (services bem estruturados)
```

**Arquitetura corrreta:**
- Modelos → Services → Screens (padrão MVC)
- Separação clara de responsabilidades
- Banco de dados bem normalizado
- Conexão Supabase/PostgreSQL funcionando

### O Que Falta ❌ (Crítico para Crescimento)

| Falta | Problema | Impacto |
|-------|----------|--------|
| **SAFRA estruturada** | Sem contexto temporal | Não pode comparar safra 2024/25 vs 2025/26 |
| **Base de insumos** | Digitação livre (texto) | Erros, análise de custos impossível |
| **Variedades centralizadas** | Dados no talhão apenas | Não sabe TCH por variedade |
| **Monitoramento de pragas** | Não tem estrutura | Sem histórico, sem recomendação |
| **Contexto propriedade ativa** | Sem Provider global | Risco de misturar dados |
| **Recomendações automáticas** | Tudo manual | Produtor fica sozinho nas decisões |

---

## 🚀 Os 4 MELHORAMENTOS ESTRATÉGICOS

### #1: SAFRA - Estrutura Temporal (CRÍTICA)

#### Problema Atual
```
Registra: operações, produtividade, tratos
Falta: "qual safra?" → impossível comparar ciclos
```

#### Solução: Tabela SAFRAS

```sql
-- lib/sql/005_safras.pgsql

CREATE TABLE IF NOT EXISTS public.safras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proprietario_id UUID NOT NULL REFERENCES public.proprietarios(id),
    
    safra VARCHAR(10) NOT NULL,        -- "2025/26"
    data_inicio DATE NOT NULL,         -- 01/04/2025
    data_fim DATE NOT NULL,            -- 31/03/2026
    status VARCHAR(20) DEFAULT 'ativa', -- "ativa", "finalizada"
    
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(proprietario_id, safra)
);

CREATE INDEX idx_safras_proprietario ON public.safras(proprietario_id);
CREATE INDEX idx_safras_status ON public.safras(status);

-- RLS
ALTER TABLE public.safras ENABLE ROW LEVEL SECURITY;
CREATE POLICY safras_rls ON public.safras FOR ALL 
    USING (auth.uid() IS NOT NULL);
```

#### Model para Adicionar

```dart
// lib/models/safra.dart

class Safra {
  final String id;
  final String proprietarioId;
  final String safra;              // "2025/26"
  final DateTime dataInicio;
  final DateTime dataFim;
  final String status;             // "ativa", "finalizada"
  final String? observacoes;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  Safra({
    required this.id,
    required this.proprietarioId,
    required this.safra,
    required this.dataInicio,
    required this.dataFim,
    this.status = 'ativa',
    this.observacoes,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  // Getters úteis
  bool get estaAtiva {
    final agora = DateTime.now();
    return agora.isAfter(dataInicio) && agora.isBefore(dataFim);
  }

  int get diasDesdeInicio => 
      DateTime.now().difference(dataInicio).inDays;

  double get percentualCiclo {
    final totalDias = dataFim.difference(dataInicio).inDays;
    final diasPassados = DateTime.now().difference(dataInicio).inDays;
    return (diasPassados / totalDias) * 100;
  }

  factory Safra.fromJson(Map<String, dynamic> json) {
    return Safra(
      id: json['id'],
      proprietarioId: json['proprietario_id'],
      safra: json['safra'],
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: DateTime.parse(json['data_fim']),
      status: json['status'] ?? 'ativa',
      observacoes: json['observacoes'],
      criadoEm: DateTime.parse(json['criado_em']),
      atualizadoEm: DateTime.parse(json['atualizado_em']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'proprietario_id': proprietarioId,
    'safra': safra,
    'data_inicio': dataInicio.toIso8601String(),
    'data_fim': dataFim.toIso8601String(),
    'status': status,
    'observacoes': observacoes,
    'criado_em': criadoEm.toIso8601String(),
    'atualizado_em': atualizadoEm.toIso8601String(),
  };

  @override
  String toString() => 'Safra(safra: $safra, status: $status, ciclo: ${percentualCiclo.toStringAsFixed(1)}%)';
}
```

#### Service

```dart
// lib/services/safra_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safra.dart';

class SafraService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'safras';

  /// Buscar safra ativa de um proprietário
  Future<Safra?> buscarSafraAtiva(String proprietarioId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('proprietario_id', proprietarioId)
          .eq('status', 'ativa')
          .maybeSingle();
      
      return response != null ? Safra.fromJson(response) : null;
    } catch (e) {
      throw Exception('Erro ao buscar safra ativa: $e');
    }
  }

  /// Listar todas as safras do proprietário
  Future<List<Safra>> buscarPorProprietario(String proprietarioId) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('proprietario_id', proprietarioId)
          .order('safra', ascending: false);
      
      return (response as List)
          .map((json) => Safra.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar safras: $e');
    }
  }

  /// Criar nova safra
  Future<Safra> criar(Safra safra) async {
    try {
      final response = await _supabase
          .from(tableName)
          .insert(safra.toJson())
          .select()
          .single();
      
      return Safra.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar safra: $e');
    }
  }
}
```

#### Impacto Direto
✅ Comparar produtividade safra 2024/25 vs 2025/26
✅ Calcular custo total por safra
✅ Histórico agronômico estruturado
✅ Análises por ciclo completo

#### Vinculações Necessárias
Adicionar `safra_id` em:
- operacoes_cultivo
- tratos_culturais
- produtividade
- precipitacao

---

### #2: INSUMOS - Base Centralizada (CRÍTICA)

#### Problema Atual
```
Hoje: usuário digita "Glifosato" ou "glifosato" ou "GLIFOSATO"
Resultado: 3 registros diferentes = relatório errado
```

#### Solução: Tabela INSUMOS_AGRICOLAS

```sql
-- lib/sql/006_insumos_agricolas.pgsql

CREATE TABLE IF NOT EXISTS public.insumos_agricolas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Classificação
    categoria VARCHAR(50) NOT NULL,       -- "Defensivo", "Fertilizante"
    tipo VARCHAR(50) NOT NULL,            -- "Herbicida", "Mineral"
    produto VARCHAR(100) NOT NULL UNIQUE, -- "Glifosato"
    ingrediente_ativo VARCHAR(100),       -- "Glyphosate"
    
    -- Doses
    dose_minima NUMERIC(10,2) NOT NULL,
    dose_maxima NUMERIC(10,2) NOT NULL,
    unidade VARCHAR(20) NOT NULL,         -- "kg/ha", "L/ha"
    forma_aplicacao VARCHAR(50),          -- "Pulverização"
    
    -- Preço
    preco_unitario NUMERIC(10,2),
    
    -- Metadata
    observacoes TEXT,
    ativo BOOLEAN DEFAULT true,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT dose_min_menor_max CHECK (dose_minima < dose_maxima)
);

CREATE INDEX idx_insumos_categoria ON public.insumos_agricolas(categoria);
CREATE INDEX idx_insumos_tipo ON public.insumos_agricolas(tipo);
CREATE INDEX idx_insumos_produto ON public.insumos_agricolas(produto);

ALTER TABLE public.insumos_agricolas ENABLE ROW LEVEL SECURITY;
CREATE POLICY insumos_rls ON public.insumos_agricolas FOR ALL 
    USING (auth.uid() IS NOT NULL);

-- Dados iniciais
INSERT INTO public.insumos_agricolas 
(categoria, tipo, produto, ingrediente_ativo, dose_minima, dose_maxima, unidade, preco_unitario)
VALUES
('Defensivo', 'Herbicida', 'Glifosato', 'Glyphosate', 2.5, 4.0, 'L/ha', 11.70),
('Defensivo', 'Herbicida', '2,4-D Amina', '2,4-D', 1.0, 2.0, 'L/ha', 8.50),
('Defensivo', 'Inseticida', 'Fipronil', 'Fipronil', 0.75, 1.0, 'L/ha', 22.50),
('Defensivo', 'Fungicida', 'Azoxistrobina', 'Azoxistrobina', 0.5, 0.75, 'L/ha', 32.00),
('Fertilizante', 'Mineral', 'Ureia', 'N', 80.0, 150.0, 'kg/ha', 2.50),
('Fertilizante', 'Mineral', 'DAP', 'N+P', 100.0, 200.0, 'kg/ha', 3.20),
('Fertilizante', 'Mineral', 'Cloreto de Potássio', 'K', 60.0, 120.0, 'kg/ha', 2.85),
('Corretivo', 'Calcário', 'Calcário Dolomítico', 'Ca+Mg', 2.0, 4.0, 't/ha', 90.00)
ON CONFLICT (produto) DO NOTHING;
```

#### Model

```dart
// lib/models/insumo_agricola.dart

class InsumoAgricola {
  final String id;
  final String categoria;
  final String tipo;
  final String produto;
  final String? ingredienteAtivo;
  final double doseMinima;
  final double doseMaxima;
  final String unidade;
  final String? formaAplicacao;
  final double? precoUnitario;
  final String? observacoes;
  final bool ativo;

  InsumoAgricola({
    required this.id,
    required this.categoria,
    required this.tipo,
    required this.produto,
    this.ingredienteAtivo,
    required this.doseMinima,
    required this.doseMaxima,
    required this.unidade,
    this.formaAplicacao,
    this.precoUnitario,
    this.observacoes,
    this.ativo = true,
  });

  factory InsumoAgricola.fromJson(Map<String, dynamic> json) {
    return InsumoAgricola(
      id: json['id'],
      categoria: json['categoria'],
      tipo: json['tipo'],
      produto: json['produto'],
      ingredienteAtivo: json['ingrediente_ativo'],
      doseMinima: (json['dose_minima'] as num).toDouble(),
      doseMaxima: (json['dose_maxima'] as num).toDouble(),
      unidade: json['unidade'],
      formaAplicacao: json['forma_aplicacao'],
      precoUnitario: json['preco_unitario'] != null 
          ? (json['preco_unitario'] as num).toDouble() 
          : null,
      observacoes: json['observacoes'],
      ativo: json['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoria': categoria,
    'tipo': tipo,
    'produto': produto,
    'ingrediente_ativo': ingredienteAtivo,
    'dose_minima': doseMinima,
    'dose_maxima': doseMaxima,
    'unidade': unidade,
    'forma_aplicacao': formaAplicacao,
    'preco_unitario': precoUnitario,
    'observacoes': observacoes,
    'ativo': ativo,
  };
}
```

#### Impacto Direto
✅ Relatório: "Glifosato aplicado 12x na safra"
✅ Calcular custo real por insumo
✅ Insumos mais usados (análise)
✅ Auditoria de aplicações

---

### #3: VARIEDADES - Gestão Inteligente (ALTA PRIORIDADE)

#### Problema Atual
```
Hoje: variedade como texto livre no talhão
Ideal: variedade_id + dados agronômicos estruturados
```

#### Solução: Tabela VARIEDADES_CANA

```sql
-- lib/sql/007_variedades_cana.pgsql

CREATE TABLE IF NOT EXISTS public.variedades_cana (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Identificação
    codigo VARCHAR(20) NOT NULL UNIQUE,    -- "CTC2", "RB966928"
    nome VARCHAR(100) NOT NULL,            -- "CTC 2"
    origem VARCHAR(50),                    -- "CTC", "RIDESA", "IAC"
    ano_lancamento INTEGER,
    
    -- Ambiente de produção (A-E)
    ambiente_producao VARCHAR(50),         -- "A,B,C"
    
    -- Características
    maturacao VARCHAR(20),                 -- "precoce", "média", "tardia"
    perfilhamento VARCHAR(20),             -- "alto", "médio", "baixo"
    teor_ATR_estimado NUMERIC(5,2),       -- 132, 135, 138
    TCH_medio NUMERIC(5,2),               -- produção média
    
    -- Susceptibilidades
    destaque TEXT,                         -- "Alto ATR, Rusticidade"
    tolerancia_seca VARCHAR(50),          -- "Alta", "Média", "Baixa"
    susceptibilidade_pragas TEXT,         -- "Broca baixa, cigarrinha alta"
    
    -- Status
    ativo BOOLEAN DEFAULT true,
    observacoes TEXT,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT ambiente_valido CHECK (ambiente_producao ~ '^[A-E](,[A-E])*$')
);

CREATE INDEX idx_variedades_codigo ON public.variedades_cana(codigo);
CREATE INDEX idx_variedades_ambiente ON public.variedades_cana(ambiente_producao);

ALTER TABLE public.variedades_cana ENABLE ROW LEVEL SECURITY;
CREATE POLICY variedades_rls ON public.variedades_cana FOR ALL 
    USING (auth.uid() IS NOT NULL);

-- Dados principais
INSERT INTO public.variedades_cana 
(codigo, nome, origem, ano_lancamento, ambiente_producao, maturacao, teor_ATR_estimado, TCH_medio, destaque)
VALUES
('CTC2', 'CTC 2', 'CTC', 2007, 'B,C', 'média', 134, 82, 'Alto ATR, boa brotação'),
('CTC4', 'CTC 4', 'CTC', 2010, 'A,B,C,D', 'tardia', 136, 80, 'Muito alto ATR'),
('RB966928', 'RB 966928', 'RIDESA', 2008, 'B,C,D,E', 'média', 132, 78, 'Produtividade alta'),
('RB867515', 'RB 867515', 'RIDESA', 2002, 'A,B,C,D,E', 'tardia', 128, 76, 'Clássica'),
('SP806015', 'SP 80-6015', 'IAC', 2004, 'A,B,C', 'média', 130, 79, 'Confiável')
ON CONFLICT (codigo) DO NOTHING;
```

#### Model

```dart
// lib/models/variedade_cana.dart

class VariedadeCana {
  final String id;
  final String codigo;              // "CTC2"
  final String nome;                // "CTC 2"
  final String? origem;
  final int? anoLancamento;
  final String? ambienteProducao;   // "A,B,C"
  final String? maturacao;
  final String? perfilhamento;
  final double? teorATREstimado;
  final double? tchMedio;
  final String? destaque;
  final String? toleranciaSeca;
  final String? susceptibilidadePragas;
  final bool ativo;
  final String? observacoes;

  VariedadeCana({
    required this.id,
    required this.codigo,
    required this.nome,
    this.origem,
    this.anoLancamento,
    this.ambienteProducao,
    this.maturacao,
    this.perfilhamento,
    this.teorATREstimado,
    this.tchMedio,
    this.destaque,
    this.toleranciaSeca,
    this.susceptibilidadePragas,
    this.ativo = true,
    this.observacoes,
  });

  // Verificar se é recomendada para ambiente
  bool recomendadaPara(String ambiente) {
    if (ambienteProducao == null) return false;
    return ambienteProducao!.split(',').contains(ambiente);
  }

  factory VariedadeCana.fromJson(Map<String, dynamic> json) {
    return VariedadeCana(
      id: json['id'],
      codigo: json['codigo'],
      nome: json['nome'],
      origem: json['origem'],
      anoLancamento: json['ano_lancamento'],
      ambienteProducao: json['ambiente_producao'],
      maturacao: json['maturacao'],
      perfilhamento: json['perfilhamento'],
      teorATREstimado: json['teor_ATR_estimado'] != null 
          ? (json['teor_ATR_estimado'] as num).toDouble() 
          : null,
      tchMedio: json['TCH_medio'] != null 
          ? (json['TCH_medio'] as num).toDouble() 
          : null,
      destaque: json['destaque'],
      toleranciaSeca: json['tolerancia_seca'],
      susceptibilidadePragas: json['susceptibilidade_pragas'],
      ativo: json['ativo'] ?? true,
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo': codigo,
    'nome': nome,
    'origem': origem,
    'ano_lancamento': anoLancamento,
    'ambiente_producao': ambienteProducao,
    'maturacao': maturacao,
    'perfilhamento': perfilhamento,
    'teor_ATR_estimado': teorATREstimado,
    'TCH_medio': tchMedio,
    'destaque': destaque,
    'tolerancia_seca': toleranciaSeca,
    'susceptibilidade_pragas': susceptibilidadePragas,
    'ativo': ativo,
    'observacoes': observacoes,
  };

  @override
  String toString() => '$codigo - $nome (TCH: $tchMedio, ATR: $teorATREstimado)';
}
```

#### Atualizar Talhão

```dart
// lib/models/talhao.dart - ADICIONAR:

class Talhao {
  // ... campos existentes ...
  
  // NOVO:
  final String? variedadeId; // FK para variedades_cana
  
  // Remover ou manter como backup:
  final String? variedade; // pode ficar desnormalizado para compatibilidade
}
```

#### Impacto Direto
✅ TCH médio por variedade (CTC2 = 82 TCH)
✅ Melhor variedade por ambiente (C = CTC4)
✅ Histórico de performance
✅ Recomendação automática

---

### #4: MONITORAMENTO DE PRAGAS + RECOMENDAÇÕES (ESTRATÉGICO)

#### Problema Atual
```
Sem histórico de pragas
Sem recomendações automáticas
Produtor fica sozinho nas decisões
```

#### Solução: Tabelas MONITORAMENTO + RECOMENDAÇÕES

```sql
-- lib/sql/008_monitoramento_pragas.pgsql

CREATE TABLE IF NOT EXISTS public.monitoramento_pragas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    talhao_id UUID NOT NULL REFERENCES public.talhoes(id),
    safra_id UUID NOT NULL REFERENCES public.safras(id),
    
    -- Praga
    praga VARCHAR(50) NOT NULL,            -- "cigarrinha", "broca"
    nivel_infestacao VARCHAR(20) NOT NULL, -- "baixo", "médio", "alto", "crítico"
    data_monitoramento DATE NOT NULL,
    area_afetada NUMERIC(10,2),            -- hectares
    
    -- Ação tomada
    acao_recomendada VARCHAR(100),
    insumo_id UUID REFERENCES public.insumos_agricolas(id),
    data_acao DATE,
    
    -- Metadata
    observacoes TEXT,
    responsavel VARCHAR(100),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT nivel_valido CHECK (nivel_infestacao IN ('baixo', 'médio', 'alto', 'crítico'))
);

CREATE INDEX idx_monitoramento_talhao ON public.monitoramento_pragas(talhao_id);
CREATE INDEX idx_monitoramento_safra ON public.monitoramento_pragas(safra_id);
CREATE INDEX idx_monitoramento_data ON public.monitoramento_pragas(data_monitoramento);
```

```sql
-- lib/sql/009_recomendacoes_automaticas.pgsql

CREATE TABLE IF NOT EXISTS public.recomendacoes_automaticas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    talhao_id UUID NOT NULL REFERENCES public.talhoes(id),
    safra_id UUID NOT NULL REFERENCES public.safras(id),
    
    -- Tipo de recomendação
    tipo VARCHAR(50) NOT NULL,            -- "controle_praga", "adubacao", "correcao"
    descricao TEXT NOT NULL,
    
    -- Insumo recomendado
    insumo_id UUID REFERENCES public.insumos_agricolas(id),
    dose_recomendada NUMERIC(10,2),
    unidade VARCHAR(20),
    
    -- Status
    status VARCHAR(20) DEFAULT 'pendente', -- "pendente", "implementada", "ignorada"
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_implementacao DATE,
    
    -- Justificativa da IA
    motivo TEXT,                          -- "Nível cigarrinha acima de 2/gema"
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_recomendacoes_talhao ON public.recomendacoes_automaticas(talhao_id);
CREATE INDEX idx_recomendacoes_status ON public.recomendacoes_automaticas(status);
```

#### Models

```dart
// lib/models/monitoramento_praga.dart

class MonitoramentoPraga {
  final String id;
  final String talhaoId;
  final String safraId;
  final String praga;                    // "cigarrinha"
  final String nivelInfestacao;          // "baixo", "médio", "alto", "crítico"
  final DateTime dataMonitoramento;
  final double? areaAfetada;
  final String? acaoRecomendada;
  final String? insumoId;
  final DateTime? dataAcao;
  final String? observacoes;
  final String? responsavel;

  MonitoramentoPraga({
    required this.id,
    required this.talhaoId,
    required this.safraId,
    required this.praga,
    required this.nivelInfestacao,
    required this.dataMonitoramento,
    this.areaAfetada,
    this.acaoRecomendada,
    this.insumoId,
    this.dataAcao,
    this.observacoes,
    this.responsavel,
  });

  factory MonitoramentoPraga.fromJson(Map<String, dynamic> json) {
    return MonitoramentoPraga(
      id: json['id'],
      talhaoId: json['talhao_id'],
      safraId: json['safra_id'],
      praga: json['praga'],
      nivelInfestacao: json['nivel_infestacao'],
      dataMonitoramento: DateTime.parse(json['data_monitoramento']),
      areaAfetada: json['area_afetada'] != null 
          ? (json['area_afetada'] as num).toDouble() 
          : null,
      acaoRecomendada: json['acao_recomendada'],
      insumoId: json['insumo_id'],
      dataAcao: json['data_acao'] != null 
          ? DateTime.parse(json['data_acao']) 
          : null,
      observacoes: json['observacoes'],
      responsavel: json['responsavel'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'talhao_id': talhaoId,
    'safra_id': safraId,
    'praga': praga,
    'nivel_infestacao': nivelInfestacao,
    'data_monitoramento': dataMonitoramento.toIso8601String(),
    'area_afetada': areaAfetada,
    'acao_recomendada': acaoRecomendada,
    'insumo_id': insumoId,
    'data_acao': dataAcao?.toIso8601String(),
    'observacoes': observacoes,
    'responsavel': responsavel,
  };
}
```

#### Impacto Direto
✅ Histórico de pragas por talhão
✅ Recomendações automáticas
✅ Comparar eficácia de tratamentos
✅ Auditoria de decisões

---

## 📅 ROADMAP DE IMPLEMENTAÇÃO

### FASE 1: Fundação (Semanas 1-2)
```
✓ Criar tabela SQL: safras
✓ Criar model: Safra
✓ Criar service: SafraService
✓ Adicionar safra_id aos registros existentes
✓ Testar com dados reais
```

**Tempo:** 40-50 horas
**Risco:** Baixo (adiciona, não quebra)

### FASE 2: Base Centralizada (Semanas 2-3)
```
✓ Criar tabela SQL: insumos_agricolas
✓ Criar model: InsumoAgricola
✓ Criar service: InsumoAgricolaService
✓ Atualizar tratos_culturais para usar insumo_id
✓ Criar tela de gestão de insumos
```

**Tempo:** 35-40 horas
**Risco:** Médio (quebra compatibilidade)

### FASE 3: Variedades (Semanas 3-4)
```
✓ Criar tabela SQL: variedades_cana
✓ Criar model: VariedadeCana
✓ Criar service: VariedadeService
✓ Atualizar talhao.dart com variedadeId
✓ Criar dropdown de variedades no formulário
✓ Gerar relatórios por variedade
```

**Tempo:** 30-35 horas
**Risco:** Baixo

### FASE 4: Inteligência (Semanas 4-5)
```
✓ Criar tabela: monitoramento_pragas
✓ Criar model: MonitoramentoPraga
✓ Criar tela de monitoramento
✓ Criar tabela: recomendacoes_automaticas
✓ Implementar engine de recomendações
✓ Criar tela "Recomendações do Dia"
```

**Tempo:** 50-60 horas
**Risco:** Alto (lógica complexa)

### FASE 5: Dashboard Inteligente (Semanas 5-6)
```
✓ Criar dashboard com indicadores KPI
✓ Gráficos de produtividade
✓ Alertas e notificações
✓ Comparação benchmarking
✓ Relatórios automáticos
```

**Tempo:** 40-50 horas
**Risco:** Médio

---

## 🎯 PROVIDER GLOBAL: Contexto de Propriedade Ativa

#### Problema Atual
```
Sem contexto global = risco de misturar dados
```

#### Solução: Riverpod Provider

```dart
// lib/providers/current_propriedade_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/propriedade.dart';

final currentPropriedadeProvider = StateProvider<Propriedade?>((ref) {
  // TODO: Obter da navegação ou preferences
  return null;
});

final currentSafraProvider = FutureProvider((ref) async {
  final propriedade = ref.watch(currentPropriedadeProvider);
  if (propriedade == null) return null;
  
  // Buscar safra ativa dessa propriedade
  // return await safrService.buscarSafraAtiva(propriedade.id);
});

// Usar em qualquer tela:
// final propriedadeAtiva = ref.watch(currentPropriedadeProvider);
// final safraAtiva = ref.watch(currentSafraProvider);
```

---

## 📊 ESTRUTURA FINAL DO BANCO

```
PROPRIETARIO (base)
    ↓
PROPRIEDADE
    ├─ SAFRA (contexto temporal)
    │   ├─ OPERACOES_CULTIVO
    │   ├─ TRATOS_CULTURAIS (com insumo_id)
    │   ├─ PRODUTIVIDADE
    │   ├─ PRECIPITACAO
    │   ├─ MONITORAMENTO_PRAGAS
    │   └─ RECOMENDACOES_AUTOMATICAS
    │
    └─ TALHAO (com variedade_id)
        └─ OPERACOES_ESPECIFICAS_TALHAO

TABELAS CENTRALIZADAS:
├─ VARIEDADES_CANA
└─ INSUMOS_AGRICOLAS
```

---

## 💡 VISÃO FINAL: Do "App de Registro" para "Sistema Inteligente"

### ANTES (Situação Atual)
```
App de Cadastro e Registro
├─ Proprietário ✓
├─ Propriedade ✓
├─ Talhão ✓
├─ Operação (texto livre) ✓
├─ Trato (texto livre) ✓
└─ Produtividade ✓

Análise: nenhuma (tudo manual)
Recomendação: nenhuma
```

### DEPOIS (Com Roadmap Implementado)
```
Sistema Inteligente de Gestão de Cana
├─ Cadastros estruturados
├─ Base centralizada de insumos
├─ Variedades com dados agronômicos
├─ Histórico de pragas
├─ Recomendações automáticas
├─ Dashboard com KPIs
├─ Análise comparativa
└─ Relatórios agronômicos

Análise: automática + histórica
Recomendação: inteligente (IA)
```

---

## 🚀 Benefícios Concretos

### Para o Produtor
✅ Decisões baseadas em dados
✅ Recomendações automáticas
✅ Histórico agronômico completo
✅ Análise de rentabilidade

### Para a AFCRC
✅ Padronização de recomendações
✅ Histórico técnico estruturado
✅ Dados agregados para políticas
✅ Ferramenta de suporte técnico

### Para o App
✅ Escalável para 500+ produtores
✅ Integração com IA agrícola
✅ Diferenciador competitivo
✅ Base para evolução futura

---

## 📋 PROGRESSO GERAL — Atualizado em 12/03/2026

| Fase | Status | % |
|---|---|---|
| **1. Safras** | ✅ COMPLETO | 100% |
| **2. Insumos** | ⚠️ Falta tela CRUD | 80% |
| **3. Variedades** | ✅ COMPLETO | 100% |
| **4. Monitoramento Pragas** | ⚠️ Parcial (só PDF) | 40% |
| **5. Dashboard** | ✅ COMPLETO | 100% |

---

## ☑️ LISTA DE TAREFAS POR FASE — Arquivos e Ações

### FASE 1 — SAFRAS ✅ CONCLUÍDA

- [x] `lib/sql/005_safras.pgsql` — Tabela `safras` com RLS, constraints, índices
- [x] `lib/sql/006_safra_id_tabelas_operacionais.pgsql` — `safra_id` em operacoes_cultivo, tratos_culturais, produtividade, precipitacao
- [x] `lib/models/safra.dart` — Model com fromJson, toJson, copyWith, getters (percentualCiclo, diasRestantes)
- [x] `lib/models/models.dart` — Adicionado `export 'safra.dart'`
- [x] `lib/services/safra_service.dart` — CRUD + buscarSafraAtiva, finalizarSafra, reativarSafra
- [x] `lib/screens/safras_screen.dart` — Listagem com cards, barra de progresso, menu de ações
- [x] `lib/screens/safra_form_screen.dart` — Formulário criar/editar com auto-preenchimento de datas
- [x] `lib/screens/propriedade_hub_screen.dart` — Item "Safras" adicionado ao hub
- [ ] **EXECUTAR** `005_safras.pgsql` no Supabase SQL Editor
- [ ] **EXECUTAR** `006_safra_id_tabelas_operacionais.pgsql` no Supabase SQL Editor
- [ ] **TESTAR** criar uma safra no app e verificar se salva no banco

---

### FASE 2 — INSUMOS ⚠️ 80% (falta tela CRUD)

**Já implementado:**
- [x] `lib/sql/004_insumos_com_doses.pgsql` — Tabela com 58 insumos de seed data
- [x] `lib/models/insumo_com_dose.dart` — Model completo
- [x] `lib/models/models.dart` — Export adicionado
- [x] `lib/services/insumo_com_dose_service.dart` — buscarInsumos, buscarPorCategoria, buscarPorTipo
- [x] `lib/widgets/insumo_selector_widget.dart` — Widget de seleção usado em tratos culturais

**Pendente:**
- [ ] **CRIAR** `lib/screens/insumos_screen.dart` — Tela de listagem dos insumos cadastrados (filtro por categoria/tipo)
- [ ] **CRIAR** `lib/screens/insumo_form_screen.dart` — Formulário para criar/editar insumo
- [ ] **MODIFICAR** `lib/screens/propriedade_hub_screen.dart` — Adicionar item "Insumos" ao hub (ou menu lateral)
- [ ] **TESTAR** CRUD completo (criar, editar, excluir insumo)

> **Padrão:** Seguir o mesmo padrão de `safras_screen.dart` + `safra_form_screen.dart`
> **Arquivos de referência:** `lib/screens/talhoes_screen.dart` (listagem) e `lib/screens/talhao_form_screen.dart` (formulário)

---

### FASE 3 — VARIEDADES ✅ CONCLUÍDA

- [x] `lib/sql/003_variedades_cana.pgsql` — Tabela com 54 variedades AFCRC 2024
- [x] `lib/models/variedade.dart` — Model com campos agronômicos
- [x] `lib/models/models.dart` — Export adicionado
- [x] `lib/services/variedade_service.dart` — Cache, busca por ambiente/época
- [x] `lib/screens/variedade_form_screen.dart` — CRUD de variedades
- [x] `lib/widgets/variedade_dropdown_widget.dart` — Dropdown para talhões
- [x] `lib/screens/censo_varietal_screen.dart` — Censo varietal por propriedade
- [x] `lib/services/pdf_generators/pdf_censo_varietal.dart` — PDF de censo

---

### FASE 4 — MONITORAMENTO DE PRAGAS ⚠️ 40% (falta banco + model + service)

**Já implementado:**
- [x] `lib/services/pdf_generators/pdf_broca_cigarrinha.dart` — PDF de Broca + Cigarrinha
- [x] `lib/services/pdf_generators/pdf_broca_infestacao.dart` — PDF de Broca Infestação
- [x] `lib/services/pdf_generators/pdf_sphenophorus.dart` — PDF de Sphenophorus
- [x] `lib/screens/formularios_pdf_screen.dart` — Tela que gera os 3 PDFs acima
- [x] `lib/screens/propriedade_hub_screen.dart` — Item "Relatórios de Pragas" no hub

**Pendente — Criar tabela e estrutura de dados:**
- [ ] **CRIAR** `lib/sql/007_monitoramento_pragas.pgsql` — Tabela `monitoramento_pragas` com:
  - `id UUID PK`, `talhao_id UUID FK`, `safra_id UUID FK`
  - `praga VARCHAR` (cigarrinha, broca, sphenophorus, etc.)
  - `nivel_infestacao VARCHAR` (baixo, médio, alto, crítico)
  - `data_monitoramento DATE`, `area_afetada NUMERIC`
  - `acao_recomendada VARCHAR`, `insumo_id UUID FK` (ref insumos_com_doses)
  - `observacoes TEXT`, `responsavel VARCHAR`
  - RLS + índices
- [ ] **CRIAR** `lib/models/monitoramento_praga.dart` — Model com fromJson, toJson, copyWith
- [ ] **MODIFICAR** `lib/models/models.dart` — Adicionar `export 'monitoramento_praga.dart'`
- [ ] **CRIAR** `lib/services/monitoramento_praga_service.dart` — CRUD + buscarPorTalhao, buscarPorSafra
- [ ] **CRIAR** `lib/screens/monitoramento_pragas_screen.dart` — Listagem com filtro por talhão/safra/praga
- [ ] **CRIAR** `lib/screens/monitoramento_praga_form_screen.dart` — Formulário de registro (praga, nível, data, ação)
- [ ] **MODIFICAR** `lib/screens/propriedade_hub_screen.dart` — Adicionar item "Monitoramento de Pragas"
- [ ] **EXECUTAR** `007_monitoramento_pragas.pgsql` no Supabase SQL Editor
- [ ] **TESTAR** CRUD completo + filtros

> **Padrão:** Model segue `safra.dart`, Service segue `safra_service.dart`, Screen segue `safras_screen.dart`
> **Diferencial:** Dropdown de `praga` com opções fixas (cigarrinha, broca, sphenophorus, etc.)
> **Dropdown de `insumo`** usa `InsumoSelectorWidget` já existente

**Pendente — Recomendações automáticas (opcional/futuro):**
- [ ] **CRIAR** `lib/sql/008_recomendacoes_automaticas.pgsql` — Tabela `recomendacoes_automaticas`
- [ ] **CRIAR** `lib/models/recomendacao.dart` — Model
- [ ] **CRIAR** `lib/services/recomendacao_service.dart` — Engine de recomendações
- [ ] **CRIAR** `lib/screens/recomendacoes_screen.dart` — Tela "Recomendações do Dia"

---

### FASE 5 — DASHBOARD INTELIGENTE ✅ CONCLUÍDA

- [x] `lib/screens/gestao_agricola_dashboard_screen.dart` — Dashboard geral com KPIs reais
- [x] `lib/screens/dashboard_analitico_screen.dart` — Gráficos por propriedade
- [x] `lib/widgets/kpi_card.dart` — Widget de KPI
- [x] `lib/constants/chart_styles.dart` — Estilos dos gráficos

---

## 📂 INVENTÁRIO COMPLETO DE ARQUIVOS — Referência

### Migrations SQL (`lib/sql/`)
```
✅ 001_tabelas_operacionais.pgsql
✅ 002_analises_solo.pgsql
✅ 003_variedades_cana.pgsql
✅ 004_insumos_com_doses.pgsql
✅ 005_safras.pgsql
✅ 006_safra_id_tabelas_operacionais.pgsql
✅ custo_operacional_supabase.pgsql
❌ 007_monitoramento_pragas.pgsql          (criar na Fase 4)
❌ 008_recomendacoes_automaticas.pgsql     (criar na Fase 4 - opcional)
```

### Models (`lib/models/`)
```
✅ proprietario.dart
✅ propriedade.dart
✅ talhao.dart
✅ variedade.dart
✅ safra.dart
✅ insumo_com_dose.dart
✅ produtividade.dart
✅ precipitacao.dart
✅ operacao_cultivo.dart
✅ operacao_custos.dart
✅ tratos_culturais.dart
✅ analise_solo.dart
✅ anexo.dart
✅ contexto_propriedade.dart
✅ models.dart (barrel export)
❌ monitoramento_praga.dart                (criar na Fase 4)
❌ recomendacao.dart                       (criar na Fase 4 - opcional)
```

### Services (`lib/services/`)
```
✅ auth_service.dart
✅ proprietario_service.dart
✅ propriedade_service.dart
✅ talhao_service.dart
✅ variedade_service.dart
✅ safra_service.dart
✅ insumo_com_dose_service.dart
✅ produtividade_service.dart
✅ precipitacao_service.dart
✅ precipitacao_agregada_service.dart
✅ operacao_cultivo_service.dart
✅ tratos_culturais_service.dart
✅ custo_operacional_service.dart
✅ custo_operacional_repository.dart
✅ custo_operacional_analise.dart
✅ analise_solo_service.dart
✅ anexo_service.dart
✅ exportacao_pdf_service.dart
❌ monitoramento_praga_service.dart        (criar na Fase 4)
❌ recomendacao_service.dart               (criar na Fase 4 - opcional)
```

### PDF Generators (`lib/services/pdf_generators/`)
```
✅ pdf_cabecalho.dart
✅ pdf_talhoes.dart
✅ pdf_produtividade.dart
✅ pdf_precipitacao.dart
✅ pdf_operacoes.dart
✅ pdf_tratos.dart
✅ pdf_custo.dart
✅ pdf_lancamentos_custo.dart
✅ pdf_censo_varietal.dart
✅ pdf_analise_solo.dart
✅ pdf_broca_cigarrinha.dart
✅ pdf_broca_infestacao.dart
✅ pdf_sphenophorus.dart
```

### Screens (`lib/screens/`)
```
✅ login_screen.dart
✅ home_screen.dart
✅ dashboard_screen.dart
✅ gestao_agricola_dashboard_screen.dart
✅ dashboard_analitico_screen.dart
✅ proprietarios_screen.dart / proprietario_form_screen.dart / proprietario_detail_screen.dart
✅ propriedades_screen.dart / propriedade_form_screen.dart / propriedade_detalhes_screen.dart
✅ propriedade_hub_screen.dart
✅ propriedades_por_proprietario_screen.dart
✅ safras_screen.dart / safra_form_screen.dart
✅ talhoes_screen.dart / talhao_form_screen.dart
✅ variedade_form_screen.dart
✅ censo_varietal_screen.dart
✅ tratos_culturais_screen.dart / tratos_culturais_form_screen.dart
✅ operacoes_cultivo_screen.dart / operacao_form_screen.dart / operacoes_detalhes_screen.dart
✅ produtividade_screen.dart / produtividade_form_screen.dart
✅ precipitacao_screen.dart / precipitacao_por_municipios_screen.dart
✅ custo_operacional_screen.dart / custo_operacional_form_screen.dart
✅ custo_operacional_dashboard_screen.dart
✅ custo_operacional_lancamentos_screen.dart / custo_operacional_lancamento_screen.dart
✅ historico_custo_operacional_screen.dart
✅ matriz_sensibilidade_screen.dart
✅ projecao_financeira_screen.dart
✅ analise_solo_screen.dart / analise_solo_form_screen.dart / analise_solo_graficos_screen.dart
✅ interpretacao_analise_solo_screen.dart
✅ formularios_pdf_screen.dart
✅ central_relatorios_screen.dart
✅ graficos_comparativo_screen.dart
✅ anexos_screen.dart / anexo_upload_screen.dart
❌ insumos_screen.dart / insumo_form_screen.dart                  (criar na Fase 2)
❌ monitoramento_pragas_screen.dart / monitoramento_praga_form_screen.dart  (criar na Fase 4)
❌ recomendacoes_screen.dart                                      (criar na Fase 4 - opcional)
```

### Widgets (`lib/widgets/`)
```
✅ app_shell.dart
✅ app_bar_afcrc.dart
✅ header_propriedade.dart
✅ empresa_header.dart
✅ kpi_card.dart
✅ chart_card.dart
✅ data_table_widget.dart
✅ operacao_card.dart
✅ produtividade_card.dart
✅ propriedade_card.dart
✅ variedade_dropdown_widget.dart
✅ insumo_selector_widget.dart
```

---

## 🔜 PRÓXIMAS AÇÕES (em ordem de prioridade)

1. **Executar migrations SQL no Supabase** — `005_safras.pgsql` + `006_safra_id_tabelas_operacionais.pgsql`
2. **Fase 2 — Tela CRUD de Insumos** — 2 arquivos novos + 1 modificação no hub
3. **Fase 4 — Monitoramento de Pragas** — 1 SQL + 1 model + 1 service + 2 screens + hub

> **Para implementar qualquer tarefa pendente**, basta dizer:
> - "Implementa a tela CRUD de Insumos" (Fase 2)
> - "Implementa o Monitoramento de Pragas" (Fase 4)
> - "Implementa as Recomendações Automáticas" (Fase 4 opcional)

---

**Versão:** 3.0 Atualizado | **Data:** 12 de Março de 2026 | **Status:** ✅ Fase 1, 3, 5 completas | ⚠️ Fase 2, 4 parciais

