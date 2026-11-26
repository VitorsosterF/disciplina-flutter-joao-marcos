import 'package:flutter_test/flutter_test.dart';

import 'package:atividade_joaobortolotti/models/receita.dart';

void main() {
  group('Receita.fromJson', () {
    test('lê todos os campos usados pelo app', () {
      final receita = Receita.fromJson({
        'id': 1,
        'name': '  Classic Margherita Pizza ',
        'ingredients': ['Pizza dough', 'Tomato sauce'],
        'instructions': ['Passo 1', 'Passo 2', 'Passo 3'],
        'image': 'https://cdn.dummyjson.com/recipe-images/1.webp',
        'prepTimeMinutes': 20,
        'cookTimeMinutes': 15,
        'servings': 4,
        'rating': 4.6,
        'mealType': ['Dinner'],
        'difficulty': 'Easy',
        'cuisine': 'Italian',
      });

      expect(receita.id, 1);
      expect(receita.nome, 'Classic Margherita Pizza');
      expect(receita.ingredientes, ['Pizza dough', 'Tomato sauce']);
      expect(receita.instrucoes, ['Passo 1', 'Passo 2', 'Passo 3']);
      expect(receita.imagem, 'https://cdn.dummyjson.com/recipe-images/1.webp');
      expect(receita.minutosTotais, 35);
      expect(receita.tempoResumo, '35 min');
      expect(receita.porcoes, 4);
      expect(receita.avaliacaoFormatada, '4,6 / 5');
      expect(receita.tiposRefeicao, ['Dinner']);
      expect(receita.dificuldade, 'Easy');
      expect(receita.culinaria, 'Italian');
    });

    test('trata campos ausentes sem inventar valores', () {
      final receita = Receita.fromJson({'id': 7});

      expect(receita.nome, Receita.nomePadrao);
      expect(receita.ingredientes, isEmpty);
      expect(receita.instrucoes, isEmpty);
      expect(receita.imagem, isNull);
      expect(receita.minutosTotais, isNull);
      expect(receita.tempoResumo, 'Tempo não informado');
      expect(receita.porcoes, isNull);
      expect(receita.avaliacaoFormatada, isNull);
      expect(receita.tiposRefeicao, isEmpty);
    });

    test('não soma o total quando falta um dos tempos', () {
      final soPreparo = Receita.fromJson({'id': 1, 'prepTimeMinutes': 20});
      final soCozimento = Receita.fromJson({'id': 2, 'cookTimeMinutes': 15});

      expect(soPreparo.minutosTotais, isNull);
      expect(soPreparo.tempoResumo, 'Preparo 20 min');
      expect(soCozimento.tempoResumo, 'Cozimento 15 min');
    });

    test('confere os tipos antes de usar os valores', () {
      final receita = Receita.fromJson({
        'id': 3,
        'name': 123,
        'ingredients': 'farinha',
        'instructions': ['Misture', 42, '  ', null, 'Asse'],
        'image': 'não é uma url',
        'prepTimeMinutes': '20',
        'cookTimeMinutes': 10.5,
        'servings': 0,
        'rating': '4.5',
        'mealType': 'Dinner',
      });

      expect(receita.nome, Receita.nomePadrao);
      expect(receita.ingredientes, isEmpty);
      expect(receita.instrucoes, ['Misture', 'Asse']);
      expect(receita.imagem, isNull);
      expect(receita.minutosPreparo, isNull);
      expect(receita.minutosCozimento, isNull);
      expect(receita.porcoes, isNull);
      expect(receita.avaliacao, isNull);
      expect(receita.tiposRefeicao, isEmpty);
    });

    test('aceita números inteiros vindos como double e nota inteira', () {
      final receita = Receita.fromJson({
        'id': 4.0,
        'prepTimeMinutes': 10.0,
        'cookTimeMinutes': 5,
        'rating': 4,
      });

      expect(receita.id, 4);
      expect(receita.minutosTotais, 15);
      expect(receita.avaliacaoFormatada, '4,0 / 5');
    });

    test('exige um id válido', () {
      expect(() => Receita.fromJson({'name': 'Sem id'}), throwsFormatException);
      expect(() => Receita.fromJson({'id': '1'}), throwsFormatException);
    });
  });

  group('Receita.listaDoJson', () {
    test('descarta itens inválidos e ids repetidos', () {
      final receitas = Receita.listaDoJson({
        'recipes': [
          {'id': 1, 'name': 'A'},
          {'name': 'Sem id'},
          'texto solto',
          {'id': 1, 'name': 'A repetida'},
          {'id': 2, 'name': 'B'},
        ],
      });

      expect(receitas.map((r) => r.nome), ['A', 'B']);
    });

    test('recusa corpo incompatível', () {
      expect(() => Receita.listaDoJson([1, 2]), throwsFormatException);
      expect(() => Receita.listaDoJson({'foo': 1}), throwsFormatException);
      expect(
        () => Receita.listaDoJson({'recipes': 'nada'}),
        throwsFormatException,
      );
    });
  });
}
