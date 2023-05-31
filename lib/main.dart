import 'dart:async';

import 'dart:io';

import 'dart:typed_data';

import 'package:app_prova_tirocinio/controlloLocation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocation1;
import 'package:location/location.dart' ;
import 'Segnale.dart';
import 'limite.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_prova_tirocinio/provaAvvisiSegnali.dart';
import 'package:app_prova_tirocinio/controlloLocation.dart';
import 'dart:ui' as ui;





void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye2Street',
      home: MapSample(),
      
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  


  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();




  
  
  LocationData? currentLocation;
  
 
  StreamSubscription<geolocation1.Position>? _positionStream;
  List<Marker> listamarkers=[];
  Set<Marker> setmarkers = {};
  LocationData? oldLoc;
  BitmapDescriptor? indicatorebtmp;
  Timer? steadyTimeout;
  bool _steady = true;

  

  void getCurrentLocation () async{
    Location location = Location();
    location.getLocation().then(
      (location) {
        currentLocation = location;
        
        setState(() {
          
        });
    },
    
    );
    GoogleMapController googleMapController = await _controller.future;


    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
    );
    CollectionReference _collectionRef = FirebaseFirestore.instance.collection('Segnali');


    List<Segnale> segnali=[];
    creaPunto(DocumentSnapshot dati)
    {
      Segnale nuovo_segnale=
        Segnale(dati.reference.id, dati.get('categoria'), dati.get('specifica'), dati.get('descrizione'), dati.get('nomeSegnale'), dati.get('inizio'), dati.get('fine'));
      segnali.add(nuovo_segnale);
    }

    
    

   
    
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: 40);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }



  
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('Segnali').get();
    final List<DocumentSnapshot> documents = result.docs;
    documents.forEach((data) => creaPunto(data));
    BitmapDescriptor bitmp;


    await Future.forEach<Segnale>(segnali, (segnale) async{
      Uint8List markerIcon = await getBytesFromAsset("lib/images/"+segnale.specifica+".png", 40);
      bitmp=BitmapDescriptor.fromBytes(markerIcon);
     
     
      listamarkers.add(Marker(markerId: MarkerId(segnale.docid),
            position: LatLng(segnale.inizio.latitude, segnale.inizio.longitude),
            icon: bitmp,
        )); 
    });

    setmarkers=Set<Marker>.of(listamarkers);
    

    location.onLocationChanged.listen((newLoc) {
      if(oldLoc == null)
        oldLoc = newLoc;
      currentLocation = newLoc;
      if(geolocation1.Geolocator.distanceBetween(oldLoc!.latitude!, oldLoc!.longitude!, currentLocation!.latitude!, currentLocation!.longitude!) >= 10){
        oldLoc = null;
        steadyTimeout = null;
        _steady = false;
      }
        

      if(steadyTimeout == null){
        steadyTimeout=Timer(Duration(seconds: 10), () {
          if(geolocation1.Geolocator.distanceBetween(oldLoc!.latitude!, oldLoc!.longitude!, currentLocation!.latitude!, currentLocation!.longitude!) < 10)
            _steady = true;
            //controlloLocation(steady: _steady);
        });
        
      }
      
      
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 16.8,
          target: LatLng(
            newLoc.latitude!, 
            newLoc.longitude!
            ),
          
          )
          )
          );
      setState(() {});
     },
     );

     
  }
  

  
 
  


  final geolocation1.LocationSettings locationsettings = geolocation1.LocationSettings(
    accuracy: geolocation1.LocationAccuracy.bestForNavigation,
    distanceFilter: 1,
    
  );
  

 /* bool sameLocation(LocationData? currentLocation){
    LocationData? prec_location=currentLocation;
    const time = const Duration(minutes: 1);
    Timer.periodic(time, (Timer t) => prec_location==currentLocation);
    return(prec_location==currentLocation);

  }*/
  
@override
void initState()
{
  _determinePosition();
  getCurrentLocation();
   setState(() {
    
  });
  creaIndicatore();
  
  super.initState();
 
}

 


  @override
  Widget build(BuildContext context) {

    //creaIcone();
    creaIndicatore();
    
    return SafeArea(
      child: Scaffold(
       
       
      body: currentLocation == null 
      ? 
            
                    Center(
                      child: CircularProgressIndicator(
                                backgroundColor: Color.fromARGB(255, 0, 174, 255),
                              ),
                    )          
      
      : Stack(
        
        children: <Widget>[

      
      
      GoogleMap(
        trafficEnabled:true,
        mapType: MapType.normal,
        markers: setmarkers.union(
        {
          
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
            rotation: currentLocation!.heading!,
            icon: indicatorebtmp! ,
            
            
          )
            
            }),
            
          
        
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition (
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 16.8,
          
          ),
        scrollGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          
        },
       
      ),
      
      
     // segnali(),


      limite(),

      provaAvvisiSegnali(segnali: []),
      
      
          
          
        
       ],
       
       
      ),
     
    ),
    
    );
  }
  
//Controllo permessi geolocalizzazione
Future<geolocation1.Position> _determinePosition() async {
  bool serviceEnabled;
  geolocation1.LocationPermission permission;
  serviceEnabled = await geolocation1.Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Accesso alla posizione non possibile');
  }
  
  permission = await geolocation1.Geolocator.checkPermission();
  if (permission == geolocation1.LocationPermission.denied) {
       permission = await geolocation1.Geolocator.requestPermission();
       if (permission == geolocation1.LocationPermission.denied) {
            return Future.error('Accesso alla posizione non permesso');
    }
  }
  
  if (permission == geolocation1.LocationPermission.deniedForever) {
    return Future.error(
      'Acccesso alla posizione negato, non è possibile effettuare ancora la richiesta.');
  } 
  
  return await geolocation1.Geolocator.getCurrentPosition();
}

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future<void> creaIndicatore() async {
    Uint8List indicatoreIcon = await getBytesFromAsset('lib/images/indicatore.png', 40);
    indicatorebtmp=BitmapDescriptor.fromBytes(indicatoreIcon);
    
  }

  
}