import 'package:flutter/material.dart';
import 'package:mi_garaje/data/models/activity.dart';
import 'package:mi_garaje/shared/constants/constants.dart';
import 'package:mi_garaje/view/home/home_tab_view/dialog_wigdet/dialog_add_repostaje.dart';
import 'package:mi_garaje/view/home/home_tab_view/dialog_wigdet/dialog_add_documento.dart';
import 'package:mi_garaje/view/home/home_tab_view/dialog_wigdet/dialog_add_mantenimiento.dart';
import 'package:provider/provider.dart';
import 'package:mi_garaje/shared/widgets/cards/activity_card.dart';
import 'package:mi_garaje/view_model/garage_view_model.dart';

class HomeTabView extends StatefulWidget {
  const HomeTabView({
    super.key,
  });

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GarageViewModel>(
      builder: (context, provider, _) {
        final car = provider.selectedCoche!;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBar(
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text('Repostajes'))),
                  Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text('Arreglos'))),
                  Tab(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: const Text('Facturas'))),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(car.getActivities(ActivityType.refuel), car.getName()),
              _buildTabContent(car.getActivities(ActivityType.repair), car.getName()),
              _buildTabContent(car.getActivities(ActivityType.record), car.getName()),
            ],
          ),
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  switch (_tabController.index){
                    case 0:
                      DialogAddRefuel.show(context, provider);
                      break;
                    case 1:
                      DialogAddRepair.show(context, provider);
                      break;
                    case 2:
                      DialogAddDocument.show(context, provider);
                      break;
                  }
                },
                tooltip: "Añadir actividad",
                child: const Icon(Icons.add_rounded, size: 50),
              ),
            ],
          ),
        );
      },
    );
  }

  // Conenido de los tab
  Widget _buildTabContent(List<Actividad> activities, String carName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: AppDimensions.screenHeight(context) * 0.007),
        Expanded(
          child: ListView.builder(
            itemCount: activities.length + 1,
            itemBuilder: (context, index) {
              if (index == activities.length) {
                return SizedBox(height: AppDimensions.screenHeight(context) * 0.09);
              }

              return ActivityCard(
                    activity: activities[index],
                    type: _tabController.index,
                    carName: carName,
                  );
            },
          ),
        ),
      ],
    );
  }
}
