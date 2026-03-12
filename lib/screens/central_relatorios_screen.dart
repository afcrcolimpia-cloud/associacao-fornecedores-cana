import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/custo_operacional_service.dart';
import '../services/operacao_cultivo_service.dart';
import '../services/precipitacao_service.dart';
import '../services/produtividade_service.dart';
import '../services/talhao_service.dart';
import '../services/tratos_culturais_service.dart';
import '../services/variedade_service.dart';
import '../services/analise_solo_service.dart';
import '../services/pdf_generators/pdf_custo.dart';
import '../services/pdf_generators/pdf_operacoes.dart';
import '../services/pdf_generators/pdf_precipitacao.dart';
import '../services/pdf_generators/pdf_produtividade.dart';
import '../services/pdf_generators/pdf_talhoes.dart';
import '../services/pdf_generators/pdf_tratos.dart';
import '../services/pdf_generators/pdf_analise_solo.dart';
import '../services/pdf_generators/pdf_censo_varietal.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';

/// Central de Relatórios — permite ao proprietário selecionar uma categoria
/// de registros operacionais e gerar o PDF correspondente.
class CentralRelatoriosScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const CentralRelatoriosScreen({super.key, required this.contexto});

  @override
  State<CentralRelatoriosScreen> createState() =>
      _CentralRelatoriosScreenState();
}

// ─── Enum de categorias disponíveis ────────────────────────────────────────
enum _Categoria {
  talhoes,
  produtividade,
  precipitacao,
  operacoesCultivo,
  tratosCulturais,
  custoOperacional,
  censoVarietal,
  analiseSolo,
}

extension _CategoriaLabel on _Categoria {
  String get label {
    switch (this) {
      case _Categoria.talhoes:
        return 'Talhões';
      case _Categoria.produtividade:
        return 'Produtividade';
      case _Categoria.precipitacao:
        return 'Precipitação';
      case _Categoria.operacoesCultivo:
        return 'Operações de Cultivo';
      case _Categoria.tratosCulturais:
        return 'Tratos Culturais';
      case _Categoria.custoOperacional:
        return 'Custo Operacional';
      case _Categoria.censoVarietal:
        return 'Censo Varietal';
      case _Categoria.analiseSolo:
        return 'Análise de Solo';
    }
  }

  IconData get icon {
    switch (this) {
      case _Categoria.talhoes:
        return Icons.agriculture;
      case _Categoria.produtividade:
        return Icons.trending_up;
      case _Categoria.precipitacao:
        return Icons.cloud;
      case _Categoria.operacoesCultivo:
        return Icons.build;
      case _Categoria.tratosCulturais:
        return Icons.spa;
      case _Categoria.custoOperacional:
        return Icons.money;
      case _Categoria.censoVarietal:
        return Icons.grass;
      case _Categoria.analiseSolo:
        return Icons.science;
    }
  }
}

// ─── Representa um item selecionável no dropdown secundário ────────────────
class _ItemRelatorio {
  final String id;
  final String descricao;
  final dynamic dados; // objeto original (cenário, ano, etc.)

  const _ItemRelatorio({
    required this.id,
    required this.descricao,
    required this.dados,
  });
}

class _CentralRelatoriosScreenState extends State<CentralRelatoriosScreen> {
  int _selectedIndex = 0;

  _Categoria? _categoriaSelecionada;
  _ItemRelatorio? _itemSelecionado;

  bool _carregandoItens = false;
  List<_ItemRelatorio> _itensDisponiveis = [];
  String? _mensagemVazia;

  bool _gerandoPdf = false;

  // ─── Services ──────────────────────────────────────────────────────────
  final _talhaoService = TalhaoService();
  final _produtividadeService = ProdutividadeService();
  final _precipitacaoService = PrecipitacaoService();
  final _operacaoService = OperacaoCultivoService();
  final _tratosService = TratosCulturaisService();
  final _custoService = CustoOperacionalService();
  final _variedadeService = VariedadeService();
  final _analiseSoloService = AnaliseSoloService();

  String get _propId => widget.contexto.propriedade.id;

  // ─── Carregar itens de acordo com a categoria ──────────────────────────
  Future<void> _carregarItens(_Categoria categoria) async {
    setState(() {
      _carregandoItens = true;
      _itensDisponiveis = [];
      _itemSelecionado = null;
      _mensagemVazia = null;
    });

    try {
      switch (categoria) {
        case _Categoria.talhoes:
          await _carregarTalhoes();
          break;
        case _Categoria.produtividade:
          await _carregarProdutividade();
          break;
        case _Categoria.precipitacao:
          await _carregarPrecipitacao();
          break;
        case _Categoria.operacoesCultivo:
          await _carregarOperacoes();
          break;
        case _Categoria.tratosCulturais:
          await _carregarTratos();
          break;
        case _Categoria.custoOperacional:
          await _carregarCusto();
          break;
        case _Categoria.censoVarietal:
          await _carregarCensoVarietal();
          break;
        case _Categoria.analiseSolo:
          await _carregarAnaliseSolo();
          break;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemVazia = 'Erro ao carregar dados: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _carregandoItens = false);
      }
    }
  }

