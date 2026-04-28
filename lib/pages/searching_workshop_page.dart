import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme.dart';

class SearchingWorkshopPage extends StatefulWidget {
  const SearchingWorkshopPage({super.key});

  @override
  State<SearchingWorkshopPage> createState() => _SearchingWorkshopPageState();
}

class _SearchingWorkshopPageState extends State<SearchingWorkshopPage> {
  String _status = "Analizando situación con Inteligencia Artificial...";
  int _step = 0;
  int? _idIncidente;
  String _categoria = "Batería";
  String _urgencia = "Alta";
  bool _argsLoaded = false;
  Timer? _pollingTimer;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _startRealFlow();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _idIncidente = args['id_incidente'];
        _categoria = args['categoria'] ?? 'Batería';
        _urgencia = args['urgencia'] ?? 'Alta';
      }
      _argsLoaded = true;
    }
  }

  void _startRealFlow() async {
    // 1. Diagnóstico de IA
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _status = "Diagnóstico: Problema de $_categoria detectado.\nPrioridad asignada: $_urgencia";
        _step = 1;
      });
    }

    // 2. Búsqueda de Talleres
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _status = "Contactando al especialista más rápido...";
        _step = 2;
      });
    }

    // 3. Polling Real del Estado del Incidente
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkIncidentStatus();
    });
  }

  Future<void> _checkIncidentStatus() async {
    if (_idIncidente == null) return;

    try {
      final response = await _apiService.getIncidente(_idIncidente!);
      
      if (response.statusCode == 200) {
        final data = response.data;
        final estado = data['estado_solicitud'] ?? data['estado'];
        
        // Si ya fue asignado, cambiar de pantalla
        if (estado == 'Aceptado' || estado == 'Atendido' || estado == 'En Camino') {
          _pollingTimer?.cancel();
          if (mounted) {
            Navigator.pushReplacementNamed(
              context, 
              '/tracking',
              arguments: {'id_incidente': _idIncidente},
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error verificando estado del incidente: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Animation / Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryBlue,
                        strokeWidth: 3,
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.primaryBlue,
                      size: 50,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              
              Text(
                "Tranquilo, estamos contigo.",
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _status,
                  key: ValueKey<String>(_status),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: _step == 1 ? AppTheme.secondaryGreen : AppTheme.textGray,
                    fontWeight: _step == 1 ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
