import 'package:flutter/material.dart';

import '../tema.dart';

/// Imagem da receita com alternativa visual quando ela falta ou falha.
class ReceitaImagem extends StatelessWidget {
  final String? url;
  final double tamanhoIcone;

  const ReceitaImagem({super.key, required this.url, this.tamanhoIcone = 40});

  @override
  Widget build(BuildContext context) {
    final endereco = url;
    final alternativa = _Alternativa(tamanhoIcone: tamanhoIcone);
    if (endereco == null) return alternativa;

    return Image.network(
      endereco,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: 'Foto da receita',
      loadingBuilder: (context, child, progresso) {
        return progresso == null ? child : alternativa;
      },
      errorBuilder: (context, erro, pilha) => alternativa,
    );
  }
}

class _Alternativa extends StatelessWidget {
  final double tamanhoIcone;

  const _Alternativa({required this.tamanhoIcone});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CoresApp.imagemFundo,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: tamanhoIcone,
          color: CoresApp.textoSecundario,
          semanticLabel: 'Imagem indisponível',
        ),
      ),
    );
  }
}
