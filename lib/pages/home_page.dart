import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../rotas.dart';
import '../services/receitas_api.dart';
import '../state/app_scope.dart';
import '../tema.dart';
import '../widgets/estados.dart';
import '../widgets/receita_card.dart';
import 'pesquisa_receitas_page.dart';

enum _Fase { carregando, sucesso, erro }

/// Tela principal: identidade do app, acesso à pesquisa e listagem.
class HomePage extends StatefulWidget {
  /// Abre a pesquisa; recebe o termo digitado aqui, se houver.
  final ValueChanged<String?> aoPesquisar;

  const HomePage({super.key, required this.aoPesquisar});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  _Fase _fase = _Fase.carregando;
  List<Receita> _receitas = const [];
  ReceitasException? _erro;
  bool _iniciado = false;
  bool _carregando = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carrega uma única vez, e não a cada reconstrução da tela.
    if (!_iniciado) {
      _iniciado = true;
      _carregar();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    // Impede requisições simultâneas (ex.: toques repetidos em "Tentar novamente").
    if (_carregando) return;
    _carregando = true;
    if (_fase != _Fase.carregando) {
      setState(() => _fase = _Fase.carregando);
    }

    try {
      final receitas = await AppScope.apiDe(context).listar();
      if (!mounted) return;
      setState(() {
        _receitas = receitas;
        _erro = null;
        _fase = _Fase.sucesso;
      });
    } on ReceitasException catch (erro) {
      if (!mounted) return;
      setState(() {
        _erro = erro;
        _fase = _Fase.erro;
      });
    } finally {
      _carregando = false;
    }
  }

  void _abrirPesquisa() {
    FocusScope.of(context).unfocus();
    final termo = normalizarConsulta(_controller.text);
    widget.aoPesquisar(termo.isEmpty ? null : termo);
  }

  void _abrirDetalhes(Receita receita) {
    Navigator.of(context).pushNamed(Rotas.detalhes, arguments: receita);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_fase) {
          _Fase.carregando => ListView(
            padding: _paddingTela,
            children: const [
              CabecalhoMarca(),
              Text('Explorar receitas', style: TextosApp.tituloTela),
              SizedBox(height: 28),
              CarregandoReceitas(),
            ],
          ),
          _Fase.erro => ListView(
            padding: _paddingTela,
            children: [
              const CabecalhoMarca(),
              EstadoMensagem(
                icone: Icons.priority_high,
                titulo: 'Não foi possível carregar as receitas.',
                mensagem: _erro!.mensagem,
                rotuloAcao: 'Tentar novamente',
                onAcao: _carregar,
              ),
            ],
          ),
          _Fase.sucesso => ListView.builder(
            padding: _paddingTela,
            itemCount: _receitas.length + 1,
            itemBuilder: (context, indice) {
              if (indice == 0) return _cabecalhoLista();
              final receita = _receitas[indice - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ReceitaCard(
                  receita: receita,
                  onTap: () => _abrirDetalhes(receita),
                ),
              );
            },
          ),
        },
      ),
    );
  }

  Widget _cabecalhoLista() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CabecalhoMarca(),
        const Text('Receitas', style: TextosApp.tituloTela),
        const SizedBox(height: 8),
        const Text('Pesquise uma receita pelo nome.', style: TextosApp.apoio),
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
        Text(
          _receitas.isEmpty
              ? 'Nenhuma receita disponível no momento.'
              : 'Selecione uma receita para ver o preparo.',
          style: TextosApp.apoio,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

const _paddingTela = EdgeInsets.fromLTRB(20, 24, 20, 24);
