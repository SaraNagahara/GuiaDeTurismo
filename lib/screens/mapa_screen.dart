import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:guia_turismo/controller/lugares_controller.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final _buscaController = TextEditingController();
  final MapController _mapController = MapController();
  
  LatLng? _pontoSelecionado;
  bool _pesquisando = false;
  String _nomeLocalEncontrado = "";

  // Busca o endereço digitado na API do Nominatim (OpenStreetMap)
  Future<void> _pesquisarEndereco() async {
    final query = _buscaController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _pesquisando = true;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'br.com.guiadeturismo.app'},
      );

      if (response.statusCode == 200) {
        final List dados = json.decode(response.body);
        if (dados.isNotEmpty) {
          final double lat = double.parse(dados[0]['lat']);
          final double lon = double.parse(dados[0]['lon']);
          final String displayName = dados[0]['display_name'] ?? 'Local encontrado';

          setState(() {
            _pontoSelecionado = LatLng(lat, lon);
            _nomeLocalEncontrado = displayName;
          });

          // Move o mapa automaticamente para o endereço encontrado
          _mapController.move(_pontoSelecionado!, 15.0);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Endereço não encontrado.')),
          );
        }
      }
    } catch (e) {
      debugPrint("Erro ao buscar endereço: $e");
    } finally {
      setState(() {
        _pesquisando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Endereço no Mapa'),
        backgroundColor: Colors.pink,
      ),
      body: Consumer<LugaresController>(
        builder: (context, lugaresController, child) {
          if (lugaresController.carregando) {
            return const Center(child: CircularProgressIndicator());
          }

          LatLng pontoInicial = const LatLng(-23.550520, -46.633308);
          if (lugaresController.lugares.isNotEmpty) {
            final primeiroLugar = lugaresController.lugares.first;
            pontoInicial = LatLng(primeiroLugar.latitude, primeiroLugar.longitude);
          }

          return Stack(
            children: [
              // O Mapa
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pontoInicial,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() {
                      _pontoSelecionado = point;
                      _nomeLocalEncontrado = "Lat: ${point.latitude.toStringAsFixed(4)}, Lng: ${point.longitude.toStringAsFixed(4)}";
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'br.com.guiadeturismo.app',
                  ),
                  MarkerLayer(
                    markers: [
                      // Pinos dos lugares já cadastrados
                      ...lugaresController.lugares.map((lugar) {
                        return Marker(
                          point: LatLng(lugar.latitude, lugar.longitude),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        );
                      }),
                      // Pino azul do endereço pesquisado ou tocado
                      if (_pontoSelecionado != null)
                        Marker(
                          point: _pontoSelecionado!,
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.blue,
                            size: 50,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              // Caixa de pesquisa no topo
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _buscaController,
                            decoration: const InputDecoration(
                              hintText: "Digite o endereço ou CEP...",
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _pesquisarEndereco(),
                          ),
                        ),
                        _pesquisando
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.search, color: Colors.pink),
                                onPressed: _pesquisarEndereco,
                              ),
                      ],
                    ),
                  ),
                ),
              ),

              // Exibe o nome do local encontrado embaixo
              if (_nomeLocalEncontrado.isNotEmpty)
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                    ),
                    child: Text(
                      _nomeLocalEncontrado,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      // Botão para confirmar e retornar a coordenada para a tela de cadastro
      floatingActionButton: _pontoSelecionado != null
          ? FloatingActionButton.extended(
              backgroundColor: Colors.pink,
              onPressed: () {
                Navigator.pop(context, _pontoSelecionado);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Confirmar Local', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}