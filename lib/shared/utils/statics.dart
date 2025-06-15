import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/shared/utils/monthly_total_spending.dart';

class Statics {
  static Map<String, dynamic> generateStats(
    Map<String, List<Activity>> vehicleActivities,
    String? selectedVehicleId,
    String? selectedYear,
  ) {
    List<Activity> activities;

    if (selectedVehicleId != null) {
      activities = vehicleActivities[selectedVehicleId] ?? [];
    } else {
      activities = vehicleActivities.values.expand((list) => list).toList();
    }

    final availableYearsList = availableYears(activities);

    if (selectedYear != null) {
      activities = activities
          .where((activity) => activity.date.year.toString() == selectedYear)
          .toList();
    }

    if (activities.isEmpty) {
      return {
        'totalSpent': 0.0,
        'activityCount': 0,
        'avgMonthly': 0.0,
        'avgActivity': 0.0,
        'totalSpendingPerMonth': [],
        'totalPerActivity': <String, double>{},
        'availableYears': [],
      };
    }

    final totalSpent = calculateTotalSpent(activities);
    final activityCount = activities.length;
    final avgMonthly = calculateAverageMonthlySpending(activities);
    final avgActivity = calculateAverageActivitySpending(activities);
    final totalSpendingPerMonth = calculateTotalSpendingPerMonth(activities);
    final totalPerActivity = agruparPorSubtipo(activities);

    return {
      'totalSpent': totalSpent,
      'activityCount': activityCount,
      'avgMonthly': avgMonthly,
      'avgActivity': avgActivity,
      'totalSpendingPerMonth': totalSpendingPerMonth,
      'totalPerActivity': totalPerActivity,
      'availableYears': availableYearsList,
    };
  }

  static double calculateTotalSpent(List<Activity> activities) {
    return activities.fold(
      0.0,
      (sum, activity) => sum + (activity.cost ?? 0.0),
    );
  }

  static double calculateAverageMonthlySpending(List<Activity> activities) {
    if (activities.isEmpty) return 0.0;

    activities.sort((a, b) => a.date.compareTo(b.date));
    final firstDate =
        DateTime(activities.first.date.year, activities.first.date.month);
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month);

    final totalMonths = (currentDate.year - firstDate.year) * 12 +
        (currentDate.month - firstDate.month) +
        1;

    final totalSpent = activities.fold<double>(
      0.0,
      (sum, activity) => sum + (activity.cost ?? 0.0),
    );

    return totalMonths > 0 ? totalSpent / totalMonths : 0.0;
  }

  static double calculateAverageActivitySpending(List<Activity> activities) {
    return activities.isEmpty
        ? 0.0
        : activities.fold(
              0.0,
              (sum, activity) => sum + (activity.cost ?? 0.0),
            ) /
            activities.length;
  }

  static List<MonthlyTotalSpending> calculateTotalSpendingPerMonth(
      List<Activity> activities) {
    final Map<String, double> monthlyTotals = {};

    for (final activity in activities) {
      final date = activity.date;
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      monthlyTotals[key] = (monthlyTotals[key] ?? 0.0) + (activity.cost ?? 0.0);
    }

    final result = monthlyTotals.entries.map((entry) {
      final monthLabel = entry.key;
      return MonthlyTotalSpending(monthLabel, entry.value);
    }).toList();

    result.sort((a, b) => a.monthLabel.compareTo(b.monthLabel));
    return result;
  }

  static List<MonthlyTotalSpending> generateMonthlyDataForYear(
    List<MonthlyTotalSpending> allData,
    String year,
  ) {
    return List.generate(12, (index) {
      final month = (index + 1).toString().padLeft(2, '0');
      final label = '$year-$month';

      final match = allData.firstWhere(
        (e) => e.monthLabel == label,
        orElse: () => MonthlyTotalSpending(label, 0),
      );

      return match;
    });
  }

  static Map<String, double> agruparPorSubtipo(List<Activity> actividades) {
    final Map<String, double> agrupado = {};

    for (var actividad in actividades) {
      agrupado[actividad.getActivityType] =
          (agrupado[actividad.getActivityType] ?? 0) + 1.0;
    }

    return agrupado;
  }

  static List<int> availableYears(List<Activity> activities) {
    final years = activities.map((a) => a.date.year).toSet().toList();
    years.sort();
    return years;
  }
}
