class Location {
  double lon;
  double lat;
  Location(this.lon, this.lat);
  @override
  String toString() {
    return 'lon:$lon, lat:$lat';
  }
}
