# Saborê – Aplicativo de Receitas

Aplicativo Flutter para descobrir receitas, pesquisar por nome, ler ingredientes e
modo de preparo e salvar favoritos durante a sessão. Os dados vêm da API pública
[DummyJSON Recipes](https://dummyjson.com/docs/recipes). Os textos da API aparecem
em inglês, sem tradução.

## Funcionalidades

| Requisito | Como foi atendido |
|---|---|
| **RF01 – Tela principal** | Mostra a marca "Saborê", um campo de busca com o botão "Buscar receitas" e a lista de receitas. Ao abrir o app, as receitas começam a carregar. |
| **RF02 – Listagem** | Cards com imagem, nome, tempo, dificuldade e avaliação. Se a imagem faltar ou falhar, aparece um ícone no lugar. A lista rola. |
| **RF03 – Pesquisa** | Pesquisa remota em `/recipes/search?q=`. Remove os espaços das pontas e recusa consulta vazia. Tem os botões "Limpar pesquisa", "Ver todas as receitas" e a seta de voltar. |
| **RF04 – Detalhes** | Imagem, nome, culinária, dificuldade, avaliação, tipos de refeição, tempo total, porções, tempos de preparo e cozimento, ingredientes e passos numerados, em uma tela com rolagem. |
| **RF05 – Favoritos** | O coração no card ou nos detalhes adiciona e remove a receita, sem duplicar. A aba "Favoritos" lista as receitas salvas na sessão. |
| **RF06 – Carregamento** | Esqueleto com "Carregando receitas..." ou "Pesquisando receitas...". O botão "Pesquisar" fica desabilitado enquanto a busca está em andamento. |
| **RF07 – Erros** | Falta de conexão, tempo esgotado, status HTTP de erro e corpo incompatível têm cada um uma mensagem clara e o botão "Tentar novamente". |
| **RF08 – Ausência de resultados** | "Nenhum resultado" (busca sem correspondência), "Não foi possível…" (falha) e "Nenhum favorito" (favoritos vazios) são telas diferentes. |
| **RF09 – Navegação** | Ao voltar dos detalhes, a pesquisa aparece com o mesmo termo e os mesmos resultados. A listagem e a pesquisa se mantêm ao trocar de aba. |

## Decisões de implementação

- **Detalhes sem nova requisição.** A listagem e a pesquisa já devolvem o objeto
  completo da receita, com ingredientes e instruções. Por isso a tela de detalhes
  reaproveita esse objeto e não consulta `/recipes/{id}`. Isso evita uma requisição
  a mais e um estado de erro extra na tela de detalhes.
- **Listagem completa.** A listagem usa `/recipes?limit=0`, que devolve as 50
  receitas de uma vez. A pesquisa também usa `limit=0` para trazer todas as
  correspondências.
- **Operação única e consultas concorrentes.**
  - A listagem é carregada uma vez, em `didChangeDependencies` com uma flag, e
    não a cada reconstrução da tela. Uma segunda flag impede duas cargas ao mesmo
    tempo.
  - Na pesquisa, o botão fica desabilitado durante a busca e cada consulta recebe
    um número. Respostas que chegam depois de a pesquisa ser limpa ou substituída
    são descartadas.
- **Favoritos com uma única fonte de verdade.** Um `FavoritosController`
  (`ChangeNotifier`) guarda as receitas em memória, indexadas pelo `id`, o que
  impede duplicatas. Ele é compartilhado com todas as telas por um
  `InheritedNotifier` (`AppScope`), e por isso o coração fica igual na listagem,
  na pesquisa, nos detalhes e na aba de favoritos.
- **Leitura defensiva do JSON** (`Receita.fromJson`):
  - `id` é obrigatório. Itens sem `id` válido são descartados.
  - Sem `name`, aparece "Receita sem nome". Listas ausentes viram vazias, e a tela
    mostra "não informado".
  - `prepTimeMinutes` e `cookTimeMinutes` têm o tipo conferido antes do uso. O
    total só é somado quando os dois existem, e a ausência aparece como "não
    informado", nunca como zero.
  - `servings` só é exibido quando é maior que zero.
  - `rating` é lido como `num`, então um valor inteiro também funciona.
  - `mealType` é tratado como lista.
- **Erros de rede** são convertidos em `ReceitasException`, com o tipo da falha e
  uma mensagem em português.

## Estrutura

```
lib/
├── main.dart                      # App, tema e AppScope
├── rotas.dart                     # Rotas nomeadas (/ e /detalhes)
├── tema.dart                      # Cores e estilos
├── models/receita.dart            # Modelo e leitura do JSON
├── services/receitas_api.dart     # Requisições HTTP e tratamento de falhas
├── state/
│   ├── app_scope.dart             # Disponibiliza API e favoritos às telas
│   └── favoritos_controller.dart  # Favoritos da sessão
├── pages/
│   ├── app_shell.dart             # Barra inferior Explorar / Favoritos
│   ├── home_page.dart             # Tela principal e listagem
│   ├── pesquisa_receitas_page.dart
│   ├── detalhes_receita_page.dart
│   └── favoritos_page.dart
└── widgets/                       # Card, imagem com alternativa e estados
test/                              # Testes de modelo, API, favoritos e telas
```

## Dependências

| Pacote | Uso |
|---|---|
| [`http`](https://pub.dev/packages/http) ^1.6.0 | Requisições à API (e `MockClient` nos testes) |
| `cupertino_icons` ^1.0.8 | Ícones |
| `flutter_lints` ^6.0.0 (dev) | Regras de análise estática |
| `flutter_test` (dev) | Testes |

## SDK

- Flutter 3.47.9 (canal stable)
- Dart 3.13.7 (`environment: sdk: ^3.13.7`)

## Como executar

1. Instale o Flutter (versão acima ou compatível) e confira com `flutter doctor`.
2. Clone o repositório e entre na pasta:
   ```bash
   git clone https://github.com/VitorsosterF/disciplina-flutter-joao-marcos.git
   cd disciplina-flutter-joao-marcos
   ```
3. Instale as dependências:
   ```bash
   flutter pub get
   ```
4. Rode em um emulador, aparelho ou navegador (é necessário ter internet):
   ```bash
   flutter run
   ```
5. Para rodar os testes e a análise:
   ```bash
   flutter test
   flutter analyze
   ```

O Android usa a permissão `INTERNET`, já declarada no `AndroidManifest.xml`. No
macOS, a permissão de rede está nos arquivos `.entitlements`.
