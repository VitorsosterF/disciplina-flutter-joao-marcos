import 'package:flutter/material.dart';

/// Paleta do layout "Saborê".
abstract final class CoresApp {
  static const fundo = Color(0xFFF7F4EE);
  static const superficie = Colors.white;
  static const primaria = Color(0xFF235A47);
  static const texto = Color(0xFF1E3D32);
  static const textoSecundario = Color(0xFF5F625E);
  static const borda = Color(0xFFDCDDD6);
  static const destaque = Color(0xFFE8ECE3);
  static const imagemFundo = Color(0xFFE8E4D6);
  static const erro = Color(0xFFB5472A);
}

ThemeData criarTema() {
  final esquemaCores = ColorScheme.fromSeed(
    seedColor: CoresApp.primaria,
    primary: CoresApp.primaria,
    onPrimary: Colors.white,
    surface: CoresApp.fundo,
    onSurface: CoresApp.texto,
    error: CoresApp.erro,
  );

  final bordaCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: CoresApp.borda),
  );
  final formaBotao = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  );
  const textoBotao = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  const paddingBotao = EdgeInsets.symmetric(vertical: 16);

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquemaCores,
    scaffoldBackgroundColor: CoresApp.fundo,
    appBarTheme: const AppBarTheme(
      backgroundColor: CoresApp.fundo,
      foregroundColor: CoresApp.texto,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: CoresApp.texto,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: CoresApp.superficie,
      surfaceTintColor: Colors.transparent,
      indicatorColor: CoresApp.destaque,
      height: 68,
      iconTheme: const WidgetStatePropertyAll(
        IconThemeData(color: CoresApp.texto),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => TextStyle(
          fontSize: 12,
          color: CoresApp.texto,
          fontWeight: estados.contains(WidgetState.selected)
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: CoresApp.borda,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CoresApp.superficie,
      hintStyle: const TextStyle(color: CoresApp.textoSecundario),
      prefixIconColor: CoresApp.textoSecundario,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: bordaCampo,
      enabledBorder: bordaCampo,
      focusedBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: CoresApp.primaria, width: 1.5),
      ),
      errorBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: CoresApp.erro),
      ),
      focusedErrorBorder: bordaCampo.copyWith(
        borderSide: const BorderSide(color: CoresApp.erro, width: 1.5),
      ),
      errorStyle: const TextStyle(color: CoresApp.erro),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CoresApp.primaria,
        foregroundColor: Colors.white,
        padding: paddingBotao,
        shape: formaBotao,
        textStyle: textoBotao,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: CoresApp.primaria,
        side: const BorderSide(color: CoresApp.primaria),
        padding: paddingBotao,
        shape: formaBotao,
        textStyle: textoBotao,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: CoresApp.primaria,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

/// Estilos de texto reaproveitados pelas telas.
abstract final class TextosApp {
  static const marca = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: CoresApp.texto,
  );
  static const tituloTela = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: CoresApp.texto,
  );
  static const tituloSecao = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
    color: CoresApp.texto,
  );
  static const rotulo = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.bold,
    color: CoresApp.texto,
  );
  static const apoio = TextStyle(
    fontSize: 14,
    color: CoresApp.textoSecundario,
    height: 1.4,
  );
}
