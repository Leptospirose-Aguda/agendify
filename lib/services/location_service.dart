// lib/services/location_service.dart
//
// Serviço de geolocalização do Agendify.
// Obtém a posição atual do dispositivo (mobile e web) e realiza geocodificação
// reversa para retornar um endereço legível ao usuário.
//
// Implementado em: 11/11/2026 — Relatório Semanal #07

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Verifica se o serviço de localização está habilitado e se as permissões
  /// foram concedidas. Solicita a permissão quando necessário.
  Future<bool> _checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  /// Retorna a posição geográfica atual do dispositivo.
  /// Lança [Exception] caso o serviço esteja indisponível ou a permissão
  /// seja negada.
  Future<Position> getCurrentPosition() async {
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      throw Exception(
        'Permissão de localização negada ou serviço desativado.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// Converte coordenadas geográficas em um endereço legível.
  /// Na web ([kIsWeb]) usa a API de geocodificação reversa via browser;
  /// no mobile usa o pacote `geocoding`.
  Future<String> getAddressFromPosition(Position position) async {
    // Na web o geocoding nativo não funciona — retornamos as coordenadas
    // formatadas como endereço provisório.
    if (kIsWeb) {
      return 'Lat: ${position.latitude.toStringAsFixed(5)}, '
          'Lng: ${position.longitude.toStringAsFixed(5)}';
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        return '${position.latitude.toStringAsFixed(5)}, '
            '${position.longitude.toStringAsFixed(5)}';
      }

      final place = placemarks.first;
      final parts = <String>[
        if ((place.street ?? '').isNotEmpty) place.street!,
        if ((place.subLocality ?? '').isNotEmpty) place.subLocality!,
        if ((place.locality ?? '').isNotEmpty) place.locality!,
        if ((place.administrativeArea ?? '').isNotEmpty)
          place.administrativeArea!,
        if ((place.country ?? '').isNotEmpty) place.country!,
      ];

      return parts.join(', ');
    } catch (_) {
      // Fallback: exibe as coordenadas brutas caso a geocodificação falhe.
      return '${position.latitude.toStringAsFixed(5)}, '
          '${position.longitude.toStringAsFixed(5)}';
    }
  }

  /// Obtém a posição atual e retorna diretamente o endereço formatado.
  Future<String> getCurrentAddress() async {
    final position = await getCurrentPosition();
    return getAddressFromPosition(position);
  }
}
