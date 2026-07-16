import 'package:flutter/material.dart';

@immutable
class DndThemeColors extends ThemeExtension<DndThemeColors> {
  final Color surfaceRaised;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color border;
  final Color borderStrong;
  final Color mutedText;
  final Color subtleText;
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color danger;
  final Color onDanger;
  final Color dangerContainer;
  final Color onDangerContainer;

  const DndThemeColors({
    required this.surfaceRaised,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.border,
    required this.borderStrong,
    required this.mutedText,
    required this.subtleText,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
    required this.onDangerContainer,
  });

  static const light = DndThemeColors(
    surfaceRaised: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF4F5F7),
    surfaceStrong: Color(0xFFE9EBEF),
    border: Color(0xFFD8DBE2),
    borderStrong: Color(0xFFB8BDC8),
    mutedText: Color(0xFF626875),
    subtleText: Color(0xFF858B96),
    success: Color(0xFF237A42),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFDDF3E4),
    onSuccessContainer: Color(0xFF124A27),
    warning: Color(0xFF9A5B00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFE9C2),
    onWarningContainer: Color(0xFF5A3500),
    info: Color(0xFF2767A5),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFDDEEFF),
    onInfoContainer: Color(0xFF173D62),
    danger: Color(0xFFBA1A1A),
    onDanger: Color(0xFFFFFFFF),
    dangerContainer: Color(0xFFFFDAD6),
    onDangerContainer: Color(0xFF93000A),
  );

  static const dark = DndThemeColors(
    surfaceRaised: Color(0xFF1B1D22),
    surfaceMuted: Color(0xFF202329),
    surfaceStrong: Color(0xFF2A2D34),
    border: Color(0xFF373B44),
    borderStrong: Color(0xFF555B67),
    mutedText: Color(0xFFB8BDC7),
    subtleText: Color(0xFF8E949F),
    success: Color(0xFF7ED99A),
    onSuccess: Color(0xFF073918),
    successContainer: Color(0xFF174D29),
    onSuccessContainer: Color(0xFFB5F2C5),
    warning: Color(0xFFFFC36B),
    onWarning: Color(0xFF4D2B00),
    warningContainer: Color(0xFF5B3A0B),
    onWarningContainer: Color(0xFFFFDCA8),
    info: Color(0xFF9ACBFF),
    onInfo: Color(0xFF003258),
    infoContainer: Color(0xFF173F62),
    onInfoContainer: Color(0xFFD1E8FF),
    danger: Color(0xFFFFB4AB),
    onDanger: Color(0xFF690005),
    dangerContainer: Color(0xFF7F1D1D),
    onDangerContainer: Color(0xFFFFDAD6),
  );

  @override
  DndThemeColors copyWith({
    Color? surfaceRaised,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? border,
    Color? borderStrong,
    Color? mutedText,
    Color? subtleText,
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
    Color? onDangerContainer,
  }) {
    return DndThemeColors(
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      mutedText: mutedText ?? this.mutedText,
      subtleText: subtleText ?? this.subtleText,
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
      onDangerContainer: onDangerContainer ?? this.onDangerContainer,
    );
  }

  @override
  DndThemeColors lerp(ThemeExtension<DndThemeColors>? other, double t) {
    if (other is! DndThemeColors) return this;

    return DndThemeColors(
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      subtleText: Color.lerp(subtleText, other.subtleText, t)!,
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer:
          Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer:
          Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer:
          Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer:
          Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
      onDangerContainer:
          Color.lerp(onDangerContainer, other.onDangerContainer, t)!,
    );
  }
}

extension DndThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  DndThemeColors get dndColors =>
      Theme.of(this).extension<DndThemeColors>() ??
      (isDarkMode ? DndThemeColors.dark : DndThemeColors.light);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  static const primaryRed = Color(0xFFE50914);
  static const darkPrimaryRed = Color(0xFFFF5A62);

  static final ThemeData lightTheme = _buildTheme(Brightness.light);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryRed,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? darkPrimaryRed : primaryRed,
      surface: isDark ? const Color(0xFF121317) : const Color(0xFFFDFDFE),
    );
    final extra = isDark ? DndThemeColors.dark : DndThemeColors.light;
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF101115) : const Color(0xFFF8F9FB),
      extensions: <ThemeExtension<dynamic>>[extra],
    );

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: extra.border),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF8F1018) : primaryRed,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        elevation: isDark ? 0 : 1,
        color: extra.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: extra.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: extra.border,
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: extra.surfaceRaised,
        hintStyle: TextStyle(color: extra.subtleText),
        labelStyle: TextStyle(color: extra.mutedText),
        helperStyle: TextStyle(color: extra.mutedText),
        prefixIconColor: extra.mutedText,
        suffixIconColor: extra.mutedText,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: outlineBorder.copyWith(
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: extra.mutedText,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: Colors.transparent,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: scheme.primary,
        collapsedIconColor: extra.mutedText,
        textColor: scheme.onSurface,
        collapsedTextColor: scheme.onSurface,
        shape: const Border(),
        collapsedShape: const Border(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 8,
        backgroundColor: extra.surfaceRaised,
        selectedItemColor: scheme.primary,
        unselectedItemColor: extra.mutedText,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 8,
        backgroundColor: extra.surfaceRaised,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : extra.mutedText,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
          );
        }),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: extra.surfaceRaised,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: extra.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: extra.surfaceRaised,
        modalBackgroundColor: extra.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: extra.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFFE7E9EE)
            : const Color(0xFF25272D),
        contentTextStyle: TextStyle(
          color: isDark ? const Color(0xFF1A1B1F) : Colors.white,
        ),
        actionTextColor: isDark ? primaryRed : const Color(0xFFFFB4AB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: extra.surfaceMuted,
        selectedColor: scheme.primaryContainer,
        disabledColor: extra.surfaceStrong,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
        side: BorderSide(color: extra.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: extra.surfaceStrong,
          disabledForegroundColor: extra.subtleText,
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: extra.borderStrong),
          minimumSize: const Size(0, 46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return extra.mutedText;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return extra.surfaceStrong;
        }),
        trackOutlineColor: WidgetStatePropertyAll(extra.borderStrong),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: extra.borderStrong),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return extra.mutedText;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: extra.surfaceStrong,
        circularTrackColor: extra.surfaceStrong,
      ),
      iconTheme: IconThemeData(color: extra.mutedText),
      primaryIconTheme: const IconThemeData(color: Colors.white),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.28),
        selectionHandleColor: scheme.primary,
      ),
    );
  }
}
