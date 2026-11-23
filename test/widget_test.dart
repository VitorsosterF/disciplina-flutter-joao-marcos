import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade_joaobortolotti/home_page.dart';
import 'package:atividade_joaobortolotti/main.dart';
import 'package:atividade_joaobortolotti/pesquisa_receitas_page.dart';
import 'package:atividade_joaobortolotti/receitas.dart';
import 'package:atividade_joaobortolotti/widgets/receita_card.dart';

void main() {
  group('normalizarConsulta', () {
    test('remove espaços das pontas', () {
      expect(normalizarConsulta('   bolo   '), 'bolo');
    });

    test('reduz espaços repetidos entre as palavras', () {
      expect(normalizarConsulta('bolo    de \t cenoura'), 'bolo de cenoura');
    });

    test('mantém uma consulta já normalizada', () {
      expect(normalizarConsulta('pão de queijo'), 'pão de queijo');
    });
  });

  group('validarConsulta', () {
    test('recusa nulo, vazio e apenas espaços', () {
      expect(validarConsulta(null), mensagemConsultaVazia);
      expect(validarConsulta(''), mensagemConsultaVazia);
      expect(validarConsulta('    '), mensagemConsultaVazia);
      expect(validarConsulta(' \t\n  '), mensagemConsultaVazia);
    });

    test('aceita texto com espaços nas pontas', () {
      expect(validarConsulta('  bolo  '), isNull);
    });
  });

  group('buscarReceitas', () {
    test('encontra por parte do nome, sem diferenciar maiúsculas', () {
      expect(buscarReceitas('margherita'), hasLength(1));
      expect(buscarReceitas('PIZZA'), hasLength(1));
    });

    test('ignora acentos', () {
      const receitas = [
        Receita(
          nome: 'Pão de queijo',
          culinaria: 'Brasileira',
          dificuldade: 'Fácil',
          minutos: 40,
          nota: 4.8,
        ),
      ];
      expect(buscarReceitas('pao', receitas: receitas), hasLength(1));
    });

    test('retorna vazio quando nada corresponde', () {
      expect(buscarReceitas('zzzz987'), isEmpty);
    });
  });

  group('PesquisaReceitasPage', () {
    final campo = find.byType(TextFormField);
    final botaoPesquisar = find.widgetWithText(FilledButton, 'Pesquisar');
    final botaoLimpar = find.text('Limpar pesquisa');
    final erro = find.text(mensagemConsultaVazia);
    final resultados = find.textContaining('Resultados para');
    final nenhumResultado = find.text('Nenhum resultado');

    Future<void> abrirTela(WidgetTester tester, {String? termo}) {
      return tester.pumpWidget(
        MaterialApp(home: PesquisaReceitasPage(termoInicial: termo)),
      );
    }

    Future<void> pesquisar(WidgetTester tester, String texto) async {
      await tester.enterText(campo, texto);
      await tester.tap(botaoPesquisar);
      await tester.pump();
    }

    testWidgets('mostra o estado inicial', (tester) async {
      await abrirTela(tester);

      expect(find.text('Qual receita você procura?'), findsOneWidget);
      expect(find.text('Nome da receita'), findsOneWidget);
      expect(botaoPesquisar, findsOneWidget);
      expect(erro, findsNothing);
      expect(resultados, findsNothing);
    });

    testWidgets('recusa consulta vazia ou só com espaços', (tester) async {
      await abrirTela(tester);

      await tester.tap(botaoPesquisar);
      await tester.pump();
      expect(erro, findsOneWidget);

      await pesquisar(tester, '     ');
      expect(erro, findsOneWidget);
      expect(resultados, findsNothing);
      expect(nenhumResultado, findsNothing);
    });

    testWidgets('lista as receitas encontradas com o termo tratado', (
      tester,
    ) async {
      await abrirTela(tester);

      await pesquisar(tester, '   Margherita  ');

      expect(find.text('Resultados para “Margherita”'), findsOneWidget);
      expect(find.byType(ReceitaCard), findsOneWidget);
      expect(find.text('Qual receita você procura?'), findsNothing);
    });

    testWidgets('pesquisa pela tecla de ação do teclado', (tester) async {
      await abrirTela(tester);

      await tester.enterText(campo, 'pizza');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(find.text('Resultados para “pizza”'), findsOneWidget);
    });

    testWidgets('mostra estado vazio quando nada é encontrado', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, 'zzzz987');

      expect(nenhumResultado, findsOneWidget);
      expect(find.text('Alterar pesquisa'), findsOneWidget);
      expect(find.text('Ver todas as receitas'), findsOneWidget);
      expect(find.byType(ReceitaCard), findsNothing);
    });

    testWidgets('permite corrigir depois de um erro', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, '   ');
      expect(erro, findsOneWidget);

      await tester.enterText(campo, 'pizza');
      await tester.pump();
      expect(erro, findsNothing);

      await tester.tap(botaoPesquisar);
      await tester.pump();
      expect(find.text('Resultados para “pizza”'), findsOneWidget);
    });

    testWidgets('consulta inválida remove o resultado anterior', (
      tester,
    ) async {
      await abrirTela(tester);

      await pesquisar(tester, 'pizza');
      await pesquisar(tester, '   ');

      expect(erro, findsOneWidget);
      expect(resultados, findsNothing);
    });

    testWidgets('limpar pesquisa volta ao estado inicial', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, 'pizza');
      await tester.ensureVisible(botaoLimpar);
      await tester.tap(botaoLimpar);
      await tester.pump();

      expect(tester.widget<TextFormField>(campo).controller!.text, isEmpty);
      expect(resultados, findsNothing);
      expect(erro, findsNothing);
      expect(find.text('Qual receita você procura?'), findsOneWidget);
    });

    testWidgets('abre já pesquisando o termo recebido', (tester) async {
      await abrirTela(tester, termo: 'margherita');

      expect(find.text('Resultados para “margherita”'), findsOneWidget);
      expect(
        tester.widget<TextFormField>(campo).controller!.text,
        'margherita',
      );
    });
  });

  group('navegação', () {
    final campoInicio = find.byType(TextField);
    final botaoBuscar = find.text('Buscar receitas');

    testWidgets('a tela inicial mostra as receitas disponíveis', (
      tester,
    ) async {
      await tester.pumpWidget(const DisciplinaFlutterApp());

      expect(find.text('Saborê'), findsOneWidget);
      expect(find.text('Receitas disponíveis'), findsOneWidget);
      expect(find.text('Classic Margherita Pizza'), findsOneWidget);
    });

    testWidgets('buscar sem termo abre a pesquisa vazia e volta', (
      tester,
    ) async {
      await tester.pumpWidget(const DisciplinaFlutterApp());

      await tester.tap(botaoBuscar);
      await tester.pumpAndSettle();
      expect(find.byType(PesquisaReceitasPage), findsOneWidget);
      expect(find.text('Qual receita você procura?'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.byType(PesquisaReceitasPage), findsNothing);
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('buscar com termo abre a pesquisa com resultados', (
      tester,
    ) async {
      await tester.pumpWidget(const DisciplinaFlutterApp());

      await tester.enterText(campoInicio, 'pizza');
      await tester.tap(botaoBuscar);
      await tester.pumpAndSettle();

      expect(find.text('Resultados para “pizza”'), findsOneWidget);
    });

    testWidgets('"Ver todas as receitas" volta para a tela inicial', (
      tester,
    ) async {
      await tester.pumpWidget(const DisciplinaFlutterApp());

      await tester.enterText(campoInicio, 'zzzz987');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Nenhum resultado'), findsOneWidget);

      final verTodas = find.text('Ver todas as receitas');
      await tester.ensureVisible(verTodas);
      await tester.tap(verTodas);
      await tester.pumpAndSettle();

      expect(find.byType(PesquisaReceitasPage), findsNothing);
      expect(find.text('Receitas disponíveis'), findsOneWidget);
    });
  });
}
