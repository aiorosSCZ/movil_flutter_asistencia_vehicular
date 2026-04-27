import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class MechanicHistoryPage extends StatefulWidget {
  const MechanicHistoryPage({super.key});

  @override
  State<MechanicHistoryPage> createState() => _MechanicHistoryPageState();
}

class _MechanicHistoryPageState extends State<MechanicHistoryPage> {
  // Datos simulados de historial para el técnico
  final List<Map<String, dynamic>> _history = [
    {
      "id": 1,
      "cliente": "Juan Perez",
      "servicio": "Cambio de llanta",
      "fecha": "25 Abr 2026",
      "monto": 150.00,
      "estado_pago": "Pagado con Stripe",
      "tipo": "Llantas"
    },
    {
      "id": 2,
      "cliente": "Maria Gomez",
      "servicio": "Recarga de batería",
      "fecha": "23 Abr 2026",
      "monto": 80.00,
      "estado_pago": "Pagado con Stripe",
      "tipo": "Eléctrico"
    },
    {
      "id": 3,
      "cliente": "Carlos Sosa",
      "servicio": "Revisión de frenos",
      "fecha": "20 Abr 2026",
      "monto": 220.00,
      "estado_pago": "Pagado con Stripe",
      "tipo": "Frenos"
    },
  ];

  Color _getCategoryColor(String type) {
    switch (type) {
      case 'Llantas':
        return Colors.orange.shade700;
      case 'Eléctrico':
        return Colors.blue.shade700;
      case 'Frenos':
        return Colors.red.shade700;
      default:
        return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text(
          "Historial de Trabajos",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
      body: _history.isEmpty
          ? Center(
              child: Text(
                "No tienes servicios completados aún.",
                style: GoogleFonts.inter(color: AppTheme.textGray, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(item['tipo']).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.build_circle_rounded,
                          color: _getCategoryColor(item['tipo']),
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['servicio'],
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Cliente: ${item['cliente']}",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Fecha: ${item['fecha']}",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textGray.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${item['monto'].toStringAsFixed(2)} Bs.",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Pagado",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
