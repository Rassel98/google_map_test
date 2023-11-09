import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const customSwatch = MaterialColor(
    0xFFFF5252,
    <int, Color>{
      50: Color(0xFFFFEBEE),
      100: Color(0xFFFFCDD2),
      200: Color(0xFFEF9A9A),
      300: Color(0xFFE57373),
      400: Color(0xFFEF5350),
      500: Color(0xFFFF5252),
      600: Color(0xFFE53935),
      700: Color(0xFFD32F2F),
      800: Color(0xFFC62828),
      900: Color(0xFFB71C1C),
    },
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primarySwatch: customSwatch,
      ),
      home: LocationPickerMap(),
    );
  }
}

class LocationPickerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LocationPickerMap(),
    );
  }
}

class LocationPickerMap extends StatefulWidget {
  @override
  _LocationPickerMapState createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  GoogleMapController? mapController;
  late Position currentPosition;
  late Marker _selectedLocation;
  late LatLng loc = const LatLng(23.456, -122.7545); // Make it nullable
  double? selectedLatitude; // Make it nullable
  double? selectedLongitude;
  bool isLoading = true;
  String dfg = 'No results found.';

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(),
      "images/icon128.png",
    ).then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<void> getCurrentPosition() async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      print(position.longitude);
      setState(() {
        currentPosition = position;
        _selectedLocation = Marker(
          markerId: const MarkerId('current_location '),
          position: LatLng(position.latitude, position.longitude),
          draggable: true,
          visible: true,
           icon: markerIcon,
          onDragEnd: (value) {
            print('gfdkgfkdsg ${value.longitude} ${value.longitude}');
          },
        ); //
        isLoading = false;
      });
    }).catchError((e) {
      debugPrint(e);
    });
  } // Make it nullable

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentPosition();
    addCustomIcon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const LinearProgressIndicator()
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    setState(() {
                      mapController = controller;
                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: true,
                  mapType: MapType.normal, layoutDirection: TextDirection.ltr,
                  cameraTargetBounds: CameraTargetBounds.unbounded,
                  initialCameraPosition: CameraPosition(target: LatLng(currentPosition.latitude, currentPosition.longitude), zoom: 14.5),
                  onCameraMove: (CameraPosition? position) {
                    selectedLatitude = position?.target.latitude;
                    selectedLongitude = position?.target.longitude;
                    // if(currentPosition != position!.target){
                    //   setState(() {
                    //     currentPosition=position.target;
                    //   });
                    // }
                  },
                  onCameraMoveStarted: () {
                    print("fjkvgdkjfvdfv      camera started     dfgvdlfgdflgfd");
                  },
                  onCameraIdle: () {
                    print('camera idl');
                    placemarkFromCoordinates(selectedLatitude!, selectedLongitude!).then((placemarks) {
                      if (placemarks.isNotEmpty) {

                        Placemark placemark = placemarks[0];
                        String? locality = placemark.locality;
                        String? country = placemark.country;
                        // Print or use the information as needed
                        print('Name: ${placemark.name}');
                        print('Postal Code: ${placemark.postalCode}');
                        print('Locality: $locality');
                        print('Country: $country');
                        setState(() {
                          dfg =
                              'Name: ${placemark.name} Postal Code: ${placemark.postalCode} Locality: ${placemark.locality} Country : ${placemark.country} street: ${placemark.subAdministrativeArea} administrativeArea: ${placemark.administrativeArea}';
                        });
                      }
                    });
                  },
                  markers: {_selectedLocation},
                  onTap: _onMapTap, // Listen for taps on the map
                ),
                // Align(
                //   alignment: Alignment.center,
                //   child: Image.asset(
                //     "images/location_map_marker.png",
                //     height: 30,
                //     width: 30,
                //   ),
                // ),
                Positioned(
                    top: 40,
                    right: 20,
                    left: 20,
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black), color: Colors.white),
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        selectedLongitude == null ? "pickyourLocation" : dfg,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ))
              ],
            ),
    );
  }

  void _onMapTap(LatLng latLng) {
    print(latLng.toString());
    setState(() {
      _selectedLocation = Marker(
        markerId: MarkerId("SelectedLocation"),
        position: latLng,
        draggable: true,
        visible: true,
        // icon: markerIcon,
        onDragEnd: (value) {
          print('gfdkgfkdsg ${value.longitude} ${value.longitude}');
        },
      );

      // Store the selected coordinates
      selectedLatitude = latLng.latitude;
      selectedLongitude = latLng.longitude;
    });

    placemarkFromCoordinates(selectedLatitude!, selectedLongitude!).then((placemarks) async {
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        //Print or use the information as needed
        print('Name: ${placemark.name}');
        print('street: ${placemark.street}');
        print('administrativeArea: ${placemark.administrativeArea}');
        print('administrativeArea: ${placemark.subAdministrativeArea}');
        print('administrativeArea: ${placemark.subLocality}');
        // var name=await getLocationInfoFromPlusCode(placemark.name!);
        //  print(name);
        setState(() {
          dfg =
              'Name: ${placemark.name}  Postal Code: ${placemark.postalCode} Locality: ${placemark.locality} Country : ${placemark.country} street: ${placemark.street} administrativeArea: ${placemark.administrativeArea}';
        });
      }
    });
  }
}

