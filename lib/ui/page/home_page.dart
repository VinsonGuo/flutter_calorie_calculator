import 'package:flutter/material.dart';
import 'package:flutter_calorie_calculator/model/models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
                        provider.generateResult(await image.readAsBytes());
                      }
                    },
                    icon: Icon(Icons.photo_camera),
                    label: Text('take picture')),
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
                        provider.generateResult(await image.readAsBytes());
                      }
                    },
                    icon: Icon(Icons.add_photo_alternate),
                    label: Text('Gallery')),
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
                      title: Text(
                          'Total Calories: ${item.nutrition.calories.value} ${item.nutrition.calories.unit}'),
                      subtitle: Row(
                        children: [
                          Expanded(
                              child: Text(
                                  'carbs\n${item.nutrition.carbs.value} ${item.nutrition.carbs.unit}')),
                          Expanded(
                              child: Text(
                                  'fat\n${item.nutrition.fat.value} ${item.nutrition.fat.unit}')),
                          Expanded(
                              child: Text(
                                  'protein\n${item.nutrition.protein.value} ${item.nutrition.protein.unit}')),
                          Expanded(
                              child: Text(
                                  'fibers\n${item.nutrition.fibers.value} ${item.nutrition.fibers.unit}')),
                        ],
                      ),
                      children: [
                        SfCircularChart(
                          legend: Legend(isVisible: true),
                          series: <PieSeries<CalculateItem, String>>[
                            PieSeries<CalculateItem, String>(
                              dataSource: item.items,
                              xValueMapper: (CalculateItem data, _) =>
                                  data.name,
                              yValueMapper: (CalculateItem data, _) =>
                                  num.tryParse(data.calories.value) ?? 0,
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true),
                            ),
                          ],
                        )
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
