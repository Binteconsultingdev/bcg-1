import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ThemeColor {
  // ===========================
  // COLORES PRINCIPALES - BCG
  // ===========================
  static const Color primaryColor = Color(0xFF1A1A1A); // Negro principal
  static const Color secondaryColor = Color(0xFF2C2C2C); // Negro secundario
  static const Color tertiaryColor = Color(0xFF3F3F3F); // Gris oscuro

  static const Color accentColor = Color(0xFFF5A623); // Dorado/Amarillo BCG
  static const Color accentDark = Color(0xFFD4891A); // Dorado oscuro

  // Colores de fondo
  static const Color backgroundColor = Color(0xFFF5F5F5); // Gris muy claro
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static final Color backgroundColorfondo = const Color(0xFFEEEEEE);

  // Colores de texto
  static const Color textPrimaryColor = Color(0xFF1A1A1A); // Negro
  static const Color textSecondaryColor = Color(0xFF757575); // Gris medio
  static const Color textTertiaryColor = Color(0xFF9E9E9E); // Gris claro
  static const Color textLightColor = Colors.white;
  static const Color textDarkColor = Color(0xFF1A1A1A);

  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50); // Verde - PAGADO
  static const Color warningColor = Color(0xFFF5A623); // Amarillo - PENDIENTE
  static const Color errorColor = Color(0xFFE53935); // Rojo - ADEUDO
  static const Color infoColor = Color(0xFF1565C0); // Azul info
  static const Color onlineColor = Color(0xFF4CAF50);

  // Loading
  static final Color loaddingwithOpacity1 = const Color(
    0xFFBDBDBD,
  ).withOpacity(0.15);
  static final Color loaddingwithOpacity3 = const Color(
    0xFF9E9E9E,
  ).withOpacity(0.35);
  static final Color loadding = const Color(0xFF757575);

  // Colores específicos de la app
  static const Color badgeColor = accentColor;
  static const Color distanceBadgeColor = accentColor;
  static const Color likeButtonColor = accentColor;

  // Colores para navegación
  static const Color navbarSelectedColor = accentColor;
  static final Color navbarUnselectedColor = Colors.grey.shade500;

  // Utilidades
  static final Color shadowColor = Colors.black.withOpacity(0.12);
  static final Color dividerColor = const Color(0xFFE0E0E0);
  static final Color disabledColor = Colors.grey.shade400;

  // Dimensiones
  static const double smallRadius = 8.0;
  static const double mediumRadius = 12.0;
  static const double largeRadius = 16.0;
  static const double extraLargeRadius = 40.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  static const double elevationSmall = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationLarge = 8.0;

  // BorderRadius
  static BorderRadius get smallBorderRadius =>
      BorderRadius.circular(smallRadius);
  static BorderRadius get mediumBorderRadius =>
      BorderRadius.circular(mediumRadius);
  static BorderRadius get largeBorderRadius =>
      BorderRadius.circular(largeRadius);
  static BorderRadius get extraLargeBorderRadius =>
      BorderRadius.circular(extraLargeRadius);
  static BorderRadius get circularBorderRadius => BorderRadius.circular(100);

  // Sombras
  static BoxShadow get lightShadow => BoxShadow(
    color: Colors.black.withOpacity(0.05),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  static BoxShadow get mediumShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 10,
    offset: const Offset(0, 4),
  );

  static BoxShadow get darkShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );

  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  // Gradientes
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => const LinearGradient(
    colors: [accentColor, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Decoraciones
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: mediumBorderRadius,
    boxShadow: [cardShadow],
  );

  static BoxDecoration get profileCardDecoration => BoxDecoration(
    color: cardColor,
    borderRadius: largeBorderRadius,
    boxShadow: [cardShadow],
  );

  // Estilos de texto
  static TextStyle get headingLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get headingMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get headingSmall => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static TextStyle get subtitleLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static TextStyle get subtitleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimaryColor,
  );

  static TextStyle get bodyLarge =>
      const TextStyle(fontSize: 16, color: textPrimaryColor);

  static TextStyle get bodyMedium =>
      const TextStyle(fontSize: 14, color: textPrimaryColor);

  static TextStyle get bodySmall =>
      const TextStyle(fontSize: 12, color: textSecondaryColor);

  static TextStyle get caption =>
      const TextStyle(fontSize: 11, color: textSecondaryColor);

  static TextStyle get buttonText => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textLightColor,
  );

  static TextStyle get badgeText => const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textDarkColor,
  );

  // Theme Data
  static ThemeData get themeData => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: textLightColor,
      secondary: accentColor,
      onSecondary: textDarkColor,
      tertiary: tertiaryColor,
      error: errorColor,
      onError: textLightColor,
      background: backgroundColor,
      onBackground: textPrimaryColor,
      surface: surfaceColor,
      onSurface: textPrimaryColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: textLightColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),

    cardTheme: CardThemeData(
      color: cardColor,
      elevation: elevationSmall,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: mediumBorderRadius),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLightColor,
        shape: RoundedRectangleBorder(borderRadius: mediumBorderRadius),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        textStyle: buttonText,
        elevation: elevationSmall,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: mediumBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: mediumBorderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: mediumBorderRadius,
        borderSide: const BorderSide(color: accentColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondaryColor),
      hintStyle: const TextStyle(color: textSecondaryColor),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryColor,
      selectedItemColor: accentColor,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    dividerTheme: DividerThemeData(color: dividerColor, thickness: 1, space: 1),

    iconTheme: const IconThemeData(color: textPrimaryColor, size: 24),
  );

  // ========================================
  // WIDGETS PERSONALIZADOS
  // ========================================

  static Widget createAppLogo({
    String imagePath = 'assets/logo/logo.png',
    double size = 150,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 60.0,
      vertical: 70.0,
    ),
  }) {
    return Padding(
      padding: padding,
      child: Center(
        child: ClipOval(
          child: Container(
            child: Center(
              child: Image.asset(imagePath, width: size, height: size),
            ),
          ),
        ),
      ),
    );
  }

  // Badge de estado (PAGADO, PENDIENTE, ADEUDO, VENDIDO, etc.)
  static Widget createStatusBadge(String text, {Color? color}) {
    Color badgeBackgroundColor;
    Color textCol = Colors.white;

    switch (text.toUpperCase()) {
      case 'PAGADO':
        badgeBackgroundColor = successColor;
        break;
      case 'PENDIENTE':
        badgeBackgroundColor = warningColor;
        textCol = textDarkColor;
        break;
      case 'ADEUDO':
      case 'ELIMINADO':
        badgeBackgroundColor = errorColor;
        break;
      case 'VENDIDO':
        badgeBackgroundColor = infoColor;
        break;
      default:
        badgeBackgroundColor = color ?? primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: badgeBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textCol,
        ),
      ),
    );
  }

  // Badge genérico (reemplaza createTurnBadge y createDistanceBadge)
  static Widget createTurnBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textDarkColor,
        ),
      ),
    );
  }

  static Widget createDistanceBadge(String distance) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        distance,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textDarkColor,
        ),
      ),
    );
  }

  static Widget widgetButton({
    VoidCallback? onPressed,
    String text = 'GUARDAR',
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    EdgeInsets? padding,
    double? borderRadius,
    bool showShadow = true,
    List<BoxShadow>? boxShadow,
    Color? borderColor,
    double? borderWidth,
    FontWeight? fontWeight,
    BoxShadow? customShadow,
    bool isLoading = false,
  }) {
    VoidCallback finalOnPressed = onPressed ?? () {};

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isLoading ? null : finalOnPressed,
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
          decoration: BoxDecoration(
            color: isLoading
                ? (backgroundColor ?? primaryColor).withOpacity(0.7)
                : (backgroundColor ?? primaryColor),
            borderRadius: BorderRadius.circular(borderRadius ?? 5),
            border: borderColor != null
                ? Border.all(color: borderColor, width: borderWidth ?? 1.0)
                : null,
            boxShadow: showShadow ? [customShadow ?? darkShadow] : null,
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: (fontSize ?? 12) + 8,
                    width: (fontSize ?? 12) + 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: fontSize ?? 12,
                      fontWeight: fontWeight ?? FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  // Botón de acción con acento dorado (para acciones primarias como "Cobrar")
  static Widget widgetAccentButton({
    required VoidCallback onPressed,
    required String text,
    double? fontSize,
    EdgeInsets? padding,
    double? borderRadius,
    bool isLoading = false,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isLoading ? null : onPressed,
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: accentGradient,
            borderRadius: BorderRadius.circular(borderRadius ?? 8),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(textDarkColor),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      color: textDarkColor,
                      fontSize: fontSize ?? 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }

  // Botón circular de acción
  static Widget createCircularActionButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? iconColor,
    double size = 44,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [lightShadow],
        ),
        child: Icon(icon, color: iconColor ?? primaryColor, size: size * 0.55),
      ),
    );
  }

  static Widget createMainScaffold({
    required Widget body,
    required int currentIndex,
    required Function(int) onNavigationTap,
    required List<String> iconPaths,
    List<String>? labels,
    Color? backgroundColor,
    Color? bottomNavBackgroundColor,
  }) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ThemeColor.backgroundColor,
      body: body,
      bottomNavigationBar: createBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onNavigationTap,
        iconPaths: iconPaths,
        labels: labels,
        backgroundColor: bottomNavBackgroundColor,
      ),
    );
  }

  static Widget createBottomNavigationBar({
    required int currentIndex,
    required Function(int) onTap,
    required List<String> iconPaths,
    List<String>? labels,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    final Color bgColor = backgroundColor ?? primaryColor;
    final Color selectedColor = selectedItemColor ?? accentColor;
    final Color unselectedColor = unselectedItemColor ?? Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(iconPaths.length, (index) {
              final isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        iconPaths[index],
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                        color: isSelected ? selectedColor : unselectedColor,
                      ),
                      if (labels != null && index < labels.length) ...[
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected ? selectedColor : unselectedColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }


  static Widget createLabeledTextField({
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onSubmitted,
    void Function(String)? onChanged,
    bool enabled = true,
    int maxLines = 1,
    String? errorText,
    bool showError = false,
    EdgeInsets? contentPadding,
    Color? fillColor,
    Color? labelColor,
    Color? textColor,
    Color? hintColor,
    Color? borderColor,
    Color? focusedBorderColor,
    BorderRadius? borderRadius,
    TextStyle? labelStyle,
    TextStyle? textStyle,
    TextStyle? hintStyle,
    double? labelSpacing,
    bool isRequired = false,
      TextCapitalization textCapitalization = TextCapitalization.none,
  List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style:
                  labelStyle ??
                  bodyMedium.copyWith(
                    color: labelColor ?? textDarkColor,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: errorColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: labelSpacing ?? paddingSmall),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onSubmitted: onSubmitted,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,inputFormatters: inputFormatters, 
          style:
              textStyle ??
              bodyMedium.copyWith(color: textColor ?? textDarkColor),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                hintStyle ??
                bodyMedium.copyWith(color: hintColor ?? textSecondaryColor),
            errorText: showError ? errorText : null,
            errorStyle: bodySmall.copyWith(color: errorColor, height: 1.5),
            filled: true,
            fillColor: fillColor ?? surfaceColor,
            contentPadding:
                contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: paddingLarge,
                  vertical: paddingSmall,
                ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: showError
                  ? BorderSide(color: errorColor, width: 1.5)
                  : BorderSide(color: Colors.grey.shade300),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(
                color: (borderColor ?? dividerColor).withOpacity(0.5),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(
                color: showError
                    ? errorColor
                    : (focusedBorderColor ?? accentColor),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(color: errorColor, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? circularBorderRadius,
              borderSide: BorderSide(color: errorColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Card de perfil activo (adaptado para app de ventas - item de cliente/producto)
  static Widget createActiveProfileCard({
    required String imageUrl,
    required String name,
    required int age,
    required String location,
    required double distance,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: secondaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(name, style: subtitleLarge)),
                      const SizedBox(width: 8),
                      createDistanceBadge('${distance.toInt()} km'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ubicación: $location',
                    style: bodyMedium.copyWith(color: textSecondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Edad: $age años',
                    style: bodyMedium.copyWith(color: textSecondaryColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Item de lista genérico (reemplaza createChatItem para ventas/cotizaciones)
  static Widget createListItem({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? leading,
    Widget? trailing,
    String? statusText,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 12)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: subtitleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (statusText != null) createStatusBadge(statusText),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: bodyMedium.copyWith(color: textSecondaryColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }

  static Widget searchTextField({
  required TextEditingController controller,
  required String hintText,
  required void Function(String) onChanged,
  VoidCallback? onClear,
  bool isLoading = false,
  bool hasText = false,
  IconData? prefixIcon,
  BorderRadius? borderRadius,
  Color? fillColor,
    VoidCallback? onPrefixTap, 
  Color? prefixIconColor, 
  TextCapitalization textCapitalization = TextCapitalization.none,
}) {
  return TextField(
    controller: controller,
    style: bodyMedium.copyWith(color: textPrimaryColor),
    textCapitalization: textCapitalization,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: bodyMedium.copyWith(color: textSecondaryColor),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      filled: true,
      fillColor: fillColor ?? backgroundColor,
   prefixIcon: prefixIcon != null
    ? GestureDetector(
        onTap: onPrefixTap,
        child: Icon(
          prefixIcon,
          color: prefixIconColor ?? textSecondaryColor, 
          size: 18,
        ),
      )
    : null,
      suffixIcon: isLoading
          ? const Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : (hasText && onClear != null)
              ? GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: textSecondaryColor,
                  ),
                )
              : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? extraLargeBorderRadius,
        borderSide: BorderSide(
          color: hasText
              ? accentColor.withOpacity(0.5)
              : dividerColor,
          width: hasText ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius ?? extraLargeBorderRadius,
        borderSide: const BorderSide(
          color: accentColor,
          width: 1.5,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius ?? extraLargeBorderRadius,
        borderSide: BorderSide.none,
      ),
    ),
  );
}
}
