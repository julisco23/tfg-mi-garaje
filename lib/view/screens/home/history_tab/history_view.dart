import 'package:flutter/material.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "General"),
            Tab(text: "Detalles"),
            Tab(text: "Estadísticas"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text("Contenido General")),
          Center(child: Text("Detalles del Historial")),
          Center(child: Text("Estadísticas del Historial")),
        ],
      ),
    );
  }
}