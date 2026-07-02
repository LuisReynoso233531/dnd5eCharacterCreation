import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'character_sheet_text_utils.dart';
import 'pdf_text_flow.dart';

class PdfFieldWriter {
  final PdfForm form;
  late final Map<String, int> _fieldIndex;

  PdfFieldWriter(this.form) {
    _fieldIndex = _buildFieldIndex();
  }

  Map<String, int> _buildFieldIndex() {
    final index = <String, int>{};

    for (int i = 0; i < form.fields.count; i++) {
      final raw = form.fields[i].name;
      if (raw == null) continue;

      index[raw] = i;
      index[raw.trim()] = i;
      index[raw.replaceAll(RegExp(r'\s+'), ' ').trim()] = i;
    }

    return index;
  }

  int? _indexFor(String name) {
    final normalized = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return _fieldIndex[name] ?? _fieldIndex[normalized];
  }

  void setText(
  String name,
  String value, {
  bool multiline = false,
  double? fontSize,
  PdfTextAlignment? textAlignment,
}) {
  final idx = _indexFor(name);
  if (idx == null) {
    print('PDF field not found: $name');
    return;
  }

  final field = form.fields[idx];

  if (field is PdfTextBoxField) {
    field.text = CharacterSheetTextUtils.cleanPdfText(value);
    field.multiline = multiline;
    field.scrollable = false;

    if (textAlignment != null) {
      field.textAlignment = textAlignment;
    }

    if (fontSize != null) {
      field.font = PdfStandardFont(PdfFontFamily.helvetica, fontSize);
    }
  }
}

  void setCheckbox(String name, bool value) {
    final idx = _indexFor(name);
    if (idx == null) return;

    final field = form.fields[idx];
    if (field is PdfCheckBoxField) {
      field.isChecked = value;
    }
  }

  PdfTextBoxField? textField(String name) {
    final idx = _indexFor(name);

    if (idx == null) {
      print('PDF field not found: $name');
      return null;
    }

    final field = form.fields[idx];
    return field is PdfTextBoxField ? field : null;
  }

  void setMultilineField(
    PdfTextBoxField field,
    String value, {
    double fontSize = 4.8,
  }) {
    field.multiline = true;
    field.scrollable = false;
    field.textAlignment = PdfTextAlignment.left;
    field.font = PdfStandardFont(PdfFontFamily.helvetica, fontSize);
    field.text = CharacterSheetTextUtils.cleanPdfText(value);
  }

  void fillTextAcrossFields({
    required String text,
    required List<String> fieldNames,
    double fontSize = 4.5,
    Map<String, int> reservedBottomLinesByField = const {},
  }) {
    var remaining = CharacterSheetTextUtils.cleanPdfText(text);

    for (final fieldName in fieldNames) {
      final field = textField(fieldName);
      if (field == null) continue;

      if (remaining.isEmpty) {
        setMultilineField(field, '', fontSize: fontSize);
        continue;
      }

      final result = PdfTextFlow.takeMeasuredTextForField(
        remaining,
        field,
        fontSize,
        reservedBottomLines: reservedBottomLinesByField[fieldName] ?? 0,
      );

      setMultilineField(field, result[0], fontSize: fontSize);
      remaining = result[1];
    }

    if (remaining.isNotEmpty) {
      print(
        'PDF traits text still did not fit. Remaining chars: ${remaining.length}',
      );
    }
  }
}
