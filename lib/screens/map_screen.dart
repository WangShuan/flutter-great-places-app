import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/place.dart';

class MapScreen extends StatefulWidget {
  final PlaceLocation initLocation;
  final bool isSelecting;

  const MapScreen({
    Key key,
    this.initLocation = const PlaceLocation(
      lat: 25.10235351700014,
      lng: 121.54849200004878,
    ),
    this.isSelecting = false,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _markerLocation;
  void _selectedLocation(LatLng posi) {
    setState(() {
      _markerLocation = posi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地圖'),
        actions: [
          if (widget.isSelecting && _markerLocation != null)
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(_markerLocation);
              },
              icon: const Icon(Icons.check),
            )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.initLocation.lat, widget.initLocation.lng),
          zoom: 16,
        ),
        onTap: widget.isSelecting ? _selectedLocation : null,
        markers: (_markerLocation == null && widget.isSelecting)
            ? {}
            : {
                Marker(
                  markerId: const MarkerId('m1'),
                  position:
                      _markerLocation ?? LatLng(widget.initLocation.lat, widget.initLocation.lng),
                ),
              },
      ),
    );
  }
}
