import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cochons_dafrik_mobile/core/themes/app_color.dart';
import 'package:cochons_dafrik_mobile/presentation/common/evelatedButton_common.dart';

/// Position par défaut : Plateau, Abidjan.
const LatLng _defaultCenter = LatLng(5.3197, -4.0167);

/// Permet au client de choisir sa position de livraison : soit sa position GPS
/// actuelle, soit un point choisi librement sur la carte (le repère reste au
/// centre de l'écran, on déplace la carte en dessous).
class LocationPickerPage extends StatefulWidget {
  final LatLng? initialPosition;

  const LocationPickerPage({super.key, this.initialPosition});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  late LatLng _selectedPosition;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition ?? _defaultCenter;
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Le service de localisation est désactivé.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Permission de localisation refusée.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          "Permission de localisation refusée définitivement. Autorisez-la dans les réglages.",
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPosition = latLng;
      });
      _mapController.move(latLng, 16);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: CdaColors.rouge,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CdaColors.creme,
      appBar: AppBar(
        backgroundColor: CdaColors.vertForet,
        foregroundColor: Colors.white,
        title: Text(
          "Position de livraison",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPosition,
              initialZoom: 15,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedPosition = camera.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cochons.dafrik',
              ),
            ],
          ),
          // Repère fixe au centre de l'écran : le client déplace la carte
          // en dessous, ce qui évite d'avoir à gérer le tap précis d'un marqueur.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(
                  LucideIcons.mapPin,
                  color: CdaColors.rouge,
                  size: 44,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'locate-me',
              backgroundColor: Colors.white,
              foregroundColor: CdaColors.vertForet,
              onPressed: _isLocating ? null : _useCurrentLocation,
              child: _isLocating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(LucideIcons.locate),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    "${_selectedPosition.latitude.toStringAsFixed(5)}, ${_selectedPosition.longitude.toStringAsFixed(5)}",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: CdaColors.gris,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                CdaElevatedButton(
                  text: "Confirmer cette position",
                  onPressed: () => Navigator.of(context).pop(_selectedPosition),
                  backgroundColor: CdaColors.vertForet,
                  foregroundColor: Colors.white,
                  height: 52,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
