// lib/screens/precipitacao_por_municipios_screen.dart

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/precipitacao.dart';
import '../services/precipitacao_agregada_service.dart';
import '../utils/formatters.dart';

class PrecipitacaoPorMunicipiosScreen extends StatefulWidget {
  const PrecipitacaoPorMunicipiosScreen({super.key});

  @override
  State<PrecipitacaoPorMunicipiosScreen> createState() => _PrecipitacaoPorMunicipiosScreenState();
}

class _PrecipitacaoPorMunicipiosScreenState extends State<PrecipitacaoPorMunicipiosScreen> {
  final PrecipitacaoAgregadaService _service = PrecipitacaoAgregadaService();
  String? _municipioSelecionado;
  final _searchController = TextEditingController();
  List<String> _municipios = [];
  List<String> _municipiosFiltrados = [];
  bool _carregando = true;
  String _tipoVisualizacao = 'todos'; // 'todos' ou 'selecionado'

  @override
  void initState() {
    super.initState();
    _carregarMunicipios();
    _searchController.addListener(_filtrarMunicipios);
  }

  Future<void> _carregarMunicipios() async {
    try {
      final municipios = await _service.obterMunicipios();
      setState(() {
        _municipios = municipios;
        _municipiosFiltrados = municipios;
        if (municipios.isNotEmpty && _municipioSelecionado == null) {
          _municipioSelecionado = municipios.first;
        }
        _carregando = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar municípios: $e')),
        );
      }
      setState(() => _carregando = false);
    }
  }

  void _filtrarMunicipios() {
    final termo = _searchController.text.toLowerCase();
    setState(() {
      _municipiosFiltrados = _municipios
          .where((m) => m.toLowerCase().contains(termo))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRECIPITAÇÃO POR MUNICÍPIOS'),
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Abas de visualização
                  Container(
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tipoVisualizacao = 'todos'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _tipoVisualizacao == 'todos'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Todos os Municípios',
                                  style: TextStyle(
                                    fontWeight: _tipoVisualizacao == 'todos'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _tipoVisualizacao == 'todos'
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _tipoVisualizacao = 'selecionado'),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _tipoVisualizacao == 'selecionado'
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Detalhes',
                                  style: TextStyle(
                                    fontWeight: _tipoVisualizacao == 'selecionado'
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _tipoVisualizacao == 'selecionado'
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Conteúdo
                  if (_tipoVisualizacao == 'todos')
                    _buildTodosMunicipios()
                  else
                    _buildDetalhes(),
                ],
              ),
            ),
    );
  }

  Widget _buildTodosMunicipios() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar município...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filtrarMunicipios();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (_municipiosFiltrados.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.location_city, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('Nenhum município encontrado'),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _municipiosFiltrados.length,
            itemBuilder: (context, index) {
              final municipio = _municipiosFiltrados[index];
              return _buildCardMunicipio(municipio);
            },
          ),
      ],
    );
  }

  Widget _buildCardMunicipio(String municipio) {
    return FutureBuilder<Map<String, double>>(
      future: _service.totalPorMes(municipio: municipio),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    municipio,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(municipio, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Erro: ${snapshot.error}'),
                ],
              ),
            ),
          );
        }

        final totalPorMes = snapshot.data ?? {};
        final totalVolume = totalPorMes.values.fold(0.0, (a, b) => a + b);

        return GestureDetector(
          onTap: () {
            setState(() {
              _municipioSelecionado = municipio;
              _tipoVisualizacao = 'selecionado';
            });
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          municipio,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${totalVolume.toStringAsFixed(1)} mm',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMiniaturaRegistros(totalPorMes),
                  const SizedBox(height: 8),
                  Text(
                    '${totalPorMes.length} meses com dados',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniaturaRegistros(Map<String, double> totalPorMes) {
    if (totalPorMes.isEmpty) {
      return const Text('Sem dados');
    }

    // Mostrar últimos 6 meses
    final meses = totalPorMes.keys.toList().reversed.take(6).toList();

    return Row(
      children: meses.map((mes) {
        final volume = totalPorMes[mes]!;
        final maxVolume = totalPorMes.values.reduce((a, b) => a > b ? a : b);

        return Expanded(
          child: Tooltip(
            message: '$mes: ${volume.toStringAsFixed(1)} mm',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      width: double.infinity,
                      height: 30,
                      color: volume > 0
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.grey[200],
                      child: volume > 0
                          ? FractionallySizedBox(
                              heightFactor: volume / (maxVolume > 0 ? maxVolume : 1),
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mes.split('-').last,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetalhes() {
    if (_municipioSelecionado == null) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Selecione um município para ver detalhes'),
          ],
        ),
      );
    }

    return FutureBuilder<List<Precipitacao>>(
      future: _service.getTodas().then((p) =>
          p.where((prec) => prec.municipio == _municipioSelecionado).toList()
            ..sort((a, b) => b.data.compareTo(a.data))),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        final precipitacoes = snapshot.data ?? [];

        // Agrupar por mês
        final porMes = <String, List<Precipitacao>>{};
        for (var p in precipitacoes) {
          final mesAno = '${p.data.year}-${p.data.month.toString().padLeft(2, '0')}';
          porMes.putIfAbsent(mesAno, () => []);
          porMes[mesAno]!.add(p);
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Município Selecionado',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _municipioSelecionado!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _tipoVisualizacao = 'todos');
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Voltar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (porMes.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('Sem dados de precipitação para este município'),
                  ],
                ),
              )
            else
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: porMes.entries.toList().reversed.map((entry) {
                  final mes = entry.key;
                  final dados = entry.value;
                  final total = dados.fold(0.0, (sum, p) => sum + p.volume);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      child: ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatarMes(mes),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${total.toStringAsFixed(1)} mm',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dados.length,
                            itemBuilder: (context, index) {
                              final p = dados[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Data: ${Formatters.formatDate(p.data)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (p.observacoes != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              p.observacoes!,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      '${p.volume.toStringAsFixed(1)} mm',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total do mês (${dados.length} registros)',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${total.toStringAsFixed(1)} mm',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  String _formatarMes(String mesAno) {
    try {
      final parts = mesAno.split('-');
      final ano = int.parse(parts[0]);
      final mes = int.parse(parts[1]);
      const meses = [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro'
      ];
      return '${meses[mes - 1]} de $ano';
    } catch (e) {
      return mesAno;
    }
  }
}
