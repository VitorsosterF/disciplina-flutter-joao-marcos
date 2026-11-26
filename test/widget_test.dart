import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:atividade_joaobortolotti/main.dart';
import 'package:atividade_joaobortolotti/pages/detalhes_receita_page.dart';
import 'package:atividade_joaobortolotti/pages/pesquisa_receitas_page.dart';
import 'package:atividade_joaobortolotti/widgets/receita_card.dart';

import 'apoio/servidor_falso.dart';

final pizza = find.text('Classic Margherita Pizza');
final botaoBuscarInicio = find.text('Buscar receitas');
final botaoPesquisar = find.widgetWithText(FilledButton, 'Pesquisar');

Future<ServidorFalso> abrirApp(
  WidgetTester tester, {
  ServidorFalso? servidor,
  bool aguardar = true,
}) async {
  tester.view.physicalSize = const Size(420, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final s = servidor ?? ServidorFalso();
  await tester.pumpWidget(DisciplinaFlutterApp(api: s.api));
  if (aguardar) await tester.pumpAndSettle();
  return s;
}

/// Digita na tela inicial e abre a pesquisa.
Future<void> buscarPelaInicio(WidgetTester tester, String termo) async {
  await tester.enterText(find.byType(TextField), termo);
  await tester.tap(botaoBuscarInicio);
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  group('normalizarConsulta e validarConsulta', () {
    test('remove espaços externos e repetidos', () {
      expect(
        normalizarConsulta('   bolo    de \t cenoura  '),
        'bolo de cenoura',
      );
    });

    test('recusa consulta vazia ou só com espaços', () {
      expect(validarConsulta(null), mensagemConsultaVazia);
      expect(validarConsulta(''), mensagemConsultaVazia);
      expect(validarConsulta(' \t\n '), mensagemConsultaVazia);
      expect(validarConsulta('  bolo  '), isNull);
    });
  });

  group('tela principal e listagem', () {
    testWidgets('mostra carregamento e depois as receitas da API', (
      tester,
    ) async {
      final servidor = ServidorFalso();
      final resposta = Completer<http.Response>();
      servidor.aoListar = () => resposta.future;

      await abrirApp(tester, servidor: servidor, aguardar: false);
      await tester.pump();

      expect(find.text('Saborê'), findsOneWidget);
      expect(find.text('Carregando receitas...'), findsOneWidget);

      resposta.complete(respostaJson({'recipes': receitasJson}));
      await tester.pumpAndSettle();

      expect(find.text('Receitas disponíveis'), findsOneWidget);
      expect(pizza, findsOneWidget);
      expect(find.text('Vegetarian Stir-Fry'), findsOneWidget);
      expect(find.text('35 min  •  Easy'), findsOneWidget);
      expect(find.text('4,6 / 5'), findsOneWidget);
    });

    testWidgets('carrega a listagem uma única vez', (tester) async {
      final servidor = await abrirApp(tester);

      await tocar(tester, find.text('Favoritos'));
      await tocar(tester, find.text('Explorar'));
      await buscarPelaInicio(tester, 'pizza');
      await tocar(tester, find.byTooltip('Voltar'));

      expect(servidor.listagens, 1);
      expect(pizza, findsOneWidget);
    });

    testWidgets('falha de rede mostra mensagem e permite tentar de novo', (
      tester,
    ) async {
      final servidor = ServidorFalso();
      servidor.aoListar = () async => throw http.ClientException('offline');

      await abrirApp(tester, servidor: servidor);

      expect(
        find.text('Não foi possível carregar as receitas.'),
        findsOneWidget,
      );
      expect(find.textContaining('Verifique sua conexão'), findsOneWidget);

      servidor.aoListar = () async => respostaJson({'recipes': receitasJson});
      await tocar(tester, find.text('Tentar novamente'));

      expect(pizza, findsOneWidget);
      expect(servidor.listagens, 2);
    });

    testWidgets('status de erro e corpo incompatível têm mensagens próprias', (
      tester,
    ) async {
      final servidor = ServidorFalso();
      servidor.aoListar = () async => http.Response('erro', 503);

      await abrirApp(tester, servidor: servidor);
      expect(find.textContaining('código 503'), findsOneWidget);

      servidor.aoListar = () async => respostaJson({'outra': 'coisa'});
      await tocar(tester, find.text('Tentar novamente'));
      expect(find.textContaining('formato inesperado'), findsOneWidget);
    });

    testWidgets('receita incompleta usa alternativas em vez de quebrar', (
      tester,
    ) async {
      final servidor = ServidorFalso();
      servidor.aoListar = () async => respostaJson({
        'recipes': [
          {'id': 9},
        ],
      });

      await abrirApp(tester, servidor: servidor);

      expect(find.text('Receita sem nome'), findsOneWidget);
      expect(find.text('Tempo não informado'), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);

      await tocar(tester, find.text('Receita sem nome'));
      expect(find.text('Ingredientes não informados.'), findsOneWidget);
      expect(find.text('Modo de preparo não informado.'), findsOneWidget);
      expect(find.text('tempo total n/i'), findsOneWidget);
    });
  });

  group('pesquisa', () {
    testWidgets('recusa consulta vazia sem chamar a API', (tester) async {
      final servidor = await abrirApp(tester);

      await buscarPelaInicio(tester, '    ');
      expect(find.text('Qual receita você procura?'), findsOneWidget);

      await tester.tap(botaoPesquisar);
      await tester.pump();

      expect(find.text(mensagemConsultaVazia), findsOneWidget);
      expect(servidor.pesquisas, isEmpty);
    });

    testWidgets('pesquisa remota com o termo sem espaços externos', (
      tester,
    ) async {
      final servidor = await abrirApp(tester);

      await buscarPelaInicio(tester, '   margherita  ');

      expect(servidor.pesquisas, ['margherita']);
      expect(find.text('Resultados para “margherita”'), findsOneWidget);
      expect(find.byType(ReceitaCard), findsOneWidget);
    });

    testWidgets('pesquisa pelo campo da própria tela', (tester) async {
      final servidor = await abrirApp(tester);
      await buscarPelaInicio(tester, '');

      await tester.enterText(find.byType(TextFormField), ' stir ');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(servidor.pesquisas, ['stir']);
      expect(find.text('Vegetarian Stir-Fry'), findsOneWidget);
    });

    testWidgets('sem resultados é diferente de erro e volta à listagem', (
      tester,
    ) async {
      await abrirApp(tester);
      await buscarPelaInicio(tester, 'zzzz987');

      expect(find.text('Nenhum resultado'), findsOneWidget);
      expect(find.text('Não foi possível pesquisar.'), findsNothing);

      await tocar(tester, find.text('Ver todas as receitas'));

      expect(find.byType(PesquisaReceitasPage), findsNothing);
      expect(find.text('Receitas disponíveis'), findsOneWidget);
    });

    testWidgets('erro na pesquisa permite tentar novamente', (tester) async {
      final servidor = await abrirApp(tester);
      final pesquisaNormal = servidor.aoPesquisar;
      servidor.aoPesquisar = (_) async => throw http.ClientException('x');

      await buscarPelaInicio(tester, 'pizza');
      expect(find.text('Não foi possível pesquisar.'), findsOneWidget);
      expect(find.text('Nenhum resultado'), findsNothing);

      servidor.aoPesquisar = pesquisaNormal;
      await tocar(tester, find.text('Tentar novamente'));

      expect(find.text('Resultados para “pizza”'), findsOneWidget);
      expect(servidor.pesquisas, ['pizza', 'pizza']);
    });

    testWidgets('bloqueia novos toques enquanto pesquisa', (tester) async {
      final servidor = await abrirApp(tester);
      final resposta = Completer<http.Response>();
      servidor.aoPesquisar = (_) => resposta.future;

      await buscarPelaInicio(tester, '');
      await tester.enterText(find.byType(TextFormField), 'pizza');
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(find.text('Pesquisando receitas...'), findsOneWidget);
      final botao = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(botao.onPressed, isNull);

      await tester.tap(find.byType(FilledButton), warnIfMissed: false);
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();
      expect(servidor.pesquisas, ['pizza']);

      resposta.complete(
        respostaJson({'recipes': receitasJson.take(1).toList()}),
      );
      await tester.pumpAndSettle();
      expect(find.text('Resultados para “pizza”'), findsOneWidget);
    });

    testWidgets('limpar pesquisa volta ao estado inicial', (tester) async {
      await abrirApp(tester);
      await buscarPelaInicio(tester, 'pizza');

      await tocar(tester, find.text('Limpar pesquisa'));

      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        isEmpty,
      );
      expect(find.text('Qual receita você procura?'), findsOneWidget);
    });

    testWidgets('a seta de voltar retorna à listagem', (tester) async {
      await abrirApp(tester);
      await buscarPelaInicio(tester, 'pizza');

      await tocar(tester, find.byTooltip('Voltar'));

      expect(find.byType(PesquisaReceitasPage), findsNothing);
      expect(find.text('Receitas disponíveis'), findsOneWidget);
    });
  });

  group('detalhes e navegação', () {
    testWidgets('mostra ingredientes, passos e dados úteis', (tester) async {
      await abrirApp(tester);

      await tocar(tester, pizza);

      expect(find.byType(DetalhesReceitaPage), findsOneWidget);
      expect(find.text('Italian  •  Easy  •  4,6 / 5'), findsOneWidget);
      expect(find.text('35 min'), findsOneWidget);
      expect(find.text('porções'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
      expect(
        find.text('Preparo: 20 min  •  Cozimento: 15 min'),
        findsOneWidget,
      );
      expect(find.text('Pizza dough'), findsOneWidget);

      final ultimoPasso = find.text('Bake for 12-15 minutes.');
      await tester.scrollUntilVisible(ultimoPasso, 200);
      expect(ultimoPasso, findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('voltar dos detalhes conserva a consulta', (tester) async {
      final servidor = await abrirApp(tester);
      await buscarPelaInicio(tester, 'pizza');

      await tocar(tester, pizza);
      expect(find.byType(DetalhesReceitaPage), findsOneWidget);

      await tocar(tester, find.byTooltip('Voltar'));

      expect(find.text('Resultados para “pizza”'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller!
            .text,
        'pizza',
      );
      expect(servidor.pesquisas, ['pizza']);
    });
  });

  group('favoritos', () {
    testWidgets('lista vazia tem estado próprio e leva a explorar', (
      tester,
    ) async {
      await abrirApp(tester);

      await tocar(tester, find.text('Favoritos'));
      expect(find.text('Nenhum favorito'), findsOneWidget);

      await tocar(tester, find.text('Explorar receitas'));
      expect(find.text('Receitas disponíveis'), findsOneWidget);
    });

    testWidgets('adiciona pelo card e remove na tela de favoritos', (
      tester,
    ) async {
      await abrirApp(tester);

      await tocar(tester, find.byTooltip('Adicionar aos favoritos').first);
      await tocar(tester, find.text('Favoritos'));

      expect(find.text('Receitas salvas nesta sessão.'), findsOneWidget);
      expect(find.byType(ReceitaCard), findsOneWidget);
      expect(pizza, findsOneWidget);

      await tocar(tester, find.byTooltip('Remover dos favoritos'));
      expect(find.text('Nenhum favorito'), findsOneWidget);
    });

    testWidgets('detalhes e listagem compartilham o mesmo estado', (
      tester,
    ) async {
      await abrirApp(tester);

      await tocar(tester, pizza);
      expect(find.text('Não salva'), findsOneWidget);
      await tocar(tester, find.byTooltip('Adicionar aos favoritos'));
      expect(find.text('Salva'), findsOneWidget);

      await tocar(tester, find.byTooltip('Voltar'));
      expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);

      // Favoritar de novo pela pesquisa não duplica.
      await buscarPelaInicio(tester, 'pizza');
      expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
      await tocar(tester, find.text('Favoritos'));
      expect(find.byType(ReceitaCard), findsOneWidget);
    });
  });
}
