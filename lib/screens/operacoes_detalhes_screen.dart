import 'package:flutter/material.dart';
import '../widgets/app_shell.dart';
import '../services/dados_custo_operacional.dart';
import '../services/custo_operacional_service.dart';
import '../models/operacao_custos.dart';
import '../constants/app_colors.dart';

class OperacoesDetalhesScreen extends StatefulWidget {
  final CustoOperacionalCenario cenario;
  const OperacoesDetalhesScreen({super.key, required this.cenario});

  @override
  State<OperacoesDetalhesScreen> createState() =>
      _OperacoesDetalhesScreenState();
}

class _OperacoesDetalhesScreenState extends State<OperacoesDetalhesScreen> {
  int _indiceAbaAtiva = 0;
  int _selectedNavigationIndex = 0;

  final List<String> _abas = [
    'Resumo',
    'Parâmetros',
    'Conservação',
    'Preparo de Solo',
    'Plantio',
    'Manutenção',
    'Colheita',
  ];

  // Variáveis de estado para os parâmetros editáveis
  late TextEditingController _produtividadeCtrl;
  late TextEditingController _atrCtrl;
  late TextEditingController _longevidadeCtrl;
  late TextEditingController _doseMudaCtrl;
  late TextEditingController _precoDieselCtrl;
  late TextEditingController _custoAdminCtrl;
  late TextEditingController _arrendamentoCtrl;
  late TextEditingController _atrArrendCtrl;
  late TextEditingController _precoATRCtrl;

  @override
  void initState() {
    super.initState();
    final cenario = widget.cenario;
    _produtividadeCtrl = TextEditingController()..text = cenario.produtividade.toString();
    _atrCtrl = TextEditingController()..text = cenario.atr.toString();
    _longevidadeCtrl = TextEditingController()..text = (cenario.longevidade ?? DadosCustoOperacional.parametros.longevidade).toString();
    _doseMudaCtrl = TextEditingController()..text = (cenario.doseMuda ?? DadosCustoOperacional.parametros.doseMuda).toString();
    _precoDieselCtrl = TextEditingController()..text = (cenario.precoDiesel ?? DadosCustoOperacional.parametros.precoDiesel).toString();
    _custoAdminCtrl = TextEditingController()..text = (cenario.custoAdministrativo ?? DadosCustoOperacional.parametros.custoAdmin).toString();
    _arrendamentoCtrl = TextEditingController()..text = (cenario.arrendamento ?? DadosCustoOperacional.parametros.arrendamento).toString();
    _atrArrendCtrl = TextEditingController()..text = (cenario.atrArrend ?? DadosCustoOperacional.parametros.atrArrend).toString();
    _precoATRCtrl = TextEditingController()..text = (cenario.precoAtr ?? DadosCustoOperacional.parametros.precoATR).toString();
  }

  @override
  void dispose() {
    _produtividadeCtrl.dispose();
    _atrCtrl.dispose();
    _longevidadeCtrl.dispose();
    _doseMudaCtrl.dispose();
    _precoDieselCtrl.dispose();
    _custoAdminCtrl.dispose();
    _arrendamentoCtrl.dispose();
    _atrArrendCtrl.dispose();
    _precoATRCtrl.dispose();
    super.dispose();
  }

  // Constrói parâmetros a partir dos valores editáveis
  ParametrosCustoOperacional _obterParametrosEditados() {
    return ParametrosCustoOperacional(
      produtividade: double.tryParse(_produtividadeCtrl.text) ?? DadosCustoOperacional.parametros.produtividade,
      atr: int.tryParse(_atrCtrl.text) ?? DadosCustoOperacional.parametros.atr,
      longevidade: int.tryParse(_longevidadeCtrl.text) ?? DadosCustoOperacional.parametros.longevidade,
      doseMuda: double.tryParse(_doseMudaCtrl.text) ?? DadosCustoOperacional.parametros.doseMuda,
      precoDiesel: double.tryParse(_precoDieselCtrl.text) ?? DadosCustoOperacional.parametros.precoDiesel,
      custoAdmin: double.tryParse(_custoAdminCtrl.text) ?? DadosCustoOperacional.parametros.custoAdmin,
      arrendamento: double.tryParse(_arrendamentoCtrl.text) ?? DadosCustoOperacional.parametros.arrendamento,
      atrArrend: double.tryParse(_atrArrendCtrl.text) ?? DadosCustoOperacional.parametros.atrArrend,
      precoATR: double.tryParse(_precoATRCtrl.text) ?? DadosCustoOperacional.parametros.precoATR,
      periodoRef: DadosCustoOperacional.parametros.periodoRef,
    );
  }

