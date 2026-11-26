import 'package:flutter/foundation.dart';

import '../models/receita.dart';

/// Fonte única de verdade dos favoritos, mantida em memória durante a sessão.
///
/// As receitas são indexadas pelo `id`, o que impede duplicatas e preserva
/// a ordem em que foram adicionadas.
class FavoritosController extends ChangeNotifier {
  final _itens = <int, Receita>{};

  List<Receita> get itens => List.unmodifiable(_itens.values);

  int get quantidade => _itens.length;

  bool get vazio => _itens.isEmpty;

  bool contem(int id) => _itens.containsKey(id);

  /// Retorna `false` se a receita já estava nos favoritos.
  bool adicionar(Receita receita) {
    if (_itens.containsKey(receita.id)) return false;
    _itens[receita.id] = receita;
    notifyListeners();
    return true;
  }

  /// Retorna `false` se a receita não estava nos favoritos.
  bool remover(int id) {
    if (_itens.remove(id) == null) return false;
    notifyListeners();
    return true;
  }

  void alternar(Receita receita) {
    if (!remover(receita.id)) adicionar(receita);
  }
}
