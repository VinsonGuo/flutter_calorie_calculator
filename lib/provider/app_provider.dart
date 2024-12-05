import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../common/logger.dart';
import '../model/models.dart';

class AppProvider with ChangeNotifier {
  Result<CalculateResult> calculateResult = Result.failed('no data');
  bool isLoading = false;

  Future<void> generateResult(Uint8List image) async {
    isLoading = true;
    notifyListeners();
    try {
      const prompt = """
        Analyze this image to identify food items, estimate their quantities and provide a detailed nutritional breakdown with units. Return the results as JSON, strictly adhering to this structure and do not include other content:
{
  "items": [
    {
      "name": "food_item_1",
      "quantity": "quantity_value",
      "unit": "quantity_unit",
      "calories": {
        "value": "total_calories",
        "unit": "kcal"
      },
    },
    {
      "name": "food_item_2",
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
  }
}
        """;
      final response = await Gemini.instance
          .textAndImage(text: prompt, images: [image], modelName: 'models/gemini-1.5-flash');
      final geminiResult = response!.content!.parts!.last.text!;
      logger.i('geminiResult -> $geminiResult');
      final adjustedResult = geminiResult.replaceAll(RegExp(r'```json|```'), '');
      logger.i('result-> $adjustedResult');
      calculateResult = Result.success(CalculateResult.fromJson(jsonDecode(adjustedResult)));

      notifyListeners();
    } catch (e) {
      logger.e('gemini error', error: e);
      calculateResult = Result.failed('Api error: ${e.toString()}');
    }
    isLoading = false;
    notifyListeners();
  }
}
