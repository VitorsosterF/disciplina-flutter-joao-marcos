import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:atividade_joaobortolotti/services/receitas_api.dart';

import 'apoio/servidor_falso.dart';

TypeMatcher<ReceitasException> falhaDoTipo(TipoFalha tipo) =>
    isA<ReceitasException>().having((e) => e.tipo, 'tipo', tipo);

void main() {
  test('listar busca todas as receitas', () async {
    late Uri chamada;
    final api = ReceitasApi(
      cliente: MockClient((requisicao) async {
        chamada = requisicao.url;
        return respostaJson({'recipes': receitasJson});
      }),
    );

    final receitas = await api.listar();

    expect(chamada.host, 'dummyjson.com');
    expect(chamada.path, '/recipes');
    expect(chamada.queryParameters['limit'], '0');
    expect(receitas.map((r) => r.id), [1, 2]);
  });

  test('pesquisar usa o endpoint remoto com o termo', () async {
    late Uri chamada;
    final api = ReceitasApi(
      cliente: MockClient((requisicao) async {
        chamada = requisicao.url;
        return respostaJson({'recipes': <Object>[]});
      }),
    );

    final receitas = await api.pesquisar('bolo de cenoura');

    expect(chamada.path, '/recipes/search');
    expect(chamada.queryParameters['q'], 'bolo de cenoura');
    expect(receitas, isEmpty);
  });

  test('status de erro vira falha com o código', () async {
    final api = ReceitasApi(
      cliente: MockClient((_) async => http.Response('erro', 500)),
    );

    await expectLater(
      api.listar(),
      throwsA(
        falhaDoTipo(TipoFalha.status).having((e) => e.status, 'status', 500),
      ),
    );
  });

  test('JSON inválido vira resposta inválida', () async {
    final api = ReceitasApi(
      cliente: MockClient((_) async => http.Response('<html>', 200)),
    );

    await expectLater(
      api.listar(),
      throwsA(falhaDoTipo(TipoFalha.respostaInvalida)),
    );
  });

  test('corpo com formato incompatível vira resposta inválida', () async {
    final api = ReceitasApi(
      cliente: MockClient((_) async => respostaJson({'produtos': []})),
    );

    await expectLater(
      api.pesquisar('pizza'),
      throwsA(falhaDoTipo(TipoFalha.respostaInvalida)),
    );
  });

  test('falha de rede vira sem conexão', () async {
    final api = ReceitasApi(
      cliente: MockClient((_) async => throw http.ClientException('offline')),
    );

    await expectLater(api.listar(), throwsA(falhaDoTipo(TipoFalha.semConexao)));
  });

  test('demora excessiva vira tempo esgotado', () async {
    final api = ReceitasApi(
      tempoLimite: const Duration(milliseconds: 10),
      cliente: MockClient((_) => Completer<http.Response>().future),
    );

    await expectLater(
      api.listar(),
      throwsA(falhaDoTipo(TipoFalha.tempoEsgotado)),
    );
  });

  test('toda falha tem mensagem compreensível', () {
    for (final tipo in TipoFalha.values) {
      expect(ReceitasException(tipo, status: 503).mensagem, isNotEmpty);
    }
    expect(
      const ReceitasException(TipoFalha.status, status: 503).mensagem,
      contains('503'),
    );
  });
}
