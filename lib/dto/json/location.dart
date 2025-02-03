class Location {
  double lon;
  double lat;
  Location({required this.lon, required this.lat});
  @override
  String toString() {
    return 'lon:$lon, lat:$lat';
  }
}
