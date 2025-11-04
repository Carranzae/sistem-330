import 'package:flutter/material.dart';

class PaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodSelector({
    Key? key,
    required this.selectedMethod,
    required this.onMethodSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de Pago',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Billeteras digitales
        const Text(
          'Billeteras Digitales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildPaymentOption(
          'yape',
          'Yape',
          'assets/images/yape_logo.png',
          Icons.phone_android,
          'Pago instantáneo con tu celular',
        ),
        
        _buildPaymentOption(
          'plin',
          'Plin',
          'assets/images/plin_logo.png',
          Icons.phone_android,
          'Transferencia inmediata',
        ),
        
        _buildPaymentOption(
          'tunki',
          'Tunki',
          'assets/images/tunki_logo.png',
          Icons.account_balance_wallet,
          'Pago seguro con Tunki',
        ),
        
        const SizedBox(height: 24),
        
        // Tarjetas
        const Text(
          'Tarjetas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildPaymentOption(
          'visa',
          'Tarjeta Visa',
          'assets/images/visa_logo.png',
          Icons.credit_card,
          'Débito o crédito',
        ),
        
        _buildPaymentOption(
          'mastercard',
          'Tarjeta Mastercard',
          'assets/images/mastercard_logo.png',
          Icons.credit_card,
          'Débito o crédito',
        ),
        
        _buildPaymentOption(
          'amex',
          'American Express',
          'assets/images/amex_logo.png',
          Icons.credit_card,
          'Tarjeta de crédito',
        ),
        
        const SizedBox(height: 24),
        
        // Otros métodos
        const Text(
          'Otros Métodos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        _buildPaymentOption(
          'paypal',
          'PayPal',
          'assets/images/paypal_logo.png',
          Icons.account_balance,
          'Pago internacional seguro',
        ),
        
        _buildPaymentOption(
          'cash',
          'Pago Contra Entrega',
          null,
          Icons.money,
          'Paga cuando recibas tu pedido',
        ),
        
        // Información de seguridad
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.security,
                color: Colors.green,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pago 100% Seguro',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Tus datos están protegidos con encriptación SSL',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    String value,
    String title,
    String? logoPath,
    IconData fallbackIcon,
    String description,
  ) {
    final isSelected = selectedMethod == value;
    
    return GestureDetector(
      onTap: () => onMethodSelected(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEC4899).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFEC4899) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Logo o icono
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: logoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        logoPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            fallbackIcon,
                            color: Colors.grey[600],
                            size: 20,
                          );
                        },
                      ),
                    )
                  : Icon(
                      fallbackIcon,
                      color: Colors.grey[600],
                      size: 20,
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Información del método de pago
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isSelected ? const Color(0xFFEC4899) : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicador de selección
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFEC4899) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFFEC4899) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}