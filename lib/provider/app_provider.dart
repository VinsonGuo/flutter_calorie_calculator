import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../common/logger.dart';
import '../model/models.dart';

class AppProvider with ChangeNotifier {
  Result<CalculateResult> calculateResult = Result.failed('no data');
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

  Future<void> generateResult(DateTime dateTime, Uint8List image, String imagePath) async {
    isLoading = true;
    notifyListeners();
    try {
      const prompt = """
        Analyze this image to identify food items(item needs to append emoji in "name" field), estimate their quantities and provide a detailed nutritional breakdown with units. Return the results as JSON, strictly adhering to this structure and do not include other content:
{
  "items": [
    {
      "name": "egg🥚",
      "quantity": "quantity_value",
      "unit": "quantity_unit",
      "calories": {
        "value": "total_calories",
        "unit": "kcal"
      },
    },
    {
      "name": "apple🍎",
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
      final data = CalculateResult.fromJson(jsonDecode(adjustedResult));
      data.dateTime = dateTime.toIso8601String();
      data.imagePath = imagePath;
      calculateResult = Result.success(data);

      notifyListeners();
    } catch (e) {
      logger.e('gemini error', error: e);
      calculateResult = Result.failed('Api error: ${e.toString()}');
    }
    isLoading = false;
    notifyListeners();
  }
}
