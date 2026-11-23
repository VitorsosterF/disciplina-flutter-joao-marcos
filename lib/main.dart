import 'package:flutter/material.dart';

import 'rotas.dart';
import 'tema.dart';

void main() => runApp(const DisciplinaFlutterApp());

class DisciplinaFlutterApp extends StatelessWidget {
  const DisciplinaFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Disciplina Flutter',
      debugShowCheckedModeBanner: false,
      theme: criarTema(),
      initialRoute: Rotas.inicio,
      onGenerateRoute: Rotas.gerar,
    );
  }
}
