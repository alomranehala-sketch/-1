import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  // Center on Amman, Jordan
  static const LatLng _ammanCenter = LatLng(31.9539, 35.9106);

  // Jordanian hospitals with real coordinates
  final List<_Hospital> _hospitals = const [
    _Hospital('مستشفى الجامعة الأردنية', LatLng(32.0194, 35.8744)),
    _Hospital('مستشفى الملك حسين الطبي', LatLng(31.9773, 35.8639)),
    _Hospital('مستشفى البشير', LatLng(31.9500, 35.9350)),
    _Hospital('مستشفى الأمير حمزة', LatLng(31.9980, 35.8700)),
    _Hospital('المركز العربي الطبي', LatLng(31.9620, 35.8570)),
    _Hospital('مستشفى الاستقلال', LatLng(31.9700, 35.9400)),
    _Hospital('مستشفى الخالدي', LatLng(31.9530, 35.8900)),
    _Hospital('مستشفى ابن الهيثم', LatLng(31.9630, 35.9050)),
    _Hospital('مستشفى الإسراء', LatLng(31.9420, 35.8700)),
    _Hospital('مستشفى الأردن', LatLng(31.9580, 35.8650)),
  ];

  Set<Marker> get _markers {
    return _hospitals.map((h) {
      return Marker(
        markerId: MarkerId(h.name),
        position: h.location,
        infoWindow: InfoWindow(title: h.name, snippet: 'اضغط للتفاصيل'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).toSet();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المستشفيات القريبة',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF006F3E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _ammanCenter,
              zoom: 12.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          // Hospital count badge
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF006F3E),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(64),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '🏥 ${_hospitals.length} مستشفى',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006F3E),
        onPressed: () {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_ammanCenter, 12.0),
          );
        },
        child: const Icon(Icons.center_focus_strong, color: Colors.white),
      ),
    );
  }
}

class _Hospital {
  final String name;
  final LatLng location;
  const _Hospital(this.name, this.location);
}
