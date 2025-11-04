import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DigitalPaymentWidget extends StatefulWidget {
  final double amount;
  final Function(String paymentMethod, Map<String, dynamic> paymentData) onPaymentCompleted;

  const DigitalPaymentWidget({
    Key? key,
    required this.amount,
    required this.onPaymentCompleted,
  }) : super(key: key);

  @override
  State<DigitalPaymentWidget> createState() => _DigitalPaymentWidgetState();
}

class _DigitalPaymentWidgetState extends State<DigitalPaymentWidget>
    with TickerProviderStateMixin {
  String selectedPaymentMethod = '';
  bool isProcessing = false;
  bool showQRCode = false;
  String qrCodeData = '';
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();

  List<Map<String, dynamic>> digitalWallets = [
    {
      'id': 'yape',
      'name': 'Yape',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF722F8E),
      'description': 'Pago instantáneo con Yape',
      'requiresPhone': true,
    },
    {
      'id': 'plin',
      'name': 'Plin',
      'icon': Icons.payment,
      'color': Color(0xFF00BCD4),
      'description': 'Transferencia con Plin',
      'requiresPhone': true,
    },
    {
      'id': 'tunki',
      'name': 'Tunki',
      'icon': Icons.wallet,
      'color': Color(0xFFFF5722),
      'description': 'Pago con Tunki',
      'requiresPhone': true,
    },
    {
      'id': 'lukita',
      'name': 'Lukita',
      'icon': Icons.account_balance,
      'color': Color(0xFF4CAF50),
      'description': 'Transferencia Lukita',
      'requiresPhone': true,
    },
  ];

  List<Map<String, dynamic>> cardTypes = [
    {
      'id': 'visa',
      'name': 'Visa',
      'icon': Icons.credit_card,
      'color': Color(0xFF1A1F71),
    },
    {
      'id': 'mastercard',
      'name': 'Mastercard',
      'icon': Icons.credit_card,
      'color': Color(0xFFEB001B),
    },
    {
      'id': 'amex',
      'name': 'American Express',
      'icon': Icons.credit_card,
      'color': Color(0xFF006FCF),
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildPaymentMethods(),
          if (selectedPaymentMethod.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildPaymentForm(),
          ],
          if (showQRCode) ...[
            const SizedBox(height: 20),
            _buildQRCodeSection(),
          ],
          if (isProcessing) ...[
            const SizedBox(height: 20),
            _buildProcessingIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.payment,
          color: Color(0xFFEC4899),
          size: 24,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Métodos de Pago',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Total: S/ ${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security,
                size: 16,
                color: const Color(0xFFEC4899),
              ),
              const SizedBox(width: 4),
              const Text(
                'Seguro',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEC4899),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Billeteras Digitales',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: digitalWallets.length,
          itemBuilder: (context, index) {
            final wallet = digitalWallets[index];
            final isSelected = selectedPaymentMethod == wallet['id'];
            
            return GestureDetector(
              onTap: () => _selectPaymentMethod(wallet['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? wallet['color'].withOpacity(0.1)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? wallet['color']
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: wallet['color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        wallet['icon'],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        wallet['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? wallet['color']
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Tarjetas de Crédito/Débito',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: cardTypes.map((card) {
            final isSelected = selectedPaymentMethod == card['id'];
            
            return Expanded(
              child: GestureDetector(
                onTap: () => _selectPaymentMethod(card['id']),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? card['color'].withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? card['color']
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        card['icon'],
                        color: card['color'],
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        card['name'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? card['color']
                              : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPaymentForm() {
    if (digitalWallets.any((w) => w['id'] == selectedPaymentMethod)) {
      return _buildDigitalWalletForm();
    } else if (cardTypes.any((c) => c['id'] == selectedPaymentMethod)) {
      return _buildCardForm();
    }
    return Container();
  }

  Widget _buildDigitalWalletForm() {
    final wallet = digitalWallets.firstWhere((w) => w['id'] == selectedPaymentMethod);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: wallet['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: wallet['color'].withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                wallet['icon'],
                color: wallet['color'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pago con ${wallet['name']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: wallet['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (wallet['requiresPhone']) ...[
            const Text(
              'Número de teléfono',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: InputDecoration(
                hintText: '9XXXXXXXX',
                prefixText: '+51 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: wallet['color']),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _phoneController.text.length == 9 
                  ? () => _processDigitalWalletPayment(wallet)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: wallet['color'],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Generar QR - S/ ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardForm() {
    final card = cardTypes.firstWhere((c) => c['id'] == selectedPaymentMethod);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: card['color'].withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                card['icon'],
                color: card['color'],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Pago con ${card['name']}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: card['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Número de tarjeta',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            decoration: InputDecoration(
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: card['color']),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha de vencimiento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      decoration: InputDecoration(
                        hintText: 'MM/AA',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: card['color']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CVV',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: InputDecoration(
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: card['color']),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nombre del titular',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cardHolderController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'NOMBRE APELLIDO',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: card['color']),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCardFormValid() 
                  ? () => _processCardPayment(card)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: card['color'],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Pagar S/ ${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          const Text(
            'Escanea el código QR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEC4899), width: 2),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code,
                          size: 80,
                          color: Color(0xFFEC4899),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Código QR',
                          style: TextStyle(
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Monto: S/ ${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Abre tu app de billetera digital y escanea este código',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showQRCode = false;
                      selectedPaymentMethod = '';
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _simulatePaymentSuccess(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                  ),
                  child: const Text(
                    'Simular Pago',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: const Column(
        children: [
          CircularProgressIndicator(
            color: Color(0xFFEC4899),
          ),
          SizedBox(height: 16),
          Text(
            'Procesando pago...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Por favor espera mientras verificamos tu pago',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
      showQRCode = false;
    });
  }

  void _processDigitalWalletPayment(Map<String, dynamic> wallet) {
    setState(() {
      showQRCode = true;
      qrCodeData = 'payment:${wallet['id']}:${widget.amount}:${_phoneController.text}';
    });
  }

  void _processCardPayment(Map<String, dynamic> card) {
    setState(() {
      isProcessing = true;
    });

    // Simular procesamiento de pago
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
        
        widget.onPaymentCompleted(card['id'], {
          'cardNumber': _cardNumberController.text,
          'expiryDate': _expiryController.text,
          'cardHolder': _cardHolderController.text,
          'amount': widget.amount,
        });
      }
    });
  }

  void _simulatePaymentSuccess() {
    final wallet = digitalWallets.firstWhere((w) => w['id'] == selectedPaymentMethod);
    
    widget.onPaymentCompleted(wallet['id'], {
      'phone': _phoneController.text,
      'amount': widget.amount,
      'qrCode': qrCodeData,
    });
  }

  bool _isCardFormValid() {
    return _cardNumberController.text.replaceAll(' ', '').length >= 13 &&
           _expiryController.text.length == 5 &&
           _cvvController.text.length >= 3 &&
           _cardHolderController.text.isNotEmpty;
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }
    
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}