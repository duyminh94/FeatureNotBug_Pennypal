class TextLinePosition {
  final String text;
  final double top;
  final double bottom;
  final double left;

  const TextLinePosition({required this.text, required this.top, required this.bottom, required this.left});

  double get centerY => (top + bottom) / 2;
  double get height => bottom - top;
}

class ReceiptTextBuilder {
  static String buildRows(List<TextLinePosition> lines) {
    if (lines.isEmpty) return '';

    final List<TextLinePosition> sorted = [...lines]..sort((a, b) => a.centerY.compareTo(b.centerY));
    final List<List<TextLinePosition>> rows = [];

    for (final TextLinePosition line in sorted) {
      final List<TextLinePosition>? lastRow = rows.isEmpty ? null : rows.last;
      if (lastRow != null && _isSameRow(lastRow.first, line)) {
        lastRow.add(line);
      } else {
        rows.add([line]);
      }
    }

    return rows.map((row) {
      row.sort((a, b) => a.left.compareTo(b.left));
      return row.map((line) => line.text).join('   ');
    }).join('\n');
  }

  static bool _isSameRow(TextLinePosition rowStart, TextLinePosition line) {
    final double smallerHeight = rowStart.height < line.height ? rowStart.height : line.height;
    return (line.centerY - rowStart.centerY).abs() <= smallerHeight / 2;
  }
}
