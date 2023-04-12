import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:great_places_app/helpers/location_helper.dart';

import '../helpers/db_helper.dart';

import '../models/place.dart';

class UserPlaces with ChangeNotifier {
  List<Place> _items = [];

  List<Place> get items {
    return [..._items];
  }

  Place findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> addPlace(
      String title, String description, File packedImage, PlaceLocation packedLocation) async {
    final address = await LocationHelper.getAddressByLatLng(packedLocation.lat, packedLocation.lng);
    final newLocation = PlaceLocation(
      lat: packedLocation.lat,
      lng: packedLocation.lng,
      address: address,
    );
    final newPlace = Place(
      id: DateTime.now().toString(),
      image: packedImage,
      location: newLocation,
      title: title,
      description: description,
    );
    _items.insert(0, newPlace);
    notifyListeners();
    DBHelper.insert('user_places', {
      'id': newPlace.id,
      'image': newPlace.image.path,
      'title': newPlace.title,
      'description': newPlace.description,
      'loc_lat': newLocation.lat,
      'loc_lng': newLocation.lng,
      'address': newLocation.address
    });
  }

  Future<void> fetchAndSetPlaces() async {
    final dataList = await DBHelper.getTableData('user_places');
    _items = dataList
        .map((item) => Place(
              id: item['id'],
              image: File(item['image']),
              location: PlaceLocation(
                lat: item['loc_lat'],
                lng: item['loc_lng'],
                address: item['address'],
              ),
              title: item['title'],
              description: item['description'],
            ))
        .toList();
    notifyListeners();
  }
}
