import 'package:flutter/material.dart';

import 'home_page.dart';
import 'pesquisa_receitas_page.dart';

/// Rotas nomeadas do app.
abstract final class Rotas {
  static const inicio = '/';

  /// Aceita como argumento opcional o termo (`String`) já digitado na tela inicial.
  static const pesquisa = '/pesquisa';

  static Route<void>? gerar(RouteSettings settings) {
    switch (settings.name) {
      case inicio:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const HomePage(),
        );
      case pesquisa:
        final termo = settings.arguments as String?;
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => PesquisaReceitasPage(termoInicial: termo),
        );
    }
    return null;
  }
}
