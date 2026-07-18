class PdfFeatureTextPolicy {
  const PdfFeatureTextPolicy._();

  static String sanitizeClassDescription({
    required String classSlug,
    required String rawDescription,
  }) {
    var result = rawDescription;

    if (classSlug.trim().toLowerCase() == 'warlock') {
      /*
       * El primer encabezado "Eldritch Invocations" explica la
       * característica de nivel 2.
       *
       * El segundo contiene el catálogo completo. Todo lo que está
       * desde el segundo encabezado en adelante no debe ir al PDF.
       */
      result = _truncateAtHeadingOccurrence(
        result,
        headingTitle: 'Eldritch Invocations',
        occurrence: 2,
      );

      /*
       * No queremos imprimir las tres opciones de pacto.
       * Posteriormente agregaremos únicamente el pacto escogido.
       */
      result = _removeMarkdownSections(
        result,
        sectionTitles: const {
          'pact of the chain',
          'pact of the blade',
          'pact of the tome',
        },
      );

      result = _removeQuotedSection(
        result,
        sectionTitle: 'Your Pact Boon',
      );
    }

    return _clean(result);
  }

  static String sanitizeSubclassDescription({
    required String classSlug,
    required String archetypeSlug,
    required String rawDescription,
  }) {
    final normalizedClass = classSlug.trim().toLowerCase();
    final normalizedArchetype = archetypeSlug.trim().toLowerCase();

    var result = rawDescription;

    final isWildMagicSorcerer =
        normalizedClass == 'sorcerer' &&
        {
          'wild-magic',
          'wyrd-magic',
        }.contains(normalizedArchetype);

    if (isWildMagicSorcerer) {
      /*
       * Conservamos la explicación de Wild Magic/Flood of Chaos,
       * pero eliminamos la tabla d100.
       */
      result = _removeMarkdownTables(
        result,
        shouldRemove: (title) {
          return title.contains('wild magic surge') ||
              title.contains('flood of chaos');
        },
        replacement:
            'Wild Magic table omitted from this character sheet. '
            'Use the in-app reference when a surge occurs.',
      );
    }

    if (normalizedClass == 'warlock') {
      /*
       * Expanded Spell List no concede automáticamente los conjuros.
       * Solo los añade a las opciones disponibles, por lo que no
       * necesita imprimirse completa en la hoja.
       */
      result = _removeMarkdownSections(
        result,
        sectionTitles: const {
          'expanded spell list',
        },
      );
    }

    return _clean(result);
  }

  static String _truncateAtHeadingOccurrence(
    String text, {
    required String headingTitle,
    required int occurrence,
  }) {
    final lines = _normalizeNewLines(text).split('\n');
    final expectedTitle = headingTitle.trim().toLowerCase();

    var found = 0;

    for (var index = 0; index < lines.length; index++) {
      final heading = _parseHeading(lines[index]);

      if (heading == null) {
        continue;
      }

      if (heading.title == expectedTitle) {
        found++;

        if (found == occurrence) {
          return lines.take(index).join('\n');
        }
      }
    }

    return text;
  }

  static String _removeMarkdownSections(
    String text, {
    required Set<String> sectionTitles,
  }) {
    final lines = _normalizeNewLines(text).split('\n');

    final normalizedTitles = sectionTitles
        .map((title) => title.trim().toLowerCase())
        .toSet();

    final result = <String>[];

    var index = 0;

    while (index < lines.length) {
      final heading = _parseHeading(lines[index]);

      if (heading == null ||
          !normalizedTitles.contains(heading.title)) {
        result.add(lines[index]);
        index++;
        continue;
      }

      final removedHeadingLevel = heading.level;
      index++;

      /*
       * Se omite el contenido hasta encontrar otro encabezado del
       * mismo nivel o uno superior.
       */
      while (index < lines.length) {
        final nextHeading = _parseHeading(lines[index]);

        if (nextHeading != null &&
            nextHeading.level <= removedHeadingLevel) {
          break;
        }

        index++;
      }
    }

    return result.join('\n');
  }

  static String _removeQuotedSection(
    String text, {
    required String sectionTitle,
  }) {
    final lines = _normalizeNewLines(text).split('\n');
    final expectedTitle = sectionTitle.trim().toLowerCase();
    final result = <String>[];

    var index = 0;

    while (index < lines.length) {
      final line = lines[index];
      final heading = _parseHeading(line);

      final isQuotedHeading =
          line.trimLeft().startsWith('>') &&
          heading?.title == expectedTitle;

      if (!isQuotedHeading) {
        result.add(line);
        index++;
        continue;
      }

      index++;

      while (index < lines.length) {
        final current = lines[index].trimLeft();

        if (current.startsWith('>') || current.isEmpty) {
          index++;
          continue;
        }

        break;
      }
    }

    return result.join('\n');
  }

  static String _removeMarkdownTables(
    String text, {
    required bool Function(String normalizedTitle) shouldRemove,
    String? replacement,
  }) {
    final lines = _normalizeNewLines(text).split('\n');
    final result = <String>[];

    var index = 0;

    while (index < lines.length) {
      final currentLine = lines[index];
      final normalizedTitle = _plainMarkdown(currentLine);

      var tableStart = index + 1;

      while (tableStart < lines.length &&
          lines[tableStart].trim().isEmpty) {
        tableStart++;
      }

      final hasTableAfterTitle =
          tableStart < lines.length &&
          lines[tableStart].trimLeft().startsWith('|');

      if (!hasTableAfterTitle ||
          !shouldRemove(normalizedTitle)) {
        result.add(currentLine);
        index++;
        continue;
      }

      if (replacement != null &&
          replacement.trim().isNotEmpty) {
        result.add(replacement.trim());
        result.add('');
      }

      index = tableStart;

      while (index < lines.length &&
          lines[index].trimLeft().startsWith('|')) {
        index++;
      }

      while (index < lines.length &&
          lines[index].trim().isEmpty) {
        index++;
      }
    }

    return result.join('\n');
  }

  static _MarkdownHeading? _parseHeading(String line) {
    var normalized = line.trimLeft();

    if (normalized.startsWith('>')) {
      normalized = normalized.substring(1).trimLeft();
    }

    final match = RegExp(
      r'^(#{1,6})\s+(.+?)\s*$',
    ).firstMatch(normalized);

    if (match == null) {
      return null;
    }

    return _MarkdownHeading(
      level: match.group(1)!.length,
      title: _plainMarkdown(match.group(2)!),
    );
  }

  static String _plainMarkdown(String value) {
    return value
        .replaceAll(RegExp(r'[*_`>]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  static String _normalizeNewLines(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
  }

  static String _clean(String value) {
    return _normalizeNewLines(value)
        .replaceAll(RegExp(r'\n[ \t]+\n'), '\n\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class _MarkdownHeading {
  const _MarkdownHeading({
    required this.level,
    required this.title,
  });

  final int level;
  final String title;
}