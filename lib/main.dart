import 'package:flutter/material.dart';

import 'rotas.dart';
import 'services/receitas_api.dart';
import 'state/app_scope.dart';
import 'state/favoritos_controller.dart';
import 'tema.dart';

void main() => runApp(const DisciplinaFlutterApp());

class DisciplinaFlutterApp extends StatefulWidget {
  /// Permite injetar uma API falsa nos testes.
  final ReceitasApi? api;

  const DisciplinaFlutterApp({super.key, this.api});

  @override
  State<DisciplinaFlutterApp> createState() => _DisciplinaFlutterAppState();
}

class _DisciplinaFlutterAppState extends State<DisciplinaFlutterApp> {
  late final ReceitasApi _api = widget.api ?? ReceitasApi();
  final _favoritos = FavoritosController();

  @override
  void dispose() {
    _favoritos.dispose();
    if (widget.api == null) _api.fechar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      api: _api,
      favoritos: _favoritos,
      child: MaterialApp(
        title: 'Disciplina Flutter',
        debugShowCheckedModeBanner: false,
        theme: criarTema(),
        initialRoute: Rotas.inicio,
        onGenerateRoute: Rotas.gerar,
      ),
    );
  }
}
