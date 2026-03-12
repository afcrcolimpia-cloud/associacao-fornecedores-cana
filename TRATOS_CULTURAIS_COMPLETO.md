# TRATOS CULTURAIS — Melhorias v2.0 — Documentação Completa

> Documentação para melhorar o módulo de Tratos Culturais
> com carregamento automático de talhões, doses dinâmicas e cálculos automáticos.

**Versão:** 2.0 | **Data:** 12 de Março de 2025 | **Status:** ✅ Pronto para Usar

---

## 📚 Índice Rápido

1. Visão Geral
2. Funcionalidades Principais
3. Estrutura de Dados Aprimorada
4. Banco de Dados (SQL)
5. Modelos Aprimorados
6. Services Aprimorados
7. Telas Aprimoradas
8. Widgets Novos
9. Exemplos de Código
10. Checklist de Implementação

---

## 🎯 Visão Geral

### Situação Atual do Seu Projeto

✅ Já possui:
- Modelo `TratosCulturais` com estrutura de insumos
- Service `TratosCulturaisService` com CRUD
- Telas `tratos_culturais_screen.dart` e `tratos_culturais_form_screen.dart`
- PDF generator `pdf_tratos.dart`
- Integração com `ContextoPropriedade`

### O Que Será Melhorado

🆕 Adicionar:
- Carregamento automático de talhões com dados
- Doses recomendadas dinâmicas
- Cálculos automáticos de custo
- Validação visual de doses
- Tabela de insumos com preços
- Agrupamento na listagem

---

## ✨ Funcionalidades Principais

### 1. Carregamento Automático de Talhões
```
Ao abrir o formulário:
├─ Carrega talhões da propriedade
├─ Exibe: Número, Variedade, Área (ha)
└─ Pré-carrega dados automaticamente
```

### 2. Doses Recomendadas Dinâmicas
```
Ao selecionar insumo:
├─ Busca doses mín/máx na tabela
├─ Carrega preço unitário
├─ Sugere dose média
└─ Exibe observações técnicas
```

### 3. Cálculos Automáticos
```
Conforme usuário altera:
├─ Total insumo = dose × área
├─ Custo por ha = dose × preço
├─ Custo total = custo/ha × área
└─ Atualiza em tempo real
```

### 4. Validação Visual de Doses
```
Verde: ✓ Dentro do intervalo
Amarelo: ⚠️ Fora (permite salvar)
Vermelho: ❌ Muito fora (alerta)
```

### 5. Agrupamento por Talhão
```
Na listagem:
├─ Agrupa tratos por talhão
├─ Mostra custo total
└─ Lista tratos do talhão
```

### 6. Tabela de 200+ Insumos
```sql
Nova tabela: insumos_com_doses
├─ categoria
├─ tipo
├─ produto
├─ doses min/max
├─ unidade
├─ preco_unitario
└─ observacoes
```

---

## 📊 Estrutura de Dados Aprimorada

### Classe Insumo (APRIMORADA)

Adicionar à classe existente em `lib/models/tratos_culturais.dart`:

```dart
class Insumo {
  final String nome;
  final double quantidade;
  final String unidade;
  final DateTime? dataAplicacao;
  
  // ====== NOVOS CAMPOS ======
  final double? doseMinima;
  final double? doseMaxima;
  final double? precoUnitario;
  // =========================

  Insumo({
    required this.nome,
    required this.quantidade,
    required this.unidade,
    this.dataAplicacao,
    this.doseMinima,
    this.doseMaxima,
    this.precoUnitario,
  });

  // NOVO: Getter para custo total
  double get custoTotal {
    if (precoUnitario == null) return 0.0;
    return quantidade * precoUnitario!;
  }

  // NOVO: Validar se dose está no range
  bool get doseEstaNoRange {
    if (doseMinima == null || doseMaxima == null) return true;
    return quantidade >= doseMinima! && quantidade <= doseMaxima!;
  }

  // NOVO: Status visual
  String get statusDose {
    if (doseMinima == null || doseMaxima == null) return '✓ Sem recomendação';
    if (doseEstaNoRange) return '✓ Dentro do intervalo';
    if (quantidade < doseMinima!) return '⚠️ Abaixo do recomendado';
    return '⚠️ Acima do recomendado';
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'quantidade': quantidade,
      'unidade': unidade,
      'data_aplicacao': dataAplicacao?.toIso8601String(),
      'dose_minima': doseMinima,
      'dose_maxima': doseMaxima,
      'preco_unitario': precoUnitario,
    };
  }

  factory Insumo.fromJson(Map<String, dynamic> json) {
    return Insumo(
      nome: json['nome']?.toString() ?? '',
      quantidade: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      unidade: json['unidade']?.toString() ?? 'kg/ha',
      dataAplicacao: json['data_aplicacao'] != null
          ? DateTime.tryParse(json['data_aplicacao'].toString())
          : null,
      doseMinima: json['dose_minima'] != null
          ? (json['dose_minima'] as num).toDouble()
          : null,
      doseMaxima: json['dose_maxima'] != null
          ? (json['dose_maxima'] as num).toDouble()
          : null,
      precoUnitario: json['preco_unitario'] != null
          ? (json['preco_unitario'] as num).toDouble()
          : null,
    );
  }

  Insumo copyWith({
    String? nome,
    double? quantidade,
    String? unidade,
    DateTime? dataAplicacao,
    double? doseMinima,
    double? doseMaxima,
    double? precoUnitario,
  }) {
    return Insumo(
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      dataAplicacao: dataAplicacao ?? this.dataAplicacao,
      doseMinima: doseMinima ?? this.doseMinima,
      doseMaxima: doseMaxima ?? this.doseMaxima,
      precoUnitario: precoUnitario ?? this.precoUnitario,
    );
  }
}
```

### Classe TratosCulturais (APRIMORADA)

Adicionar campos à classe existente:

```dart
class TratosCulturais {
  // ... campos existentes ...
  
  // ====== NOVOS CAMPOS (DESNORMALIZADOS) ======
  final String? talhaoNumero;
  final String? variedadeNome;
  final double? areaHaTalhao;
  // ============================================

  // NOVO: Nome amigável
  String get nomeAmigavel {
    if (talhaoNumero != null && variedadeNome != null) {
      return '$talhaoNumero - $variedadeNome';
    }
    return 'Talhão Desconhecido';
  }

  // NOVO: Custo total de insumos
  double get custoTotalInsumos {
    double total = 0.0;
    if (adubos != null) {
      total += adubos!.fold(0.0, (sum, i) => sum + i.custoTotal);
    }
    if (herbicidas != null) {
      total += herbicidas!.fold(0.0, (sum, i) => sum + i.custoTotal);
    }
    if (inseticidas != null) {
      total += inseticidas!.fold(0.0, (sum, i) => sum + i.custoTotal);
    }
    if (maturadores != null) {
      total += maturadores!.fold(0.0, (sum, i) => sum + i.custoTotal);
    }
    return total;
  }

  // NOVO: Custo total completo
  double get custoTotalCompleto {
    double total = custoTotalInsumos;
    if (areaHaTalhao != null && areaHaTalhao! > 0) {
      if (calagem != null) total += (calagem! * areaHaTalhao!);
      if (gessagem != null) total += (gessagem! * areaHaTalhao!);
      if (oxidoDeCilcio != null) total += (oxidoDeCilcio! * areaHaTalhao!);
    }
    return total;
  }

  // Adicionar aos construtores e toJson/fromJson...
}
```

### Classe InsumoComDose (NOVA)

Criar novo arquivo: `lib/models/insumo_com_dose.dart`:

```dart
class InsumoComDose {
  final String id;
  final String categoria;
  final String tipo;
  final String produto;
  final String? situacao;
  final double doseMinima;
  final double doseMaxima;
  final String unidade;
  final double precoUnitario;
  final String? observacoes;
  final DateTime dataCriacao;

  InsumoComDose({
    required this.id,
    required this.categoria,
    required this.tipo,
    required this.produto,
    this.situacao,
    required this.doseMinima,
    required this.doseMaxima,
    required this.unidade,
    required this.precoUnitario,
    this.observacoes,
    required this.dataCriacao,
  });

  factory InsumoComDose.fromJson(Map<String, dynamic> json) {
    return InsumoComDose(
      id: json['id']?.toString() ?? '',
      categoria: json['categoria']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      produto: json['produto']?.toString() ?? '',
      situacao: json['situacao']?.toString(),
      doseMinima: (json['dose_minima'] as num?)?.toDouble() ?? 0.0,
      doseMaxima: (json['dose_maxima'] as num?)?.toDouble() ?? 0.0,
      unidade: json['unidade']?.toString() ?? '',
      precoUnitario: (json['preco_unitario'] as num?)?.toDouble() ?? 0.0,
      observacoes: json['observacoes']?.toString(),
      dataCriacao: DateTime.parse(json['data_criacao']?.toString() ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria,
      'tipo': tipo,
      'produto': produto,
      'situacao': situacao,
      'dose_minima': doseMinima,
      'dose_maxima': doseMaxima,
      'unidade': unidade,
      'preco_unitario': precoUnitario,
      'observacoes': observacoes,
      'data_criacao': dataCriacao.toIso8601String(),
    };
  }
}
```

---

## 🗄️ Banco de Dados (SQL)

### Migration: Criar Tabela de Insumos

Arquivo: `lib/sql/004_insumos_com_doses.pgsql`:

```sql
-- Tabela de Insumos com Doses Recomendadas
CREATE TABLE IF NOT EXISTS public.insumos_com_doses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    categoria VARCHAR(50) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    produto VARCHAR(100) NOT NULL UNIQUE,
    situacao VARCHAR(100),
    dose_minima NUMERIC(10,2) NOT NULL,
    dose_maxima NUMERIC(10,2) NOT NULL,
    unidade VARCHAR(20) NOT NULL,
    preco_unitario NUMERIC(10,2) NOT NULL DEFAULT 0,
    observacoes TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT dose_minima_menor_maxima CHECK (dose_minima < dose_maxima)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_insumos_categoria ON public.insumos_com_doses(categoria);
CREATE INDEX IF NOT EXISTS idx_insumos_tipo ON public.insumos_com_doses(tipo);
CREATE INDEX IF NOT EXISTS idx_insumos_produto ON public.insumos_com_doses(produto);

-- RLS
ALTER TABLE public.insumos_com_doses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS insumos_com_doses_rls ON public.insumos_com_doses;
CREATE POLICY insumos_com_doses_rls ON public.insumos_com_doses
    FOR ALL USING (auth.uid() IS NOT NULL);

-- Inserir dados principais
INSERT INTO public.insumos_com_doses 
(categoria, tipo, produto, situacao, dose_minima, dose_maxima, unidade, preco_unitario, observacoes)
VALUES
('Defensivo', 'Herbicida', 'Glifosato', 'Pós-emergência', 2.5, 4.0, 'L/ha', 11.70, 'Aplicar em pós-emergência em plantas de 2-4 folhas'),
('Defensivo', 'Herbicida', '2,4-D Amina', 'Pós-emergência', 1.0, 2.0, 'L/ha', 8.50, 'Ideal para dicotiledôneas'),
('Defensivo', 'Inseticida', 'Fipronil', 'Controle de cigarrinha', 0.75, 1.0, 'L/ha', 22.50, 'Aplicar em 2-3 pulverizações'),
('Defensivo', 'Fungicida', 'Azoxistrobina', 'Controle de ferrugem', 0.5, 0.75, 'L/ha', 32.00, 'Pulverizar a partir da identificação'),
('Fertilizante', 'Mineral', 'Ureia', 'Adubação nitrogenada', 80.0, 150.0, 'kg/ha', 2.50, 'Parcelado em 2-3 aplicações'),
('Fertilizante', 'Mineral', 'DAP', 'Adubação NPK', 100.0, 200.0, 'kg/ha', 3.20, 'Excelente para plantio'),
('Fertilizante', 'Mineral', 'Cloreto de Potássio', 'Adubação potássica', 60.0, 120.0, 'kg/ha', 2.85, 'Parcelado em aplicações'),
('Fertilizante', 'Foliar', 'NPK Foliar', 'Pulverização foliar', 2.0, 3.0, 'L/ha', 12.50, 'Aplicar em 3-4 pulverizações'),
('Corretivo', 'Calcário', 'Calcário Calcítico', 'Correção de acidez', 2.0, 4.0, 't/ha', 85.00, 'Para solos com pH < 5.5'),
('Matéria Orgânica', 'Orgânico', 'Cama de Frango', 'Adubação orgânica', 10.0, 20.0, 't/ha', 65.00, 'Fresca ou compostada'),
('Biológico', 'Promotor', 'Azospirillum brasilense', 'Inoculante de solo', 200.0, 500.0, 'ml/ha', 0.18, 'Fixador de N'),
('Regulador', 'Maturador', 'Etefom', 'Maturação', 1.0, 2.0, 'L/ha', 42.00, '30-60 dias antes da colheita')
ON CONFLICT (produto) DO NOTHING;
```

