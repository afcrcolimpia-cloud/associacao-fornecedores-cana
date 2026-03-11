import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/analise_solo_service.dart';
import '../services/talhao_service.dart';
import 'analise_solo_form_screen.dart';

class InterpretacaoAnaliseSoloScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const InterpretacaoAnaliseSoloScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<InterpretacaoAnaliseSoloScreen> createState() =>
      _InterpretacaoAnaliseSoloScreenState();
}

class _InterpretacaoAnaliseSoloScreenState
    extends State<InterpretacaoAnaliseSoloScreen> {
  final AnaliseSoloService _service = AnaliseSoloService();
  final TalhaoService _talhaoService = TalhaoService();
  int _selectedNavigationIndex = 0;

  List<AnaliseSolo> _analises = [];
  List<Talhao> _talhoes = [];
  bool _carregando = true;
  String? _talhaoFiltro;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _carregando = true);
    try {
      final results = await Future.wait([
        _service.getAnalisesPorPropriedade(widget.contexto.propriedade.id),
        _talhaoService.getTalhoesPorPropriedade(widget.contexto.propriedade.id),
      ]);

      if (mounted) {
        setState(() {
          _analises = results[0] as List<AnaliseSolo>;
          _talhoes = results[1] as List<Talhao>;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  List<AnaliseSolo> get _analisesFiltradas {
    if (_talhaoFiltro == null) return _analises;
    return _analises.where((a) => a.talhaoId == _talhaoFiltro).toList();
  }

  String _nomeTalhao(String? talhaoId) {
    if (talhaoId == null) return 'Geral';
    final talhao = _talhoes.where((t) => t.id == talhaoId).firstOrNull;
    return talhao?.nome ?? 'Talhão $talhaoId';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Interpretação de Análises de Solo',
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          _buildBannerBoletim100(),
          _buildFiltros(),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _analisesFiltradas.isEmpty
                    ? _buildEstadoVazio()
                    : _buildListaAnalises(),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerBoletim100() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.newInfo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.newInfo.withValues(alpha: 0.3)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book, color: AppColors.newInfo, size: 32),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interpretação baseada no Boletim 100 do IAC',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.newTextPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Os critérios de interpretação dos resultados de análise de solo '
                  'seguem as tabelas de classes de teores e faixas de fertilidade '
                  'do Boletim Técnico 100 — "Recomendações de Adubação e Calagem '
                  'para o Estado de São Paulo" (IAC, 1997). '
                  'As faixas Muito Baixo, Baixo, Médio, Alto e Muito Alto são '
                  'aplicadas automaticamente a cada parâmetro conforme a referência oficial.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.newTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String?>(
              value: _talhaoFiltro,
              decoration: InputDecoration(
                labelText: 'Filtrar por Talhão',
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos os Talhões'),
                ),
                ..._talhoes.map((t) => DropdownMenuItem<String?>(
                      value: t.id,
                      child: Text(t.nome),
                    )),
              ],
              onChanged: (value) {
                setState(() => _talhaoFiltro = value);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _adicionarAnalise,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nova Análise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimary,
              foregroundColor: AppColors.bgDark,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma análise de solo cadastrada',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Adicione uma análise para visualizar a interpretação',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _adicionarAnalise,
            icon: const Icon(Icons.add),
            label: const Text('Cadastrar Primeira Análise'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimary,
              foregroundColor: AppColors.bgDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaAnalises() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _analisesFiltradas.length,
      itemBuilder: (context, index) {
        final analise = _analisesFiltradas[index];
        return _buildAnaliseCard(analise);
      },
    );
  }

  Widget _buildAnaliseCard(AnaliseSolo analise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: AppColors.newPrimary.withValues(alpha: 0.1),
            child: const Icon(Icons.science, color: AppColors.newPrimary),
          ),
          title: Text(
            _nomeTalhao(analise.talhaoId),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            '${analise.laboratorio ?? "Lab. não informado"} — '
            '${analise.dataColeta != null ? _formatarData(analise.dataColeta!) : "Data não informada"}'
            '${analise.numeroAmostra != null ? " — Amostra: ${analise.numeroAmostra}" : ""}',
            style: const TextStyle(fontSize: 12, color: AppColors.newTextSecondary),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _editarAnalise(analise),
                tooltip: 'Editar',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: AppColors.newDanger),
                onPressed: () => _confirmarExclusao(analise),
                tooltip: 'Excluir',
              ),
            ],
          ),
          children: [
            _buildInterpretacaoCompleta(analise),
          ],
        ),
      ),
    );
  }

  Widget _buildInterpretacaoCompleta(AnaliseSolo analise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          'Interpretação — Boletim 100',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),

        // Macronutrientes
        _buildSecaoInterpretacao('Macronutrientes e Acidez', [
          if (analise.ph != null)
            _buildLinhaInterpretacao(
                'pH (CaCl₂)', analise.ph!, '',
                InterpretacaoBoletim100.interpretarPH(analise.ph!)),
          if (analise.materiaOrganica != null)
            _buildLinhaInterpretacao(
                'Matéria Orgânica', analise.materiaOrganica!, 'g/dm³',
                InterpretacaoBoletim100.interpretarMateriaOrganica(
                    analise.materiaOrganica!)),
          if (analise.fosforo != null)
            _buildLinhaInterpretacao(
                'Fósforo (P resina)', analise.fosforo!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarFosforo(analise.fosforo!)),
          if (analise.potassio != null)
            _buildLinhaInterpretacao(
                'Potássio (K)', analise.potassio!, 'mmolc/dm³',
                InterpretacaoBoletim100.interpretarPotassio(
                    analise.potassio!)),
          if (analise.calcio != null)
            _buildLinhaInterpretacao(
                'Cálcio (Ca)', analise.calcio!, 'mmolc/dm³',
                InterpretacaoBoletim100.interpretarCalcio(analise.calcio!)),
          if (analise.magnesio != null)
            _buildLinhaInterpretacao(
                'Magnésio (Mg)', analise.magnesio!, 'mmolc/dm³',
                InterpretacaoBoletim100.interpretarMagnesio(
                    analise.magnesio!)),
          if (analise.enxofre != null)
            _buildLinhaInterpretacao(
                'Enxofre (S-SO₄)', analise.enxofre!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarEnxofre(analise.enxofre!)),
        ]),

        // CTC
        _buildSecaoInterpretacao('Complexo de Troca', [
          if (analise.saturacaoBases != null)
            _buildLinhaInterpretacao(
                'Saturação por Bases (V%)', analise.saturacaoBases!, '%',
                InterpretacaoBoletim100.interpretarSaturacaoBases(
                    analise.saturacaoBases!)),
          if (analise.ctc != null)
            _buildLinhaInterpretacao(
                'CTC', analise.ctc!, 'mmolc/dm³',
                InterpretacaoBoletim100.interpretarCTC(analise.ctc!)),
          if (analise.somasBases != null)
            _buildLinhaValor('Soma de Bases (SB)', analise.somasBases!,
                'mmolc/dm³'),
          if (analise.acidezPotencial != null)
            _buildLinhaValor('Acidez Potencial (H+Al)',
                analise.acidezPotencial!, 'mmolc/dm³'),
          if (analise.aluminio != null)
            _buildLinhaValor('Alumínio (Al)', analise.aluminio!, 'mmolc/dm³'),
        ]),

        // Micronutrientes
        _buildSecaoInterpretacao('Micronutrientes', [
          if (analise.boro != null)
            _buildLinhaInterpretacao(
                'Boro (B)', analise.boro!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarBoro(analise.boro!)),
          if (analise.cobre != null)
            _buildLinhaInterpretacao(
                'Cobre (Cu)', analise.cobre!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarCobre(analise.cobre!)),
          if (analise.ferro != null)
            _buildLinhaInterpretacao(
                'Ferro (Fe)', analise.ferro!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarFerro(analise.ferro!)),
          if (analise.manganes != null)
            _buildLinhaInterpretacao(
                'Manganês (Mn)', analise.manganes!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarManganes(
                    analise.manganes!)),
          if (analise.zinco != null)
            _buildLinhaInterpretacao(
                'Zinco (Zn)', analise.zinco!, 'mg/dm³',
                InterpretacaoBoletim100.interpretarZinco(analise.zinco!)),
        ]),

        // Textura
        if (analise.argila != null ||
            analise.silte != null ||
            analise.areia != null)
          _buildSecaoInterpretacao('Textura', [
            if (analise.argila != null)
              _buildLinhaValor('Argila', analise.argila!, 'g/kg'),
            if (analise.silte != null)
              _buildLinhaValor('Silte', analise.silte!, 'g/kg'),
            if (analise.areia != null)
              _buildLinhaValor('Areia', analise.areia!, 'g/kg'),
          ]),

        if (analise.observacoes != null && analise.observacoes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Obs: ${analise.observacoes}',
            style: const TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: AppColors.newTextMuted,
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSecaoInterpretacao(String titulo, List<Widget> linhas) {
    if (linhas.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: AppColors.newTextSecondary,
          ),
        ),
        const SizedBox(height: 4),
        ...linhas,
      ],
    );
  }

  Widget _buildLinhaInterpretacao(
      String nome, double valor, String unidade, FaixaInterpretacao faixa) {
    final corFaixa = _corDaFaixa(faixa);
    final texto = InterpretacaoBoletim100.textoFaixa(faixa);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(nome,
                style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${valor.toStringAsFixed(1)} $unidade',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: corFaixa.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: corFaixa.withValues(alpha: 0.4)),
            ),
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: corFaixa,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinhaValor(String nome, double valor, String unidade) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(nome, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${valor.toStringAsFixed(1)} $unidade',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Color _corDaFaixa(FaixaInterpretacao faixa) {
    switch (faixa) {
      case FaixaInterpretacao.muitoBaixo:
        return AppColors.newDanger;
      case FaixaInterpretacao.baixo:
        return AppColors.newWarning;
      case FaixaInterpretacao.medio:
        return AppColors.newInfo;
      case FaixaInterpretacao.alto:
        return AppColors.newSuccess;
      case FaixaInterpretacao.muitoAlto:
        return const Color(0xFF7C3AED); // Roxo para muito alto
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _adicionarAnalise() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AnaliseSoloFormScreen(
          contexto: widget.contexto,
          talhoes: _talhoes,
        ),
      ),
    );
    if (resultado == true) {
      _carregarDados();
    }
  }

  void _editarAnalise(AnaliseSolo analise) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AnaliseSoloFormScreen(
          contexto: widget.contexto,
          talhoes: _talhoes,
          analise: analise,
        ),
      ),
    );
    if (resultado == true) {
      _carregarDados();
    }
  }

  Future<void> _confirmarExclusao(AnaliseSolo analise) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a análise de solo '
          '${analise.numeroAmostra ?? "sem número"} '
          'do ${_nomeTalhao(analise.talhaoId)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.newDanger),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.deletarAnalise(analise.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Análise excluída com sucesso')),
          );
          _carregarDados();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao excluir: $e')),
          );
        }
      }
    }
  }
}
