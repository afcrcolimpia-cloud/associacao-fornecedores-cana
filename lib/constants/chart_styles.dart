// lib/constants/chart_styles.dart
// Estilos padronizados para todos os gráficos do sistema AFCRC
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class ChartStyles {
  ChartStyles._();

  // ═══════════════════════════════════════════════════════════════
  // PALETA DE CORES PARA GRÁFICOS
  // ═══════════════════════════════════════════════════════════════

  /// Cor principal para barras e linhas (verde AFCRC)
  static const Color barPrimary = AppColors.newPrimary;

  /// Azul para precipitação e dados secundários
  static const Color barBlue = Color(0xFF60A5FA);

  /// Cores para séries múltiplas (PieChart, comparativos)
  static const List<Color> seriesColors = [
    Color(0xFF16A34A), // verde
    Color(0xFF2563EB), // azul
    Color(0xFFD97706), // amarelo
    Color(0xFFDC2626), // vermelho
    Color(0xFF7C3AED), // roxo
    Color(0xFF0891B2), // ciano
    Color(0xFFEA580C), // laranja
    Color(0xFFDB2777), // pink
  ];

  /// Valor positivo / negativo
  static const Color positive = AppColors.newSuccess;
  static const Color negative = AppColors.newDanger;

  // ═══════════════════════════════════════════════════════════════
  // TIPOGRAFIA
  // ═══════════════════════════════════════════════════════════════

  /// Título do gráfico
  static TextStyle titleStyle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.newTextPrimary,
  );

  /// Subtítulo / contexto
  static TextStyle subtitleStyle = GoogleFonts.inter(
    fontSize: 13,
    color: AppColors.newTextSecondary,
  );

  /// Labels dos eixos
  static TextStyle axisLabelStyle = GoogleFonts.inter(
    fontSize: 11,
    color: AppColors.newTextSecondary,
  );

  /// Tooltip value
  static TextStyle tooltipStyle = GoogleFonts.inter(
    fontSize: 12,
    color: Colors.white,
    fontWeight: FontWeight.w600,
  );

  /// Legenda
  static TextStyle legendStyle = GoogleFonts.inter(
    fontSize: 12,
    color: AppColors.newTextSecondary,
  );

  /// Observação técnica (footer do chart)
  static TextStyle observacaoStyle = GoogleFonts.inter(
    fontSize: 11,
    fontStyle: FontStyle.italic,
    color: AppColors.newTextMuted,
  );

  // ═══════════════════════════════════════════════════════════════
  // GRID & BORDER
  // ═══════════════════════════════════════════════════════════════

  /// Grid padrão — apenas linhas horizontais
  static FlGridData get gridPadrao => FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: AppColors.borderDark,
          strokeWidth: 0.5,
        ),
      );

  /// Sem grid
  static const FlGridData gridNenhum = FlGridData(show: false);

  /// Border padrão — nenhuma (chart "flutuante")
  static FlBorderData get borderNenhum => FlBorderData(show: false);

  // ═══════════════════════════════════════════════════════════════
  // TITLES DATA
  // ═══════════════════════════════════════════════════════════════

  /// Esconde top e right titles (padrão)
  static const AxisTitles hiddenAxis = AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  );

  /// Left axis com labels customizados
  static AxisTitles leftAxis({
    required Widget Function(double, TitleMeta) getTitlesWidget,
    double reservedSize = 45,
  }) =>
      AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: reservedSize,
          getTitlesWidget: getTitlesWidget,
        ),
      );

  /// Bottom axis com labels customizados
  static AxisTitles bottomAxis({
    required Widget Function(double, TitleMeta) getTitlesWidget,
    double reservedSize = 32,
  }) =>
      AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: reservedSize,
          getTitlesWidget: getTitlesWidget,
        ),
      );

  /// Monta FlTitlesData padronizado (esconde top e right)
  static FlTitlesData titlesData({
    required AxisTitles left,
    required AxisTitles bottom,
  }) =>
      FlTitlesData(
        leftTitles: left,
        bottomTitles: bottom,
        topTitles: hiddenAxis,
        rightTitles: hiddenAxis,
      );

  // ═══════════════════════════════════════════════════════════════
  // BAR CHART
  // ═══════════════════════════════════════════════════════════════

  /// Estilo padrão para baras verticais
  static BarChartRodData barRod({
    required double toY,
    Color? color,
    double width = 16,
  }) =>
      BarChartRodData(
        toY: toY,
        color: color ?? barPrimary,
        width: width,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      );

  /// Tooltip padrão para BarChart
  static BarTouchTooltipData barTooltip({
    required String Function(int groupIndex) getLabel,
  }) =>
      BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            getLabel(groupIndex),
            tooltipStyle,
          );
        },
      );

  // ═══════════════════════════════════════════════════════════════
  // LINE CHART
  // ═══════════════════════════════════════════════════════════════

  /// Estilo padrão para linhas
  static LineChartBarData lineBar({
    required List<FlSpot> spots,
    required Color color,
    bool showArea = false,
    bool showDots = false,
    double barWidth = 2.5,
  }) =>
      LineChartBarData(
        spots: spots,
        isCurved: true,
        color: color,
        barWidth: barWidth,
        dotData: FlDotData(show: showDots),
        belowBarData: BarAreaData(
          show: showArea,
          color: color.withValues(alpha: 0.10),
        ),
      );

  // ═══════════════════════════════════════════════════════════════
  // PIE CHART
  // ═══════════════════════════════════════════════════════════════

  /// Seção padrão para PieChart
  static PieChartSectionData pieSection({
    required double value,
    required String title,
    required Color color,
    double radius = 60,
  }) =>
      PieChartSectionData(
        value: value,
        title: title,
        color: color,
        radius: radius,
        titleStyle: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Label de eixo padrão (Text widget com estilo axisLabel)
  static Widget axisLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text, style: axisLabelStyle),
      );

  /// Widget de legenda (bolinha + texto)
  static Widget legendItem(String label, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: legendStyle),
        ],
      );
}
