import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:teamloc/dto/json/player.dart';

import 'controller/gameinfo_controller.dart';

/// The home page of the application which hosts the datagrid.
class MemberGridListView extends StatefulWidget {
  List<Player> players = [];
  Function filterFunction;

  /// Creates the home page.
  MemberGridListView(
      {Key? key, required this.players, required this.filterFunction})
      : super(key: key);

  @override
  _MemberGridListViewState createState() => _MemberGridListViewState();
}

class _MemberGridListViewState extends State<MemberGridListView> {
  final List<PlutoColumn> columns = <PlutoColumn>[
    PlutoColumn(
      title: 'Color',
      field: 'color',
      type: PlutoColumnType.text(),
      enableRowChecked: true,
    ),
    PlutoColumn(
      title: 'Nick',
      field: 'nick',
      type: PlutoColumnType.text(),
    ),
    PlutoColumn(
      title: 'Status',
      field: 'status',
      type: PlutoColumnType.number(),
    ),
  ];

  // late List<PlutoRow> rows;

  /// columnGroups that can group columns can be omitted.
  final List<PlutoColumnGroup> columnGroups = [
    PlutoColumnGroup(title: 'color', fields: ['color']),
    PlutoColumnGroup(title: 'nick', fields: ['nick']),
    PlutoColumnGroup(title: 'status', fields: ['status']),
  ];

  void checkCallback(PlutoGridOnRowCheckedEvent event) {
    // print(event.isAll);
    // print(event.isRow);
    print(stateManager.checkedRows.length);
    Get.find<GameInfoController>().drawInitialLines(
        filter: stateManager.checkedRows.map((e) => e.key.toString()).toSet());
  }

  /// [PlutoGridStateManager] has many methods and properties to dynamically manipulate the grid.
  /// You can manipulate the grid dynamically at runtime by passing this through the [onLoaded] callback.
  late PlutoGridStateManager stateManager;
  UniqueKey k = UniqueKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get.put(GameInfoController());
    // return GetX<GameInfoController>(builder: (getMapController) {
    widget.players.sort((a,b)=>b.status.compareTo(a.status));
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: widget.players.length,
        itemBuilder: (context, index) {
          final player = widget.players[index];
          return Container(
            child: Row(
              children: [
                Text(player.memberInfo.nickName),
                TextButton(
                    onPressed: null,
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Color(player.lineColor))),
                    child: Text(player.status)),

                Text(player.status),
              ],
            ),
          );
        });
    // });
  }
}
