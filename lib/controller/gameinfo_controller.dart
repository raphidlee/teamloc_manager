import 'dart:collection';
import 'dart:convert';
// import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_randomcolor/flutter_randomcolor.dart' as rc;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../constants.dart';
import '../dto/json/location.dart';
import '../dto/json/player.dart';

class GameInfoController extends GetxController {
  RxSet<Polyline> polylines = <Polyline>{}.obs;
  RxMap<Player, Location> locations = <Player, Location>{}.obs;
  RxMap<String, Player> players = <String, Player>{}.obs;
  RxList<PlutoRow> rows = <PlutoRow>[
    PlutoRow(
      key: UniqueKey(),
      checked: true,
      cells: {
        'color': PlutoCell(value: Color(0)),
        'nick': PlutoCell(value: '1'),
        'status': PlutoCell(value: '1'),
      },
    )
  ].obs;

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    // await fetchBaseData();
    await initMembers();
    // drawInitialLines();
  }

  @override
  void dispose() {
    super.dispose();
    SSEClient.unsubscribeFromSSE();
  }

  initMembers() async {
    SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: 'https://teamloc-server-449244787941.asia-northeast1.run.app/api/events',
        header: {
          "Cookie":
              'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
          "Accept": "text/event-stream",
          "Cache-Control": "no-cache",
        }).listen(
      (event) {
        debugPrint('event received');
        final decoded = json.decode(event.data!);
        final type = decoded['type'];
        debugPrint(type);
        final _players = Map<String, Player>();
        final _locations = Map<Player, Location>();
        if (type == 'INITIAL_DATA') {
          final data = decoded['data'] as Map<String, dynamic>;
          for (final e in data.entries) {
            final player = Player(
                MemberInfo(e.key, 'player_${e.key}'), uniqueColor().value);
            _players.putIfAbsent(e.key, () => player);
            _locations.putIfAbsent(player,
                () => Location(lat: e.value['lat'], lon: e.value['lon']));
          }

          players(_players);
          locations(_locations);
        } else if (type == "PERSONAL_ACTIVATION") {
          final data = decoded['data'];
          final pId = data['player'];
          final lat = data['lat'];
          final lon = data['lon'];
          final p = locations.keys.where((p) => p.memberInfo.id == pId).first;
          locations.update(p, (l) => Location(lat: lat, lon: lon));
          debugPrint('locations updated ${pId}');
        } else if (type == "PLAYER_UPDATED") {
          final data = decoded['data'];
          final pId = data['uid'];
          final status = data['status'];

          players.update(pId, (p) {
            p.status = status;
            return p;
          });

          final finishedCount = players.values.where((p)=>'FINISHED'==p.status).length;

          if(finishedCount>0){
            Get.snackbar('Finished Players', '$finishedCount',snackPosition: SnackPosition.BOTTOM);
          }
        }
      },
    );
  }

  Color uniqueColor() {
    return rc.RandomColor.getColorObject(rc.Options());
  }

  void drawInitialLines({lastCount = 55, Set<String>? filter}) {
    // polylines(locations.entries
    //     .where((entry) =>
    //         filter == null ||
    //         filter.contains('[<\'${entry.key.memberInfo.id}\'>]'))
    //     .map((entry) {
    //   final player = entry.key;
    //   final memberInfo = player.memberInfo;
    //   final locations = entry.value;
    //   final points = List<LatLng>.from(
    //       locations.take(lastCount).map((e) => LatLng(e.lat, e.lon)).toList());
    //   return Polyline(
    //       polylineId: PolylineId(memberInfo.id),
    //       width: 2,
    //       color: Color(player.lineColor),
    //       points: points);
    // }).toSet());
  }
}