---

## 🔧 Services Aprimorados

### Aprimorar TratosCulturaisService

Adicionar à classe existente em `lib/services/tratos_culturais_service.dart`:

```dart
// Novos métodos:

/// Buscar tratos agrupados por talhão
Future<Map<String, List<TratosCulturais>>> buscarTratosPorPropriedadeAgrupado(
    String propriedadeId) async {
  try {
    final tratos = await getTratosByPropriedade(propriedadeId);
    
    final Map<String, List<TratosCulturais>> agrupado = {};
    
    for (var trato in tratos) {
      final chave = trato.talhaoId ?? 'desconhecido';
      agrupado.putIfAbsent(chave, () => []).add(trato);
    }
    
    return agrupado;
  } catch (e) {
    throw Exception('Erro ao agrupar tratos: $e');
  }
}

/// Calcular custo total por talhão
Future<double> custoTotalTalhao(String talhaoId) async {
  try {
    final tratos = await getTratosByTalhao(talhaoId);
    return tratos.fold(0.0, (sum, t) => sum + t.custoTotalCompleto);
  } catch (e) {
    throw Exception('Erro ao calcular custo: $e');
  }
}

/// Buscar insumos com doses
Future<List<InsumoComDose>> buscarInsumosComDoses({
  String? categoria,
  String? tipo,
}) async {
  try {
    var query = _supabase.from('insumos_com_doses').select();
    
    if (categoria != null) query = query.eq('categoria', categoria);
    if (tipo != null) query = query.eq('tipo', tipo);
    
    final response = await query.order('produto');
    
    return (response as List)
        .map((json) => InsumoComDose.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Erro ao buscar insumos: $e');
  }
}
```

### Criar InsumoComDoseService

Novo arquivo: `lib/services/insumo_com_dose_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/insumo_com_dose.dart';

class InsumoComDoseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String tableName = 'insumos_com_doses';

  Future<List<InsumoComDose>> buscarInsumos() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .order('categoria')
          .order('tipo')
          .order('produto');
      
      return (response as List)
          .map((e) => InsumoComDose.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar insumos: $e');
    }
  }

  Future<List<InsumoComDose>> buscarPorCategoria(String categoria) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('categoria', categoria)
          .order('tipo')
          .order('produto');
      
      return (response as List)
          .map((e) => InsumoComDose.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar: $e');
    }
  }

  Future<List<InsumoComDose>> buscarPorTipo(String tipo) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('tipo', tipo)
          .order('produto');
      
      return (response as List)
          .map((e) => InsumoComDose.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<InsumoComDose?> buscarPorProduto(String produto) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('produto', produto)
          .maybeSingle();
      
      return response != null 
          ? InsumoComDose.fromJson(response)
          : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> buscarCategorias() async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('categoria')
          .distinct();
      
      final cats = (response as List)
          .map((e) => (e as Map)['categoria'] as String)
          .toList();
      cats.sort();
      return cats;
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<List<String>> buscarTiposPorCategoria(String categoria) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('tipo')
          .eq('categoria', categoria)
          .distinct();
      
      final tipos = (response as List)
          .map((e) => (e as Map)['tipo'] as String)
          .toList();
      tipos.sort();
      return tipos;
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }

  Future<List<String>> buscarProdutosPorTipo(String tipo) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select('produto')
          .eq('tipo', tipo)
          .order('produto');
      
      return (response as List)
          .map((e) => (e as Map)['produto'] as String)
          .toList();
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
```

---

## 📱 Telas Aprimoradas

### Melhorias no TratosCulturaisFormScreen

