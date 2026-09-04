import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  MaplibreMapController? _controller;

  void _onMapCreated(MaplibreMapController controller) {
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver GPS & Map (MapLibre)')),
      body: MaplibreMap(
        styleString: 'https://demotiles.maplibre.org/style.json',
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(10.7769, 106.7009), // Ho Chi Minh City Default
          zoom: 14.0,
        ),
      ),
    );
  }
}
