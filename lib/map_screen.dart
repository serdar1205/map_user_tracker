import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_user_tracker/directions_repository.dart';
import 'directions_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _googleMapController;
  Marker? _orign;
  Marker? _destinaion;
  //Directions? _info;
  static const _initialCameraPosition =
  CameraPosition(target: LatLng(37.931327, 58.390618), zoom: 14.5);

  int _polylineIdCounter = 1;
  Set<Polyline> _polyline = Set<Polyline>();
  static final Polyline _kPolyline = Polyline(
    polylineId: PolylineId('polyline1'),
    points: [
      LatLng(37.42796133580664, -122.085749655962),
      LatLng(37.43296265331129, -122.08832357078792),
    ],
    width: 5,
  );
  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';

    _polylineIdCounter++;

    _polyline.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points.map((e) => LatLng(e.latitude,
            e.longitude),).toList()
    ));
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
        centerTitle: false,
        backgroundColor: Colors.red,
        title: Text('Google Maps'),
        actions: [
          if (_orign != null)
            TextButton(
              child: Text(
                'Orign',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => _googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                      target: _orign!.position, zoom: 17.5, tilt: 50.0))),
            ),
          if (_destinaion != null)
            TextButton(
              child: Text('Destina', style: TextStyle(color: Colors.white)),
              onPressed: () => _googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(
                      target: _destinaion!.position, zoom: 17.5, tilt: 50.0))),
            )
        ],
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _initialCameraPosition,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                if (_orign != null) _orign!,
                if (_destinaion != null) _destinaion!,
              },
              polylines: {
               _kPolyline
              },
              onLongPress: _addMarker,
            ),

          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.location_on_outlined),
        onPressed: () => _googleMapController!.animateCamera(
            CameraUpdate.newCameraPosition(_initialCameraPosition)),
      ),
    );
  }

  _addMarker(LatLng pos) async {
    if (_orign == null || (_orign != null && _destinaion != null)) {
      setState(() {
        _orign = Marker(
            markerId: MarkerId('orign'),
            infoWindow: InfoWindow(title: 'Orign'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueGreen),
            position: pos);

        ///reset destination
        _destinaion = null;
      });
    } else {
      setState(() {
        _destinaion = Marker(
            markerId: MarkerId('destination'),
            infoWindow: InfoWindow(title: 'Destination'),
            icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            position: pos);

        /// reset destination

      });

      /// get direcions
      final directions = await DirectionsRepository()
          .getDirections(orign: _orign!.position, desination: pos);
      setState(() {

      });
    }
  }
}