import 'dart:math' as math;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'character_sheet_text_utils.dart';

class PdfTextFlow {
  static List<String> takeMeasuredTextForField(
    String text,
    PdfTextBoxField field,
    double fontSize, {
    int reservedBottomLines = 0,
  }) {
    final font = PdfStandardFont(PdfFontFamily.helvetica, fontSize);

    final maxWidth = math.max(10.0, field.bounds.width - 6.0);
    final maxHeight = math.max(10.0, field.bounds.height - 6.0);

    final lineHeight = fontSize * 1.16;
    final calculatedMaxLines = math.max(1, (maxHeight / lineHeight).floor());
    final maxLines = math.max(1, calculatedMaxLines - reservedBottomLines);

    final lines = wrapTextByMeasuredWidth(
      CharacterSheetTextUtils.cleanPdfText(text),
      font,
      maxWidth,
    );

    if (lines.length <= maxLines) {
      return [lines.join('\n').trim(), ''];
    }

    return [
      lines.take(maxLines).join('\n').trim(),
      lines.skip(maxLines).join('\n').trim(),
    ];
  }

  static List<String> wrapTextByMeasuredWidth(
    String text,
    PdfFont font,
    double maxWidth,
  ) {
    final result = <String>[];
    final paragraphs = text.split('\n');

    for (final paragraph in paragraphs) {
      final cleanParagraph = paragraph.trim();

      if (cleanParagraph.isEmpty) {
        if (result.isNotEmpty && result.last.isNotEmpty) {
          result.add('');
        }
        continue;
      }

      final words = cleanParagraph.split(RegExp(r'\s+'));
      var currentLine = '';

      for (final word in words) {
        if (currentLine.isEmpty) {
          if (_textFits(font, word, maxWidth)) {
            currentLine = word;
          } else {
            final split = _splitLongWordByMeasuredWidth(word, font, maxWidth);
            result.addAll(split.take(split.length - 1));
            currentLine = split.isNotEmpty ? split.last : '';
          }
          continue;
        }

        final candidate = '$currentLine $word';

        if (_textFits(font, candidate, maxWidth)) {
          currentLine = candidate;
        } else {
          result.add(currentLine);

          if (_textFits(font, word, maxWidth)) {
            currentLine = word;
          } else {
            final split = _splitLongWordByMeasuredWidth(word, font, maxWidth);
            result.addAll(split.take(split.length - 1));
            currentLine = split.isNotEmpty ? split.last : '';
          }
        }
      }

      if (currentLine.isNotEmpty) {
        result.add(currentLine);
      }
    }

    while (result.isNotEmpty && result.last.trim().isEmpty) {
      result.removeLast();
    }

    return result;
  }

  static bool _textFits(PdfFont font, String text, double maxWidth) {
    return font.measureString(text).width <= maxWidth;
  }

  static List<String> _splitLongWordByMeasuredWidth(
    String word,
    PdfFont font,
    double maxWidth,
  ) {
    final chunks = <String>[];
    var current = '';

    for (int i = 0; i < word.length; i++) {
      final candidate = '$current${word[i]}';

      if (_textFits(font, candidate, maxWidth)) {
        current = candidate;
      } else {
        if (current.isNotEmpty) {
          chunks.add(current);
        }
        current = word[i];
      }
    }

    if (current.isNotEmpty) {
      chunks.add(current);
    }

    return chunks;
  }
}