  double _totalResumoRHa() {
    if (widget.cenario.totalOperacional != null && widget.cenario.totalOperacional! > 0) {
      return widget.cenario.totalOperacional!;
    }
    return DadosCustoOperacional.resumo.fold<double>(
      0.0,
      (soma, item) => soma + item.rHa,
    );
  }

  double _totalResumoRT() {
    if (widget.cenario.totalOperacional != null && widget.cenario.totalOperacional! > 0) {
      final produtividade = _obterParametrosEditados().produtividade;
      if (produtividade <= 0) return 0.0;
      return widget.cenario.totalOperacional! / produtividade;
    }
    return DadosCustoOperacional.resumo.fold<double>(
      0.0,
      (soma, item) => soma + item.rT,
    );
  }

  double _calcularPrecoRecebidoPorTonEditado() {
    final params = _obterParametrosEditados();
    return params.atr * params.precoATR;
  }

  double _calcularMargemPorTonEditada() {
    final totalOperacionalPorTon = _totalResumoRT();
    final precoRecebidoPorTon = _calcularPrecoRecebidoPorTonEditado();
    return precoRecebidoPorTon - totalOperacionalPorTon;
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Detalhes de Operações',
      child: Column(
        children: [
          // Abas
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: List.generate(
                  _abas.length,
                  (index) => Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text(_abas[index]),
                      selected: _indiceAbaAtiva == index,
                      onSelected: (selected) {
                        setState(() => _indiceAbaAtiva = index);
                      },
                      backgroundColor:
                          _indiceAbaAtiva == index ? AppColors.primary : null,
                      labelStyle: TextStyle(
                        color: _indiceAbaAtiva == index
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 16),

          // Conteúdo das abas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildConteudoAba(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudoAba() {
    switch (_indiceAbaAtiva) {
      case 0:
        return _buildResumo();
      case 1:
        return _buildParametros();
      case 2:
        return _buildOperacoes(DadosCustoOperacional.conservacaoSolo);
      case 3:
        return _buildOperacoes(DadosCustoOperacional.preparoSolo);
      case 4:
        return _buildOperacoes(DadosCustoOperacional.plantio);
      case 5:
        return _buildOperacoes(DadosCustoOperacional.manutencaoSoqueira);
      case 6:
        return _buildOperacoes(DadosCustoOperacional.colheita);
      default:
        return const SizedBox.shrink();
    }
  }
  Widget _buildResumo() {
    final totalRHa = _totalResumoRHa();
    final totalRT = _totalResumoRT();
    final precoRecebidoRT = _calcularPrecoRecebidoPorTonEditado();
    final margemRT = _calcularMargemPorTonEditada();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Composição do Custo Operacional',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Estágio')),
                      DataColumn(
                        label: Text('R\$/ha'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('R\$/t'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('R\$/kg ATR'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Part. (%)'),
                        numeric: true,
                      ),
                    ],
                    rows: [
                      ...DadosCustoOperacional.resumo.map(
                        (r) => DataRow(
                          cells: [
                            DataCell(Text(r.estagio)),
                            DataCell(
                              Text(_fmt(r.rHa)),
                              showEditIcon: false,
                            ),
                            DataCell(
                              Text(_fmt(r.rT)),
                              showEditIcon: false,
                            ),
                            DataCell(
                              Text(_fmt(r.rKgATR, 6)),
                              showEditIcon: false,
                            ),
                            DataCell(
                              Text(r.pct),
                              showEditIcon: false,
                            ),
                          ],
                        ),
                      ),
                      DataRow(
                        cells: [
                          const DataCell(
                            Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataCell(
                            Text(
                              _fmt(totalRHa),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              _fmt(totalRT),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const DataCell(
                            Text(
                              '-',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const DataCell(
                            Text(
                              '100%',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Operacional',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'R\$ ${_fmt(totalRT)}/t',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Preço Recebido',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'R\$ ${_fmt(precoRecebidoRT)}/t',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Margem',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            'R\$ ${_fmt(margemRT)}/t',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: margemRT >= 0 ? Colors.green : Colors.red,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📌 Nota sobre Margem',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para encontrar o cenário de margem (R\$/t), cruzar os parâmetros desejados de produtividade (t/ha) e preço (R\$/Kg ATR). Por exemplo, para uma produtividade de 85 t/ha e preço de R\$ 1,15/kg ATR, a margem de lucro seria de R\$ 17,94/t. Os dados têm caráter estritamente informativo.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParametros() {
    final params = DadosCustoOperacional.parametros;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Parâmetros Técnicos',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'AFCRC – ${params.periodoRef}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Lista de parâmetros editáveis
                _buildParametroInput(
                  label: 'Produtividade',
                  unidade: 't/ha',
                  controller: _produtividadeCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'ATR',
                  unidade: 'kg/t',
                  controller: _atrCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'Longevidade',
                  unidade: 'safras',
                  controller: _longevidadeCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'Dose de Muda',
                  unidade: 't/ha',
                  controller: _doseMudaCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'Preço do Diesel',
                  unidade: 'R\$/L',
                  controller: _precoDieselCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'Custo Administrativo',
                  unidade: '%',
                  controller: _custoAdminCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'Arrendamento',
                  unidade: 't/ha',
                  controller: _arrendamentoCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'ATR Arrendamento',
                  unidade: 'kg/t',
                  controller: _atrArrendCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildParametroInput(
                  label: 'Preço do ATR',
                  unidade: 'R\$/kg',
                  controller: _precoATRCtrl,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Observação',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Edite os parâmetros acima para recalcular automaticamente os custos operacionais na aba Resumo. Os valores são utilizados como referência baseada em dados AFCRC de janeiro-fevereiro de 2026.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParametroInput({
    required String label,
    required String unidade,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    hintText: '0.0',
                    hintStyle: const TextStyle(fontSize: 13),
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                child: Text(
                  unidade,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperacoes(EstagioCustos estagio) {
    final temInsumo = estagio.operacoes.any((op) => op.insumo != null);
    final ehColheita = estagio.titulo == 'Sistema de Colheita';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      estagio.titulo,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        'R\$ ${_fmt(estagio.total)}/ha',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      const DataColumn(label: Text('Operação')),
                      const DataColumn(label: Text('Máquina')),
                      const DataColumn(
                        label: Text('R\$/und'),
                        numeric: true,
                      ),
                      if (!ehColheita)
                        const DataColumn(label: Text('Implemento')),
                      if (!ehColheita)
                        const DataColumn(
                          label: Text('R\$/und'),
                          numeric: true,
                        ),
                      const DataColumn(
                        label: Text('Op. R\$/und'),
                        numeric: true,
                      ),
                      const DataColumn(
                        label: Text('Rend.'),
                        numeric: true,
                      ),
                      const DataColumn(
                        label: Text('Op. R\$/ha'),
                        numeric: true,
                      ),
                      if (temInsumo && !ehColheita)
                        const DataColumn(label: Text('Insumo')),
                      if (temInsumo && !ehColheita)
                        const DataColumn(
                          label: Text('Dose'),
                          numeric: true,
                        ),
                      if (temInsumo && !ehColheita)
                        const DataColumn(
                          label: Text('Insumo R\$/ha'),
                          numeric: true,
                        ),
                      const DataColumn(
                        label: Text('Total R\$/ha'),
                        numeric: true,
                      ),
                    ],
                    rows: estagio.operacoes
                        .map(
                          (op) => DataRow(
                            cells: [
                              DataCell(Text(op.operacao)),
                              DataCell(Text(op.maquina)),
                              DataCell(Text(_fmt(op.maquinaVal))),
                              if (!ehColheita)
                                DataCell(Text(op.implemento)),
                              if (!ehColheita)
                                DataCell(
                                  Text(
                                    op.implVal > 0
                                        ? _fmt(op.implVal)
                                        : '-',
                                  ),
                                ),
                              DataCell(Text(_fmt(op.operacaoVal))),
                              DataCell(Text(_fmt(op.rend))),
                              DataCell(Text(_fmt(op.operRHa))),
                              if (temInsumo && !ehColheita)
                                DataCell(Text(op.insumo ?? '-')),
                              if (temInsumo && !ehColheita)
                                DataCell(
                                  Text(
                                    op.dose != null && op.dose! > 0
                                        ? _fmt(op.dose!)
                                        : '-',
                                  ),
                                ),
                              if (temInsumo && !ehColheita)
                                DataCell(
                                  Text(
                                    op.insumoRHa != null &&
                                            op.insumoRHa! > 0
                                        ? _fmt(op.insumoRHa!)
                                        : '-',
                                  ),
                                ),
                              DataCell(
                                Text(
                                  _fmt(op.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    estagio.obs,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Formata números em formato brasileiro
  String _fmt(double value, [int decimals = 2]) {
    return value.toStringAsFixed(decimals).replaceAll('.', ',');
  }
}