Adicionar dropdown de talhões e seletor de insumos:

```dart
// Novos estado e métodos:

List<Talhao> _talhoes = [];
Talhao? _talhaoSelecionado;
List<String>? _categorias;
List<String>? _tipos;
List<String>? _produtos;
InsumoComDose? _insumoSelecionado;

Future<void> _carregarDados() async {
  try {
    // Carregar talhões
    final talhoes = await TalhaoService()
        .getTalhoesPorPropriedade(widget.contexto.propriedade.id);
    
    // Carregar categorias
    final categorias = await InsumoComDoseService()
        .buscarCategorias();

    setState(() {
      _talhoes = talhoes;
      _categorias = categorias;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }
}

Future<void> _onCategoriaSelecionada(String? categoria) async {
  if (categoria == null) return;
  
  try {
    final tipos = await InsumoComDoseService()
        .buscarTiposPorCategoria(categoria);
    
    setState(() {
      _tipos = tipos;
      _tipoSelecionado = null;
      _produtos = null;
      _insumoSelecionado = null;
    });
  } catch (e) {
    // handle erro
  }
}

Future<void> _onProdutoSelecionado(String? produto) async {
  if (produto == null) return;
  
  try {
    final insumo = await InsumoComDoseService()
        .buscarPorProduto(produto);
    
    if (insumo != null) {
      setState(() => _insumoSelecionado = insumo);
    }
  } catch (e) {
    // handle erro
  }
}
```

### Melhorias no TratosCulturaisScreen

Adicionar agrupamento por talhão:

```dart
// Novo método:

Future<void> _carregarTratosAgrupados() async {
  try {
    final agrupados = await _service
        .buscarTratosPorPropriedadeAgrupado(widget.contexto.propriedade.id);
    
    setState(() => _tratosAgrupados = agrupados);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: $e')),
    );
  }
}

// Widget para exibir talhão agrupado:

Widget _buildTalhaoAgrupado(String talhaoId, List<TratosCulturais> tratos) {
  if (tratos.isEmpty) return const SizedBox.shrink();
  
  final primeiro = tratos.first;
  final custoTotal = tratos.fold(0.0, (sum, t) => sum + t.custoTotalCompleto);

  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        color: Colors.green[50],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primeiro.nomeAmigavel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${primeiro.areaHaTalhao ?? 0} ha',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Total:',
                    style: TextStyle(fontSize: 11)),
                Text(
                  'R\$ ${custoTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      ...tratos.map((trato) => _buildTratoCard(trato)).toList(),
      const Divider(thickness: 2),
    ],
  );
}
```

---

## 🎨 Widgets Novos

### InsumoSelectorWidget

Criar: `lib/widgets/insumo_selector_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/insumo_com_dose_service.dart';
import '../models/insumo_com_dose.dart';

class InsumoSelectorWidget extends StatefulWidget {
  final Function(InsumoComDose?) onInsumoSelecionado;

  const InsumoSelectorWidget({
    super.key,
    required this.onInsumoSelecionado,
  });

  @override
  State<InsumoSelectorWidget> createState() => _InsumoSelectorWidgetState();
}

class _InsumoSelectorWidgetState extends State<InsumoSelectorWidget> {
  final InsumoComDoseService _service = InsumoComDoseService();
  
  List<String>? _categorias;
  List<String>? _tipos;
  List<String>? _produtos;
  
  String? _categoriaSelecionada;
  String? _tipoSelecionado;
  String? _produtoSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      final cats = await _service.buscarCategorias();
      setState(() => _categorias = cats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _onCategoriaSelecionada(String? categoria) async {
    if (categoria == null) return;
    
    try {
      final tipos = await _service.buscarTiposPorCategoria(categoria);
      setState(() {
        _categoriaSelecionada = categoria;
        _tipos = tipos;
        _tipoSelecionado = null;
        _produtoSelecionado = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _onTipoSelecionado(String? tipo) async {
    if (tipo == null) return;
    
    try {
      final produtos = await _service.buscarProdutosPorTipo(tipo);
      setState(() {
        _tipoSelecionado = tipo;
        _produtos = produtos;
        _produtoSelecionado = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _onProdutoSelecionado(String? produto) async {
    if (produto == null) return;
    
    try {
      final insumo = await _service.buscarPorProduto(produto);
      setState(() => _produtoSelecionado = produto);
      widget.onInsumoSelecionado(insumo);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
          ),
          value: _categoriaSelecionada,
          items: _categorias?.map((c) => DropdownMenuItem(
            value: c,
            child: Text(c),
          )).toList(),
          onChanged: _onCategoriaSelecionada,
        ),
        if (_tipos != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
            ),
            value: _tipoSelecionado,
            items: _tipos!.map((t) => DropdownMenuItem(
              value: t,
              child: Text(t),
            )).toList(),
            onChanged: _onTipoSelecionado,
          ),
        ],
        if (_produtos != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Produto',
              border: OutlineInputBorder(),
            ),
            value: _produtoSelecionado,
            items: _produtos!.map((p) => DropdownMenuItem(
              value: p,
              child: Text(p),
            )).toList(),
            onChanged: _onProdutoSelecionado,
          ),
        ],
      ],
    );
  }
}
```