  // ─── Carregadores por categoria ────────────────────────────────────────

  Future<void> _carregarTalhoes() async {
    final talhoes = await _talhaoService.getTalhoesPorPropriedade(_propId);
    if (talhoes.isEmpty) {
      _mensagemVazia = 'Nenhum talhão cadastrado';
      return;
    }
    // Talhões gera um único PDF com todos — item único
    _itensDisponiveis = [
      _ItemRelatorio(
        id: 'todos',
        descricao: 'Todos os talhões (${talhoes.length})',
        dados: talhoes,
      ),
    ];
  }

  Future<void> _carregarProdutividade() async {
    final anos = await _produtividadeService.getAnosSafraDisponiveis(_propId);
    if (anos.isEmpty) {
      _mensagemVazia = 'Nenhum registro de produtividade';
      return;
    }
    _itensDisponiveis = anos
        .map((ano) => _ItemRelatorio(
              id: ano,
              descricao: 'Safra $ano',
              dados: ano,
            ))
        .toList();
  }

  Future<void> _carregarPrecipitacao() async {
    final precipitacoes =
        await _precipitacaoService.getPrecipitacoesByPropriedade(_propId);
    if (precipitacoes.isEmpty) {
      _mensagemVazia = 'Nenhum registro de precipitação';
      return;
    }
    // Agrupar por ano
    final anosSet = <int>{};
    for (final p in precipitacoes) {
      anosSet.add(p.ano);
    }
    final anos = anosSet.toList()..sort((a, b) => b.compareTo(a));
    if (anos.isEmpty) {
      _mensagemVazia = 'Nenhum ano de precipitação encontrado';
      return;
    }
    _itensDisponiveis = anos
        .map((ano) => _ItemRelatorio(
              id: ano.toString(),
              descricao: 'Ano $ano',
              dados: {'ano': ano, 'precipitacoes': precipitacoes},
            ))
        .toList();
  }

  Future<void> _carregarOperacoes() async {
    final operacoes = await _operacaoService
        .getOperacoesPorPropriedade(_propId)
        .first;
    if (operacoes.isEmpty) {
      _mensagemVazia = 'Nenhuma operação de cultivo registrada';
      return;
    }
    // Um PDF com todas as operações
    _itensDisponiveis = [
      _ItemRelatorio(
        id: 'todos',
        descricao: 'Todas as operações (${operacoes.length})',
        dados: operacoes,
      ),
    ];
  }

  Future<void> _carregarTratos() async {
    final tratos = await _tratosService.getTratosByPropriedade(_propId);
    if (tratos.isEmpty) {
      _mensagemVazia = 'Nenhum trato cultural registrado';
      return;
    }
    // Agrupar por ano da safra
    final anosSet = <String>{};
    for (final t in tratos) {
      if (t.anoSafra.isNotEmpty) anosSet.add(t.anoSafra);
    }
    final anos = anosSet.toList()..sort((a, b) => b.compareTo(a));
    if (anos.isEmpty) {
      // Se nenhum trato tem anoSafra, exibir todos
      _itensDisponiveis = [
        _ItemRelatorio(
          id: 'todos',
          descricao: 'Todos os tratos (${tratos.length})',
          dados: {'ano': DateTime.now().year.toString(), 'tratos': tratos},
        ),
      ];
      return;
    }
    _itensDisponiveis = anos
        .map((ano) => _ItemRelatorio(
              id: ano,
              descricao: 'Safra $ano',
              dados: {
                'ano': ano,
                'tratos': tratos.where((t) => t.anoSafra == ano).toList(),
              },
            ))
        .toList();
  }

  Future<void> _carregarCusto() async {
    final cenarios = await _custoService.getCenariosByPropriedade(_propId);
    if (cenarios.isEmpty) {
      _mensagemVazia = 'Nenhum cenário de custo operacional';
      return;
    }
    _itensDisponiveis = cenarios
        .map((c) => _ItemRelatorio(
              id: c.id ?? c.nomeCenario,
              descricao: '${c.nomeCenario} — ${c.periodoRef}',
              dados: c,
            ))
        .toList();
  }

