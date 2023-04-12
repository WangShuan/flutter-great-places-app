import 'dart:convert';

import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;

final googleApiKey = FlutterConfig.get('GOOGLE_API_KEY');

class LocationHelper {
  static String locationPreviewImg({double long, double lat}) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&scale=2&zoom=15&size=400x300&key=$googleApiKey&markers=color:red%7Clabel:%7C$lat%2C$long';
  }

  static Future<String> getAddressByLatLng(double lat, double lng) async {
    final url = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      "latlng": "$lat,$lng",
      "key": googleApiKey,
      "language": "zh-TW",
    });
    final res = await http.get(url);
    return json.decode(res.body)['results'][0]['formatted_address'];
  }
}
