// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateResult _$CalculateResultFromJson(Map<String, dynamic> json) =>
    CalculateResult(
      (json['items'] as List<dynamic>)
          .map((e) => CalculateItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CalculateResultToJson(CalculateResult instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nutrition': instance.nutrition,
    };

CalculateItem _$CalculateItemFromJson(Map<String, dynamic> json) =>
    CalculateItem(
      json['name'] as String,
      json['quantity'] as String,
      json['unit'] as String,
      NutritionItem.fromJson(json['calories'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CalculateItemToJson(CalculateItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'calories': instance.calories,
    };

Nutrition _$NutritionFromJson(Map<String, dynamic> json) => Nutrition(
      NutritionItem.fromJson(json['calories'] as Map<String, dynamic>),
      NutritionItem.fromJson(json['carbs'] as Map<String, dynamic>),
      NutritionItem.fromJson(json['fat'] as Map<String, dynamic>),
      NutritionItem.fromJson(json['protein'] as Map<String, dynamic>),
      NutritionItem.fromJson(json['fibers'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NutritionToJson(Nutrition instance) => <String, dynamic>{
      'calories': instance.calories,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'protein': instance.protein,
      'fibers': instance.fibers,
    };

NutritionItem _$NutritionItemFromJson(Map<String, dynamic> json) =>
    NutritionItem(
      json['value'] as String,
      json['unit'] as String,
    );

Map<String, dynamic> _$NutritionItemToJson(NutritionItem instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unit': instance.unit,
    };