Future<String> getLocationInfoFromPlusCode(String plusCode) async {
  const apiKey = 'AIzaSyAcaq8cpLQSZLS03MLmto5OXxBs218UZRw'; // Replace with your Google Maps API key
  final apiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?plus_code=$plusCode&key=$apiKey';

  final response = await get(Uri.parse(apiUrl));
  print(response.body);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print(data);
    if (data['status'] == 'OK' && data['results'] is List && data['results'].isNotEmpty) {
      // Extract location information, e.g., formatted address
      final formattedAddress = data['results'][0]['formatted_address'];
      return formattedAddress;
    }
  }

  return 'Location information not found';
}

//
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;
//   late Position currentPosition;
//   LatLng? destLocation = LatLng(37.78754, -122.34757345);
//   Marker? sourse;
//   final Completer<GoogleMapController?> _controller = Completer();
//
//   String? _adress;
//
//   Future<bool> handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }
//     return true;
//   }
//
//   Future<void> getCurrentPosition() async {
//     final GoogleMapController ? controller=await _controller.future;
//     final hasPermission = await handleLocationPermission();
//     if (!hasPermission) return;
//     await Geolocator.getCurrentPosition().then((Position position) {
//       setState(() {
//         currentPosition = position;
//       });
//       controller?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(currentPosition.latitude,currentPosition.longitude),zoom: 14.5)));
//       setState(() {
//          destLocation = LatLng(currentPosition.latitude,currentPosition.longitude);
//       });
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: Stack(
//
//         children: <Widget>[
//           GoogleMap(
//             myLocationEnabled: true,
//               myLocationButtonEnabled: true,
//               zoomControlsEnabled: true,
//               initialCameraPosition: CameraPosition(
//             target: destLocation!,
//             zoom: 15
//           ),
//             onCameraMove: (CameraPosition?position){
//               if(destLocation!=position!.target){
//                 setState(() {
//                   destLocation=position.target;
//                 });
//               }
//             },
//             onCameraIdle: (){
//               print('camera idl');
//             }
//             ,
//             onTap: (latLong){
//               print(latLong);
//               setState(() {
//                 _adress="${latLong.latitude}     ${latLong.longitude}";
//               });
//             },
//             onMapCreated: (GoogleMapController ctr){
//               _controller.complete(ctr);
//             },
//
//
//           ),
//           Align(alignment: Alignment.center,child: Image.asset("images/location_map_marker.png",height: 45,width: 45,),),
//           Positioned(
//             top: 40,
//               right: 20,
//               left: 20,
//               child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.black),
//               color: Colors.white
//             ),
//                 padding: EdgeInsets.all(20),
//                 child: Text(_adress??"pickyourLocation",overflow: TextOverflow.visible,softWrap: true,),
//           ))
//
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => const DownloadFilePage(),
//             )),
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
