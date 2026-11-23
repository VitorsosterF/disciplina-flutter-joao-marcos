import 'package:flutter/material.dart';

import 'receitas.dart';
import 'rotas.dart';
import 'tema.dart';
import 'widgets/receita_card.dart';

const mensagemConsultaVazia = 'Digite um nome para pesquisar.';

/// Remove os espaços das pontas e reduz espaços repetidos entre as palavras.
String normalizarConsulta(String texto) {
  return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Retorna a mensagem de erro da consulta, ou `null` se ela for válida.
String? validarConsulta(String? texto) {
  if (normalizarConsulta(texto ?? '').isEmpty) {
    return mensagemConsultaVazia;
  }
  return null;
}

class PesquisaReceitasPage extends StatefulWidget {
  /// Termo digitado na tela inicial; quando válido, a pesquisa já abre feita.
  final String? termoInicial;

  const PesquisaReceitasPage({super.key, this.termoInicial});

  @override
  State<PesquisaReceitasPage> createState() => _PesquisaReceitasPageState();
}

class _PesquisaReceitasPageState extends State<PesquisaReceitasPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focoCampo = FocusNode();

  // Depois de uma tentativa inválida, o erro some assim que a entrada é corrigida.
  AutovalidateMode _modoValidacao = AutovalidateMode.disabled;
  String? _termoPesquisado;
  List<Receita> _resultados = const [];

  @override
  void initState() {
    super.initState();
    final termo = normalizarConsulta(widget.termoInicial ?? '');
    if (termo.isNotEmpty) {
      _controller.text = termo;
      _termoPesquisado = termo;
      _resultados = buscarReceitas(termo);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focoCampo.dispose();
    super.dispose();
  }

  void _pesquisar() {
    final valida = _formKey.currentState!.validate();
    final termo = valida ? normalizarConsulta(_controller.text) : null;

    setState(() {
      _termoPesquisado = termo;
      _resultados = termo == null ? const [] : buscarReceitas(termo);
      _modoValidacao = valida
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction;
    });

    if (!valida) {
      _focoCampo.requestFocus();
    }
  }

  void _limparPesquisa() {
    _formKey.currentState!.reset();
    _controller.clear();

    setState(() {
      _termoPesquisado = null;
      _resultados = const [];
      _modoValidacao = AutovalidateMode.disabled;
    });

    _focoCampo.requestFocus();
  }

  /// Volta o foco ao campo com o texto selecionado para digitar outro termo.
  void _alterarPesquisa() {
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    _focoCampo.requestFocus();
  }

  void _verTodasAsReceitas() {
    Navigator.of(context).popUntil(ModalRoute.withName(Rotas.inicio));
  }

  @override
  Widget build(BuildContext context) {
    final termo = _termoPesquisado;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: const Text('Pesquisar receitas'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          if (termo == null) ...[
            const Text(
              'Qual receita você procura?',
              style: TextosApp.tituloSecao,
            ),
            const SizedBox(height: 20),
          ],
          const Text('Nome da receita', style: TextosApp.rotulo),
          const SizedBox(height: 8),
          Form(
            key: _formKey,
            autovalidateMode: _modoValidacao,
            child: TextFormField(
              controller: _controller,
              focusNode: _focoCampo,
              validator: validarConsulta,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => _pesquisar(),
              decoration: const InputDecoration(
                hintText: 'Buscar pelo nome',
                prefixIcon: Icon(Icons.search),
                errorMaxLines: 3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _pesquisar, child: const Text('Pesquisar')),
          const SizedBox(height: 28),
          if (termo == null)
            const Text(
              'Você pode buscar por parte do nome da receita.',
              style: TextosApp.apoio,
            )
          else if (_resultados.isEmpty)
            _NenhumResultado(
              aoAlterarPesquisa: _alterarPesquisa,
              aoVerTodas: _verTodasAsReceitas,
            )
          else
            _Resultados(
              termo: termo,
              receitas: _resultados,
              aoLimpar: _limparPesquisa,
            ),
        ],
      ),
    );
  }
}

class _Resultados extends StatelessWidget {
  final String termo;
  final List<Receita> receitas;
  final VoidCallback aoLimpar;

  const _Resultados({
    required this.termo,
    required this.receitas,
    required this.aoLimpar,
  });

  @override
  Widget build(BuildContext context) {
    final quantidade = receitas.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text('Resultados para “$termo”', style: TextosApp.tituloSecao),
        ),
        const SizedBox(height: 6),
        Text(
          quantidade == 1
              ? '1 receita encontrada.'
              : '$quantidade receitas encontradas.',
          style: TextosApp.apoio,
        ),
        const SizedBox(height: 16),
        for (final receita in receitas) ...[
          ReceitaCard(receita: receita),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: aoLimpar,
          child: const Text('Limpar pesquisa'),
        ),
      ],
    );
  }
}

class _NenhumResultado extends StatelessWidget {
  final VoidCallback aoAlterarPesquisa;
  final VoidCallback aoVerTodas;

  const _NenhumResultado({
    required this.aoAlterarPesquisa,
    required this.aoVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: CoresApp.destaque,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search, color: CoresApp.texto),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          liveRegion: true,
          child: const Text('Nenhum resultado', style: TextosApp.tituloTela),
        ),
        const SizedBox(height: 12),
        const Text(
          'Não encontramos receitas para esse nome. Tente outro termo.',
          style: TextosApp.apoio,
        ),
        const SizedBox(height: 28),
        FilledButton(
          onPressed: aoAlterarPesquisa,
          child: const Text('Alterar pesquisa'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: aoVerTodas,
          child: const Text('Ver todas as receitas'),
        ),
      ],
    );
  }
}
