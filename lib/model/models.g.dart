// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculateResult _$CalculateResultFromJson(Map<String, dynamic> json) =>
    CalculateResult(
      json['id'] as String?,
      (json['ingredients'] as List<dynamic>)
          .map((e) => CalculateIngredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      json['dateTime'] as String? ?? '2024-12-05',
      json['imagePath'] as String? ?? '',
      json['suggestion'] as String,
    );

Map<String, dynamic> _$CalculateResultToJson(CalculateResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ingredients': instance.ingredients,
      'nutrition': instance.nutrition,
      'dateTime': instance.dateTime,
      'imagePath': instance.imagePath,
      'suggestion': instance.suggestion,
    };

CalculateIngredient _$CalculateIngredientFromJson(Map<String, dynamic> json) =>
    CalculateIngredient(
      json['name'] as String,
      json['quantity'] as String,
      json['unit'] as String,
      NutritionItem.fromJson(json['calories'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CalculateIngredientToJson(
        CalculateIngredient instance) =>
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
