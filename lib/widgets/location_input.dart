import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../screens/map_screen.dart';

import '../helpers/location_helper.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectLocation;
  const LocationInput(this.onSelectLocation, {Key key}) : super(key: key);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String _previewImgUrl;
  String _address;

  void showPreview(lat, lng) async {
    final staticMapImgUrl = LocationHelper.locationPreviewImg(
      long: lng,
      lat: lat,
    );
    final address = await LocationHelper.getAddressByLatLng(lat, lng);
    setState(() {
      _previewImgUrl = staticMapImgUrl;
      _address = address;
    });
  }

  Future<void> _getUserLocation() async {
    try {
      final locData = await Location().getLocation();
      showPreview(locData.latitude, locData.longitude);
      widget.onSelectLocation(locData.latitude, locData.longitude);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('無法取得當前位置。')),
      );
      return;
    }
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedLocation = await Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => const MapScreen(
        isSelecting: true,
      ),
    ));
    if (selectedLocation == null) {
      return;
    }
    showPreview(selectedLocation.latitude, selectedLocation.longitude);
    widget.onSelectLocation(selectedLocation.latitude, selectedLocation.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
            border: Border.all(
              color: Theme.of(context).colorScheme.secondary,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: _previewImgUrl == null
              ? const Text(
                  '尚未選取地點',
                  textAlign: TextAlign.center,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/images/location-placeholder.gif',
                    image: _previewImgUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
        ),
        const SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: _selectOnMap,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              label: const Text('選取地點'),
              icon: const Icon(Icons.map_outlined),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '或',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            ElevatedButton.icon(
              onPressed: _getUserLocation,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              label: const Text('我的地點'),
              icon: const Icon(Icons.location_on),
            ),
          ],
        ),
        if (_address != null) Text(_address)
      ],
    );
  }
}
