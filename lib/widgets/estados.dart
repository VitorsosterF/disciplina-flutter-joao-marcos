import 'package:flutter/material.dart';

import '../tema.dart';

/// Cabeçalho com a marca do app e a linha divisória.
class CabecalhoMarca extends StatelessWidget {
  const CabecalhoMarca({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Saborê', style: TextosApp.marca),
        SizedBox(height: 16),
        Divider(),
        SizedBox(height: 24),
      ],
    );
  }
}

/// Estado com ícone, título, explicação e ação (erro, vazio, sem resultado).
class EstadoMensagem extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String mensagem;
  final String rotuloAcao;
  final VoidCallback onAcao;
  final String? rotuloAcaoSecundaria;
  final VoidCallback? onAcaoSecundaria;

  const EstadoMensagem({
    super.key,
    required this.icone,
    required this.titulo,
    required this.mensagem,
    required this.rotuloAcao,
    required this.onAcao,
    this.rotuloAcaoSecundaria,
    this.onAcaoSecundaria,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: CoresApp.destaque,
              shape: BoxShape.circle,
            ),
            child: Icon(icone, size: 36, color: CoresApp.texto),
          ),
        ),
        const SizedBox(height: 28),
        Semantics(
          liveRegion: true,
          child: Text(titulo, style: TextosApp.tituloTela),
        ),
        const SizedBox(height: 12),
        Text(mensagem, style: TextosApp.apoio),
        const SizedBox(height: 32),
        FilledButton(onPressed: onAcao, child: Text(rotuloAcao)),
        if (rotuloAcaoSecundaria != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onAcaoSecundaria,
            child: Text(rotuloAcaoSecundaria!),
          ),
        ],
      ],
    );
  }
}

/// Esqueleto exibido enquanto as receitas são buscadas.
class CarregandoReceitas extends StatelessWidget {
  final String mensagem;
  final bool mostrarBarraBusca;

  const CarregandoReceitas({
    super.key,
    this.mensagem = 'Carregando receitas...',
    this.mostrarBarraBusca = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mostrarBarraBusca) ...[
          const _Bloco(altura: 48),
          const SizedBox(height: 28),
        ],
        const _CardFantasma(),
        const SizedBox(height: 14),
        const _CardFantasma(),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Semantics(
              liveRegion: true,
              child: Text(mensagem, style: TextosApp.apoio),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardFantasma extends StatelessWidget {
  const _CardFantasma();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          _Bloco(largura: 74, altura: 80),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bloco(altura: 10),
                SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  child: _Bloco(altura: 10),
                ),
                SizedBox(height: 22),
                FractionallySizedBox(
                  widthFactor: 0.45,
                  child: _Bloco(altura: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bloco extends StatelessWidget {
  final double? largura;
  final double altura;

  const _Bloco({this.largura, required this.altura});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: largura,
      height: altura,
      decoration: BoxDecoration(
        color: CoresApp.destaque,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
