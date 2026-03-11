import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/app_shell.dart';
import '../widgets/header_propriedade.dart';
import '../constants/app_colors.dart';
import '../constants/chart_styles.dart';
import '../models/models.dart';

class AnaliseSoloGraficosScreen extends StatefulWidget {
  final ResultadoInterpretacao resultado;
  final ContextoPropriedade contexto;

  const AnaliseSoloGraficosScreen({
    super.key,
    required this.resultado,
    required this.contexto,
  });

  @override
  State<AnaliseSoloGraficosScreen> createState() => _AnaliseSoloGraficosScreenState();
}

class _AnaliseSoloGraficosScreenState extends State<AnaliseSoloGraficosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedIndex: _navIndex,
      onNavigationSelect: (i) => setState(() => _navIndex = i),
      showBackButton: true,
      title: 'Gráficos — Análise de Solo',
      child: Column(
        children: [
          HeaderPropriedade(contexto: widget.contexto),
          Container(
            color: AppColors.surfaceDark,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.newPrimary,
              labelColor: AppColors.newPrimary,
              unselectedLabelColor: AppColors.newTextSecondary,
              tabs: const [
                Tab(text: 'MACRO'),
                Tab(text: 'MICRO'),
                Tab(text: 'RESUMO'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMacroTab(),
                _buildMicroTab(),
                _buildResumoTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ABA MACRO
  // ═══════════════════════════════════════════════════

  Widget _buildMacroTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Macronutrientes e Acidez',
              style: ChartStyles.titleStyle),
          const SizedBox(height: 4),
          Text('Valor atual vs. limite ideal',
              style: ChartStyles.subtitleStyle),
          const SizedBox(height: 16),
          ...widget.resultado.macronutrientes.map(_buildBarraHorizontal),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ABA MICRO
  // ═══════════════════════════════════════════════════

  Widget _buildMicroTab() {
    if (widget.resultado.micronutrientes.isEmpty) {
      return Center(
        child: Text('Nenhum micronutriente informado',
            style: ChartStyles.subtitleStyle),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Micronutrientes',
              style: ChartStyles.titleStyle),
          const SizedBox(height: 4),
          Text('Valor atual vs. limite ideal',
              style: ChartStyles.subtitleStyle),
          const SizedBox(height: 16),
          ...widget.resultado.micronutrientes.map(_buildBarraHorizontal),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // ABA RESUMO
  // ═══════════════════════════════════════════════════

  Widget _buildResumoTab() {
    final r = widget.resultado;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resumo Geral',
              style: ChartStyles.titleStyle),
          const SizedBox(height: 16),
          _buildCardResumo('V% (Saturação por Bases)',
              r.saturacaoBases, 60, '%', r.semaforoCalagem),
          const SizedBox(height: 12),
          if (r.saturacaoAluminio != null)
            _buildCardResumo('mt% (Saturação por Al)',
                r.saturacaoAluminio!, 30, '%',
                r.saturacaoAluminio! > 30 ? SemaforoSolo.vermelho : SemaforoSolo.verde),
          const SizedBox(height: 12),
          _buildCardCalagem(r),
          const SizedBox(height: 12),
          _buildCardGessagem(r),
          const SizedBox(height: 12),
          _buildCardRelacoes(r),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // WIDGETS DE GRÁFICO
  // ═══════════════════════════════════════════════════

  Widget _buildBarraHorizontal(ItemInterpretado item) {
    final corBarra = _corSemaforo(item.semaforo);
    final idealVal = item.limiteIdeal ?? item.valor;
    final maxVal = (item.valor > idealVal ? item.valor : idealVal) * 1.2;
    final valorPct = maxVal > 0 ? (item.valor / maxVal).clamp(0.0, 1.0) : 0.0;
    final idealPct = maxVal > 0 ? (idealVal / maxVal).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: corBarra, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Expanded(child: Text(item.nome,
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500,
                      color: AppColors.newTextPrimary))),
              Text('${item.valor.toStringAsFixed(item.unidade.isEmpty ? 1 : 2)} ${item.unidade}',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold,
                      color: AppColors.newTextPrimary)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 20,
            child: LayoutBuilder(builder: (ctx, constraints) {
              final barWidth = constraints.maxWidth;
              return Stack(
                children: [
                  // Fundo
                  Container(
                    width: barWidth,
                    decoration: BoxDecoration(
                      color: AppColors.borderDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Barra do valor
                  Container(
                    width: barWidth * valorPct,
                    decoration: BoxDecoration(
                      color: corBarra.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Linha do ideal
                  if (item.limiteIdeal != null)
                    Positioned(
                      left: (barWidth * idealPct - 1).clamp(0, barWidth - 2),
                      top: 0, bottom: 0,
                      child: Container(
                        width: 2,
                        color: AppColors.newSuccess,
                      ),
                    ),
                ],
              );
            }),
          ),
          if (item.limiteIdeal != null)
            Align(
              alignment: Alignment.centerRight,
              child: Text('Ideal: ${item.limiteIdeal!.toStringAsFixed(1)} ${item.unidade}',
                  style: ChartStyles.observacaoStyle),
            ),
        ],
      ),
    );
  }

  Widget _buildCardResumo(String titulo, double valor, double ideal,
      String unidade, SemaforoSolo sem) {
    final cor = _corSemaforo(sem);
    final pct = ideal > 0 ? (valor / ideal).clamp(0.0, 1.5) : 0.0;
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(titulo, style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.newTextPrimary))),
              Text('${valor.toStringAsFixed(1)}$unidade',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: cor)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: AppColors.borderDark,
                valueColor: AlwaysStoppedAnimation(cor),
              ),
            ),
            const SizedBox(height: 4),
            Text('Ideal: ${ideal.toStringAsFixed(0)}$unidade',
                style: ChartStyles.observacaoStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildCardCalagem(ResultadoInterpretacao r) {
    final cor = _corSemaforo(r.semaforoCalagem);
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.landscape, size: 20, color: cor),
              const SizedBox(width: 8),
              const Expanded(child: Text('Calagem', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.newTextPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(r.calagemFinal > 0
                    ? '${r.calagemFinal.toStringAsFixed(2)} t/ha' : 'Não necessária',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
              ),
            ]),
            const SizedBox(height: 8),
            _linhaInfo('Método 1 (Sat. Bases)', '${r.calagemMetodo1.toStringAsFixed(2)} t/ha'),
            _linhaInfo('Método 2 (Neutraliz.)', '${r.calagemMetodo2.toStringAsFixed(2)} t/ha'),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGessagem(ResultadoInterpretacao r) {
    final cor = _corSemaforo(r.semaforoGessagem);
    String texto;
    if (r.gessagemNecessaria) {
      texto = '${r.gessagemDose.toStringAsFixed(2)} t/ha';
    } else if (r.fonteS) {
      texto = 'Fonte S: ${r.doseFonteS.toStringAsFixed(1)} t/ha';
    } else {
      texto = 'Não necessária';
    }
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Icon(Icons.water_drop, size: 20, color: cor),
          const SizedBox(width: 8),
          const Expanded(child: Text('Gessagem', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.newTextPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(texto,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: cor)),
          ),
        ]),
      ),
    );
  }

  Widget _buildCardRelacoes(ResultadoInterpretacao r) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [
              Icon(Icons.balance, size: 20, color: AppColors.newInfo),
              SizedBox(width: 8),
              Text('Relações Iônicas', style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.newTextPrimary)),
            ]),
            const SizedBox(height: 10),
            if (r.relacaoCaMg != null)
              _buildRelacaoBarra('Ca/Mg', r.relacaoCaMg!, 1.0, 4.0, r.semaforoCaMg),
            if (r.relacaoCaK != null)
              _buildRelacaoBarra('Ca/K', r.relacaoCaK!, 8.0, 20.0, r.semaforoCaK),
            if (r.relacaoMgK != null)
              _buildRelacaoBarra('Mg/K', r.relacaoMgK!, 1.5, 6.0, r.semaforoMgK),
          ],
        ),
      ),
    );
  }

  Widget _buildRelacaoBarra(String nome, double valor, double min, double max,
      SemaforoSolo? sem) {
    final cor = sem != null ? _corSemaforo(sem) : AppColors.newTextSecondary;
    final rangeMax = max * 1.5;
    final pct = rangeMax > 0 ? (valor / rangeMax).clamp(0.0, 1.0) : 0.0;
    final minPct = rangeMax > 0 ? (min / rangeMax).clamp(0.0, 1.0) : 0.0;
    final maxPct = rangeMax > 0 ? (max / rangeMax).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 10, height: 10,
                decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(nome, style: GoogleFonts.inter(fontSize: 12,
                fontWeight: FontWeight.w500, color: AppColors.newTextPrimary)),
            const Spacer(),
            Text(valor.toStringAsFixed(1),
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: cor)),
            Text('  (${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)})',
                style: ChartStyles.observacaoStyle),
          ]),
          const SizedBox(height: 6),
          SizedBox(
            height: 16,
            child: LayoutBuilder(builder: (ctx, constraints) {
              final w = constraints.maxWidth;
              return Stack(
                children: [
                  Container(width: w,
                      decoration: BoxDecoration(color: AppColors.borderDark,
                          borderRadius: BorderRadius.circular(4))),
                  // Faixa ideal
                  Positioned(
                    left: w * minPct, width: w * (maxPct - minPct),
                    top: 0, bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.newSuccess.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  // Marcador do valor
                  Positioned(
                    left: (w * pct - 4).clamp(0, w - 8),
                    top: 2, bottom: 2,
                    child: Container(width: 8,
                        decoration: BoxDecoration(color: cor,
                            borderRadius: BorderRadius.circular(4))),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _linhaInfo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(children: [
        Expanded(child: Text(label, style: GoogleFonts.inter(
            fontSize: 11, color: AppColors.newTextSecondary))),
        Text(valor, style: GoogleFonts.inter(
            fontSize: 11, color: AppColors.newTextPrimary)),
      ]),
    );
  }

  Color _corSemaforo(SemaforoSolo s) {
    switch (s) {
      case SemaforoSolo.vermelho: return AppColors.newDanger;
      case SemaforoSolo.amarelo: return AppColors.newWarning;
      case SemaforoSolo.verde: return AppColors.newSuccess;
    }
  }
}
