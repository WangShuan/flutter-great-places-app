import 'dart:io';

import 'package:flutter/material.dart';

class PlaceLocation {
  final double lng; // longitude 經度
  final double lat; // latitude 緯度
  final String address;

  const PlaceLocation({
    this.address,
    @required this.lat,
    @required this.lng,
  });
}

class Place {
  final String id;
  final String title;
  final String description;
  final PlaceLocation location;
  final File image;

  const Place({
    @required this.id,
    @required this.image,
    @required this.location,
    @required this.title,
    @required this.description,
  });
}
