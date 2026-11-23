import 'package:flutter/material.dart';

import '../receitas.dart';
import '../tema.dart';

class ReceitaCard extends StatelessWidget {
  final Receita receita;

  const ReceitaCard({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CoresApp.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CoresApp.borda),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 78,
            height: 88,
            decoration: BoxDecoration(
              color: CoresApp.imagemFundo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_pizza,
              size: 44,
              color: Color(0xFFC9772B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receita.nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CoresApp.texto,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${receita.minutos} min  •  ${receita.dificuldade}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CoresApp.textoSecundario,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    receita.notaFormatada,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: CoresApp.primaria,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
