import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mi_garaje/data/models/vehicle.dart';
import 'package:mi_garaje/data/provider/auth_notifier.dart';
import 'package:mi_garaje/data/services/garage_service.dart';

class GarageState {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;

  GarageState({
    this.vehicles = const [],
    this.selectedVehicle,
  });

  bool get isVehicleSelected => selectedVehicle != null;
  String get id => selectedVehicle?.id ?? '';

  GarageState copyWith({
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    bool? initialized,
  }) {
    return GarageState(
      vehicles: vehicles ?? this.vehicles,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
    );
  }
}

class GarageNotifier extends AsyncNotifier<GarageState> {
  final CarService _carService = CarService();

  @override
  Future<GarageState> build() async {
    final auth = ref.watch(authProvider).value;
    if (auth == null) return GarageState();

    if (!auth.isUser) {
      return GarageState(
        vehicles: [],
        selectedVehicle: null,
      );
    }

    final vehicles = await _carService.getVehiclesFuture(auth.id, auth.type);

    return (GarageState(
      vehicles: vehicles,
      selectedVehicle: vehicles.isNotEmpty ? vehicles.first : null,
    ));
  }

  Future<void> setSelectedVehicle(Vehicle? vehicle) async {
    state = AsyncData(state.value!.copyWith(selectedVehicle: vehicle));
  }

  Future<void> refreshGarage() async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    final vehicles = await _carService.getVehiclesFuture(auth.id, auth.type);
    Vehicle? selected;
    if (vehicles.isNotEmpty) {
      selected = vehicles.firstWhere(
        (v) => v.id == state.value?.selectedVehicle?.id,
        orElse: () => vehicles.first,
      );
    } else {
      selected = null;
    }

    state = AsyncData(GarageState(
      vehicles: vehicles,
      selectedVehicle: selected,
    ));
  }

  void cerrarSesion() {
    state = AsyncData(GarageState(vehicles: [], selectedVehicle: null));
  }

  Future<void> eliminarCuenta() async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    if (auth.isFamily) {
      await leaveFamily();
    } else {
      await _carService.deleteVehicles(auth.id, "users");
      state = AsyncData(GarageState(vehicles: [], selectedVehicle: null));
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _carService.addVehicle(vehicle, auth.id, auth.type);
    final updatedList = [...state.value!.vehicles, vehicle];

    state = AsyncData(state.value!.copyWith(
      vehicles: updatedList,
      selectedVehicle: vehicle,
    ));
  }

  Future<void> deleteVehicle(Vehicle vehicle) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _carService.deleteVehicle(vehicle.id!, auth.id, auth.type);
    final updatedList =
        state.value!.vehicles.where((v) => v.id != vehicle.id).toList();
    final selected = state.value!.selectedVehicle?.id == vehicle.id
        ? (updatedList.isNotEmpty ? updatedList.first : null)
        : state.value!.selectedVehicle;

    state = AsyncData(state.value!
        .copyWith(vehicles: updatedList, selectedVehicle: selected));
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _carService.updateVehicle(vehicle, auth.id, auth.type);
    final updatedList = state.value!.vehicles
        .map((v) => v.id == vehicle.id ? vehicle : v)
        .toList();

    state = AsyncData(state.value!.copyWith(
      vehicles: updatedList,
      selectedVehicle: vehicle,
    ));
  }

  Future<void> deleteVehicleType(String type, String typeName) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _carService.deleteVehicleType(auth.id, type, typeName, auth.type);

    final updatedVehicles =
        state.value!.vehicles.where((v) => !(v.vehicleType == type)).toList();
    final selected = updatedVehicles.firstWhere(
      (v) => v.id == state.value?.selectedVehicle?.id,
      orElse: () => updatedVehicles.first,
    );
    state = AsyncData(
        GarageState(vehicles: updatedVehicles, selectedVehicle: selected));
  }

  Future<void> updateVehicleType(
      String oldName, String newName, String type) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;

    await _carService.updateVehicleType(
        auth.id, oldName, newName, type, auth.type);

    final updatedVehicles = state.value!.vehicles.map((v) {
      if (v.vehicleType == oldName) {
        return v.copyWith(vehicleType: newName);
      }
      return v;
    }).toList();

    final selected = updatedVehicles.firstWhere(
      (v) => v.id == state.value?.selectedVehicle?.id,
      orElse: () => updatedVehicles.first,
    );
    state = AsyncData(
        GarageState(vehicles: updatedVehicles, selectedVehicle: selected));
  }

  Future<void> convertToFamily(String idFamily) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;
    await _carService.convertToFamily(auth.id, idFamily);
    await _carService.deleteVehicles(auth.id, "users");
  }

  Future<void> joinFamily(String idFamily) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;
    await _carService.deleteVehicles(auth.id, "users");
  }

  Future<void> leaveFamily() async {
    final auth = ref.read(authProvider).value;
    if (auth == null) return;
    if (auth.isLastMember) {
      await _carService.deleteVehicles(auth.id, auth.type);
    }
    state = AsyncData(GarageState(vehicles: [], selectedVehicle: null));
  }
}

final garageProvider = AsyncNotifierProvider<GarageNotifier, GarageState>(
  GarageNotifier.new,
);
