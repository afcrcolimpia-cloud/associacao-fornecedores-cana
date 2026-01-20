// lib/screens/precipitacao_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/app_colors.dart';
import '../models/models.dart';
import '../services/precipitacao_service.dart';
import '../utils/formatters.dart';
import '../utils/municipios_sp.dart';

class PrecipitacaoScreen extends StatefulWidget {
  final Propriedade propriedade;

  const PrecipitacaoScreen({
    super.key,
    required this.propriedade,
  });

  @override
  State<PrecipitacaoScreen> createState() => _PrecipitacaoScreenState();
}

class _PrecipitacaoScreenState extends State<PrecipitacaoScreen> {
  final PrecipitacaoService _service = PrecipitacaoService();
  final _volumeController = TextEditingController();
  final _observacoesController = TextEditingController();

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  String _municipioSelecionado = 'Catanduva';
  int _anoSelecionado = DateTime.now().year;
  Map<DateTime, List<Precipitacao>> _eventosMap = {};
  List<Precipitacao> _precipitacoesSelecionadas = [];

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _anoSelecionado = DateTime.now().year;
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final dados = await _service.getPrecipitacoesByPropriedade(widget.propriedade.id);
      final mapa = <DateTime, List<Precipitacao>>{};

      for (var precipitacao in dados) {
        final data = DateTime(
          precipitacao.data.year,
          precipitacao.data.month,
          precipitacao.data.day,
        );
        if (mapa[data] == null) {
          mapa[data] = [];
        }
        mapa[data]!.add(precipitacao);
      }

      setState(() => _eventosMap = mapa);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  List<Precipitacao> _obterEventos(DateTime day) {
    return _eventosMap[day] ?? [];
  }

  Future<void> _adicionarPrecipitacao() async {
    if (_selectedDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um dia no calendário')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => _DialogAdicionarPrecipitacao(
        data: _selectedDay!,
        onSalvar: (volume, observacoes) async {
          try {
            final precipitacao = Precipitacao(
              id: '',
              propriedadeId: widget.propriedade.id,
              data: _selectedDay!,
              volume: volume,
              municipio: _municipioSelecionado,
              observacoes: observacoes.isEmpty ? null : observacoes,
              criadoEm: DateTime.now(),
              atualizadoEm: DateTime.now(),
            );

            await _service.addPrecipitacao(precipitacao);
            if (!mounted) return;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Precipitação registrada!'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
            _carregarDados();
          } catch (e) {
            if (!mounted) return;
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erro: $e')),
              );
            }
          }
        },
      ),
    );
  }

  Future<void> _deletarPrecipitacao(Precipitacao p) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Precipitação?'),
        content: Text('${p.volume}mm em ${Formatters.formatDate(p.data)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.deletePrecipitacao(p.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Excluído com sucesso!')),
          );
          _carregarDados();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  double _calcularSomaTotal() {
    double soma = 0;
    for (var eventos in _eventosMap.values) {
      for (var p in eventos) {
        if (p.data.month == _focusedDay.month &&
            p.data.year == _focusedDay.year) {
          soma += p.volume;
        }
      }
    }
    return soma;
  }

  double _calcularSomaAno() {
    double soma = 0;
    for (var eventos in _eventosMap.values) {
      for (var p in eventos) {
        if (p.data.year == _anoSelecionado) {
          soma += p.volume;
        }
      }
    }
    return soma;
  }

  int _contarDiasComChuva() {
    int contador = 0;
    for (var eventos in _eventosMap.values) {
      for (var p in eventos) {
        if (p.data.month == _focusedDay.month &&
            p.data.year == _focusedDay.year) {
          contador++;
        }
      }
    }
    return contador;
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Precipitação'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informações da Propriedade
              Card(
                color: AppColors.primary.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.home_work, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.propriedade.nomePropriedade,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'FA: ${widget.propriedade.numeroFA}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Filtros: Município e Ano
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _municipioSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Município',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                      items: MunicipiosSP.municipiosList.map((municipio) {
                        return DropdownMenuItem(
                          value: municipio,
                          child: Text(municipio),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _municipioSelecionado = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _anoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      items: MunicipiosSP.yearsAvailable.map((year) {
                        return DropdownMenuItem(
                          value: year,
                          child: Text(year.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _anoSelecionado = value;
                            _focusedDay = DateTime(value, _focusedDay.month);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Calendário
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime(2025, 1, 1),
                    lastDay: DateTime(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                        _precipitacoesSelecionadas = _obterEventos(selectedDay);
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: _obterEventos,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                      markerDecoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    locale: 'pt_BR',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Estatísticas do Mês
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Mês',
                      '${_calcularSomaTotal().toStringAsFixed(1)}mm',
                      Icons.water_drop,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Dias com Chuva',
                      '${_contarDiasComChuva()}',
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      'Total Ano',
                      '${_calcularSomaAno().toStringAsFixed(1)}mm',
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Dia Selecionado e Precipitações
              if (_selectedDay != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dia: ${Formatters.formatDate(_selectedDay!)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (_precipitacoesSelecionadas.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('Nenhum registro para este dia'),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _precipitacoesSelecionadas.length,
                            itemBuilder: (context, index) {
                              final p = _precipitacoesSelecionadas[index];
                              return ListTile(
                                leading: const Icon(
                                  Icons.water_drop,
                                  color: AppColors.primary,
                                ),
                                title: Text('${p.volume}mm'),
                                subtitle: Text(
                                  p.municipio,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  onPressed: () => _deletarPrecipitacao(p),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Adicionar Precipitação'),
                            onPressed: _adicionarPrecipitacao,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogAdicionarPrecipitacao extends StatefulWidget {
  final DateTime data;
  final Function(double, String) onSalvar;

  const _DialogAdicionarPrecipitacao({
    required this.data,
    required this.onSalvar,
  });

  @override
  State<_DialogAdicionarPrecipitacao> createState() =>
      _DialogAdicionarPrecipitacaoState();
}

class _DialogAdicionarPrecipitacaoState
    extends State<_DialogAdicionarPrecipitacao> {
  final _volumeController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void dispose() {
    _volumeController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Adicionar Precipitação'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Formatters.formatDate(widget.data)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _volumeController,
              decoration: const InputDecoration(
                labelText: 'Volume (mm) *',
                prefixIcon: Icon(Icons.water_drop),
                suffixText: 'mm',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_volumeController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informe o volume')),
              );
              return;
            }
            final volume = double.parse(_volumeController.text);
            final observacoes = _observacoesController.text;
            Navigator.pop(context);
            widget.onSalvar(volume, observacoes);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
