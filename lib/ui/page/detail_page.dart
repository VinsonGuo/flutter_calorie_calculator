import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calorie_calculator/model/models.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';

import '../../common/data.dart';
import '../../provider/app_provider.dart';

class DetailPage extends StatefulWidget {
  final CalculateResult result;
  const DetailPage({super.key, required this.result});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    final item = widget.result;
    return Scaffold(
      body: ListView(
        children: [
          Text(item.dateTime,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(item.suggestion),
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
          SfTreemap(
            dataCount: item.items.length,
            weightValueMapper: (int index) =>
                double.tryParse(item.items[index].calories.value) ?? 0.0,
            levels: [
              TreemapLevel(
                groupMapper: (int index) => item.items[index].name,
                labelBuilder: (BuildContext context, TreemapTile tile) {
                  return Text(
                    '${tile.group}\n${item.items[tile.indices.first].calories.value} ${item.items[tile.indices.first].calories.unit}',
                    textAlign: TextAlign.center,
                  );
                },
                colorValueMapper: (TreemapTile tile) => tile.weight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
