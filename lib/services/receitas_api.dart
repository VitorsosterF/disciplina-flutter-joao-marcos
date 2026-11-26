import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/receita.dart';

enum TipoFalha { semConexao, tempoEsgotado, status, respostaInvalida }

/// Falha ao falar com a API, já com uma mensagem compreensível.
class ReceitasException implements Exception {
  final TipoFalha tipo;
  final int? status;

  const ReceitasException(this.tipo, {this.status});

  String get mensagem => switch (tipo) {
    TipoFalha.semConexao =>
      'Verifique sua conexão com a internet e tente novamente.',
    TipoFalha.tempoEsgotado =>
      'O servidor demorou demais para responder. Tente novamente.',
    TipoFalha.status =>
      'O servidor respondeu com erro (código $status). '
          'Tente novamente em instantes.',
    TipoFalha.respostaInvalida =>
      'Os dados recebidos vieram em um formato inesperado. '
          'Tente novamente.',
  };

  @override
  String toString() => 'ReceitasException($tipo, status: $status)';
}

/// Acesso à API pública DummyJSON Recipes.
class ReceitasApi {
  static const _host = 'dummyjson.com';

  final http.Client _cliente;
  final Duration tempoLimite;

  ReceitasApi({
    http.Client? cliente,
    this.tempoLimite = const Duration(seconds: 15),
  }) : _cliente = cliente ?? http.Client();

  /// Lista todas as receitas (`limit=0` devolve o conjunto completo).
  Future<List<Receita>> listar() {
    return _buscarLista('/recipes', {'limit': '0'});
  }

  /// Pesquisa remota por nome. O termo já deve chegar normalizado.
  Future<List<Receita>> pesquisar(String termo) {
    return _buscarLista('/recipes/search', {'q': termo, 'limit': '0'});
  }

  Future<List<Receita>> _buscarLista(
    String caminho,
    Map<String, String> parametros,
  ) async {
    final corpo = await _get(Uri.https(_host, caminho, parametros));
    try {
      return Receita.listaDoJson(corpo);
    } on FormatException {
      throw const ReceitasException(TipoFalha.respostaInvalida);
    }
  }

  Future<Object?> _get(Uri uri) async {
    final http.Response resposta;
    try {
      resposta = await _cliente
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(tempoLimite);
    } on TimeoutException {
      throw const ReceitasException(TipoFalha.tempoEsgotado);
    } on Exception {
      // http.ClientException, SocketException, HandshakeException etc.
      throw const ReceitasException(TipoFalha.semConexao);
    }

    if (resposta.statusCode != 200) {
      throw ReceitasException(TipoFalha.status, status: resposta.statusCode);
    }

    try {
      return jsonDecode(utf8.decode(resposta.bodyBytes));
    } on FormatException {
      throw const ReceitasException(TipoFalha.respostaInvalida);
    }
  }

  void fechar() => _cliente.close();
}
