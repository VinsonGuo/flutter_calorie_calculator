import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../provider/app_provider.dart';
import '../widget/home_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker picker = ImagePicker();
  late AppProvider provider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.fetchResults();
    });
    provider = context.read();
  }

  @override
  Widget build(BuildContext context) {
    final results = context.select((AppProvider value) => value.results);
    final isLoading = context.select((AppProvider value) => value.isLoading);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera);
                          if (image != null) {
                            final dateTime = DateTime.now();
                            var uint8list = await image.readAsBytes();
                            final imagePath =
                                await provider.copyImage(dateTime, uint8list);
                            provider.generateResult(
                                dateTime, uint8list, imagePath);
                          }
                        },
                        icon: Icon(Icons.photo_camera),
                        label: Text('Scan Food')),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: FilledButton.tonalIcon(
                        onPressed: () async {
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            final dateTime = DateTime.now();
                            var uint8list = await image.readAsBytes();
                            final imagePath =
                                await provider.copyImage(dateTime, uint8list);
                            provider.generateResult(
                                dateTime, uint8list, imagePath);
                          }
                        },
                        icon: Icon(Icons.add_photo_alternate),
                        label: Text('Upload Photo')),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(itemBuilder: (_, index) {
                  final item = results[index];
                  return HomeListTile(item: item);
                }, itemCount: results.length,),
              ),
            ],
          ),
          if (isLoading)
            Container(
              alignment: Alignment.center,
              color: Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer
                  .withAlpha(100),
              child: LoadingAnimationWidget.stretchedDots(
                color: Theme.of(context).colorScheme.primary,
                size: 60,
              ),
            ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}