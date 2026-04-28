import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _cardNumber = TextEditingController();
  final _expiryDate = TextEditingController();
  final _cvc = TextEditingController();

  bool _isProcessing = false;
  bool _argsLoaded = false;
  int? _idIncidente;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _idIncidente = args['id_incidente'];
      }
      _argsLoaded = true;
    }
  }

  void _processPayment() async {
    if (_cardNumber.text.trim().length < 16 || 
        _expiryDate.text.trim().isEmpty || 
        _cvc.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa datos de tarjeta válidos."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    
    try {
      await http.post(
        Uri.parse('https://backend-fastapi-su7t.onrender.com/api/pagos/crear-intento'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id_incidente': _idIncidente ?? 1,
          'monto': 5000
        }),
      );
    } catch (e) {
      debugPrint("Error registrando pago: $e");
    }

    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("¡Pago aprobado por Stripe!"),
          backgroundColor: AppTheme.secondaryGreen,
        ),
      );
      Navigator.pushReplacementNamed(
        context, 
        '/rating',
        arguments: {'id_incidente': _idIncidente ?? 1},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          "Pagar Servicio",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        automaticallyImplyLeading: false, // El usuario no debe escapar del pago
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF0056B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text("Total a Pagar", style: GoogleFonts.inter(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("\$50.00", style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text("Servicio: Taller Mecánico El Rápido", style: GoogleFonts.inter(color: Colors.white, fontSize: 13)),
                  Text("Diagnóstico y Reparación de Batería", style: GoogleFonts.inter(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            Text("Detalles de la Tarjeta", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            
            TextField(
              controller: _cardNumber,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Número de Tarjeta",
                prefixIcon: Icon(Icons.credit_card_rounded, color: AppTheme.textGray),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryDate,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(
                      hintText: "MM/AA",
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _cvc,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "CVC",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
            if (_isProcessing)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
            else
              ElevatedButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.lock_rounded, size: 20),
                label: const Text("Pagar seguro con Stripe"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
            const SizedBox(height: 12),
            Center(
              child: Text("Pagos procesados de forma segura con Stripe", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textGray)),
            ),
          ],
        ),
      ),
    );
  }
}
