import 'package:flutter/foundation.dart';
import '../../data/models/business.dart';

class AppProvider extends ChangeNotifier {
  // Estado de la aplicación
  Business? _currentBusiness;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Business? get currentBusiness => _currentBusiness;
  String get currentBusinessId => _currentBusiness?.id ?? '';
  String get currentBusinessCategory => _currentBusiness?.rubro ?? 'otro';
  String get currentBusinessName => _currentBusiness?.nombreComercial ?? 'Mi Negocio';
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasBusiness => _currentBusiness != null;

  // Métodos para actualizar el estado
  void setCurrentBusiness(Business business) {
    _currentBusiness = business;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearBusiness() {
    _currentBusiness = null;
    notifyListeners();
  }
}


