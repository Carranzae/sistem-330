import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Información de conectividad de red
class NetworkInfo {
  final Connectivity connectivity;

  NetworkInfo(this.connectivity);

  /// Verificar si hay conexión a internet
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }
    
    // Verificar conectividad real
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Stream de cambios de conectividad
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(
      (result) => !result.contains(ConnectivityResult.none),
    );
  }
}

