import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../rotas.dart';
import '../services/receitas_api.dart';
import '../state/app_scope.dart';
import '../tema.dart';
import '../widgets/estados.dart';
import '../widgets/receita_card.dart';

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

enum _Fase { inicial, carregando, resultados, semResultados, erro }

class PesquisaReceitasPage extends StatefulWidget {
  /// Termo digitado na tela inicial; quando válido, a pesquisa já abre feita.
  final String? termoInicial;

  /// Volta para a listagem (seta de voltar e "Ver todas as receitas").
  final VoidCallback aoVoltar;

  const PesquisaReceitasPage({
    super.key,
    this.termoInicial,
    required this.aoVoltar,
  });

  @override
  State<PesquisaReceitasPage> createState() => _PesquisaReceitasPageState();
}

class _PesquisaReceitasPageState extends State<PesquisaReceitasPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focoCampo = FocusNode();

  // Depois de uma tentativa inválida, o erro some assim que a entrada é corrigida.
  AutovalidateMode _modoValidacao = AutovalidateMode.disabled;
  _Fase _fase = _Fase.inicial;
  String? _termo;
  List<Receita> _resultados = const [];
  ReceitasException? _erro;
  bool _iniciado = false;

  /// Identifica a consulta mais recente; respostas de consultas antigas
  /// (substituídas ou limpas) são descartadas.
  int _consultaAtual = 0;

  bool get _carregando => _fase == _Fase.carregando;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_iniciado) return;
    _iniciado = true;

    final termo = normalizarConsulta(widget.termoInicial ?? '');
    if (termo.isNotEmpty) {
      _controller.text = termo;
      _executar(_prepararConsulta(termo), termo);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focoCampo.dispose();
    super.dispose();
  }

  /// Ajusta o estado para "carregando" e devolve o número da consulta.
  int _prepararConsulta(String termo) {
    _termo = termo;
    _fase = _Fase.carregando;
    _resultados = const [];
    _erro = null;
    return ++_consultaAtual;
  }

  Future<void> _executar(int consulta, String termo) async {
    try {
      final resultados = await AppScope.apiDe(context).pesquisar(termo);
      if (!mounted || consulta != _consultaAtual) return;
      setState(() {
        _resultados = resultados;
        _fase = resultados.isEmpty ? _Fase.semResultados : _Fase.resultados;
      });
    } on ReceitasException catch (erro) {
      if (!mounted || consulta != _consultaAtual) return;
      setState(() {
        _erro = erro;
        _fase = _Fase.erro;
      });
    }
  }

  void _pesquisar() {
    // Evita disparar outra consulta enquanto a atual não termina.
    if (_carregando) return;

    final valida = _formKey.currentState!.validate();
    if (!valida) {
      setState(() {
        _consultaAtual++;
        _fase = _Fase.inicial;
        _termo = null;
        _resultados = const [];
        _modoValidacao = AutovalidateMode.onUserInteraction;
      });
      _focoCampo.requestFocus();
      return;
    }

    FocusScope.of(context).unfocus();
    final termo = normalizarConsulta(_controller.text);
    late final int consulta;
    setState(() {
      _modoValidacao = AutovalidateMode.disabled;
      consulta = _prepararConsulta(termo);
    });
    _executar(consulta, termo);
  }

  void _tentarNovamente() {
    final termo = _termo;
    if (termo == null || _carregando) return;
    late final int consulta;
    setState(() => consulta = _prepararConsulta(termo));
    _executar(consulta, termo);
  }

  void _limparPesquisa() {
    _formKey.currentState!.reset();
    _controller.clear();

    setState(() {
      _consultaAtual++;
      _fase = _Fase.inicial;
      _termo = null;
      _resultados = const [];
      _erro = null;
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

  void _abrirDetalhes(Receita receita) {
    Navigator.of(context).pushNamed(Rotas.detalhes, arguments: receita);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
          onPressed: widget.aoVoltar,
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
          if (_fase == _Fase.inicial) ...[
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
          FilledButton(
            onPressed: _carregando ? null : _pesquisar,
            child: _carregando
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      semanticsLabel: 'Pesquisando',
                    ),
                  )
                : const Text('Pesquisar'),
          ),
          const SizedBox(height: 28),
          ..._conteudo(),
        ],
      ),
    );
  }

  List<Widget> _conteudo() {
    switch (_fase) {
      case _Fase.inicial:
        return const [
          Text(
            'Você pode buscar por parte do nome da receita.',
            style: TextosApp.apoio,
          ),
        ];
      case _Fase.carregando:
        return const [
          CarregandoReceitas(
            mensagem: 'Pesquisando receitas...',
            mostrarBarraBusca: false,
          ),
        ];
      case _Fase.erro:
        return [
          EstadoMensagem(
            icone: Icons.priority_high,
            titulo: 'Não foi possível pesquisar.',
            mensagem: _erro!.mensagem,
            rotuloAcao: 'Tentar novamente',
            onAcao: _tentarNovamente,
            rotuloAcaoSecundaria: 'Limpar pesquisa',
            onAcaoSecundaria: _limparPesquisa,
          ),
        ];
      case _Fase.semResultados:
        return [
          EstadoMensagem(
            icone: Icons.search_off,
            titulo: 'Nenhum resultado',
            mensagem:
                'Não encontramos receitas para “$_termo”. Tente outro termo.',
            rotuloAcao: 'Alterar pesquisa',
            onAcao: _alterarPesquisa,
            rotuloAcaoSecundaria: 'Ver todas as receitas',
            onAcaoSecundaria: widget.aoVoltar,
          ),
        ];
      case _Fase.resultados:
        final quantidade = _resultados.length;
        return [
          Semantics(
            liveRegion: true,
            child: Text(
              'Resultados para “$_termo”',
              style: TextosApp.tituloSecao,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quantidade == 1
                ? '1 receita encontrada. Toque para ver o preparo.'
                : '$quantidade receitas encontradas. '
                      'Toque para ver o preparo.',
            style: TextosApp.apoio,
          ),
          const SizedBox(height: 16),
          for (final receita in _resultados) ...[
            ReceitaCard(receita: receita, onTap: () => _abrirDetalhes(receita)),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _limparPesquisa,
            child: const Text('Limpar pesquisa'),
          ),
        ];
    }
  }
}
