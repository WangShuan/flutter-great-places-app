import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_places.dart';

import './place_detail_screen.dart';
import './add_place_screen.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Places'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AddPlaceScreen.routeName);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: FutureBuilder(
        future: Provider.of<UserPlaces>(context, listen: false).fetchAndSetPlaces(),
        builder: (context, snapshot) => snapshot.connectionState == ConnectionState.waiting
            ? const LinearProgressIndicator()
            : Consumer<UserPlaces>(
                builder: (context, userPlaces, child) => userPlaces.items.isEmpty
                    ? child
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          childAspectRatio: 18 / 22,
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: userPlaces.items.length,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              PlaceDetailScreen.routeName,
                              arguments: {
                                'id': userPlaces.items[index].id,
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Card(
                            elevation: 5,
                            color: Theme.of(context).primaryColorLight,
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(6),
                                    topRight: Radius.circular(6),
                                  ),
                                  child: Hero(
                                    tag: userPlaces.items[index].id,
                                    child: Image.file(
                                      userPlaces.items[index].image,
                                      width: 200,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          userPlaces.items[index].title,
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(top: 5),
                                          // height: 40,
                                          alignment: Alignment.center,
                                          child: Text(
                                            userPlaces.items[index].location.address,
                                            style: const TextStyle(
                                              letterSpacing: 1,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('-尚未擁有任何地點-'),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AddPlaceScreen.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(90, 30),
                        ),
                        child: const Text('添加地點'),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
