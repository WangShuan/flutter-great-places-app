import 'package:flutter/material.dart';
import 'package:great_places_app/models/place.dart';
import 'package:great_places_app/providers/user_places.dart';
import 'package:great_places_app/screens/map_screen.dart';
import 'package:provider/provider.dart';

class PlaceDetailScreen extends StatelessWidget {
  static const routeName = '/place-detail';

  const PlaceDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routerArgs = ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final String id = routerArgs['id'];
    final Place place = Provider.of<UserPlaces>(context).findById(id);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 248, 248),
      appBar: AppBar(
        title: Text(place.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => MapScreen(
                initLocation: place.location,
              ),
            ),
          );
        },
        child: const Icon(Icons.location_on),
      ),
      body: Column(
        children: [
          Hero(
            tag: id,
            child: Image.file(place.image),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: Text(
              '地址: \n${place.location.address}\n\n簡介: \n${place.description}',
              style: const TextStyle(
                letterSpacing: 1.5,
                height: 1.75,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
