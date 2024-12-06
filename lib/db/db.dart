import 'package:flutter_calorie_calculator/common/data.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/models.dart';

class CalorieDatabase {
  static final CalorieDatabase instance = CalorieDatabase._init();

  static Database? _database;

  CalorieDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('calorie.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // 创建 items 表
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        unit TEXT NOT NULL,
        calories_value TEXT NOT NULL,
        calories_unit TEXT NOT NULL,
        nutrition_id INTEGER,
        FOREIGN KEY (nutrition_id) REFERENCES nutrition(id) ON DELETE CASCADE
      )
    ''');

    // 创建 nutrition 表
    await db.execute('''
      CREATE TABLE nutrition (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calories_value TEXT NOT NULL,
        calories_unit TEXT NOT NULL,
        carbs_value TEXT,
        carbs_unit TEXT,
        fat_value TEXT,
        fat_unit TEXT,
        protein_value TEXT,
        protein_unit TEXT,
        fibers_value TEXT,
        fibers_unit TEXT,
        dateTime INTEGER NOT NULL,
        imagePath TEXT,
        suggestion TEXT
      )
    ''');
  }

  Future<void> insertCalculateResult(CalculateResult result) async {
    final nutrition = {
      'calories_value': result.nutrition.calories.value,
      'calories_unit': result.nutrition.calories.unit,
      'carbs_value': result.nutrition.carbs.value,
      'carbs_unit': result.nutrition.carbs.unit,
      'fat_value': result.nutrition.fat.value,
      'fat_unit': result.nutrition.fat.unit,
      'protein_value': result.nutrition.fat.value,
      'protein_unit': result.nutrition.fat.unit,
      'fibers_value': result.nutrition.fat.value,
      'fibers_unit': result.nutrition.fat.unit,
      'dateTime': DateTime.parse(result.dateTime).millisecondsSinceEpoch,
      'imagePath': result.imagePath,
      'suggestion': result.suggestion,
    };
    final nutrition_id = await _insertNutrition(nutrition);
    for (final item in result.items) {
      /*
      name TEXT NOT NULL,
        quantity TEXT NOT NULL,
        unit TEXT NOT NULL,
        calories_value TEXT NOT NULL,
        calories_unit TEXT NOT NULL,
        nutrition_id INTEGER,
       */
      final itemMap = {
        'name': item.name,
        'nutrition_id': nutrition_id,
        'quantity': item.quantity,
        'unit': item.unit,
        'calories_value': item.calories.value,
        'calories_unit': item.calories.unit,
      };
      await _insertItem(itemMap);
    }
  }

  Future<int> _insertNutrition(Map<String, dynamic> nutrition) async {
    final db = await instance.database;

    return await db.insert('nutrition', nutrition);
  }

  Future<int> _insertItem(Map<String, dynamic> item) async {
    final db = await instance.database;

    return await db.insert('items', item);
  }

  Future<List<CalculateItem>> _fetchItemsByNutritionId(
      int nutritionId) async {
    final db = await instance.database;
    List<Map<String, dynamic>> queryResult = await db
        .query('items', where: 'nutrition_id = ?', whereArgs: [nutritionId]);
    return queryResult
        .map((e) => CalculateItem(e['name'], e['quantity'], e['unit'],
            NutritionItem(e['calories_value'], e['calories_unit'])))
        .toList();
  }

  Future<List<CalculateResult>> fetchCalories() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> nutritions = await db.query('nutrition', orderBy: 'id DESC');
    final List<CalculateResult> results = [];
    for (final n in nutritions) {
      final items = await _fetchItemsByNutritionId(n['id']);
      final result = CalculateResult(
          n['id'],
          items,
          Nutrition(
              NutritionItem(n['calories_value'], n['calories_unit']),
              NutritionItem(n['carbs_value'], n['carbs_unit']),
              NutritionItem(n['fat_value'], n['fat_unit']),
              NutritionItem(n['protein_value'], n['protein_unit']),
              NutritionItem(n['fibers_value'], n['fibers_unit'])),
          dateTimeFormat.format(DateTime.fromMillisecondsSinceEpoch(n['dateTime'])),
          n['imagePath'],
          n['suggestion']);
      results.add(result);
    }
    /*
    id INTEGER PRIMARY KEY AUTOINCREMENT,
        calories_value TEXT NOT NULL,
        calories_unit TEXT NOT NULL,
        carbs_value TEXT,
        carbs_unit TEXT,
        fat_value TEXT,
        fat_unit TEXT,
        protein_value TEXT,
        protein_unit TEXT,
        fibers_value TEXT,
        fibers_unit TEXT,
        dateTime TEXT NOT NULL,
        imagePath TEXT,
        suggestion TEXT
     */
    return results;
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
