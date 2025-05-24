import 'package:intl/intl.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/data/models/vehicle.dart';

List<List<String>> exportAllCarsWithActivitiesToCSV(
    List<Vehicle> vehicles, Map<String, List<Activity>> activitiesMap) {
  List<List<String>> csvData = [];

  if (vehicles.isEmpty) {
    return csvData;
  }

  for (var car in vehicles) {
    if (csvData.isNotEmpty) {
      csvData.add([]);
    }

    csvData.add([
      'Name',
      'Brand',
      'Model',
      'Vehicle Type',
      'Creation Date',
    ]);

    csvData.add([
      car.getName() ?? '',
      car.getBrand(),
      car.getModel() ?? '',
      car.getVehicleType(),
      DateFormat('dd/MM/yyyy').format(car.creationDate!)
    ]);

    if (activitiesMap[car.id]!.isEmpty) {
      continue;
    }

    csvData.add([]);

    csvData.add([
      'Activity Type',
      'Activity Subtype',
      'Date',
      'Cost',
      'Details',
    ]);

    for (var act in activitiesMap[car.id]!) {
      csvData.add([
        act.getCustomType,
        act.getType,
        DateFormat('dd/MM/yyyy').format(act.date),
        act.getCost?.toString() ?? '',
        act.getDetails ?? '',
      ]);
    }
  }

  return csvData;
}
