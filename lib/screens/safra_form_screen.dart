import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../widgets/campo_data_widget.dart';
import '../models/models.dart';
import '../services/safra_service.dart';

class SafraFormScreen extends StatefulWidget {
  final ContextoPropriedade contexto;
  final Safra? safra; // null = nova safra

  const SafraFormScreen({
    super.key,
    required this.contexto,
    this.safra,
  });

  @override
  State<SafraFormScreen> createState() => _SafraFormScreenState();
}

class _SafraFormScreenState extends State<SafraFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final SafraService _service = SafraService();
  int _selectedNavigationIndex = 0;

  late final TextEditingController _safraCtrl;
  late final TextEditingController _observacoesCtrl;
  late DateTime _dataInicio;
  late DateTime _dataFim;
  late String _status;

  bool _salvando = false;
  bool get _isEdicao => widget.safra != null;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      final s = widget.safra!;
      _safraCtrl = TextEditingController(text: s.safra);
      _observacoesCtrl = TextEditingController(text: s.observacoes ?? '');
      _dataInicio = s.dataInicio;
      _dataFim = s.dataFim;
      _status = s.status;
    } else {
      // Auto-gerar safra com base no ano atual
      final anoAtual = DateTime.now().year;
      final anoProximo = (anoAtual + 1) % 100;
      _safraCtrl = TextEditingController(
        text: '$anoAtual/${anoProximo.toString().padLeft(2, '0')}',
      );
      _observacoesCtrl = TextEditingController();
      _dataInicio = DateTime(anoAtual, 4, 1); // 01/abr
      _dataFim = DateTime(anoAtual + 1, 3, 31); // 31/mar
      _status = 'ativa';
    }
  }

  @override
  void dispose() {
    _safraCtrl.dispose();
    _observacoesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: _isEdicao ? 'Editar Safra' : 'Nova Safra',
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCabecalho(),
                    const SizedBox(height: 24),
                    _buildCampoSafra(),
                    const SizedBox(height: 16),
                    _buildLinhaDataPeriodo(),
                    const SizedBox(height: 16),
                    _buildStatusDropdown(),
                    const SizedBox(height: 16),
                    _buildCampoObservacoes(),
                    const SizedBox(height: 16),
                    _buildPreviewPeriodo(),
                    const SizedBox(height: 32),
                    _buildBotoes(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCabecalho() {
    return Card(
      color: AppColors.newPrimary.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: AppColors.newPrimary, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEdicao ? 'Editando Safra' : 'Cadastro de Nova Safra',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Proprietário: ${widget.contexto.nomeProprietario}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoSafra() {
    return TextFormField(
      controller: _safraCtrl,
      decoration: const InputDecoration(
        labelText: 'Safra *',
        hintText: 'Ex: 2025/26',
        prefixIcon: Icon(Icons.calendar_today),
        border: OutlineInputBorder(),
        helperText: 'Formato: AAAA/AA (ex: 2025/26)',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Informe o nome da safra';
        }
        final regex = RegExp(r'^\d{4}/\d{2}$');
        if (!regex.hasMatch(value.trim())) {
          return 'Formato inválido. Use AAAA/AA (ex: 2025/26)';
        }
        return null;
      },
      onChanged: (value) {
        // Auto-calcular datas se o formato estiver correto
        final regex = RegExp(r'^(\d{4})/(\d{2})$');
        final match = regex.firstMatch(value.trim());
        if (match != null) {
          final anoInicio = int.parse(match.group(1)!);
          setState(() {
            _dataInicio = DateTime(anoInicio, 4, 1);
            _dataFim = DateTime(anoInicio + 1, 3, 31);
          });
        }
      },
    );
  }

  Widget _buildLinhaDataPeriodo() {
    return Row(
      children: [
        Expanded(
          child: CampoDataWidget(
            label: 'Data Início *',
            valor: _dataInicio,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            obrigatorio: true,
            onChanged: (data) {
              if (data != null) setState(() => _dataInicio = data);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CampoDataWidget(
            label: 'Data Fim *',
            valor: _dataFim,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            obrigatorio: true,
            onChanged: (data) {
              if (data != null) setState(() => _dataFim = data);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _status,
      decoration: const InputDecoration(
        labelText: 'Status',
        prefixIcon: Icon(Icons.flag),
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'planejada', child: Text('Planejada')),
        DropdownMenuItem(value: 'ativa', child: Text('Ativa')),
        DropdownMenuItem(value: 'finalizada', child: Text('Finalizada')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _status = value);
        }
      },
    );
  }

  Widget _buildCampoObservacoes() {
    return TextFormField(
      controller: _observacoesCtrl,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Observações',
        hintText: 'Notas sobre esta safra (opcional)',
        prefixIcon: Icon(Icons.notes),
        border: OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildPreviewPeriodo() {
    final duracao = _dataFim.difference(_dataInicio).inDays;
    final meses = (duracao / 30).round();
    final valido = _dataFim.isAfter(_dataInicio);

    return Card(
      color: valido
          ? AppColors.newInfo.withOpacity(0.08)
          : AppColors.newDanger.withOpacity(0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              valido ? Icons.info_outline : Icons.warning,
              color: valido ? AppColors.newInfo : AppColors.newDanger,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                valido
                    ? 'Período: $duracao dias (~$meses meses)'
                    : 'Data fim deve ser posterior à data início',
                style: TextStyle(
                  fontSize: 13,
                  color: valido ? AppColors.newInfo : AppColors.newDanger,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotoes() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _salvando ? null : () => Navigator.pop(context, false),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _salvando ? null : _salvar,
            icon: _salvando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isEdicao ? 'Atualizar' : 'Salvar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }


  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_dataFim.isAfter(_dataInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data fim deve ser posterior à data início'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      final agora = DateTime.now();
      final safra = Safra(
        id: widget.safra?.id ?? '',
        proprietarioId: widget.contexto.proprietario.id,
        safra: _safraCtrl.text.trim(),
        dataInicio: _dataInicio,
        dataFim: _dataFim,
        status: _status,
        observacoes: _observacoesCtrl.text.trim().isEmpty
            ? null
            : _observacoesCtrl.text.trim(),
        criadoEm: widget.safra?.criadoEm ?? agora,
        atualizadoEm: agora,
      );

      if (_isEdicao) {
        await _service.atualizarSafra(safra);
      } else {
        await _service.salvarSafra(safra);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdicao
                  ? 'Safra atualizada com sucesso!'
                  : 'Safra criada com sucesso!',
            ),
            backgroundColor: AppColors.newPrimary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }
}
