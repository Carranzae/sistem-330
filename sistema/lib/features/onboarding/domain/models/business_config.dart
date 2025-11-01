class BusinessConfig {
  final String nombreComercial;
  final String ruc;
  final String pais;
  final String direccionCompleta;
  final String rubro;
  final String modeloNegocio;
  final Map<String, dynamic> configuracion;
  final List<String> modulosActivos;

  BusinessConfig({
    required this.nombreComercial,
    required this.ruc,
    required this.pais,
    required this.direccionCompleta,
    required this.rubro,
    required this.modeloNegocio,
    required this.configuracion,
    required this.modulosActivos,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_comercial': nombreComercial,
      'ruc': ruc,
      'pais': pais,
      'direccion_completa': direccionCompleta,
      'rubro': rubro,
      'modelo_negocio': modeloNegocio,
      'configuracion': configuracion,
      'modulos_activos': modulosActivos,
    };
  }

  factory BusinessConfig.fromJson(Map<String, dynamic> json) {
    return BusinessConfig(
      nombreComercial: json['nombre_comercial'] ?? '',
      ruc: json['ruc'] ?? '',
      pais: json['pais'] ?? '',
      direccionCompleta: json['direccion_completa'] ?? '',
      rubro: json['rubro'] ?? '',
      modeloNegocio: json['modelo_negocio'] ?? '',
      configuracion: json['configuracion'] ?? {},
      modulosActivos: List<String>.from(json['modulos_activos'] ?? []),
    );
  }
}