  Future<void> _carregarCensoVarietal() async {
    final talhoes = await _talhaoService.getTalhoesPorPropriedade(_propId);
    if (talhoes.isEmpty) {
      _mensagemVazia = 'Nenhum talhão cadastrado para censo varietal';
      return;
    }
    // Carregar variedades para mapa
    final variedades = await _variedadeService.getAllVariedades();
    final variedadeMap = <String, Variedade>{};
    for (final v in variedades) {
      variedadeMap[v.id] = v;
    }
    _itensDisponiveis = [
      _ItemRelatorio(
        id: 'censo',
        descricao: 'Censo Varietal Completo (${talhoes.length} talhões)',
        dados: {'talhoes': talhoes, 'variedadeMap': variedadeMap},
      ),
    ];
  }

  Future<void> _carregarAnaliseSolo() async {
    final analises =
        await _analiseSoloService.getAnalisesPorPropriedade(_propId);
    if (analises.isEmpty) {
      _mensagemVazia = 'Nenhuma análise de solo registrada';
      return;
    }
    _itensDisponiveis = analises
        .map((a) => _ItemRelatorio(
              id: a.id,
              descricao:
                  '${a.laboratorio ?? "Análise"} — ${a.dataColeta != null ? '${a.dataColeta!.day.toString().padLeft(2, '0')}/${a.dataColeta!.month.toString().padLeft(2, '0')}/${a.dataColeta!.year}' : 'Sem data'}${a.numeroAmostra != null ? ' (Amostra ${a.numeroAmostra})' : ''}',
              dados: a,
            ))
        .toList();
  }

  // ─── Gerar PDF ─────────────────────────────────────────────────────────

  Future<void> _gerarPdf() async {
    if (_categoriaSelecionada == null || _itemSelecionado == null) return;
    setState(() => _gerandoPdf = true);

    try {
      final propriedade = widget.contexto.propriedade;

      switch (_categoriaSelecionada!) {
        case _Categoria.talhoes:
          final talhoes = _itemSelecionado!.dados as List<Talhao>;
          final bytes = await PdfTalhoes.gerar(
            propriedade: propriedade,
            talhoes: talhoes,
          );
          await _exibirPdf(bytes, 'Talhoes');
          break;

        case _Categoria.produtividade:
          final anoSafra = _itemSelecionado!.dados as String;
          final produtividades = await _produtividadeService
              .getProdutividadePorPropriedade(_propId)
              .first;
          final filtradas = produtividades
              .where((p) => p.anoSafra == anoSafra)
              .toList();
          final bytes = await PdfProdutividade.gerar(
            propriedade: propriedade,
            dadosProdutividade: filtradas,
            anoSafra: anoSafra,
          );
          await _exibirPdf(bytes, 'Produtividade_$anoSafra');
          break;

        case _Categoria.precipitacao:
          final map = _itemSelecionado!.dados as Map<String, dynamic>;
          final ano = map['ano'] as int;
          final precipitacoes = map['precipitacoes'] as List<Precipitacao>;
          final bytes = await PdfPrecipitacao.gerar(
            propriedade: propriedade,
            dadosPrecipitacao: precipitacoes,
            ano: ano,
          );
          await _exibirPdf(bytes, 'Precipitacao_$ano');
          break;

        case _Categoria.operacoesCultivo:
          final operacoes = _itemSelecionado!.dados as List<OperacaoCultivo>;
          final bytes = await PdfOperacoesCultivo.gerar(
            propriedade: propriedade,
            operacoes: operacoes,
          );
          await _exibirPdf(bytes, 'Operacoes_Cultivo');
          break;

        case _Categoria.tratosCulturais:
          final map = _itemSelecionado!.dados as Map<String, dynamic>;
          final anoStr = map['ano'] as String;
          final tratos = map['tratos'] as List<TratosCulturais>;
          final bytes = await PdfTratosCulturais.gerar(
            propriedade: propriedade,
            tratos: tratos,
            anoSafra: int.tryParse(anoStr) ?? DateTime.now().year,
          );
          await _exibirPdf(bytes, 'Tratos_Culturais_$anoStr');
          break;

        case _Categoria.custoOperacional:
          final cenario = _itemSelecionado!.dados as CustoOperacionalCenario;
          final bytes = await PdfCustoOperacional.gerar(
            propriedade: propriedade,
            cenario: cenario,
          );
          await _exibirPdf(bytes, 'Custo_Operacional_${cenario.nomeCenario}');
          break;

        case _Categoria.censoVarietal:
          final map = _itemSelecionado!.dados as Map<String, dynamic>;
          final talhoes = map['talhoes'] as List<Talhao>;
          final variedadeMap = map['variedadeMap'] as Map<String, Variedade>;
          final bytes = await PdfCensoVarietal.gerar(
            contexto: widget.contexto,
            talhoes: talhoes,
            variedadeMap: variedadeMap,
          );
          await _exibirPdf(bytes, 'Censo_Varietal');
          break;

        case _Categoria.analiseSolo:
          final analise = _itemSelecionado!.dados as AnaliseSolo;
          final talhoesSolo = await _talhaoService.getTalhoesPorPropriedade(_propId);
          final bytes = await PdfAnaliseSolo.gerar(
            propriedade: propriedade,
            analises: [analise],
            talhoes: talhoesSolo,
          );
          await _exibirPdf(bytes, 'Analise_Solo');
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _gerandoPdf = false);
    }
  }

