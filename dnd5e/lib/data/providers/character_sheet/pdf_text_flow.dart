import 'dart:math' as math;

import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'character_sheet_text_utils.dart';

class PdfTextFlowResult {
  final String fittedText;
  final String remainingText;

  const PdfTextFlowResult({
    required this.fittedText,
    required this.remainingText,
  });
}

class PdfTextFlow {
  static PdfTextFlowResult takeMeasuredTextForField(
    String text,
    PdfTextBoxField field,
    double fontSize, {
    int reservedBottomLines = 0,
  }) {
    final font = PdfStandardFont(
      PdfFontFamily.helvetica,
      fontSize,
    );

    final maxWidth = math.max(
      10.0,
      field.bounds.width - 6.0,
    );

    final maxHeight = math.max(
      10.0,
      field.bounds.height - 6.0,
    );

    final lineHeight = fontSize * 1.16;

    final calculatedMaxLines = math.max(
      1,
      (maxHeight / lineHeight).floor(),
    );

    final maxLines = math.max(
      1,
      calculatedMaxLines - reservedBottomLines,
    );

    final cleanText = CharacterSheetTextUtils.cleanPdfText(text);

    if (cleanText.isEmpty) {
      return const PdfTextFlowResult(
        fittedText: '',
        remainingText: '',
      );
    }

    /*
     * Cada elemento representa una línea real del contenido original.
     *
     * Los saltos creados por el ajuste automático no deben conservarse
     * cuando el texto pasa a otro campo con un ancho diferente.
     */
    final sourceLines = cleanText.split('\n');
    final fittedLines = <String>[];

    for (
      int sourceIndex = 0;
      sourceIndex < sourceLines.length;
      sourceIndex++
    ) {
      final sourceLine = sourceLines[sourceIndex];

      if (fittedLines.length >= maxLines) {
        return PdfTextFlowResult(
          fittedText: _trimLineBreaks(
            fittedLines.join('\n'),
          ),
          remainingText: _trimLineBreaks(
            sourceLines.skip(sourceIndex).join('\n'),
          ),
        );
      }

      if (sourceLine.trim().isEmpty) {
        fittedLines.add('');
        continue;
      }

      final wrappedLines = _wrapSingleSourceLine(
        sourceLine.trim(),
        font,
        maxWidth,
      );

      final availableLines = maxLines - fittedLines.length;

      if (wrappedLines.length <= availableLines) {
        fittedLines.addAll(wrappedLines);
        continue;
      }

      fittedLines.addAll(
        wrappedLines.take(availableLines),
      );

      /*
       * Este es el cambio importante.
       *
       * No usamos join('\n'), porque esos saltos corresponden al ancho
       * del campo actual. Se usan espacios para que el siguiente campo
       * vuelva a envolver el párrafo con su propio ancho.
       */
      final unfinishedSourceLine = wrappedLines
          .skip(availableLines)
          .join(' ')
          .trim();

      final remainingParts = <String>[
        if (unfinishedSourceLine.isNotEmpty)
          unfinishedSourceLine,
        ...sourceLines.skip(sourceIndex + 1),
      ];

      return PdfTextFlowResult(
        fittedText: _trimLineBreaks(
          fittedLines.join('\n'),
        ),
        remainingText: _trimLineBreaks(
          remainingParts.join('\n'),
        ),
      );
    }

    return PdfTextFlowResult(
      fittedText: _trimLineBreaks(
        fittedLines.join('\n'),
      ),
      remainingText: '',
    );
  }

  static List<String> _wrapSingleSourceLine(
    String text,
    PdfFont font,
    double maxWidth,
  ) {
    final result = <String>[];
    final words = text.split(RegExp(r'\s+'));

    var currentLine = '';

    for (final word in words) {
      if (word.isEmpty) continue;

      if (currentLine.isEmpty) {
        if (_textFits(font, word, maxWidth)) {
          currentLine = word;
        } else {
          final chunks = _splitLongWordByMeasuredWidth(
            word,
            font,
            maxWidth,
          );

          if (chunks.length > 1) {
            result.addAll(
              chunks.take(chunks.length - 1),
            );
          }

          currentLine = chunks.isNotEmpty
              ? chunks.last
              : '';
        }

        continue;
      }

      final candidate = '$currentLine $word';

      if (_textFits(font, candidate, maxWidth)) {
        currentLine = candidate;
        continue;
      }

      result.add(currentLine);

      if (_textFits(font, word, maxWidth)) {
        currentLine = word;
      } else {
        final chunks = _splitLongWordByMeasuredWidth(
          word,
          font,
          maxWidth,
        );

        if (chunks.length > 1) {
          result.addAll(
            chunks.take(chunks.length - 1),
          );
        }

        currentLine = chunks.isNotEmpty
            ? chunks.last
            : '';
      }
    }

    if (currentLine.isNotEmpty) {
      result.add(currentLine);
    }

    return result;
  }

  static bool _textFits(
    PdfFont font,
    String text,
    double maxWidth,
  ) {
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

  static String _trimLineBreaks(String value) {
    return value
        .replaceFirst(RegExp(r'^\n+'), '')
        .replaceFirst(RegExp(r'\n+$'), '');
  }
}