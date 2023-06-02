import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocation_methoda/models/direction_model.dart';
import 'package:geolocation_methoda/direction_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../components/constant.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  static const LatLng destination = LatLng(37.33429383, -122.06600055);

  static const _initialCameraPosition =
      CameraPosition(target: LatLng(37.33500926, -122.03272188), zoom: 11.5);

  List<LatLng> polylinecordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  _addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline =
        Polyline(polylineId: id, color: Colors.red, points: polylinecordinates);
    polylines[id] = polyline;
    setState(() {});
  }

  void getPolyPoint() async {
    print("hi");

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        PointLatLng(destination.latitude, destination.longitude));

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylinecordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    _addPolyLine();
  }

  @override
  void initState() {
    getPolyPoint();
    _addPolyLine();
    super.initState();
  }

  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Track order",
          ),
          actions: [
            if (_origin != null)
              TextButton(
                  onPressed: () => _googleMapController!.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: _origin!.position, zoom: 14.5, tilt: 50.0))),
                  child: const Text('ORIGIN')),
            if (_destination != null)
              TextButton(
                  onPressed: () => _googleMapController!.animateCamera(
                      CameraUpdate.newCameraPosition(CameraPosition(
                          target: _destination!.position,
                          zoom: 14.5,
                          tilt: 50.0))),
                  child: const Text('DEST'))
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (controller) => _googleMapController = controller,
              polylines: {
                if (_info != null)
                  Polyline(
                      polylineId: const PolylineId("overview_polyline"),
                      points: _info!.polylinePoints
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                      color: Colors.red,
                      width: 5)
              },
              markers: {
                if (_origin != null) _origin!,
                if (_destination != null) _destination!
              },
              onLongPress: _addMarker,
            ),
            if (_info != null)
              Positioned(
                  top: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6.0, horizontal: 12.0),
                    decoration: BoxDecoration(
                        color: Colors.yellowAccent,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 6.0)
                        ]),
                    child: Text(
                      '${_info!.totalDistance}, ${_info!.totalDuration}',
                      style: const TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.w600),
                    ),
                  ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _googleMapController!.animateCamera(_info != null
              ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
              : CameraUpdate.newCameraPosition(_initialCameraPosition)),
          child: const Icon(Icons.center_focus_strong),
        ));
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
            markerId: const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);
        _destination = null;
        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos);
      });

      final directions = await DirectionRepository()
          .getDirections(origin: _origin!.position, destination: pos);
      setState(() => _info = directions);
    }
  }
}
