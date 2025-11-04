import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/product_model.dart';
import '../widgets/payment_method_selector.dart';
import '../widgets/shipping_address_form.dart';
import '../widgets/order_summary.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int currentStep = 0;
  String? selectedPaymentMethod;
  Map<String, dynamic> shippingAddress = {};
  List<CartItem> cartItems = [];
  bool isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    // Simulación de items del carrito
    cartItems = [
      CartItem(
        product: ProductModel(
          id: '1',
          name: 'Vestido Elegante Rosa',
          price: 89.99,
          description: 'Hermoso vestido elegante',
          imageUrl: 'https://via.placeholder.com/100x120/EC4899/FFFFFF?text=Vestido',
          sizes: ['S', 'M', 'L'],
          colors: ['Rosa', 'Negro'],
          collection: 'Primavera 2024',
          inStock: true,
          category: 'Vestidos',
        ),
        selectedSize: 'M',
        selectedColor: 'Rosa',
        quantity: 1,
      ),
    ];
  }

  double get subtotal {
    return cartItems.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double get shipping => 15.00;
  double get tax => subtotal * 0.18; // 18% IGV
  double get total => subtotal + shipping + tax;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Finalizar Compra',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Indicador de progreso
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Carrito', Icons.shopping_cart),
                Expanded(child: _buildStepLine(0)),
                _buildStepIndicator(1, 'Envío', Icons.local_shipping),
                Expanded(child: _buildStepLine(1)),
                _buildStepIndicator(2, 'Pago', Icons.payment),
                Expanded(child: _buildStepLine(2)),
                _buildStepIndicator(3, 'Confirmación', Icons.check_circle),
              ],
            ),
          ),
          
          // Contenido principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          
          // Botón de continuar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isProcessingPayment ? null : _handleContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isProcessingPayment
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(_getButtonText()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon) {
    final isActive = currentStep >= step;
    final isCompleted = currentStep > step;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEC4899) : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            isCompleted ? Icons.check : icon,
            color: isActive ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFFEC4899) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isCompleted = currentStep > step;
    return Container(
      height: 2,
      color: isCompleted ? const Color(0xFFEC4899) : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 0:
        return _buildCartStep();
      case 1:
        return _buildShippingStep();
      case 2:
        return _buildPaymentStep();
      case 3:
        return _buildConfirmationStep();
      default:
        return _buildCartStep();
    }
  }

  Widget _buildCartStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen del Pedido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...cartItems.map((item) => _buildCartItemCard(item)).toList(),
        const SizedBox(height: 16),
        OrderSummary(
          subtotal: subtotal,
          shipping: shipping,
          tax: tax,
          total: total,
        ),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.product.imageUrl,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Talla: ${item.selectedSize} | Color: ${item.selectedColor}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cantidad: ${item.quantity}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFFEC4899),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingStep() {
    return ShippingAddressForm(
      onAddressChanged: (address) {
        setState(() {
          shippingAddress = address;
        });
      },
    );
  }

  Widget _buildPaymentStep() {
    return PaymentMethodSelector(
      selectedMethod: selectedPaymentMethod,
      onMethodSelected: (method) {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 80,
        ),
        const SizedBox(height: 16),
        const Text(
          '¡Pedido Confirmado!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tu pedido #12345 ha sido procesado exitosamente',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Número de pedido:'),
                    const Text(
                      '#12345',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tiempo estimado:'),
                    const Text(
                      '3-5 días hábiles',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total pagado:'),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonText() {
    switch (currentStep) {
      case 0:
        return 'Continuar al Envío';
      case 1:
        return 'Continuar al Pago';
      case 2:
        return 'Procesar Pago';
      case 3:
        return 'Volver al Inicio';
      default:
        return 'Continuar';
    }
  }

  void _handleContinue() async {
    if (currentStep < 3) {
      if (currentStep == 2) {
        // Procesar pago
        setState(() {
          isProcessingPayment = true;
        });
        
        await Future.delayed(const Duration(seconds: 2)); // Simular procesamiento
        
        setState(() {
          isProcessingPayment = false;
        });
      }
      
      setState(() {
        currentStep++;
      });
    } else {
      // Volver al marketplace
      context.go('/ropa_calzado/marketplace');
    }
  }
}

class CartItem {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;

  CartItem({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    required this.quantity,
  });
}