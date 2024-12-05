import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

class Result<T> {
  T? data;
  String? msg;

  Result(this.data, this.msg);

  bool isSuccess() => data != null;

  factory Result.success(T data) {
    return Result(data, null);
  }

  factory Result.failed(String msg) {
    return Result(null, msg);
  }
}



@JsonSerializable()
class CalculateResult {
  List<CalculateItem> items;
  Nutrition nutrition;
  @JsonKey(defaultValue: '2024-12-05')
  String dateTime;
  @JsonKey(defaultValue: '')
  String imagePath;


  CalculateResult(this.items, this.nutrition, this.dateTime, this.imagePath);

  factory CalculateResult.fromJson(Map<String, dynamic> json) =>
      _$CalculateResultFromJson(json);

  Map<String, dynamic> toJson() => _$CalculateResultToJson(this);
}

@JsonSerializable()
class CalculateItem {
  String name;
  String quantity;
  String unit;
  NutritionItem calories;

  CalculateItem(this.name, this.quantity, this.unit, this.calories);

  factory CalculateItem.fromJson(Map<String, dynamic> json) =>
      _$CalculateItemFromJson(json);

  Map<String, dynamic> toJson() => _$CalculateItemToJson(this);
}

@JsonSerializable()
class Nutrition {
  NutritionItem calories;
  NutritionItem carbs;
  NutritionItem fat;
  NutritionItem protein;
  NutritionItem fibers;

  Nutrition(this.calories, this.carbs, this.fat, this.protein, this.fibers);

  factory Nutrition.fromJson(Map<String, dynamic> json) =>
      _$NutritionFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionToJson(this);
}

@JsonSerializable()
class NutritionItem {
  String value;
  String unit;

  NutritionItem(this.value, this.unit);

  factory NutritionItem.fromJson(Map<String, dynamic> json) =>
      _$NutritionItemFromJson(json);

  Map<String, dynamic> toJson() => _$NutritionItemToJson(this);
}
