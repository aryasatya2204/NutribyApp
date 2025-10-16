import 'package:nutriby_frontend/models/recipe.dart';

class WeeklyPlan {
  final int id;
  final String name;
  final String startDate;
  final String endDate;
  final List<WeeklyPlanDetail> details;

  WeeklyPlan({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.details,
  });

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    var detailsList = json['details'] as List;
    List<WeeklyPlanDetail> planDetails = detailsList
        .map((detail) => WeeklyPlanDetail.fromJson(detail))
        .toList();

    return WeeklyPlan(
      id: json['id'],
      name: json['name'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      details: planDetails,
    );
  }
}

class WeeklyPlanDetail {
  final int id;
  final int dayOfWeek;
  final String mealType;
  final Recipe recipe;

  WeeklyPlanDetail({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.recipe,
  });

  factory WeeklyPlanDetail.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanDetail(
      id: json['id'],
      dayOfWeek: json['day_of_week'],
      mealType: json['meal_type'],
      recipe: Recipe.fromJson(json['recipe']),
    );
  }
}