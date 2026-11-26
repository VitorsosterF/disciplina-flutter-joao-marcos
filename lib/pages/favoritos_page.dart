import 'package:flutter/material.dart';

import '../rotas.dart';
import '../state/app_scope.dart';
import '../tema.dart';
import '../widgets/estados.dart';
import '../widgets/receita_card.dart';

/// Receitas marcadas como favoritas nesta sessão.
class FavoritosPage extends StatelessWidget {
  /// Leva o usuário de volta para a listagem.
  final VoidCallback aoExplorar;

  const FavoritosPage({super.key, required this.aoExplorar});

  @override
  Widget build(BuildContext context) {
    final favoritos = AppScope.favoritosDe(context).itens;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            const CabecalhoMarca(),
            if (favoritos.isEmpty)
              EstadoMensagem(
                icone: Icons.favorite_border,
                titulo: 'Nenhum favorito',
                mensagem:
                    'Marque uma receita como favorita para encontrá-la aqui.',
                rotuloAcao: 'Explorar receitas',
                onAcao: aoExplorar,
              )
            else ...[
              const Text('Favoritos', style: TextosApp.tituloTela),
              const SizedBox(height: 8),
              const Text(
                'Receitas salvas nesta sessão.',
                style: TextosApp.apoio,
              ),
              const SizedBox(height: 20),
              for (final receita in favoritos) ...[
                ReceitaCard(
                  key: ValueKey(receita.id),
                  receita: receita,
                  onTap: () =>
                      Navigator.of(context)
                          .pushNamed(Rotas.detalhes, arguments: receita),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 20),
              const Text(
                'Toque no coração para remover.',
                style: TextosApp.apoio,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
