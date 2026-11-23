class Receita {
  final String nome;
  final String culinaria;
  final String dificuldade;
  final int minutos;
  final double nota;

  const Receita({
    required this.nome,
    required this.culinaria,
    required this.dificuldade,
    required this.minutos,
    required this.nota,
  });

  /// Nota no formato do layout, ex.: "4,6 / 5".
  String get notaFormatada =>
      '${nota.toStringAsFixed(1).replaceAll('.', ',')} / 5';
}

/// Receitas disponíveis enquanto o app não consome uma fonte externa.
const receitasDisponiveis = <Receita>[
  Receita(
    nome: 'Classic Margherita Pizza',
    culinaria: 'Italiana',
    dificuldade: 'Fácil',
    minutos: 35,
    nota: 4.6,
  ),
];

const _semAcento = {
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', //
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
  'ç': 'c', 'ñ': 'n',
};

String _simplificar(String texto) {
  return texto
      .toLowerCase()
      .split('')
      .map((letra) => _semAcento[letra] ?? letra)
      .join();
}

/// Busca por parte do nome, sem diferenciar maiúsculas nem acentos.
List<Receita> buscarReceitas(
  String termo, {
  List<Receita> receitas = receitasDisponiveis,
}) {
  final busca = _simplificar(termo);
  return receitas
      .where((receita) => _simplificar(receita.nome).contains(busca))
      .toList();
}
