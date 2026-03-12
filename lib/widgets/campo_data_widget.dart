// lib/widgets/campo_data_widget.dart
//
// Widget reutilizável para campos de data.
// Permite:
//   - Digitar manualmente no formato dd/mm/aaaa
//   - Clicar no ícone de calendário para abrir showDatePicker
//
// Uso:
//   CampoDataWidget(
//     label: 'Data de Coleta',
//     valor: _dataColeta,
//     onChanged: (novaData) => setState(() => _dataColeta = novaData),
//   )

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoDataWidget extends StatefulWidget {
  final String label;
  final DateTime? valor;
  final ValueChanged<DateTime?> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool obrigatorio;
  final String? Function(DateTime?)? validator;

  const CampoDataWidget({
    super.key,
    required this.label,
    required this.valor,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.obrigatorio = false,
    this.validator,
  });

  @override
  State<CampoDataWidget> createState() => _CampoDataWidgetState();
}

class _CampoDataWidgetState extends State<CampoDataWidget> {
  late final TextEditingController _ctrl;
  late final FocusNode _focus;

  static final _regex = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: _formatar(widget.valor));
    _focus = FocusNode();
    _focus.addListener(() {
      if (!_focus.hasFocus) _tentarParsear(_ctrl.text);
    });
  }

  @override
  void didUpdateWidget(covariant CampoDataWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza o campo se o valor externo mudar (ex: após seleção no calendário)
    if (widget.valor != oldWidget.valor) {
      final texto = _formatar(widget.valor);
      if (_ctrl.text != texto) {
        _ctrl.text = texto;
        _ctrl.selection =
            TextSelection.fromPosition(TextPosition(offset: texto.length));
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _formatar(DateTime? data) {
    if (data == null) return '';
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _tentarParsear(String texto) {
    final match = _regex.firstMatch(texto.trim());
    if (match != null) {
      final dia = int.parse(match.group(1)!);
      final mes = int.parse(match.group(2)!);
      final ano = int.parse(match.group(3)!);
      // Valida intervalo simples (dia 1-31, mes 1-12)
      if (dia >= 1 && dia <= 31 && mes >= 1 && mes <= 12 && ano >= 1900) {
        try {
          final nova = DateTime(ano, mes, dia);
          widget.onChanged(nova);
        } catch (_) {
          // Data inválida (ex: 31/02/2024) — não atualiza
        }
      }
    } else if (texto.trim().isEmpty) {
      widget.onChanged(null);
    }
  }

  Future<void> _abrirCalendario() async {
    final inicial = widget.valor ?? DateTime.now();
    final primeira = widget.firstDate ?? DateTime(2000);
    final ultima = widget.lastDate ?? DateTime(2100);

    // Garante que a data inicial está dentro do range
    final inicialValida = inicial.isBefore(primeira)
        ? primeira
        : inicial.isAfter(ultima)
            ? ultima
            : inicial;

    final selecionada = await showDatePicker(
      context: context,
      initialDate: inicialValida,
      firstDate: primeira,
      lastDate: ultima,
      locale: const Locale('pt', 'BR'),
    );

    if (selecionada != null) {
      widget.onChanged(selecionada);
      // O campo de texto será atualizado via didUpdateWidget
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      focusNode: _focus,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        hintText: 'dd/mm/aaaa',
        prefixIcon: const Icon(Icons.calendar_today),
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          tooltip: 'Selecionar no calendário',
          onPressed: _abrirCalendario,
        ),
      ),
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        // Permite apenas dígitos e barras
        FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
        // Auto-insere barras: "01" → "01/", "01/01" → "01/01/"
        _DataInputFormatter(),
      ],
      maxLength: 10,
      buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
          null, // Esconde contador
      validator: widget.validator != null
          ? (_) => widget.validator!(widget.valor)
          : widget.obrigatorio
              ? (_) => widget.valor == null ? 'Informe a data' : null
              : null,
      onChanged: (texto) {
        if (texto.length == 10) _tentarParsear(texto);
      },
    );
  }
}

/// Formatter que insere barras automaticamente: 01 → 01/ → 01/03/ → 01/03/2024
class _DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    // Só adiciona barra quando o usuário digitou (não apagou)
    if (newValue.text.length < oldValue.text.length) return newValue;

    final digits = text.replaceAll('/', '');
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);
      if (i == 1 || i == 3) buffer.write('/');
    }

    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
