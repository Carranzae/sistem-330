import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedCountry = 'Perú';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final isDesktop = constraints.maxWidth >= 1024;

          // Layout para móvil (vertical)
          if (isMobile) {
            return _buildMobileLayout(context);
          }
          
          // Layout para tablet (centrado con más espacio)
          if (isTablet) {
            return _buildTabletLayout(context, constraints);
          }
          
          // Layout para desktop (horizontal o centrado)
          return _buildDesktopLayout(context, constraints);
        },
      ),
    );
  }

  // Layout móvil - vertical con imagen arriba y bottom sheet abajo
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo superior - ocupa más espacio
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  flex: 3, // Más espacio para la imagen en móvil
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.amber.shade100,
                          Colors.orange.shade50,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Selector de país en la esquina superior izquierda
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildCountrySelector(),
                          ),
                        ),
                        // Imagen de la mujer sonriente - perfectamente centrada
                        Center(
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            alignment: Alignment.center,
                            child: _buildLoginImage(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom sheet blanco con esquinas redondeadas arriba
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomSheet(context, isCompact: true),
          ),
        ],
      ),
    );
  }

  // Layout tablet - centrado con imagen y contenido
  Widget _buildTabletLayout(BuildContext context, BoxConstraints constraints) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            margin: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Imagen lado izquierdo
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                    child: _buildLoginImage(size: 150),
                  ),
                ),
                // Contenido lado derecho
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: _buildContent(context, isDesktop: false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Layout desktop - vertical con imagen arriba y contenido abajo - ELEGANTE
  Widget _buildDesktopLayout(BuildContext context, BoxConstraints constraints) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Sección superior con imagen centrada - elegante
          Expanded(
            flex: 6,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFFFBF0), // Amarillo muy claro
                    const Color(0xFFFFF9E6), // Amarillo claro
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Imagen de la mujer centrada con efecto elegante
                  Center(
                    child: Container(
                      width: constraints.maxWidth * 0.32,
                      height: constraints.maxHeight * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildLoginImage(),
                      ),
                    ),
                  ),
                  // Selector de país en la esquina superior izquierda
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: _buildCountrySelector(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sección inferior con contenido blanco - elegante
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.55),
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
                  child: _buildContent(context, isDesktop: true),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bottom sheet para móvil
  Widget _buildBottomSheet(BuildContext context, {required bool isCompact}) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.45, // Ocupa aproximadamente 45% de la pantalla
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contenido (título y descripción) con scroll si es necesario
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24.0,
                32.0,
                24.0,
                16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título
                  const Text(
                    'Administra tu negocio fácil y seguro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Descripción
                  const Text(
                    'Lleva el control de tus ventas, deudas e inventario sin estrés, ni complicaciones.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Botones al pie - diseño elegante
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Botón "Empezar" - elegante
                ElevatedButton(
                  onPressed: () {
                    context.push('/onboarding');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.3),
                  ),
                  child: const Text(
                    'Empezar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Botón "Ya tengo una cuenta" - elegante
                OutlinedButton(
                  onPressed: () {
                    _showLoginDialog(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Ya tengo una cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Contenido común (título, descripción, botones) - ELEGANTE
  Widget _buildContent(BuildContext context, {bool isDesktop = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Título - elegante y sofisticado
        Text(
          'Administra tu negocio fácil y seguro',
          style: TextStyle(
            fontSize: isDesktop ? 42 : 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937), // Gris oscuro elegante
            height: 1.3,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 24 : 16),
        // Descripción - elegante
        Text(
          'Lleva el control de tus ventas, deudas e inventario sin estrés, ni complicaciones.',
          style: TextStyle(
            fontSize: isDesktop ? 19 : 16,
            color: const Color(0xFF6B7280), // Gris medio elegante
            height: 1.6,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 48 : 32),
        // Botón "Empezar" - elegante y sofisticado
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              context.push('/onboarding');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, isDesktop ? 60 : 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: Text(
              'Empezar',
              style: TextStyle(
                fontSize: isDesktop ? 18 : 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        SizedBox(height: isDesktop ? 18 : 16),
        // Botón "Ya tengo una cuenta" - elegante
        OutlinedButton(
          onPressed: () {
            _showLoginDialog(context);
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2563EB),
            side: const BorderSide(color: Color(0xFF2563EB), width: 2.5),
            minimumSize: Size(double.infinity, isDesktop ? 60 : 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: Text(
            'Ya tengo una cuenta',
            style: TextStyle(
              fontSize: isDesktop ? 18 : 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // Selector de país - elegante
  Widget _buildCountrySelector() {
    return GestureDetector(
      onTap: () {
        // Mostrar selector de país
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Seleccionar país',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Text('🇵🇪', style: TextStyle(fontSize: 24)),
                  title: const Text('Perú'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    setState(() => _selectedCountry = 'Perú');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Text('🇨🇱', style: TextStyle(fontSize: 24)),
                  title: const Text('Chile'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onTap: () {
                    setState(() => _selectedCountry = 'Chile');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🇵🇪', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              _selectedCountry,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 22,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para la imagen del login
  Widget _buildLoginImage({double? size}) {
    if (size != null) {
      // Para desktop/tablet con tamaño específico
      return Image.asset(
        'assets/images/login_woman.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.amber.shade200,
                  Colors.orange.shade100,
                ],
              ),
            ),
            child: Icon(
              Icons.person,
              size: size * 0.6,
              color: Colors.orange.shade300,
            ),
          );
        },
      );
    } else {
      // Para móvil - imagen centrada y bien ajustada
      return Image.asset(
        'assets/images/login_woman.png',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.amber.shade200,
                  Colors.orange.shade100,
                ],
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 200,
              color: Colors.orange,
            ),
          );
        },
      );
    }
  }

  // Diálogo de login
  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Sesión'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Lógica de login
              Navigator.pop(context);
              context.push('/dashboard');
            },
            child: const Text('Ingresar'),
          ),
        ],
      ),
    );
  }
}
