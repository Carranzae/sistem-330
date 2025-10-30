class Business {
  final String id;
  final String userId;
  final String nombreComercial;
  final String? ruc;
  final String? logoUrl;
  final String pais;
  final String departamento;
  final String provincia;
  final String distrito;
  final String direccionCompleta;
  final String moneda;
  final String rubro;
  final String modeloNegocio;
  final Map<String, dynamic> configuracion;
  final Map<String, dynamic> modulosActivos;

  Business({
    required this.id,
    required this.userId,
    required this.nombreComercial,
    this.ruc,
    this.logoUrl,
    required this.pais,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.direccionCompleta,
    required this.moneda,
    required this.rubro,
    required this.modeloNegocio,
    required this.configuracion,
    required this.modulosActivos,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      userId: json['user_id'],
      nombreComercial: json['nombre_comercial'],
      ruc: json['ruc'],
      logoUrl: json['logo_url'],
      pais: json['pais'],
      departamento: json['departamento'],
      provincia: json['provincia'],
      distrito: json['distrito'],
      direccionCompleta: json['direccion_completa'],
      moneda: json['moneda'],
      rubro: json['rubro'],
      modeloNegocio: json['modelo_negocio'],
      configuracion: json['configuracion'],
      modulosActivos: json['modulos_activos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre_comercial': nombreComercial,
      'ruc': ruc,
      'logo_url': logoUrl,
      'pais': pais,
      'departamento': departamento,
      'provincia': provincia,
      'distrito': distrito,
      'direccion_completa': direccionCompleta,
      'moneda': moneda,
      'rubro': rubro,
      'modelo_negocio': modeloNegocio,
      'configuracion': configuracion,
      'modulos_activos': modulosActivos,
    };
  }
}
