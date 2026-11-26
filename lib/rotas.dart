import 'package:flutter/material.dart';

import 'models/receita.dart';
import 'pages/app_shell.dart';
import 'pages/detalhes_receita_page.dart';

/// Rotas nomeadas do app.
abstract final class Rotas {
  /// Estrutura principal com as abas Explorar e Favoritos.
  static const inicio = '/';

  /// Detalhes; exige uma [Receita] como argumento.
  static const detalhes = '/detalhes';

  static Route<void>? gerar(RouteSettings settings) {
    switch (settings.name) {
      case inicio:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AppShell(),
        );
      case detalhes:
        final receita = settings.arguments;
        if (receita is! Receita) return null;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => DetalhesReceitaPage(receita: receita),
        );
    }
    return null;
  }
}
