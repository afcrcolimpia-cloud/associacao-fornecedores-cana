import 'package:flutter/material.dart';
import '../models/insumo_com_dose.dart';
import '../services/insumo_com_dose_service.dart';

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
  List<InsumoComDose>? _produtos;

  String? _categoriaSelecionada;
  String? _tipoSelecionado;
  InsumoComDose? _produtoSelecionado;

  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarCategorias();
  }

  Future<void> _carregarCategorias() async {
    try {
      setState(() => _carregando = true);
      final cats = await _service.buscarCategorias();
      if (mounted) {
        setState(() {
          _categorias = cats;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  Future<void> _onCategoriaSelecionada(String? categoria) async {
    if (categoria == null) return;

    try {
      setState(() {
        _categoriaSelecionada = categoria;
        _tipoSelecionado = null;
        _produtos = null;
        _produtoSelecionado = null;
        _carregando = true;
      });
      widget.onInsumoSelecionado(null);

      final tipos = await _service.buscarTiposPorCategoria(categoria);
      if (mounted) {
        setState(() {
          _tipos = tipos;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _onTipoSelecionado(String? tipo) async {
    if (tipo == null || _categoriaSelecionada == null) return;

    try {
      setState(() {
        _tipoSelecionado = tipo;
        _produtoSelecionado = null;
        _carregando = true;
      });
      widget.onInsumoSelecionado(null);

      final produtos = await _service.buscarProdutosPorCategoriaETipo(
          _categoriaSelecionada!, tipo);
      if (mounted) {
        setState(() {
          _produtos = produtos;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  void _onProdutoSelecionado(InsumoComDose? produto) {
    setState(() => _produtoSelecionado = produto);
    widget.onInsumoSelecionado(produto);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Categoria',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          value: _categoriaSelecionada,
          items: _categorias?.map((c) => DropdownMenuItem(
            value: c,
            child: Text(c),
          )).toList(),
          onChanged: _onCategoriaSelecionada,
          hint: const Text('Selecione a categoria'),
        ),
        if (_tipos != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Tipo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            value: _tipoSelecionado,
            items: _tipos!.map((t) => DropdownMenuItem(
              value: t,
              child: Text(t),
            )).toList(),
            onChanged: _onTipoSelecionado,
            hint: const Text('Selecione o tipo'),
          ),
        ],
        if (_produtos != null) ...[
          const SizedBox(height: 12),
          DropdownButtonFormField<InsumoComDose>(
            decoration: const InputDecoration(
              labelText: 'Produto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.shopping_bag),
            ),
            value: _produtoSelecionado,
            items: _produtos!.map((p) => DropdownMenuItem(
              value: p,
              child: Text(p.produto),
            )).toList(),
            onChanged: _onProdutoSelecionado,
            hint: const Text('Selecione o produto'),
          ),
        ],
        if (_produtoSelecionado != null) ...[
          const SizedBox(height: 12),
          _buildResumoInsumo(_produtoSelecionado!),
        ],
        if (_carregando) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }

  Widget _buildResumoInsumo(InsumoComDose insumo) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              insumo.produto,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text('Dose: ${insumo.doseMinima} - ${insumo.doseMaxima} ${insumo.unidade}'),
            Text('Preço: R\$ ${insumo.precoUnitario.toStringAsFixed(2)} / ${insumo.unidade}'),
            if (insumo.situacao != null && insumo.situacao!.isNotEmpty)
              Text('Situação: ${insumo.situacao}'),
            if (insumo.observacoes != null && insumo.observacoes!.isNotEmpty)
              Text(
                insumo.observacoes!,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
