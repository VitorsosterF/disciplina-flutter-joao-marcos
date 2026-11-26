/// Receita recebida da API DummyJSON.
///
/// A leitura é defensiva: campos ausentes ou com tipo inesperado viram `null`
/// (ou lista vazia) em vez de quebrar o app. Somente o `id` é obrigatório,
/// porque ele identifica a receita na seleção e nos favoritos.
class Receita {
  static const nomePadrao = 'Receita sem nome';

  final int id;
  final String nome;
  final List<String> ingredientes;
  final List<String> instrucoes;
  final String? imagem;
  final int? minutosPreparo;
  final int? minutosCozimento;
  final int? porcoes;
  final num? avaliacao;
  final List<String> tiposRefeicao;
  final String? dificuldade;
  final String? culinaria;

  const Receita({
    required this.id,
    required this.nome,
    this.ingredientes = const [],
    this.instrucoes = const [],
    this.imagem,
    this.minutosPreparo,
    this.minutosCozimento,
    this.porcoes,
    this.avaliacao,
    this.tiposRefeicao = const [],
    this.dificuldade,
    this.culinaria,
  });

  /// Lança [FormatException] quando não há um `id` inteiro válido.
  factory Receita.fromJson(Map<String, dynamic> json) {
    final id = _inteiro(json['id']);
    if (id == null) {
      throw const FormatException('Receita sem id válido.');
    }

    final porcoes = _inteiro(json['servings']);
    final avaliacao = json['rating'];

    return Receita(
      id: id,
      nome: _texto(json['name']) ?? nomePadrao,
      ingredientes: _listaTextos(json['ingredients']),
      instrucoes: _listaTextos(json['instructions']),
      imagem: _url(json['image']),
      minutosPreparo: _inteiro(json['prepTimeMinutes']),
      minutosCozimento: _inteiro(json['cookTimeMinutes']),
      porcoes: porcoes != null && porcoes > 0 ? porcoes : null,
      avaliacao: avaliacao is num && avaliacao.isFinite && avaliacao >= 0
          ? avaliacao
          : null,
      tiposRefeicao: _listaTextos(json['mealType']),
      dificuldade: _texto(json['difficulty']),
      culinaria: _texto(json['cuisine']),
    );
  }

  /// Lê o corpo `{ "recipes": [...] }` da listagem e da pesquisa.
  ///
  /// Lança [FormatException] se o corpo não tiver esse formato. Itens
  /// individuais sem `id` válido são descartados.
  static List<Receita> listaDoJson(Object? corpo) {
    if (corpo is! Map<String, dynamic>) {
      throw const FormatException('O corpo da resposta não é um objeto.');
    }
    final itens = corpo['recipes'];
    if (itens is! List) {
      throw const FormatException('A resposta não contém a lista "recipes".');
    }

    final receitas = <Receita>[];
    final idsVistos = <int>{};
    for (final item in itens) {
      if (item is! Map<String, dynamic>) continue;
      try {
        final receita = Receita.fromJson(item);
        if (idsVistos.add(receita.id)) receitas.add(receita);
      } on FormatException {
        // Item incompatível: ignora apenas ele.
      }
    }
    return receitas;
  }

  /// Soma só quando os dois tempos foram informados; caso contrário, `null`.
  int? get minutosTotais {
    final preparo = minutosPreparo;
    final cozimento = minutosCozimento;
    if (preparo == null || cozimento == null) return null;
    return preparo + cozimento;
  }

  /// Tempo curto para os cards, sem tratar ausência como zero.
  String get tempoResumo {
    final total = minutosTotais;
    if (total != null) return '$total min';
    if (minutosPreparo != null) return 'Preparo $minutosPreparo min';
    if (minutosCozimento != null) return 'Cozimento $minutosCozimento min';
    return 'Tempo não informado';
  }

  /// Avaliação no formato "4,6 / 5", ou `null` se não informada.
  String? get avaliacaoFormatada {
    final nota = avaliacao;
    if (nota == null) return null;
    return '${nota.toDouble().toStringAsFixed(1).replaceAll('.', ',')} / 5';
  }

  @override
  bool operator ==(Object other) => other is Receita && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

String? _texto(Object? valor) {
  if (valor is! String) return null;
  final texto = valor.trim();
  return texto.isEmpty ? null : texto;
}

List<String> _listaTextos(Object? valor) {
  if (valor is! List) return const [];
  return List.unmodifiable(
    valor
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty),
  );
}

/// Aceita `int` ou `double` sem parte fracionária e não negativo.
int? _inteiro(Object? valor) {
  if (valor is int) return valor >= 0 ? valor : null;
  if (valor is double &&
      valor.isFinite &&
      valor >= 0 &&
      valor == valor.roundToDouble()) {
    return valor.toInt();
  }
  return null;
}

String? _url(Object? valor) {
  final texto = _texto(valor);
  if (texto == null) return null;
  final uri = Uri.tryParse(texto);
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    return null;
  }
  return texto;
}
