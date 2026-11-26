import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:atividade_joaobortolotti/services/receitas_api.dart';

/// Receitas no formato da DummyJSON (sem imagem, para não acessar a rede).
final receitasJson = <Map<String, dynamic>>[
  {
    'id': 1,
    'name': 'Classic Margherita Pizza',
    'ingredients': ['Pizza dough', 'Tomato sauce', 'Fresh mozzarella cheese'],
    'instructions': [
      'Preheat the oven to 475°F (245°C).',
      'Roll out the pizza dough and spread tomato sauce evenly.',
      'Bake for 12-15 minutes.',
    ],
    'prepTimeMinutes': 20,
    'cookTimeMinutes': 15,
    'servings': 4,
    'difficulty': 'Easy',
    'cuisine': 'Italian',
    'rating': 4.6,
    'mealType': ['Dinner'],
  },
  {
    'id': 2,
    'name': 'Vegetarian Stir-Fry',
    'ingredients': ['Tofu, cubed', 'Broccoli florets'],
    'instructions': ['Heat sesame oil.', 'Serve over cooked rice.'],
    'prepTimeMinutes': 15,
    'cookTimeMinutes': 20,
    'servings': 3,
    'difficulty': 'Medium',
    'cuisine': 'Asian',
    'rating': 4,
    'mealType': ['Lunch', 'Dinner'],
  },
];

http.Response respostaJson(Object corpo, [int status = 200]) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(corpo)),
    status,
    headers: {'content-type': 'application/json'},
  );
}

/// Simula a API: conta as chamadas e permite trocar as respostas.
class ServidorFalso {
  int listagens = 0;
  final pesquisas = <String>[];

  late Future<http.Response> Function() aoListar;
  late Future<http.Response> Function(String termo) aoPesquisar;

  ServidorFalso() {
    aoListar = () async => respostaJson({'recipes': receitasJson});
    aoPesquisar = (termo) async => respostaJson({
      'recipes': receitasJson
          .where(
            (r) => (r['name'] as String).toLowerCase().contains(
              termo.toLowerCase(),
            ),
          )
          .toList(),
    });
  }

  late final api = ReceitasApi(
    cliente: MockClient((requisicao) {
      switch (requisicao.url.path) {
        case '/recipes':
          listagens++;
          return aoListar();
        case '/recipes/search':
          final termo = requisicao.url.queryParameters['q'] ?? '';
          pesquisas.add(termo);
          return aoPesquisar(termo);
      }
      return Future.value(http.Response('not found', 404));
    }),
  );
}
