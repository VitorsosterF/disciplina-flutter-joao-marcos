import 'package:flutter_test/flutter_test.dart';

import 'package:atividade_joaobortolotti/models/receita.dart';
import 'package:atividade_joaobortolotti/state/favoritos_controller.dart';

void main() {
  const pizza = Receita(id: 1, nome: 'Pizza');
  const sopa = Receita(id: 2, nome: 'Sopa');

  test('adiciona sem duplicar e preserva a ordem', () {
    final favoritos = FavoritosController();

    expect(favoritos.adicionar(pizza), isTrue);
    expect(favoritos.adicionar(sopa), isTrue);
    expect(favoritos.adicionar(const Receita(id: 1, nome: 'Outra')), isFalse);

    expect(favoritos.itens, [pizza, sopa]);
    expect(favoritos.quantidade, 2);
  });

  test('remove e alterna pelo id', () {
    final favoritos = FavoritosController()..adicionar(pizza);

    expect(favoritos.remover(2), isFalse);
    expect(favoritos.remover(1), isTrue);
    expect(favoritos.vazio, isTrue);

    favoritos.alternar(sopa);
    expect(favoritos.contem(2), isTrue);
    favoritos.alternar(sopa);
    expect(favoritos.contem(2), isFalse);
  });

  test('avisa as telas somente quando algo muda', () {
    var avisos = 0;
    final favoritos = FavoritosController()..addListener(() => avisos++);

    favoritos.adicionar(pizza);
    favoritos.adicionar(pizza);
    favoritos.remover(99);
    favoritos.remover(1);

    expect(avisos, 2);
  });
}
