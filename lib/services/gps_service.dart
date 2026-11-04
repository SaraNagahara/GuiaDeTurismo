import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GpsService {

  Future<LatLng?> obterLocal() async {
    bool ativo = await Geolocator.isLocationServiceEnabled();

    if(!ativo){
      return null;
    }

    LocationPermission permissao = await Geolocator.checkPermission();
    if(permissao == LocationPermission.denied){
      permissao = await Geolocator.requestPermission();
    }
    if(permissao == LocationPermission.deniedForever) return null;

    Position posicao;
    try {
      posicao = await Geolocator.getCurrentPosition();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch(erro) {
        debugPrint("ERRO ao obert posição: $erro");
        return null;
    } 
  } 

}