import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:provider/provider.dart';

import './providers/user_places.dart';

import './screens/places_list_screen.dart';
import './screens/place_detail_screen.dart';
import './screens/add_place_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  await FlutterConfig.loadEnvVariables();

  runApp(const MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserPlaces(),
      child: MaterialApp(
        title: 'Great Places',
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 84, 136, 175),
          primaryColorLight: const Color.fromARGB(255, 180, 209, 231),
          primaryColorDark: const Color.fromARGB(255, 28, 57, 79),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(const Color.fromARGB(255, 84, 136, 175)),
            errorColor: const Color.fromARGB(255, 180, 78, 78),
          ).copyWith(
            secondary: const Color.fromARGB(255, 59, 159, 152),
          ),
          textTheme: const TextTheme(
            titleMedium: TextStyle(
              color: Color.fromARGB(255, 28, 57, 79),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.875,
            ),
          ).apply(
            bodyColor: const Color.fromARGB(255, 28, 57, 79),
            displayColor: const Color.fromARGB(255, 84, 136, 175),
          ),
        ),
        home: const PlacesListScreen(),
        routes: {
          AddPlaceScreen.routeName: (context) => const AddPlaceScreen(),
          PlaceDetailScreen.routeName: (context) => const PlaceDetailScreen(),
        },
      ),
    );
  }
}
