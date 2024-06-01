import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:stbbankapplication1/services/location_provider.dart';

class MapScreen extends StatefulWidget {
  final double lat;
  final double long;
  final LocationInfo currentLocation;

  const MapScreen({
    Key? key,
    required this.currentLocation,
    required this.lat,
    required this.long,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  String googleAPiKey = "AIzaSyBn9NQtMUKL6_iYfLiAW6l8Y1AFtpSxb0Q";

  double? distance;
  double? estimatedTime;
  String travelMode = 'driving'; 

  @override
  void initState() {
    super.initState();
    _addMarker(LatLng(widget.lat, widget.long), "destination", BitmapDescriptor.defaultMarker);
    _getDirections();
  }

  @override
  Widget build(BuildContext context) {
    LocationInfo currentLocation = widget.currentLocation;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  currentLocation.latitude,
                  currentLocation.longitude,
                ),
                zoom: 15,
              ),
              tiltGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              zoomGesturesEnabled: true,
              onMapCreated: _onMapCreated,
              markers: Set<Marker>.of(markers.values),
              polylines: Set<Polyline>.of(polylines.values),
            ),
            Positioned(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTransportButton('Driving', Icons.directions_car, 'driving'),
                  _buildTransportButton('Walking', Icons.directions_walk, 'walking'),
                ],
              ),
            ),
            if (distance != null && estimatedTime != null)
              Positioned(
                bottom: 16.0,
                left: 16.0,
                right: 16.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Distance: ${distance!.toStringAsFixed(0)} km\n'
                    'Estimated Time: ${estimatedTime!.toStringAsFixed(0)} minutes',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: descriptor,
      position: position,
    );
    markers[markerId] = marker;
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> _getDirections() async {
    var currentLocation = widget.currentLocation;
    var destination = LatLng(widget.lat, widget.long);

    var url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$travelMode&key=$googleAPiKey';

    var response = await http.get(Uri.parse(url));
    var json = jsonDecode(response.body);

    if (json['status'] == 'OK') {
      var routes = json['routes'][0];
      var legs = routes['legs'][0];

      distance = legs['distance']['value'] / 1000; 
      estimatedTime = legs['duration']['value'] / 60; 

      var steps = legs['steps'];
      polylineCoordinates.clear();
      for (var step in steps) {
        var startLocation = step['start_location'];
        var endLocation = step['end_location'];
        polylineCoordinates.add(LatLng(startLocation['lat'], startLocation['lng']));
        polylineCoordinates.add(LatLng(endLocation['lat'], endLocation['lng']));
      }

      _addPolyLine();
      setState(() {});
    }
  }

  Widget _buildTransportButton(String label, IconData icon, String mode) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0), 
          ),
          padding: EdgeInsets.all(8.0), 
          child: IconButton(
            onPressed: () {
              setState(() {
                travelMode = mode;
                _getDirections();
              });
            },
            icon: Icon(icon),
            tooltip: label,
          ),
        ),
        SizedBox(height: 4), 
        Text(label),
      ],
    );
  }
}
