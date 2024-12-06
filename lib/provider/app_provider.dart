import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_calorie_calculator/common/data.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../common/logger.dart';
import '../db/db.dart';
import '../model/models.dart';

class AppProvider with ChangeNotifier {
  List<CalculateResult> results = [];
  bool isLoading = false;

  Future<String> copyImage(DateTime dateTime, Uint8List image) async {
    final dir = await getApplicationDocumentsDirectory();
    final destPath = dir.path + '/images/'+ dateTime.toIso8601String() + '.jpg';
    logger.i('destPath $destPath');
    final file = File(destPath);
    file.createSync(recursive: true);
    await file.writeAsBytes(image);
    return destPath;
  }

  Future<void> fetchResults() async {
    isLoading = true;
    notifyListeners();
    try {
      results = await CalorieDatabase.instance.fetchCalories();
    } catch (e) {
      logger.e('fetchResults error', error: e);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> generateResult(DateTime dateTime, Uint8List image, String imagePath) async {
    isLoading = true;
    notifyListeners();
    try {
      const prompt = ("""
Analyze this image to identify individual food items, clearly separating them with visual signals. For each identified item, provide the following information:

1. Name: Include the food ingredients item's name appended with a relevant emoji (e.g., "Apple 🍎").
2. Quantity: Estimate the quantity of the food item.
3. Unit: Specify the unit of measurement for the quantity only with "g" and "ml".
3. suggestion: Give suggestion of this meal.

Additionally, provide a detailed nutritional breakdown for the entire meal. 
Return the results as JSON, strictly adhering to this structure and do not include other content:
{
  "items": [
    {
      "name": "item_name_1",
      "quantity": "quantity_value",
      "unit": "quantity_unit",
      "calories": {
        "value": "total_calories",
        "unit": "kcal"
      },
    },
    {
      "name": "item_name_2",
      "quantity": "quantity_value",
      "unit": "quantity_unit"
      "calories": {
        "value": "total_calories",
        "unit": "kcal"
      },
    }
  ],
  "nutrition": {
    "calories": {
      "value": "total_calories",
      "unit": "kcal"
    },
    "carbs": {
      "value": "total_carbs",
      "unit": "g"
    },
    "fat": {
      "value": "total_fat",
      "unit": "g"
    },
    "protein": {
      "value": "total_protein",
      "unit": "g"
    },
    "fibers": {
      "value": "total_fibers:,
      "unit": "g"
    }
  },
  suggestion: "suggestion detail"
}
        """);
      final response = await Gemini.instance
          .textAndImage(text: prompt, images: [image], modelName: 'models/gemini-1.5-flash');
      final geminiResult = response!.content!.parts!.last.text!;
      logger.i('geminiResult -> $geminiResult');
      final adjustedResult = geminiResult.replaceAll(RegExp(r'```json|```'), '');
      logger.i('result-> $adjustedResult');
      final data = CalculateResult.fromJson(jsonDecode(adjustedResult));
      data.dateTime = dateTimeFormat.format(dateTime);
      data.imagePath = imagePath;
      final copiedList = results.toList();
      copiedList.insert(0, data);
      results = copiedList;
      await CalorieDatabase.instance.insertCalculateResult(data);
    } catch (e, s) {
      logger.e('generateResult', error: e, stackTrace: s);
    }
    isLoading = false;
    notifyListeners();
  }
}
