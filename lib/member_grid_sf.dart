import 'package:flutter/material.dart';
import 'package:teamloc/dto/json/player.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// The home page of the application which hosts the datagrid.
class MemberGridSF extends StatefulWidget {
  List<Player> players;
  Function filterFunction;

  /// Creates the home page.
  MemberGridSF({Key? key, required this.players, required this.filterFunction})
      : super(key: key);

  @override
  _MemberGridSFState createState() => _MemberGridSFState();
}

class _MemberGridSFState extends State<MemberGridSF> {
  // List<Employee> employees = <Employee>[];
  late EmployeeDataSource employeeDataSource;
  @override
  void initState() {
    super.initState();

    employeeDataSource = EmployeeDataSource(employeeData: widget.players);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Syncfusion Flutter DataGrid'),
      // ),
      body: SfDataGrid(
        source: employeeDataSource,
        allowSorting: true,
        allowMultiColumnSorting: true,
        allowTriStateSorting: true,
        showSortNumbers: true,
        showCheckboxColumn: true,
        onSelectionChanged: (addedRows, removedRows) {},
        selectionMode: SelectionMode.multiple,
        columnWidthMode: ColumnWidthMode.fill,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'id',
              label: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'ID',
                  ))),
          GridColumn(
              allowSorting: true,
              columnName: 'name',
              label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('이름'))),
          GridColumn(
              allowSorting: true,
              columnName: 'status',
              label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text(
                    '상태',
                    overflow: TextOverflow.ellipsis,
                  ))),
          GridColumn(
              columnName: 'color',
              label: Container(
                  padding: EdgeInsets.all(8.0),
                  alignment: Alignment.center,
                  child: Text('Color'))),
        ],
      ),
    );
  }
}

/// An object to set the employee collection data source to the datagrid. This
/// is used to map the employee data to the datagrid widget.
class EmployeeDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  EmployeeDataSource({required List<Player> employeeData}) {
    _employeeData = employeeData
        .map<DataGridRow>((e) => DataGridRow(cells: [
      DataGridCell<String>(columnName: 'id', value: e.memberInfo.id),
      DataGridCell<String>(
          columnName: 'name', value: e.memberInfo.nickName),
      DataGridCell<String>(columnName: 'status', value: e.status),
      DataGridCell<int>(columnName: 'color', value: e.lineColor),
    ]))
        .toList();
  }

  List<DataGridRow> _employeeData = [];

  @override
  List<DataGridRow> get rows => _employeeData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Text(e.value.toString()),
          );
        }).toList());
  }
}
