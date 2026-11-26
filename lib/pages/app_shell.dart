import 'package:flutter/material.dart';

import '../tema.dart';
import 'favoritos_page.dart';
import 'home_page.dart';
import 'pesquisa_receitas_page.dart';

/// Estrutura com a barra inferior (Explorar / Favoritos).
///
/// As abas ficam em um [IndexedStack], então a listagem carregada e a
/// pesquisa em andamento são preservadas ao trocar de aba ou abrir detalhes.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static const _abaExplorar = 0;

  int _aba = _abaExplorar;

  /// Pesquisa aberta na aba Explorar (`null` = mostrando a listagem).
  ({String? termo, int id})? _pesquisa;
  int _proximaPesquisa = 0;

  void _abrirPesquisa(String? termo) {
    setState(() => _pesquisa = (termo: termo, id: _proximaPesquisa++));
  }

  void _voltarParaListagem() {
    setState(() {
      _pesquisa = null;
      _aba = _abaExplorar;
    });
  }

  void _selecionarAba(int aba) {
    // Tocar de novo em "Explorar" volta para a listagem.
    if (aba == _abaExplorar && _aba == _abaExplorar) {
      _voltarParaListagem();
      return;
    }
    setState(() => _aba = aba);
  }

  @override
  Widget build(BuildContext context) {
    final pesquisa = _pesquisa;
    final podeSair = _aba == _abaExplorar && pesquisa == null;

    return PopScope(
      canPop: podeSair,
      onPopInvokedWithResult: (saiu, _) {
        // Botão voltar do sistema: pesquisa/favoritos -> listagem.
        if (!saiu) _voltarParaListagem();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _aba,
          children: [
            Stack(
              children: [
                Offstage(
                  offstage: pesquisa != null,
                  child: TickerMode(
                    enabled: pesquisa == null,
                    child: HomePage(aoPesquisar: _abrirPesquisa),
                  ),
                ),
                if (pesquisa != null)
                  PesquisaReceitasPage(
                    key: ValueKey(pesquisa.id),
                    termoInicial: pesquisa.termo,
                    aoVoltar: _voltarParaListagem,
                  ),
              ],
            ),
            FavoritosPage(aoExplorar: _voltarParaListagem),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _aba,
          onDestinationSelected: _selecionarAba,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite, color: CoresApp.erro),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }
}
