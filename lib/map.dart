import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teamloc/dto/json/location.dart';
import 'package:teamloc/member_grid.dart';
import 'package:teamloc/dto/json/player.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';

class MainMap extends StatefulWidget {
  const MainMap({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state.
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {
  GoogleMapController? mapController;

  Set<Polygon> polygons = HashSet<Polygon>();
  Set<Polyline> polylines = const <Polyline>{};
  Set<Color> lineColors = Set();
  Map<Player, List<Location>> members = HashMap();

  @override
  void initState() {
    super.initState();

    initObjects();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initMembers();
    });
  }

  void initObjects() {
    polygons.add(Polygon(
      // given polygonId
      polygonId: PolygonId('_SAFE_ZONE_OURS'),
      // initialize the list of points to display polygon
      points: const [
        LatLng(37.34598579546842, 127.40113617000992),
        LatLng(37.345865300005954, 127.4013166092999),
        LatLng(37.34598149206249, 127.40155478916432),
        LatLng(37.34607473247277, 127.40140682894594),
        LatLng(37.34598579546842, 127.40113617000992)
      ],
      // given color to polygon
      fillColor: Colors.green.withOpacity(0.3),
      // given border color to polygon
      strokeColor: Colors.green,
      geodesic: true,
      // given width of border
      strokeWidth: 4,
    ));
  }

  void _drawInitialLines(
      {lastCount = 55, Set<String>? filter}) {
    setState(() {

      polylines = members.entries
          .where((entry)=>filter == null || filter.contains('[<\'${entry.key.memberInfo.id}\'>]'))
          .map((entry) {
        final player = entry.key;
        final memberInfo = player.memberInfo;
        final locations = entry.value;

        return Polyline(
            polylineId: PolylineId(memberInfo.id),
            width: 2,
            color: Color(player.lineColor),
            points: locations
                .take(lastCount)
                .map((e) => LatLng(e.lat, e.lon))
                .toList());
      }).toSet();
    });
  }

  Color uniqueColor() {
    return RandomColor.getColorObject(Options());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: const EdgeInsets.all(10),
        child: Row(children: <Widget>[
      Expanded(
          flex: 80,
          child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
                // _currentLocation();

                _drawInitialLines();
              },
              mapType: MapType.satellite,
              // mapToolbarEnabled: true,
              // rotateGesturesEnabled: true,
              // // on below line we have enabled location
              // myLocationEnabled: true,
              // myLocationButtonEnabled: true,
              // // on below line we have enabled compass location
              // compassEnabled: true,
              // on below line we have added polygon
              polygons: polygons,
              polylines: polylines,
              initialCameraPosition: const CameraPosition(
                target: const LatLng(37.346109, 127.400802),
                zoom: 20.0,
              ))),
      // const VerticalDivider(
      //   thickness: 1,
      //   indent: 20,
      //   endIndent: 0,
      //   color: Colors.grey,
      // ),
      Visibility(
          visible: true,
          child: Expanded(
            flex: 20,
            child: Container(
              decoration: const BoxDecoration(
                // borderRadius: BorderRadius.circular(10),
                color: Colors.deepOrangeAccent,
              ),
              child: members.length > 0
                  ? MemberGrid(
                      players: members.keys.toList(),
                      filterFunction: _drawInitialLines,
                    )
                  : null,
            ),
          )),
    ]));
  }

  void initMembers() async {
    final String str = await rootBundle.loadString('assets/json/test.json');
    final jsonData = json.decode(str);

    final List<dynamic> features = jsonData['features'];

    final lines = features.where((f) {
      return f['geometry']['type'] == 'LineString';
    });

    setState(() {
      members = HashMap();

      int i = 0;
      lines.forEach((element) {
        final List<dynamic> locations = element['geometry']['coordinates'];
        i++;
        members[Player(MemberInfo('id_$i', 'nick_$i'), uniqueColor().value)] =
            locations.map((e) {
          return Location(e[0], e[1]);
        }).toList();
      });
    });
  }
}
