import 'package:flutter/material.dart';

const mensagemConsultaVazia =
    'Digite o nome de uma receita para pesquisar. Exemplo: bolo de cenoura.';

/// Remove os espaços das pontas e reduz espaços repetidos entre as palavras.
String normalizarConsulta(String texto) {
  return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Retorna a mensagem de erro da consulta, ou `null` se ela for válida.
String? validarConsulta(String? texto) {
  if (normalizarConsulta(texto ?? '').isEmpty) {
    return mensagemConsultaVazia;
  }
  return null;
}

class PesquisaReceitasPage extends StatefulWidget {
  const PesquisaReceitasPage({super.key});

  @override
  State<PesquisaReceitasPage> createState() => _PesquisaReceitasPageState();
}

class _PesquisaReceitasPageState extends State<PesquisaReceitasPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  final _focoCampo = FocusNode();

  // Depois de uma tentativa inválida, o erro some assim que a entrada é corrigida.
  AutovalidateMode _modoValidacao = AutovalidateMode.disabled;
  String? _termoPesquisado;

  @override
  void dispose() {
    _controller.dispose();
    _focoCampo.dispose();
    super.dispose();
  }

  void _pesquisar() {
    final valida = _formKey.currentState!.validate();

    setState(() {
      _termoPesquisado = valida ? normalizarConsulta(_controller.text) : null;
      _modoValidacao = valida
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction;
    });

    if (!valida) {
      _focoCampo.requestFocus();
    }
  }

  void _novaConsulta() {
    _formKey.currentState!.reset();
    _controller.clear();

    setState(() {
      _termoPesquisado = null;
      _modoValidacao = AutovalidateMode.disabled;
    });

    _focoCampo.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final termo = _termoPesquisado;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesquisar receitas'),
        centerTitle: true,
        backgroundColor: cores.primary,
        foregroundColor: cores.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              autovalidateMode: _modoValidacao,
              child: TextFormField(
                controller: _controller,
                focusNode: _focoCampo,
                validator: validarConsulta,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _pesquisar(),
                decoration: const InputDecoration(
                  labelText: 'Nome da receita',
                  hintText: 'Ex.: bolo de cenoura',
                  prefixIcon: Icon(Icons.restaurant_menu),
                  border: OutlineInputBorder(),
                  errorMaxLines: 3,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _pesquisar,
              icon: const Icon(Icons.search),
              label: const Text('Pesquisar'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (termo != null) ...[
              const SizedBox(height: 24),
              _ResultadoProvisorio(termo: termo),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _novaConsulta,
                icon: const Icon(Icons.refresh),
                label: const Text('Nova consulta'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultadoProvisorio extends StatelessWidget {
  final String termo;

  const _ResultadoProvisorio({required this.termo});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pesquisando por: $termo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Resultado provisório: a lista de receitas ainda será adicionada.',
            ),
          ],
        ),
      ),
    );
  }
}
