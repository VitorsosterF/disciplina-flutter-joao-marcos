import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../state/app_scope.dart';
import '../tema.dart';
import 'receita_imagem.dart';

class ReceitaCard extends StatelessWidget {
  final Receita receita;
  final VoidCallback onTap;

  const ReceitaCard({super.key, required this.receita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final favoritos = AppScope.favoritosDe(context);
    final favorita = favoritos.contem(receita.id);
    final detalhes = [
      receita.tempoResumo,
      if (receita.dificuldade != null) receita.dificuldade!,
    ].join('  •  ');
    final avaliacao = receita.avaliacaoFormatada;

    return Material(
      color: CoresApp.superficie,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: CoresApp.borda),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 78,
                    height: 88,
                    child: ReceitaImagem(url: receita.imagem),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          receita.nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: CoresApp.texto,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          detalhes,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CoresApp.textoSecundario,
                          ),
                        ),
                        if (avaliacao != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            avaliacao,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CoresApp.primaria,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: BotaoFavorito(receita: receita, favorita: favorita),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BotaoFavorito extends StatelessWidget {
  final Receita receita;
  final bool favorita;

  const BotaoFavorito({
    super.key,
    required this.receita,
    required this.favorita,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: favorita ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      isSelected: favorita,
      icon: const Icon(Icons.favorite_border, color: CoresApp.texto),
      selectedIcon: const Icon(Icons.favorite, color: CoresApp.erro),
      onPressed: () => AppScope.favoritosDe(context).alternar(receita),
    );
  }
}
