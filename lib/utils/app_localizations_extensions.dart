import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizedVehicleType on AppLocalizations {
  String getSubType(String type, {bool isSingular = false}) {
    final normalized =
        type.toLowerCase().replaceAll(' ', '').replaceAll('-', '');

    switch (normalized) {
      // Fuel Types
      case 'gasoline':
        return isSingular ? gasoline : fuelTypeGasoline;
      case 'diesel':
        return isSingular ? diesel : fuelTypeDiesel;
      case 'electric':
        return isSingular ? electric : fuelTypeElectric;
      case 'hybrid':
        return isSingular ? hybrid : fuelTypeHybrid;

      // Repair Types
      case 'oilchange':
        return isSingular ? oilChange : repairTypeOilChange;
      case 'brakes':
        return isSingular ? brakes : repairTypeBrakes;
      case 'tires':
        return isSingular ? tires : repairTypeTires;
      case 'battery':
        return isSingular ? battery : repairTypeBattery;
      case 'generalcheckup':
        return isSingular ? generalCheckup : repairTypeGeneralCheckup;

      // Record Types
      case 'insurance':
        return isSingular ? insurance : recordTypeInsurance;
      case 'mot':
        return isSingular ? mot : recordTypeMOT;
      case 'circulationpermit':
        return isSingular ? circulationPermit : recordTypeCirculationPermit;
      case 'fine':
        return isSingular ? fine : recordTypeFine;

      // Vehicles Types
      case 'car':
        return isSingular ? car : vehicleTypeCar;
      case 'motorcycle':
        return isSingular ? motorcycle : vehicleTypeMotorcycle;
      case 'truck':
        return isSingular ? truck : vehicleTypeTruck;
      case 'bus':
        return isSingular ? bus : vehicleTypeBus;
      case 'bicycle':
        return isSingular ? bicycle : vehicleTypeBicycle;
      case 'electricscooter':
        return isSingular ? electricScooter : vehicleTypeElectricScooter;

      // TypesGlobal
      case 'fuel':
        return isSingular ? activityTypeFuel : activityTypeFuels;
      case 'repair':
        return isSingular ? activityTypeRepair : activityTypeRepairs;
      case 'record':
        return isSingular ? activityTypeRecord : activityTypeRecords;
      case 'vehicle':
        return isSingular ? vehicle2 : vehicle;
      case 'activity':
        return isSingular ? activity2 : activity;

      default:
        return isSingular ? normalized : type; // fallback
    }
  }
}
