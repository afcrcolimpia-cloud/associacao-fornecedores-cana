// lib/widgets/chart_card.dart
// Container padronizado para todos os gráficos do sistema AFCRC
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Widget container que envolve qualquer gráfico com visual padronizado.
///
/// Uso:
/// ```dart
/// ChartCard(
///   titulo: 'Produção por Mês',
///   subtitulo: 'Safra 2025',
///   height: 300,
///   observacao: 'Média regional: 86 t/ha',
///   child: BarChart(...),
/// )
/// ```
class ChartCard extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final String? observacao;
  final double height;
  final Widget child;
  final Widget? legendWidget;
  final EdgeInsetsGeometry? margin;

  const ChartCard({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.observacao,
    this.height = 300,
    required this.child,
    this.legendWidget,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            titulo,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.newTextPrimary,
            ),
          ),

          // Subtítulo
          if (subtitulo != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitulo!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.newTextSecondary,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Gráfico
          SizedBox(
            height: height,
            child: child,
          ),

          // Legenda
          if (legendWidget != null) ...[
            const SizedBox(height: 12),
            legendWidget!,
          ],

          // Observação técnica
          if (observacao != null) ...[
            const SizedBox(height: 12),
            Text(
              observacao!,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.newTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
