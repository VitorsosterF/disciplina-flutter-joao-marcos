import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atividade_joaobortolotti/main.dart';
import 'package:atividade_joaobortolotti/pesquisa_receitas_page.dart';

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
      expect(validarConsulta(' \t\n  '), mensagemConsultaVazia);
    });

    test('aceita texto com espaços nas pontas', () {
      expect(validarConsulta('  bolo  '), isNull);
    });
  });

  group('PesquisaReceitasPage', () {
    final campo = find.byType(TextFormField);
    final botaoPesquisar = find.widgetWithText(ElevatedButton, 'Pesquisar');
    final botaoNovaConsulta = find.text('Nova consulta');
    final erro = find.text(mensagemConsultaVazia);
    final feedback = find.textContaining('Pesquisando por:');

    Future<void> abrirTela(WidgetTester tester) {
      return tester.pumpWidget(const MaterialApp(home: PesquisaReceitasPage()));
    }

    Future<void> pesquisar(WidgetTester tester, String texto) async {
      await tester.enterText(campo, texto);
      await tester.tap(botaoPesquisar);
      await tester.pump();
    }

    testWidgets('mostra campo rotulado e ação de pesquisa', (tester) async {
      await abrirTela(tester);

      expect(find.text('Nome da receita'), findsOneWidget);
      expect(botaoPesquisar, findsOneWidget);
      expect(erro, findsNothing);
      expect(feedback, findsNothing);
    });

    testWidgets('recusa consulta vazia sem iniciar pesquisa', (tester) async {
      await abrirTela(tester);

      await tester.tap(botaoPesquisar);
      await tester.pump();

      expect(erro, findsOneWidget);
      expect(feedback, findsNothing);
    });

    testWidgets('recusa consulta só com espaços', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, '     ');

      expect(erro, findsOneWidget);
      expect(feedback, findsNothing);
    });

    testWidgets('mostra o termo válido já tratado', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, '   bolo    de   cenoura  ');

      expect(find.text('Pesquisando por: bolo de cenoura'), findsOneWidget);
      expect(erro, findsNothing);
    });

    testWidgets('pesquisa pela tecla de ação do teclado', (tester) async {
      await abrirTela(tester);

      await tester.enterText(campo, 'lasanha');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(find.text('Pesquisando por: lasanha'), findsOneWidget);
    });

    testWidgets('permite corrigir depois de um erro', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, '   ');
      expect(erro, findsOneWidget);

      await tester.enterText(campo, 'torta');
      await tester.pump();
      expect(erro, findsNothing);
      expect(feedback, findsNothing);

      await tester.tap(botaoPesquisar);
      await tester.pump();
      expect(find.text('Pesquisando por: torta'), findsOneWidget);
    });

    testWidgets('repete a pesquisa com outro termo', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, 'torta');
      await pesquisar(tester, 'sopa');

      expect(find.text('Pesquisando por: sopa'), findsOneWidget);
      expect(find.text('Pesquisando por: torta'), findsNothing);
    });

    testWidgets('consulta inválida remove o resultado anterior', (
      tester,
    ) async {
      await abrirTela(tester);

      await pesquisar(tester, 'torta');
      await pesquisar(tester, '   ');

      expect(erro, findsOneWidget);
      expect(feedback, findsNothing);
    });

    testWidgets('nova consulta limpa campo e resultado', (tester) async {
      await abrirTela(tester);

      await pesquisar(tester, 'torta');
      await tester.tap(botaoNovaConsulta);
      await tester.pump();

      expect(tester.widget<TextFormField>(campo).controller!.text, isEmpty);
      expect(feedback, findsNothing);
      expect(erro, findsNothing);
      expect(botaoNovaConsulta, findsNothing);
    });
  });

  testWidgets('a tela inicial abre a pesquisa de receitas', (tester) async {
    await tester.pumpWidget(const DisciplinaFlutterApp());
    expect(find.text('Disciplina Flutter'), findsOneWidget);

    final botao = find.text('Pesquisar receitas');
    await tester.ensureVisible(botao);
    await tester.pumpAndSettle();
    await tester.tap(botao);
    await tester.pumpAndSettle();

    expect(find.byType(PesquisaReceitasPage), findsOneWidget);
    expect(find.text('Nome da receita'), findsOneWidget);
  });
}
