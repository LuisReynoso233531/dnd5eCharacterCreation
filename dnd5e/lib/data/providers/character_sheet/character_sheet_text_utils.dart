class CharacterSheetTextUtils {
  static String sign(int n) => n >= 0 ? '+$n' : '$n';

  static String titleCase(String s) {
    if (s.isEmpty) return s;

    return s
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static String cleanPdfText(String value) {
  return value
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')

      // Markdown / separadores
      .replaceAll(RegExp(r'\*{1,3}|_{1,3}'), '')
      .replaceAll('──────────────────────────', '--------------------------')

      // Guiones, comillas y símbolos raros
      .replaceAll('—', '-')
      .replaceAll('–', '-')
      .replaceAll('“', '"')
      .replaceAll('”', '"')
      .replaceAll('‘', "'")
      .replaceAll('’', "'")
      .replaceAll('×', 'x')
      .replaceAll('•', '-')

      // Acentos comunes
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('ñ', 'n')
      .replaceAll('Ñ', 'N')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'U')

      // Espacios
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')

      .replaceAll(RegExp(r'[^\x09\x0A\x0D\x20-\x7E]'), '')
      .trim();
}

  static String cleanTraitText(String value) {
    return cleanPdfText(value);
  }

  static String buildSubclassTraitsText(
    Map<String, dynamic>? archetype,
    int characterLevel,
  ) {
    if (archetype == null) return '';

    final name = (archetype['name'] ?? '').toString().trim();
    if (name.isEmpty) return '';

    final sections = <String>[];

    for (final key in const [
      'features',
      'traits',
      'archetype_features',
      'subclass_features',
    ]) {
      final raw = archetype[key];

      if (raw is List) {
        for (final item in raw) {
          if (item is! Map) continue;

          final featureLevel =
              int.tryParse(
                '${item['level'] ?? item['class_level'] ?? item['unlock_level'] ?? 0}',
              ) ??
              0;

          if (featureLevel > 0 && featureLevel > characterLevel) {
            continue;
          }

          final title = (item['name'] ?? item['title'] ?? item['feature'] ?? '')
              .toString()
              .trim();

          final desc = (item['desc'] ?? item['description'] ?? item['text'] ?? '')
              .toString()
              .trim();

          if (title.isNotEmpty || desc.isNotEmpty) {
            final levelLabel = featureLevel > 0 ? 'Lv$featureLevel - ' : '';
            sections.add('$levelLabel$title\n${cleanTraitText(desc)}'.trim());
          }
        }
      }
    }

    if (sections.isNotEmpty) {
      return 'SUBCLASS: $name\n${sections.join('\n\n')}';
    }

    final desc = cleanTraitText((archetype['desc'] ?? '').toString());
    if (desc.isEmpty) return '';

    return 'SUBCLASS: $name\n$desc';
  }
}
