import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(title: ''),
    );
  }
}



class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String location ='Null, Press Button';
  String Address = 'search';

  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }
  Future<void> GetAddressFromLatLong(Position position)async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[0];
    Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(()  {
    });
  }




  @override
  Widget build(BuildContext context) {

    Position position;
    double latitude = 45;
    double longitude = 45;



    return Scaffold(
      body: Center(
        child: FlutterMap(
          options: MapOptions(
            center: latLng.LatLng(latitude, longitude),
            zoom: 12.0,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://api.mapbox.com/styles/v1/arthurkrantsevich/ckzz5mbpm000314s33xb1gf9l/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYXJ0aHVya3JhbnRzZXZpY2giLCJhIjoiY2t6ejR3OXA2MDZmZzNscXZyMG43Z212dSJ9.K7DTU1n4v2G0ZamMtH73nw",
              additionalOptions: {
                'accessToken' : 'pk.eyJ1IjoiYXJ0aHVya3JhbnRzZXZpY2giLCJhIjoiY2t6ejR3OXA2MDZmZzNscXZyMG43Z212dSJ9.K7DTU1n4v2G0ZamMtH73nw',
                'id' : 'mapbox.mapbox-streets-v8'
              },
            ),
            MarkerLayerOptions(
              markers: [
                Marker(
                  width: 50.0,
                  height: 50.0,
                  point: latLng.LatLng(31.050478, -7.931633),
                  builder: (ctx) => Container(
                    child: Image.asset(
                        'assets/images/logo.png'
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          position = await _getGeoLocationPosition();
          location ='Lat: ${position.latitude} , Long: ${position.longitude}';
          GetAddressFromLatLong(position);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(Address),
          ));
        },
        backgroundColor: Colors.green,
        child: const Text("Click!"),
      ),
    );


  }
}
