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
        return isSingular ? vehicle2 : vehicle3;
      case 'activity':
        return isSingular ? activity2 : activity;

      default:
        return isSingular ? normalized : type;
    }
  }

  String getErrorMessage(String code) {
    final normalized =
        code.replaceAll('Exception: ', '').toLowerCase().replaceAll('-', '');

    switch (normalized) {
      case 'invalidcredential':
        return invalidCredential;
      case 'singinerror':
        return singinError;
      case 'nogoogleaccountselected':
        return noGoogleAccountSelected;
      case 'googlesigninerror':
        return googleSigninError;
      case 'emailalreadyinuse':
        return emailAlreadyInUse;
      case 'singuperror':
        return singupError;
      case 'singupanonymouserror':
        return singupAnonymousError;
      case 'linkanonymousaccounterror':
        return linkAnonymousAccountError;
      case 'credentialalreadyinuse':
        return credentialAlreadyInUse;
      case 'linkgoogleaccounterror':
        return linkGoogleAccountError;
      case 'signouterror':
        return signoutError;
      case 'signoutgoogleerror':
        return signoutGoogleError;
      case 'deleteaccounterror':
        return deleteAccountError;
      case 'updateprofileerror':
        return updateProfileError;
      case 'convertofamilyerror':
        return convertToFamilyError;
      case 'leavefamilyerror':
        return leaveFamilyError;
      case 'familynotfound':
        return familyNotFound;
      case 'ejoinfamilyerror':
        return ejoinFamilyError;
      case 'getfamilyerror':
        return getFamilyError;
      case 'getuserdataerror':
        return getUserDataError;
      case 'addtypeerror':
        return addTypeError;
      case 'removetypeerror':
        return removeTypeError;
      case 'reactivatetypeerror':
        return reactivateTypeError;
      case 'gettabserror':
        return getTabsError;
      case 'transformtypeserror':
        return transformTypesError;
      case 'deletetypefromusererror':
        return deleteTypeFromUserError;
      case 'fetchvehicleserror':
        return fetchVehiclesError;
      case 'addvehicleerror':
        return addVehicleError;
      case 'deletevehicleerror':
        return deleteVehicleError;
      case 'updatevehicleerror':
        return updateVehicleError;
      case 'fetchactivitieserror':
        return fetchActivitiesError;
      case 'addactivityerror':
        return addActivityError;
      case 'deleteactivityerror':
        return deleteActivityError;
      case 'updateactivityerror':
        return updateActivityError;
      case 'deleteallactivitieserror':
        return deleteAllActivitiesError;
      case 'editallactivitieserror':
        return editAllActivitiesError;
      case 'editvehicletypeerror':
        return editVehicleTypeError;
      case 'deletevehicletypeerror':
        return deleteVehicleTypeError;
      case 'createfamilyerror':
        return createFamilyError;
      case 'deleteallvehicleserror':
        return deleteAllVehiclesError;
      default:
        return unknownError;
    }
  }
}
