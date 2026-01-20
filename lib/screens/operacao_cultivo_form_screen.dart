import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/operacao_cultivo_service.dart';
import '../utils/formatters.dart';

class OperacaoCultivoFormScreen extends StatefulWidget {
  final String propriedadeId;
  final String? talhaoId;
  final OperacaoCultivo? operacao;

  const OperacaoCultivoFormScreen({
    super.key,
    required this.propriedadeId,
    this.talhaoId,
    this.operacao,
  });

  @override
  State<OperacaoCultivoFormScreen> createState() =>
      _OperacaoCultivoFormScreenState();
}

class _OperacaoCultivoFormScreenState extends State<OperacaoCultivoFormScreen> {
  final _operacaoService = OperacaoCultivoService();
  late TextEditingController _observacoesController;
  late TextEditingController _talhaoIdController;

  DateTime? _dataPlantio;
  DateTime? _dataQuebraLombo;
  DateTime? _dataColheita;
  DateTime? _data1aAplicHerbicida;
  DateTime? _data2aAplicHerbicida;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _talhaoIdController =
        TextEditingController(text: widget.talhaoId ?? widget.operacao?.talhaoId);
    _observacoesController =
        TextEditingController(text: widget.operacao?.observacoes);

    if (widget.operacao != null) {
      _dataPlantio = widget.operacao!.dataPlantio;
      _dataQuebraLombo = widget.operacao!.dataQuebraLombo;
      _dataColheita = widget.operacao!.dataColheita;
      _data1aAplicHerbicida = widget.operacao!.data1aAplicHerbicida;
      _data2aAplicHerbicida = widget.operacao!.data2aAplicHerbicida;
    }
  }

  @override
  void dispose() {
    _talhaoIdController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.operacao == null ? 'Nova Operação' : 'Editar Operação',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Talhão
            TextFormField(
              controller: _talhaoIdController,
              decoration: const InputDecoration(
                labelText: 'Talhão ID',
                hintText: 'Digite o ID do talhão',
                prefixIcon: Icon(Icons.map),
              ),
              enabled: widget.operacao == null,
            ),
            const SizedBox(height: 16),

            // Data de Plantio
            _buildDateField(
              label: 'Data de Plantio *',
              date: _dataPlantio,
              onChanged: (date) => setState(() => _dataPlantio = date),
              required: true,
            ),
            const SizedBox(height: 16),

            // Data de Quebra-Lombo
            _buildDateField(
              label: 'Data de Quebra-Lombo',
              date: _dataQuebraLombo,
              onChanged: (date) => setState(() => _dataQuebraLombo = date),
            ),
            const SizedBox(height: 16),

            // Data 1ª Aplicação Herbicida
            _buildDateField(
              label: '1ª Aplicação de Herbicida',
              date: _data1aAplicHerbicida,
              onChanged: (date) => setState(() => _data1aAplicHerbicida = date),
            ),
            const SizedBox(height: 16),

            // Data 2ª Aplicação Herbicida
            _buildDateField(
              label: '2ª Aplicação de Herbicida',
              date: _data2aAplicHerbicida,
              onChanged: (date) => setState(() => _data2aAplicHerbicida = date),
            ),
            const SizedBox(height: 16),

            // Data de Colheita
            _buildDateField(
              label: 'Data de Colheita',
              date: _dataColheita,
              onChanged: (date) => setState(() => _dataColheita = date),
            ),
            const SizedBox(height: 16),

            // Observações
            TextFormField(
              controller: _observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Digite observações sobre a operação',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // Botões de ação
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _isLoading ? null : _salvar,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Salvar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
    bool required = false,
  }) {
    return GestureDetector(
      onTap: () => _selecionarData(
        context,
        date,
        onChanged,
      ),
      child: TextFormField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Selecione uma data',
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: date != null
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onChanged(null),
                )
              : null,
          border: const OutlineInputBorder(),
          errorText: required && date == null ? 'Campo obrigatório' : null,
        ),
        controller: TextEditingController(
          text: date != null ? Formatters.formatDate(date) : '',
        ),
      ),
    );
  }

  Future<void> _selecionarData(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime?) onChanged,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      onChanged(date);
    }
  }

  Future<void> _salvar() async {
    if (_dataPlantio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data de plantio é obrigatória')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final operacao = OperacaoCultivo(
        id: widget.operacao?.id,
        propriedadeId: widget.propriedadeId,
        talhaoId: _talhaoIdController.text.trim(),
        dataPlantio: _dataPlantio!,
        dataQuebraLombo: _dataQuebraLombo,
        dataColheita: _dataColheita,
        data1aAplicHerbicida: _data1aAplicHerbicida,
        data2aAplicHerbicida: _data2aAplicHerbicida,
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
        createdAt: widget.operacao?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.operacao == null) {
        await _operacaoService.createOperacao(operacao);
      } else {
        await _operacaoService.updateOperacao(operacao);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.operacao == null
                  ? 'Operação criada com sucesso'
                  : 'Operação atualizada com sucesso',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
