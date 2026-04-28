import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../theme.dart';
import '../services/api_service.dart';

class MechanicJobDetailsPage extends StatefulWidget {
  const MechanicJobDetailsPage({super.key});

  @override
  State<MechanicJobDetailsPage> createState() => _MechanicJobDetailsPageState();
}

class _MechanicJobDetailsPageState extends State<MechanicJobDetailsPage> {
  GoogleMapController? _mapController;
  LatLng _clientPosition = const LatLng(-16.5000, -68.1500); // Simulada
  bool _loadingLocation = true;
  String _currentState = "Asignado"; // Asignado, En camino, Atendiendo, Finalizado
  final ApiService _apiService = ApiService();
  bool _argsLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final double? lat = args['lat'];
        final double? lng = args['lng'];
        if (lat != null && lng != null) {
          _clientPosition = LatLng(lat, lng);
        }
      }
      _argsLoaded = true;
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    try {
      if (_clientPosition.latitude == -16.5000) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _clientPosition = LatLng(position.latitude + 0.01, position.longitude + 0.01);
            _loadingLocation = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  void _updateState(int? idIncidente) async {
    String nuevoEstado = "Asignado";
    if (_currentState == "Asignado") {
      nuevoEstado = "En camino";
    } else if (_currentState == "En camino") {
      nuevoEstado = "Atendiendo";
    } else if (_currentState == "Atendiendo") {
      nuevoEstado = "Finalizado";
    }

    try {
      if (idIncidente != null) {
        await _apiService.actualizarEstadoIncidente(idIncidente, nuevoEstado);
      }
    } catch (e) {
      debugPrint("Error al actualizar estado en el backend: $e");
    }

    setState(() {
      _currentState = nuevoEstado;
    });

    if (_currentState == "Finalizado") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Servicio finalizado exitosamente."),
          backgroundColor: AppTheme.secondaryGreen,
        )
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener argumentos si se pasaron
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final cliente = args?['cliente'] ?? "Carlos Mendoza";
    final vehiculo = args?['vehiculo'] ?? "Toyota Corolla (Blanco)";
    final problema = args?['problema'] ?? "Batería muerta / No arranca";
    final idIncidente = args?['id'] ?? "INC-104";

    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _clientPosition,
                zoom: 14.0,
              ),
              myLocationEnabled: true,
              zoomControlsEnabled: false,
              markers: {
                Marker(
                  markerId: const MarkerId('cliente_pos'),
                  position: _clientPosition,
                  infoWindow: InfoWindow(title: "Cliente: $cliente"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                )
              },
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),

          if (_loadingLocation)
            const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Tarjeta inferior de gestión
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppTheme.bgLight,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        idIncidente,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryBlue),
                      ),
                      _buildStatusBadge(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(cliente, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(vehiculo, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textGray)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.emergencyRed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(problema, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildActionButton(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    if (_currentState == "Asignado") {
      bgColor = AppTheme.primaryBlue.withOpacity(0.1);
      textColor = AppTheme.primaryBlue;
    } else if (_currentState == "En camino") {
      bgColor = AppTheme.accentYellow.withOpacity(0.1);
      textColor = AppTheme.accentYellow;
    } else {
      bgColor = AppTheme.secondaryGreen.withOpacity(0.1);
      textColor = AppTheme.secondaryGreen;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        _currentState,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildActionButton() {
    String label = "Confirmar / En camino";
    IconData icon = Icons.directions_car_rounded;
    Color btnColor = AppTheme.primaryBlue;

    if (_currentState == "En camino") {
      label = "Llegué / Atendiendo";
      icon = Icons.build_circle_rounded;
      btnColor = AppTheme.accentYellow;
    } else if (_currentState == "Atendiendo") {
      label = "Finalizar Servicio";
      icon = Icons.check_circle_rounded;
      btnColor = AppTheme.secondaryGreen;
    }

    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final int? idIncInt = args?['id_incidente'];

    return ElevatedButton.icon(
      onPressed: () => _updateState(idIncInt),
      icon: Icon(icon),
      label: Text(label, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
