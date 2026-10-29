import 'package:flutter/material.dart';

void main() => runApp(const SaiaDa5aSerieApp());

class SaiaDa5aSerieApp extends StatelessWidget {
  const SaiaDa5aSerieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saia da 5ª Série',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saia da 5ª Série'),
        centerTitle: true,
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cores.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.school, size: 64),
                  SizedBox(height: 12),
                  Text(
                    'Bem-vindo ao Saia da 5ª Série!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Teste seus conhecimentos e descubra se você é mais esperto que um aluno da 5ª série.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Categorias
            const Text(
              'Categorias',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _CategoriaCard(Icons.calculate, 'Matemática')),
                SizedBox(width: 12),
                Expanded(child: _CategoriaCard(Icons.menu_book, 'Português')),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _CategoriaCard(Icons.public, 'Geografia')),
                SizedBox(width: 12),
                Expanded(child: _CategoriaCard(Icons.science, 'Ciências')),
              ],
            ),
            const SizedBox(height: 32),

            // Botões
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Começar Jogo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.emoji_events),
              label: const Text('Ranking'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriaCard extends StatelessWidget {
  final IconData icone;
  final String titulo;

  const _CategoriaCard(this.icone, this.titulo);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(icone, size: 40),
            const SizedBox(height: 8),
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}