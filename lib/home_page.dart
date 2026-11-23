import 'package:flutter/material.dart';

import 'pesquisa_receitas_page.dart';
import 'receitas.dart';
import 'rotas.dart';
import 'tema.dart';
import 'widgets/receita_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Abre a pesquisa levando o que já foi digitado (se houver).
  void _abrirPesquisa() {
    final termo = normalizarConsulta(_controller.text);
    Navigator.of(context)
        .pushNamed(Rotas.pesquisa, arguments: termo.isEmpty ? null : termo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            const Text('Saborê', style: TextosApp.marca),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 24),
            const Text('Receitas', style: TextosApp.tituloTela),
            const SizedBox(height: 8),
            const Text(
              'Pesquise uma receita pelo nome.',
              style: TextosApp.apoio,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _abrirPesquisa(),
              decoration: const InputDecoration(
                hintText: 'Buscar pelo nome',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _abrirPesquisa,
              child: const Text('Buscar receitas'),
            ),
            const SizedBox(height: 28),
            const Text('Receitas disponíveis', style: TextosApp.tituloSecao),
            const SizedBox(height: 6),
            const Text(
              'Confira as receitas cadastradas no app.',
              style: TextosApp.apoio,
            ),
            const SizedBox(height: 16),
            for (final receita in receitasDisponiveis) ...[
              ReceitaCard(receita: receita),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
