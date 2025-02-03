import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teamloc/controller/gameinfo_controller.dart';
import 'package:teamloc/dto/json/location.dart';
import 'package:teamloc/member_grid.dart';
import 'package:teamloc/dto/json/player.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_randomcolor/flutter_randomcolor.dart';
import 'package:teamloc/member_grid_listview.dart';

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
  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polyLines = HashSet<Polyline>();
  Set<Polygon> polygons = HashSet<Polygon>();

  // Set<Polyline> polylines = const <Polyline>{};
  Set<Color> lineColors = Set();

  // Map<Player, List<Location>> members = HashMap();
  // Map<String, Location> members = HashMap();
  bool _drawPolygonEnabled = true;
  List<LatLng> _userPolyLinesLatLngList = <LatLng>[];
  bool _clearDrawing = false;
  int? lastXCoordinate, lastYCoordinate;

  @override
  void initState() {
    super.initState();

    initObjects();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   initMembers();
    // });
  }

  void initObjects() {

    final base_LAT = 37.346109;
    final base_LNG = 127.400802;
    final current_LAT = 37.495198389321736;
    final current_LNG = 128.3949100128851;
    final dev_LAT = base_LAT - current_LAT;
    final dev_LNG = base_LNG - current_LNG;
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
      ].map((e)=>LatLng(e.latitude-dev_LAT, e.longitude-dev_LNG)).toList(),
      // given color to polygon
      fillColor: Colors.green.withOpacity(0.3),
      // given border color to polygon
      strokeColor: Colors.green,
      geodesic: true,
      // given width of border
      strokeWidth: 4,
    ));
  }_clearPolygons() {
    setState(() {
      _polyLines.clear();
      _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }
  _toggleDrawing() {
    _clearPolygons();
    setState(() => _drawPolygonEnabled = !_drawPolygonEnabled);
  }
  _onPanEnd(DragEndDetails details) async {
    // Reset last cached coordinate
    lastXCoordinate = null;
    lastYCoordinate = null;

    if (_drawPolygonEnabled) {
      _polygons.removeWhere((polygon) => polygon.polygonId.value == 'user_polygon');
      _polygons.add(
        Polygon(
          polygonId: PolygonId('user_polygon'),
          points: _userPolyLinesLatLngList,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.4),
        ),
      );
      setState(() {
        _clearDrawing = true;
      });
    }
  }
  _onPanUpdate(DragUpdateDetails details) async {
    // To start draw new polygon every time.
    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }
    debugPrint(details.toString());
    if (_drawPolygonEnabled) {
      double x, y;
      // if (Platform.isAndroid) {
      //   // It times in 3 without any meaning,
      //   // We think it's an issue with GoogleMaps package.
      //   x = details.globalPosition.dx * 3;
      //   y = details.globalPosition.dy * 3;
      // } else if (Platform.isIOS) {
        x = details.globalPosition.dx;
        y = details.globalPosition.dy;
      // }

      // Round the x and y.
      int xCoordinate = x.round();
      int yCoordinate = y.round();

      // Check if the distance between last point is not too far.
      // to prevent two fingers drawing.
      if (lastXCoordinate != null && lastYCoordinate != null) {
        var distance = Math.sqrt(Math.pow(xCoordinate - lastXCoordinate!, 2) + Math.pow(yCoordinate - lastYCoordinate!, 2));
        // Check if the distance of point and point is large.
        if (distance > 80.0) return;
      }

      // Cached the coordinate.
      lastXCoordinate = xCoordinate;
      lastYCoordinate = yCoordinate;

      ScreenCoordinate screenCoordinate = ScreenCoordinate(x: xCoordinate, y: yCoordinate);

      final GoogleMapController controller = await _controller.future;
      LatLng latLng = await controller.getLatLng(screenCoordinate);

      try {
        // Add new point to list.
        _userPolyLinesLatLngList.add(latLng);

        _polyLines.removeWhere((polyline) => polyline.polylineId.value == 'user_polyline');
        _polyLines.add(
          Polyline(
            polylineId: PolylineId('user_polyline'),
            points: _userPolyLinesLatLngList,
            width: 2,
            color: Colors.blue,
          ),
        );
      } catch (e) {
        print(" error painting $e");
      }
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    Get.put(GameInfoController());
    return GetX<GameInfoController>(builder: (getMapController) {
      return Container(
          // padding: const EdgeInsets.all(10),
          child: Row(children: <Widget>[
        Expanded(
            flex: 80,
            child: GestureDetector(
                onPanUpdate: (_drawPolygonEnabled) ? _onPanUpdate : null,
                onPanEnd: (_drawPolygonEnabled) ? _onPanEnd : null,
                child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  getMapController.drawInitialLines();
                  //Geolocator.getCurrentPosition().then((p)=>mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(p.latitude, p.longitude))));
                  //개수리 : 37.495198389321736, 128.3949100128851

                  _controller.complete(controller);
                  mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(37.495198389321736,  128.3949100128851)));
                },
                    zoomGesturesEnabled: false,
                    scrollGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    zoomControlsEnabled: false,
                mapType: MapType.satellite,
                polygons: polygons,
                // polylines: getMapController.polylines.toSet(),
                markers: getMapController.locations.entries
                    .map<Marker>(
                        (e) => Marker(markerId: MarkerId(e.key.memberInfo.id), position: LatLng(e.value.lat, e.value.lon)))
                    .toSet(),
                initialCameraPosition: const CameraPosition(
                  target: const LatLng(37.346109, 127.400802),
                  zoom: 20.0,
                )))),

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
                child: MemberGridListView(
                  players: getMapController.players.values.toList(),
                  filterFunction: ({filter}) {
                    Get.find<GameInfoController>()
                        .drawInitialLines(filter: filter);
                  },
                ),
              ),
            )),
      ]));
    });
  }
}
