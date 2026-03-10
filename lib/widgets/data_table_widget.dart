import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DataTableWidget extends StatefulWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final List<DataColumn> dataColumns;
  final List<DataRow> dataRows;
  final bool sortable;
  final int? sortColumnIndex;
  final bool sortAscending;
  final ValueChanged<int>? onSort;

  const DataTableWidget({
    Key? key,
    required this.columns,
    required this.rows,
    this.dataColumns = const [],
    this.dataRows = const [],
    this.sortable = true,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
  }) : super(key: key);

  @override
  State<DataTableWidget> createState() => _DataTableWidgetState();
}

class _DataTableWidgetState extends State<DataTableWidget> {
  late int _sortColumnIndex;
  late bool _sortAscending;

  @override
  void initState() {
    super.initState();
    _sortColumnIndex = widget.sortColumnIndex ?? 0;
    _sortAscending = widget.sortAscending;
  }

  @override
  Widget build(BuildContext context) {
    // Use custom data columns and rows if provided, otherwise build from columns/rows
    final dataColumns = widget.dataColumns.isNotEmpty
        ? widget.dataColumns
        : _buildDataColumns();

    final dataRows = widget.dataRows.isNotEmpty
        ? widget.dataRows
        : _buildDataRows();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          border: Border.all(
            color: AppColors.borderDark,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DataTable(
          columns: dataColumns,
          rows: dataRows,
          showCheckboxColumn: false,
          sortColumnIndex: widget.sortable ? _sortColumnIndex : null,
          sortAscending: _sortAscending,
          dataRowColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.hovered)) {
              return AppColors.borderDark;
            }
            return AppColors.surfaceDark;
          }),
          headingRowColor: MaterialStateProperty.all(
            AppColors.borderDark,
          ),
          headingTextStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.newTextSecondary,
          ),
          dataTextStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.newTextPrimary,
          ),
          dividerThickness: 1,
        ),
      ),
    );
  }

  List<DataColumn> _buildDataColumns() {
    return widget.columns.map((column) {
      final isCurrentSortColumn =
          widget.columns.indexOf(column) == _sortColumnIndex;

      return DataColumn(
        label: Expanded(
          child: Text(column),
        ),
        onSort: widget.sortable
            ? (columnIndex, ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                });
                widget.onSort?.call(columnIndex);
              }
            : null,
      );
    }).toList();
  }

  List<DataRow> _buildDataRows() {
    return widget.rows.map((row) {
      return DataRow(
        cells: row
            .map((cell) => DataCell(Text(cell)))
            .toList(),
      );
    }).toList();
  }
}

// Helper widget para célula de tabela com customização
class TableCell extends StatelessWidget {
  final String value;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final Color? backgroundColor;

  const TableCell({
    Key? key,
    required this.value,
    this.textAlign = TextAlign.left,
    this.textStyle,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        value,
        textAlign: textAlign,
        style: textStyle ??
            GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}

// Helper widget para badge de status
class StatusBadge extends StatelessWidget {
  final String label;
  final String status; // 'success', 'warning', 'danger', 'info'

  const StatusBadge({
    Key? key,
    required this.label,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'success':
        bgColor = AppColors.newSuccess.withOpacity(0.1);
        textColor = AppColors.newSuccess;
        break;
      case 'warning':
        bgColor = AppColors.newWarning.withOpacity(0.1);
        textColor = AppColors.newWarning;
        break;
      case 'danger':
        bgColor = AppColors.newDanger.withOpacity(0.1);
        textColor = AppColors.newDanger;
        break;
      case 'info':
        bgColor = AppColors.newInfo.withOpacity(0.1);
        textColor = AppColors.newInfo;
        break;
      default:
        bgColor = AppColors.borderDark;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
