import 'package:flutter/widgets.dart';

import '../services/receitas_api.dart';
import 'favoritos_controller.dart';

/// Disponibiliza a API e os favoritos para todas as telas.
///
/// Quem lê os favoritos com [favoritosDe] é reconstruído a cada mudança.
class AppScope extends InheritedNotifier<FavoritosController> {
  final ReceitasApi api;

  const AppScope({
    super.key,
    required this.api,
    required FavoritosController favoritos,
    required super.child,
  }) : super(notifier: favoritos);

  static FavoritosController favoritosDe(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!.notifier!;
  }

  static ReceitasApi apiDe(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope não encontrado na árvore de widgets.');
    return scope!.api;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return oldWidget.api != api || super.updateShouldNotify(oldWidget);
  }
}