  Future<void> _exibirPdf(dynamic bytes, String nomeBase) async {
    if (!mounted) return;
    await Printing.layoutPdf(
      onLayout: (_) => bytes,
      name: '${nomeBase}_${widget.contexto.nomePropriedade}.pdf',
      format: PdfPageFormat.a4,
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedIndex,
      onNavigationSelect: (i) => setState(() => _selectedIndex = i),
      showBackButton: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Central de Relatórios'),
          backgroundColor: AppColors.primary,
          elevation: 0,
        ),
        body: Column(
          children: [
            HeaderPropriedade(contexto: widget.contexto),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Título ────────────────────────────────────
                        const Text(
                          'Gerar Relatórios PDF',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selecione a categoria e o registro desejado para gerar o relatório em PDF.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Dropdown 1: Categoria ────────────────────
                        _buildLabel('Categoria do Relatório'),
                        const SizedBox(height: 8),
                        _buildDropdownCategoria(),
                        const SizedBox(height: 24),

                        // ── Dropdown 2: Item específico ──────────────
                        if (_categoriaSelecionada != null) ...[
                          _buildLabel('Selecionar Registro'),
                          const SizedBox(height: 8),
                          if (_carregandoItens)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_mensagemVazia != null)
                            _buildMensagemVazia()
                          else
                            _buildDropdownItem(),
                          const SizedBox(height: 24),
                        ],

                        // ── Resumo do selecionado ────────────────────
                        if (_itemSelecionado != null) ...[
                          _buildResumo(),
                          const SizedBox(height: 24),
                        ],

                        // ── Botão Gerar PDF ──────────────────────────
                        if (_itemSelecionado != null)
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _gerandoPdf ? null : _gerarPdf,
                              icon: _gerandoPdf
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.picture_as_pdf),
                              label: Text(
                                _gerandoPdf
                                    ? 'Gerando PDF...'
                                    : 'Gerar Relatório PDF',
                                style: const TextStyle(fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Widgets auxiliares ────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDropdownCategoria() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_Categoria>(
          value: _categoriaSelecionada,
          isExpanded: true,
          hint: const Text('Selecione uma categoria...'),
          items: _Categoria.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Icon(cat.icon, size: 20, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Text(cat.label),
                ],
              ),
            );
          }).toList(),
          onChanged: (cat) {
            if (cat == null) return;
            setState(() {
              _categoriaSelecionada = cat;
              _itemSelecionado = null;
            });
            _carregarItens(cat);
          },
        ),
      ),
    );
  }

  Widget _buildDropdownItem() {
    if (_itensDisponiveis.isEmpty) {
      return _buildMensagemVazia();
    }

    // Se há apenas 1 item, selecionar automaticamente
    if (_itensDisponiveis.length == 1 && _itemSelecionado == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _itemSelecionado = _itensDisponiveis.first);
        }
      });
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_ItemRelatorio>(
          value: _itemSelecionado,
          isExpanded: true,
          hint: const Text('Selecione o registro...'),
          items: _itensDisponiveis.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item.descricao,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (item) {
            setState(() => _itemSelecionado = item);
          },
        ),
      ),
    );
  }

  Widget _buildMensagemVazia() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _mensagemVazia ?? 'Nenhum dado disponível para esta categoria',
              style: TextStyle(color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _categoriaSelecionada?.icon ?? Icons.description,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Relatório selecionado',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildResumoLinha(
              'Categoria', _categoriaSelecionada?.label ?? ''),
          _buildResumoLinha('Registro', _itemSelecionado?.descricao ?? ''),
          _buildResumoLinha(
              'Propriedade', widget.contexto.nomePropriedade),
          _buildResumoLinha(
              'Proprietário', widget.contexto.nomeProprietario),
        ],
      ),
    );
  }

  Widget _buildResumoLinha(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
