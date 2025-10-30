class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  static String? validateRuc(String? value) {
    if (value == null || value.isEmpty) {
      return null; // RUC es opcional
    }
    if (value.length != 11) {
      return 'El RUC debe tener 11 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El RUC solo debe contener números';
    }
    return null;
  }

  static String? validateRequired(String? value, String field) {
    if (value == null || value.isEmpty) {
      return '$field es requerido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    if (!RegExp(r'^\+?[\d\s]{7,15}$').hasMatch(value)) {
      return 'Ingrese un número de teléfono válido';
    }
    return null;
  }

  static String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre comercial es requerido';
    }
    if (value.length < 3) {
      return 'El nombre comercial debe tener al menos 3 caracteres';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dirección es requerida';
    }
    if (value.length < 5) {
      return 'La dirección debe tener al menos 5 caracteres';
    }
    return null;
  }
}
