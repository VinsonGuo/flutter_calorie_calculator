import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/foundation.dart';
import 'package:flutter_calorie_calculator/common/data.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

import '../common/logger.dart';
import '../model/models.dart';

class AppProvider with ChangeNotifier {
  List<CalculateResult> results = [];
  bool isLoading = false;
  User? user = FirebaseAuth.instance.currentUser;

  Future<String> _uploadImage(Uint8List image) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }
    try {
      final fileName = '${const Uuid().v4()}.jpg';
      final uid = user.uid;
      final storageRef =
          storage.FirebaseStorage.instance.ref().child('users/$uid/$fileName');

      await storageRef.putData(image);

      // 获取图片的下载 URL
      final downloadUrl = await storageRef.getDownloadURL();

      print('Image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  Future<bool> registerWithEmail(String email, String password) async {
    showLoading();
    try {
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 将用户信息存储到 Firestore
        await saveUserToFirestore(user);
        this.user = user;
        hideLoading();
        return true;
      }
    } catch (e) {
      print("Error during registration: $e");
    }
    hideLoading();
    return false;
  }

  Future<bool> loginWithEmail(String email, String password) async {
    showLoading();
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        this.user = user;
        hideLoading();
        return true;
      }
    } catch (e) {
      print("Error during login: $e");
    }
    hideLoading();
    return false;
  }

  Future<bool> signInWithGoogle() async {
    showLoading();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false; // 用户取消登录

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // 保存用户到 Firestore
        await saveUserToFirestore(user);
        this.user = user;
        hideLoading();
        return true;
      }
    } catch (e) {
      print("Error during Google sign-in: $e");
    }
    hideLoading();
    return false;
  }

  Future<void> signOut() async{
    if (user != null) {
      await FirebaseAuth.instance.signOut();
      user = FirebaseAuth.instance.currentUser;
      notifyListeners();
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userRef.set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
      'creationTime': user.metadata.creationTime?.toIso8601String(),
    }, SetOptions(merge: true));
  }

  Future<void> fetchResults() async {
    isLoading = true;
    notifyListeners();
    try {
      results = await fetchCalories();
    } catch (e) {
      logger.e('fetchResults error', error: e);
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> generateResult(DateTime dateTime, Uint8List image) async {
    showLoading();
    try {
      final imagePath = await _uploadImage(image);
      const prompt = ("""
Analyze this image to identify individual food items, clearly separating them with visual signals. For each identified item, provide the following information:

1. Name: Include the food ingredients item's name appended with a relevant emoji (e.g., "Apple 🍎").
2. Quantity: Estimate the quantity of the food item.
3. Unit: Specify the unit of measurement for the quantity only with "g" and "ml".
3. suggestion: Give suggestion of this meal.

Additionally, provide a detailed nutritional breakdown for the entire meal. 
Return the results as JSON, strictly adhering to this structure and do not include other content:
{
  "ingredients": [
    {
      "name": "ingredient_name_1",
      "quantity": "quantity_value",
      "unit": "quantity_unit",
      "calories": {
        "value": "total_calories",
        "unit": "kcal"
      },
    },
    {
      "name": "ingredient_name_2",
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
      final response = await Gemini.instance.textAndImage(
          text: prompt, images: [image], modelName: 'models/gemini-1.5-flash');
      final geminiResult = response!.content!.parts!.last.text!;
      logger.i('geminiResult -> $geminiResult');
      final adjustedResult =
          geminiResult.replaceAll(RegExp(r'```json|```'), '');
      logger.i('result-> $adjustedResult');
      final data = CalculateResult.fromJson(jsonDecode(adjustedResult));
      data.dateTime = dateTimeFormat.format(dateTime);
      data.imagePath = imagePath;
      final copiedList = results.toList();
      copiedList.insert(0, data);
      results = copiedList;
      await uploadCalculateResult(data);
    } catch (e, s) {
      logger.e('generateResult', error: e, stackTrace: s);
    }
    hideLoading();
  }

  Future<void> uploadCalculateResult(CalculateResult result) async {
    if (user == null) {
      throw Exception('User is not logged in');
    }
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // 构造 nutrition 数据
    final nutrition = {
      'calories_value': result.nutrition.calories.value,
      'calories_unit': result.nutrition.calories.unit,
      'carbs_value': result.nutrition.carbs.value,
      'carbs_unit': result.nutrition.carbs.unit,
      'fat_value': result.nutrition.fat.value,
      'fat_unit': result.nutrition.fat.unit,
      'protein_value': result.nutrition.protein.value,
      'protein_unit': result.nutrition.protein.unit,
      'fibers_value': result.nutrition.fibers.value,
      'fibers_unit': result.nutrition.fibers.unit,
      'dateTime': DateTime.parse(result.dateTime).millisecondsSinceEpoch,
      'imagePath': result.imagePath,
      'suggestion': result.suggestion,
    };

    // 将 nutrition 存储到 Firestore 并获取其生成的文档 ID
    final nutritionRef = await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('nutritions')
        .add(nutrition);
    final String nutritionId = nutritionRef.id;

    // 遍历 items 并将其存储到 Firestore
    for (final item in result.ingredients) {
      final itemMap = {
        'name': item.name,
        'nutrition_id': nutritionId, // 将 nutritionId 作为关联字段
        'quantity': item.quantity,
        'unit': item.unit,
        'calories_value': item.calories.value,
        'calories_unit': item.calories.unit,
      };

      await firestore
          .collection('users')
          .doc(user!.uid)
          .collection('ingredients')
          .add(itemMap);
    }

    print('Data successfully inserted into Firestore.');
  }

  /// 从 Firebase 获取指定 nutrition_id 的 items 列表
  Future<List<CalculateIngredient>> _fetchIngredientsByNutritionId(
      String nutritionId) async {
    if (user == null) {
      throw Exception('User is not logged in');
    }
    // 查询 items 集合中 nutrition_id 匹配的文档
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('ingredients')
        .where('nutrition_id', isEqualTo: nutritionId)
        .get();

    // 将查询结果映射到 CalculateItem 列表
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return CalculateIngredient(
        data['name'],
        data['quantity'],
        data['unit'],
        NutritionItem(data['calories_value'], data['calories_unit']),
      );
    }).toList();
  }

  /// 从 Firebase 获取所有 nutrition 记录并生成 CalculateResult 列表
  Future<List<CalculateResult>> fetchCalories() async {
    if (user == null) {
      throw Exception('User is not logged in');
    }
    // 查询 nutrition 集合中的所有文档
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('nutritions')
        .orderBy('dateTime', descending: true)
        .get();

    final List<CalculateResult> results = [];

    // 遍历每个 nutrition 文档
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final nutritionId = doc.id;

      // 根据 nutrition_id 获取关联的 items
      List<CalculateIngredient> items = [];
      try {
        items = await _fetchIngredientsByNutritionId(nutritionId);
      } catch (e) {
        logger.e('_fetchIngredientsByNutritionId error', error: e);
      }

      // 构造 CalculateResult
      final result = CalculateResult(
        nutritionId,
        items,
        Nutrition(
          NutritionItem(data['calories_value'], data['calories_unit']),
          NutritionItem(data['carbs_value'], data['carbs_unit']),
          NutritionItem(data['fat_value'], data['fat_unit']),
          NutritionItem(data['protein_value'], data['protein_unit']),
          NutritionItem(data['fibers_value'], data['fibers_unit']),
        ),
        dateTimeFormat
            .format(DateTime.fromMillisecondsSinceEpoch(data['dateTime'])),
        data['imagePath'] ?? '',
        data['suggestion'] ?? '',
      );
      results.add(result);
    }

    return results;
  }

  void showLoading() {
    isLoading = true;
    notifyListeners();
  }

  void hideLoading() {
    isLoading = false;
    notifyListeners();
  }
}
