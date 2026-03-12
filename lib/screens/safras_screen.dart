import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../models/models.dart';
import '../services/safra_service.dart';
import 'safra_form_screen.dart';

class SafrasScreen extends StatefulWidget {
  final ContextoPropriedade contexto;

  const SafrasScreen({
    super.key,
    required this.contexto,
  });

  @override
  State<SafrasScreen> createState() => _SafrasScreenState();
}

class _SafrasScreenState extends State<SafrasScreen> {
  final SafraService _service = SafraService();
  int _selectedNavigationIndex = 0;
  List<Safra> _safras = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregarSafras();
  }

  Future<void> _carregarSafras() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });
    try {
      final safras = await _service.buscarPorProprietario(
        widget.contexto.proprietario.id,
      );
      if (mounted) {
        setState(() {
          _safras = safras;
          _carregando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString();
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _selectedNavigationIndex,
      onNavigationSelect: (index) {
        setState(() => _selectedNavigationIndex = index);
      },
      showBackButton: true,
      title: 'Safras',
      child: Stack(
        children: [
          _buildConteudo(),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              onPressed: () => _abrirFormulario(),
              backgroundColor: AppColors.newPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Nova Safra',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return Column(
      children: [
        HeaderPropriedade(contexto: widget.contexto),
        Expanded(child: _buildCorpo()),
      ],
    );
  }

  Widget _buildCorpo() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.newDanger),
            const SizedBox(height: 12),
            const Text('Erro ao carregar safras', style: TextStyle(color: AppColors.newDanger)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _carregarSafras,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    if (_safras.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma safra cadastrada',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Clique em "Nova Safra" para começar',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _carregarSafras,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: _safras.length,
        itemBuilder: (context, index) => _buildSafraCard(_safras[index]),
      ),
    );
  }

  Widget _buildSafraCard(Safra safra) {
    final corStatus = _corDoStatus(safra.status);
    final iconeStatus = _iconeDoStatus(safra.status);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: safra.status == 'ativa'
            ? const BorderSide(color: AppColors.newPrimary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Linha título + status
            Row(
              children: [
                const Icon(Icons.date_range, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Safra ${safra.safra}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(safra.statusFormatado, corStatus, iconeStatus),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _acaoMenu(value, safra),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    if (safra.status == 'ativa')
                      const PopupMenuItem(value: 'finalizar', child: Text('Finalizar')),
                    if (safra.status == 'finalizada')
                      const PopupMenuItem(value: 'reativar', child: Text('Reativar')),
                    const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Período
            Row(
              children: [
                _infoChip(Icons.play_arrow, _formatarData(safra.dataInicio)),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                _infoChip(Icons.stop, _formatarData(safra.dataFim)),
                const Spacer(),
                Text(
                  '${safra.duracao} dias',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Barra de progresso (só para ativas/finalizadas)
            if (safra.status != 'planejada') ...[
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: safra.percentualCiclo / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          safra.status == 'finalizada'
                              ? Colors.grey
                              : AppColors.newPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${safra.percentualCiclo.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: safra.status == 'finalizada'
                          ? Colors.grey
                          : AppColors.newPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (safra.status == 'ativa')
                Text(
                  '${safra.diasRestantes} dias restantes',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],

            // ── Observações
            if (safra.observacoes != null && safra.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                safra.observacoes!,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String texto, Color cor, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: cor),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }

  Color _corDoStatus(String status) {
    switch (status) {
      case 'ativa':
        return AppColors.newPrimary;
      case 'finalizada':
        return Colors.grey;
      case 'planejada':
        return AppColors.newInfo;
      default:
        return Colors.grey;
    }
  }

  IconData _iconeDoStatus(String status) {
    switch (status) {
      case 'ativa':
        return Icons.check_circle;
      case 'finalizada':
        return Icons.archive;
      case 'planejada':
        return Icons.schedule;
      default:
        return Icons.circle;
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  // ── Ações ───────────────────────────────────────────────────

  Future<void> _abrirFormulario({Safra? safra}) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => SafraFormScreen(
          contexto: widget.contexto,
          safra: safra,
        ),
      ),
    );
    if (resultado == true) {
      _carregarSafras();
    }
  }

  Future<void> _acaoMenu(String acao, Safra safra) async {
    switch (acao) {
      case 'editar':
        _abrirFormulario(safra: safra);
        break;
      case 'finalizar':
        _confirmarAcao(
          'Finalizar Safra ${safra.safra}?',
          'A safra será marcada como finalizada.',
          () async {
            await _service.finalizarSafra(safra.id);
            _carregarSafras();
          },
        );
        break;
      case 'reativar':
        _confirmarAcao(
          'Reativar Safra ${safra.safra}?',
          'A safra será marcada como ativa novamente.',
          () async {
            await _service.reativarSafra(safra.id);
            _carregarSafras();
          },
        );
        break;
      case 'excluir':
        _confirmarAcao(
          'Excluir Safra ${safra.safra}?',
          'Esta ação não pode ser desfeita. Todos os dados vinculados serão desassociados.',
          () async {
            await _service.deletarSafra(safra.id);
            _carregarSafras();
          },
        );
        break;
    }
  }

  void _confirmarAcao(String titulo, String mensagem, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.newDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