---

## 💻 Exemplos de Código

### Buscar Insumos

```dart
final service = InsumoComDoseService();

// Categorias
final cats = await service.buscarCategorias();

// Tipos de uma categoria
final tipos = await service.buscarTiposPorCategoria('Defensivo');

// Produtos de um tipo
final produtos = await service.buscarProdutosPorTipo('Herbicida');

// Insumo específico
final insumo = await service.buscarPorProduto('Glifosato');

if (insumo != null) {
  print('Doses: ${insumo.doseMinima}-${insumo.doseMaxima} ${insumo.unidade}');
  print('Preço: R\$ ${insumo.precoUnitario}');
}
```

### Calcular Custo

```dart
final insumo = Insumo(
  nome: 'Glifosato',
  quantidade: 3.0,
  unidade: 'L/ha',
  precoUnitario: 11.70,
);

// Custo total
print('Custo: R\$ ${insumo.custoTotal.toStringAsFixed(2)}');

// Status da dose
if (insumo.doseEstaNoRange) {
  print('✓ ${insumo.statusDose}');
} else {
  print('⚠️ ${insumo.statusDose}');
}
```

### Agrupamento

```dart
final tratoService = TratosCulturaisService();
final agrupados = await tratoService
    .buscarTratosPorPropriedadeAgrupado(propriedadeId);

agrupados.forEach((talhaoId, tratos) {
  print('Talhão: ${tratos.first.nomeAmigavel}');
  print('Custo: R\$ ${tratos.fold(0.0, (sum, t) => sum + t.custoTotalCompleto)}');
});
```

---

## ✅ Checklist de Implementação

### Pré-requisitos
- [ ] Entender estrutura do projeto
- [ ] Acesso ao Supabase
- [ ] Flutter 3.0+ instalado

### Fase 1: Modelos (1 hora)
- [ ] Aprimorar classe `Insumo`
- [ ] Aprimorar classe `TratosCulturais`
- [ ] Criar classe `InsumoComDose`
- [ ] Exportar em `models.dart`

### Fase 2: Banco (1-2 horas)
- [ ] Executar migration SQL
- [ ] Inserir dados de insumos
- [ ] Testar no Supabase

### Fase 3: Services (1-2 horas)
- [ ] Aprimorar `TratosCulturaisService`
- [ ] Criar `InsumoComDoseService`
- [ ] Testar cada método

### Fase 4: Widgets (1 hora)
- [ ] Criar `InsumoSelectorWidget`
- [ ] Testar em isolamento

### Fase 5: Telas (2-3 horas)
- [ ] Aprimorar `TratosCulturaisFormScreen`
- [ ] Aprimorar `TratosCulturaisScreen`
- [ ] Integrar todos os widgets

### Fase 6: Testes (1-2 horas)
- [ ] Rodar `flutter analyze`
- [ ] Testar fluxo completo
- [ ] Validar cálculos

---

## 🎯 Conclusão

Este documento fornece um guia **completo e prático** para melhorar o módulo de Tratos Culturais.

**Tempo total estimado:** 8-16 horas de desenvolvimento.

**Próximos passos:** Comece pela Fase 1 (Modelos) e progredagradualmente.

