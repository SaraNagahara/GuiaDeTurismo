import 'package:flutter/material.dart';
import 'package:guia_turismo/controller/camera_controller.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';
import 'package:guia_turismo/models/lugares_model.dart';
import 'package:provider/provider.dart';

class CadastroLugar extends StatefulWidget {
  const CadastroLugar({super.key});

  @override
  State<CadastroLugar> createState() => _CadastroLugarState();
}

class _CadastroLugarState extends State<CadastroLugar> {
  // Controladores do formulário
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  int _categoriaId = 1;

  Future<void> _salvarDados(BuildContext contextDialog) async {
    final novoLugar = LugaresModel(
      id: 0, // A API gera o id
      nome: _nomeController.text,
      descricao: _descricaoController.text,
      latitude: double.tryParse(_latitudeController.text.replaceAll(',', '.')) ?? 0,
      longitude: double.tryParse(_longitudeController.text.replaceAll(',', '.')) ?? 0,
      categoriaId: _categoriaId,
    );
    
    final controleLugares = context.read<LugaresController>();
    final mensagem = await controleLugares.cadastrarLugar(novoLugar);
    
    if (!contextDialog.mounted) return;
    ScaffoldMessenger.of(contextDialog).showSnackBar(SnackBar(content: Text(mensagem)));
    
    if (controleLugares.erro.isEmpty) {
      // Se deu certo, volta para a tela anterior
      Navigator.pop(contextDialog); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Lugar'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<CameraController>(
          builder: (context, controleCamera, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Parte da Câmera / Imagem
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 248, 189, 208),
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(16),
                      image: exibirImagem(controleCamera),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () => abrirModal(controleCamera, context),
                      icon: const Icon(Icons.camera_alt_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Campos do Formulário
              TextField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: "Nome"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: "Descrição"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _categoriaId,
                decoration: const InputDecoration(labelText: "Categoria"),
                items: const [
                  DropdownMenuItem(value: 1, child: Text("Praias")),
                  DropdownMenuItem(value: 2, child: Text("Points")),
                  DropdownMenuItem(value: 3, child: Text("Ilhas")),
                  DropdownMenuItem(value: 4, child: Text("Gastronomia")),
                  DropdownMenuItem(value: 5, child: Text("Dicas")),
                ],
                onChanged: (valor) => setState(() => _categoriaId = valor!),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: "Latitude"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: "Longitude"),
              ),
              const SizedBox(height: 30),

              // Botão Salvar
              ElevatedButton(
                onPressed: () => _salvarDados(context),
                child: const Text("Salvar Lugar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

DecorationImage exibirImagem(CameraController controleCamera) {
  if (controleCamera.imagemSelecionada == null) {
    return const DecorationImage(
      image: NetworkImage('https://placehold.co/150x150.png'),
      fit: BoxFit.cover,
    );
  } else {
    return DecorationImage(
      image: FileImage(controleCamera.imagemSelecionada!),
      fit: BoxFit.cover,
    );
  }
}

void abrirModal(CameraController controleCamera, context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Câmera'),
            onTap: () {
              controleCamera.abrirCamera();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_album),
            title: const Text('Galeria'),
            onTap: () {
              controleCamera.abrirGaleria();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}