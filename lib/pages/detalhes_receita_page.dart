import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../state/app_scope.dart';
import '../tema.dart';
import '../widgets/receita_card.dart';
import '../widgets/receita_imagem.dart';

/// Detalhes da receita selecionada.
///
/// Reaproveita o objeto completo recebido na listagem/pesquisa, que já traz
/// ingredientes e instruções; por isso não é feita uma nova requisição a
/// `/recipes/{id}`.
class DetalhesReceitaPage extends StatelessWidget {
  final Receita receita;

  const DetalhesReceitaPage({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    final favorita = AppScope.favoritosDe(context).contem(receita.id);
    final informacoes = [
      if (receita.culinaria != null) receita.culinaria!,
      if (receita.dificuldade != null) receita.dificuldade!,
      if (receita.avaliacaoFormatada != null) receita.avaliacaoFormatada!,
    ];
    final total = receita.minutosTotais;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: const Text('Receita'),
        actions: [
          BotaoFavorito(receita: receita, favorita: favorita),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: ReceitaImagem(url: receita.imagem, tamanhoIcone: 64),
            ),
          ),
          const SizedBox(height: 24),
          Text(receita.nome, style: TextosApp.tituloTela),
          if (informacoes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(informacoes.join('  •  '), style: TextosApp.apoio),
          ],
          if (receita.tiposRefeicao.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in receita.tiposRefeicao)
                  Chip(
                    label: Text(tipo),
                    backgroundColor: CoresApp.destaque,
                    side: BorderSide.none,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: CoresApp.texto,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Indicador(
                  valor: total != null ? '$total min' : '—',
                  rotulo: total != null ? 'tempo total' : 'tempo total n/i',
                ),
              ),
              if (receita.porcoes != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: _Indicador(
                    valor: '${receita.porcoes}',
                    rotulo: receita.porcoes == 1 ? 'porção' : 'porções',
                  ),
                ),
              ],
              const SizedBox(width: 10),
              Expanded(
                child: _Indicador(
                  valor: favorita ? 'Salva' : 'Não salva',
                  rotulo: 'nos favoritos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Preparo: ${_minutos(receita.minutosPreparo)}  •  '
            'Cozimento: ${_minutos(receita.minutosCozimento)}',
            style: TextosApp.apoio,
          ),
          const SizedBox(height: 28),
          const Text('Ingredientes', style: TextosApp.tituloSecao),
          const SizedBox(height: 12),
          if (receita.ingredientes.isEmpty)
            const Text('Ingredientes não informados.', style: TextosApp.apoio)
          else
            for (final ingrediente in receita.ingredientes)
              _ItemIngrediente(ingrediente),
          const SizedBox(height: 28),
          const Text('Modo de preparo', style: TextosApp.tituloSecao),
          const SizedBox(height: 12),
          if (receita.instrucoes.isEmpty)
            const Text('Modo de preparo não informado.', style: TextosApp.apoio)
          else
            for (var i = 0; i < receita.instrucoes.length; i++)
              _Passo(numero: i + 1, texto: receita.instrucoes[i]),
        ],
      ),
    );
  }

  static String _minutos(int? valor) {
    return valor == null ? 'não informado' : '$valor min';
  }
}

class _Indicador extends StatelessWidget {
  final String valor;
  final String rotulo;

  const _Indicador({required this.valor, required this.rotulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CoresApp.destaque,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: CoresApp.texto,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rotulo,
            style: const TextStyle(
              fontSize: 11,
              color: CoresApp.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemIngrediente extends StatelessWidget {
  final String texto;

  const _ItemIngrediente(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 12, left: 2),
            child: Icon(Icons.circle, size: 6, color: CoresApp.primaria),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(fontSize: 15, color: CoresApp.texto),
            ),
          ),
        ],
      ),
    );
  }
}

class _Passo extends StatelessWidget {
  final int numero;
  final String texto;

  const _Passo({required this.numero, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: CoresApp.primaria,
            child: Text(
              '$numero',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                texto,
                style: const TextStyle(
                  fontSize: 15,
                  color: CoresApp.texto,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
