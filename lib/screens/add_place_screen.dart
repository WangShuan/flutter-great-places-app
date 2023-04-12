import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_places.dart';

import '../models/place.dart';

import '../widgets/image_input.dart';
import '../widgets/location_input.dart';

class AddPlaceScreen extends StatefulWidget {
  static const routeName = '/add-place';
  const AddPlaceScreen({Key key}) : super(key: key);

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File _packedImage;
  PlaceLocation _packedLocation;
  void _selectImage(File packedImage) {
    _packedImage = packedImage;
  }

  void _selectLocation(double lat, double lng) {
    _packedLocation = PlaceLocation(lat: lat, lng: lng);
  }

  void savePlace() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('標題不得為空。')),
      );
      return;
    }
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('簡介不得為空。')),
      );
      return;
    }
    if (_packedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('圖片不得為空。')),
      );
      return;
    }
    if (_packedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('地點不得為空。')),
      );
      return;
    }
    Provider.of<UserPlaces>(context, listen: false).addPlace(
      _titleController.text,
      _descriptionController.text,
      _packedImage,
      _packedLocation,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增地點'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: '標題',
                      ),
                      controller: _titleController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextField(
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '簡介',
                      ),
                      controller: _descriptionController,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ImageInput(_selectImage),
                    const SizedBox(
                      height: 20,
                    ),
                    LocationInput(_selectLocation),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: savePlace,
              label: const Text('新增地點'),
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
