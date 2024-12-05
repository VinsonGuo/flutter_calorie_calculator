import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

import '../../provider/app_provider.dart';

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
      // context.read<ChannelProvider>().getChannels();
    });
    provider = context.read();
  }

  @override
  Widget build(BuildContext context) {
    final result = context.select((AppProvider value) => value.calculateResult);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: FilledButton.tonalIcon(
                    onPressed: () async {
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        final dateTime = DateTime.now();
                        var uint8list = await image.readAsBytes();
                        final imagePath =
                            await provider.copyImage(dateTime, uint8list);
                        provider.generateResult(dateTime, uint8list, imagePath);
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
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        final dateTime = DateTime.now();
                        var uint8list = await image.readAsBytes();
                        final imagePath =
                            await provider.copyImage(dateTime, uint8list);
                        provider.generateResult(dateTime, uint8list, imagePath);
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
            child: ListView(
              children: [
                Builder(builder: (context) {
                  if (result.isSuccess()) {
                    final item = result.data!;
                    return ExpansionTile(
                      initiallyExpanded: true,
                      leading: Image.file(
                        File(item.imagePath),
                        width: 100,
                        height: 100,
                      ),
                      title: Text(
                          'Total Calories: ${item.nutrition.calories.value} ${item.nutrition.calories.unit}'),
                      subtitle:  Text(item.dateTime),
                      children: [
                        SingleChildScrollView(
                          scrollDirection:Axis.horizontal,
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(label: Text("Nutrition")),
                              DataColumn(label: Text("Value")),
                              DataColumn(label: Text("Unit")),
                            ],
                            rows: <DataRow>[
                              DataRow(cells: <DataCell>[
                                DataCell(Text("Carbs")),
                                DataCell(Text(item.nutrition.carbs.value)),
                                DataCell(Text(item.nutrition.carbs.unit)),
                              ]),
                              DataRow(cells: <DataCell>[
                                DataCell(Text("Fat")),
                                DataCell(Text(item.nutrition.fat.value)),
                                DataCell(Text(item.nutrition.fat.unit)),
                              ]),
                              DataRow(cells: <DataCell>[
                                DataCell(Text("Protein")),
                                DataCell(Text(item.nutrition.protein.value)),
                                DataCell(Text(item.nutrition.protein.unit)),
                              ]),
                              DataRow(cells: <DataCell>[
                                DataCell(Text("Fibers")),
                                DataCell(Text(item.nutrition.fibers.value)),
                                DataCell(Text(item.nutrition.fibers.unit)),
                              ]),
                            ],
                          ),
                        ),
                        SfTreemap(
                          dataCount: item.items.length,
                          weightValueMapper: (int index) =>
                              double.tryParse(
                                  item.items[index].calories.value) ??
                              0.0,
                          tooltipSettings: TreemapTooltipSettings(
                            color: Colors.white,
                            borderColor: Colors.black,
                            borderWidth: 1,
                          ),
                          levels: [
                            TreemapLevel(
                              groupMapper: (int index) =>
                                  item.items[index].name,
                              labelBuilder:
                                  (BuildContext context, TreemapTile tile) {
                                return Text(
                                  '${tile.group}\n${item.items[tile.indices.first].calories.value} ${item.items[tile.indices.first].calories.unit}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                  textAlign: TextAlign.center,
                                );
                              },
                              colorValueMapper: (TreemapTile tile) =>
                                  tile.weight.toInt(),
                            ),
                          ],
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const <DataColumn>[
                              DataColumn(label: Text("Name")),
                              DataColumn(label: Text("Calories (kcal)")),
                              DataColumn(label: Text("Quantity")),
                              DataColumn(label: Text("Unit")),
                            ],
                            rows: item.items
                                .map((e) => DataRow(cells: <DataCell>[
                                      DataCell(Text(e.name)),
                                      DataCell(Text(e.calories.value)),
                                      DataCell(Text(e.quantity)),
                                      DataCell(Text(e.unit)),
                                    ]))
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return ListTile(
                      title: Text(result.msg!),
                    );
                  }
                }),
              ],
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
