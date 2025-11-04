class AppConfig {
  // PostgreSQL Configuration (para backend)
  static const String dbHost = 'localhost'; // Cambiar por URL de PostgreSQL en producción
  static const int dbPort = 5432;
  static const String dbName = 'multinegocio';
  
  // Colores
  static const primaryColor = 0xFF2563EB;
  static const secondaryColor = 0xFF10B981;
  static const accentColor = 0xFFF59E0B;
  static const errorColor = 0xFFEF4444;
  static const backgroundColor = 0xFFF9FAFB;

  // Textos
  static const appName = 'Sistema Multi-Negocio';
  static const version = '1.0.0';

  // API Endpoints
  static const apiSunat = 'https://api.sunat.gob.pe/v1';
  static const apiYape = 'https://api.yape.com.pe/v1';
}
