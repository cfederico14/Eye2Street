
/*import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:app_prova_tirocinio/avvisi.dart';
//import 'package:app_prova_tirocinio/segnali.dart';
import 'package:geolocator/geolocator.dart' as geolocation1;
import 'package:location/location.dart' ;
import 'Segnale.dart';
import 'limite.dart';
import 'package:location_platform_interface/location_platform_interface.dart' as geospeed;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_prova_tirocinio/provaAvvisiSegnali.dart';





void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
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
  
  Map<String, BitmapDescriptor> iconeSegnali={};
  StreamSubscription<geolocation1.Position>? _positionStream;
  List<Marker> listamarkers=[];
  Set<Marker> setmarkers = {};
  double _speed = 0.0;

  void creaIcone() async{
    iconeSegnali={};
    iconeSegnali["caduta massi"]= await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30,30)),"lib/images/caduta massi.png");
    iconeSegnali["incendio"]= await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30,30)),"lib/images/incendio.png");
    iconeSegnali["incrocio pericoloso"]= await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30,30)),"lib/images/incrocio pericoloso.png");
    iconeSegnali["nessunSegnale"]= await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30,30)),"lib/images/nessunSegnale.png");
  }


  void getCurrentLocation () async{
    Location location = Location();
    print("STO STAMPANDO LOCATIONNNNNNNNNNNNNNNNNNNNNNNNNNNN");
    print(location);

    
    location.getLocation().then(
      (location) {
        currentLocation = location;
        print("STO STAMPANDO CURRENT LOCATIONNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
        print(currentLocation);

    },
    );

    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
    );
    CollectionReference _collectionRef =
    FirebaseFirestore.instance.collection('Segnali');


    List<Segnale> segnali=[];
    creaPunto(DocumentSnapshot dati)
    {
      Segnale nuovo_segnale=
        Segnale(dati.reference.id, dati.get('categoria'), dati.get('specifica'), dati.get('inizio'), dati.get('fine'));
      print(nuovo_segnale);
      segnali.add(nuovo_segnale);
      print(segnali);
    }
    

    
    Future<BitmapDescriptor> creaBitmap(Segnale segnale) async{
      BitmapDescriptor markerbitmap = await BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(30,30)),"lib/images/"+segnale.specifica+'.png');
      return markerbitmap;
    }
    creaMarker  (Segnale segnale) {
      BitmapDescriptor? markerbitmap=iconeSegnali[segnale.specifica];
        listamarkers.add(Marker(
            markerId: MarkerId(segnale.docid),
            position: LatLng(segnale.inizio.latitude, segnale.inizio.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
          
    }
  
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('Segnali').get();
    final List<DocumentSnapshot> documents = result.docs;
    print('STAMPO IL PORCO DI DIOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO');
    documents.forEach((data) => creaPunto(data));
    segnali.forEach((segnale) => creaMarker(segnale));
    print('STAMPO MARKEEEEERSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS');
    print(listamarkers);
    setmarkers=Set<Marker>.of(listamarkers);
    
    

    

    GoogleMapController googleMapController = await _controller.future;


    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;
    


      googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          zoom: 16,
          target: LatLng(
            newLoc.latitude!, 
            newLoc.longitude!
            ),
          )));
      setState(() {});
     },
     );
  }
  

  
 
  


final geolocation1.LocationSettings locationsettings = geolocation1.LocationSettings(
  accuracy: geolocation1.LocationAccuracy.bestForNavigation,
  distanceFilter: 20,
);

  
@override
void initState()
{
  getCurrentLocation();
  

}

 


  @override
  Widget build(BuildContext context) {

    creaIcone();
    
    return SafeArea(
      child: Scaffold(
       
       
      body: currentLocation == null 
      ? const Center (child: Text("Loading. . .") )

      : Stack(
        
        children: <Widget>[

       
      
      
      GoogleMap(
        
        mapType: MapType.normal,
        markers: setmarkers.union(
        {
          
          Marker(
            markerId: const MarkerId("currentLocation"),
            position: LatLng(
              currentLocation!.latitude!, currentLocation!.longitude!),

            ),
            }),
          
        
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition (
          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 16),
        scrollGesturesEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
       
      ),
      
     // segnali(),


      limite(),





        
       // avvisi(segnali: []),
          provaAvvisiSegnali(segnali: [])
          
          
          
        
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
    return Future.error('Location services are disabled.');
  }

  permission = await geolocation1.Geolocator.checkPermission();
  if (permission == geolocation1.LocationPermission.denied) {
       permission = await geolocation1.Geolocator.requestPermission();
       if (permission == geolocation1.LocationPermission.denied) {
            return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == geolocation1.LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
  return await geolocation1.Geolocator.getCurrentPosition();
}
}*/







/* BACKUP LIST TILE


child:  ListTile( 
                              leading: Image.asset("lib/images/"+ segn1.specifica+'.png', width: 70, height: 40,),
                              title: AnimatedContainer(
                                                     height: 300,
                                                     width: 100,
                                                     duration: const Duration(seconds: 10),
                                                     curve: Curves.fastOutSlowIn,
                                                     decoration: BoxDecoration(
                                                                                  border: Border.all(color:  Color.fromARGB(255, 239, 50, 50), width: 5),
                                                                                  color: Color.fromARGB(237, 249, 126, 126),
                                                                                  borderRadius: BorderRadius.all(Radius.circular(17)),
                                                                                  
                                                     ),
                                              child: Center(
                                                child: Text(attivi.elementAt(attivi.length-1).descrizione),
                                              )
                                                     

                                            ),
                        
              
              
              



              AVVISIIIIII

              import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import'Segnale.dart';
import 'package:geolocator/geolocator.dart' as geolocation1;
import 'dart:async';

import 'firebase_options.dart';



class avvisi extends StatefulWidget {
   

  avvisi({Key? key, this.segnali}): super(key: key);
  List<Segnale>? segnali;

 @override
  State<avvisi> createState() => avvisiState();

}

class avvisiState extends State<avvisi> {

  StreamSubscription<geolocation1.Position>? _positionStream;

  

final geolocation1.LocationSettings locationsettings = geolocation1.LocationSettings(
  accuracy: geolocation1.LocationAccuracy.bestForNavigation,
  distanceFilter: 20,
);
  List<Segnale> attivi=[];
  List<Segnale> disattivi=[];
  String tiposegnale="";
  List<Segnale>? listasegnali;
  Future<void>? _future;

  void mostraSegnale(Segnale segnale)
  {
    this.tiposegnale=segnale.specifica;
  }

  double calcoladistanzaInizio(Position position, Segnale segnale){
    return(geolocation1.Geolocator.distanceBetween(position.latitude, position.longitude, segnale.inizio.latitude, segnale.inizio.longitude));
  }

   double calcoladistanzaFine(Position position, Segnale segnale){
    return(geolocation1.Geolocator.distanceBetween(position.latitude, position.longitude, segnale.fine.latitude, segnale.fine.longitude));
  }


  void checkAggiunta(Position position, Segnale segnale)
  { 
    if(calcoladistanzaFine(position, segnale)<10){
      if(!disattivi.contains(segnale))
        disattivi.add(segnale);
      if(attivi.remove(segnale)){
        if(attivi.length>0)
         {
          mostraSegnale(attivi.elementAt(attivi.length-1));
          print("STAMPO ATTIVIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII");
          print(attivi.length);
         }
        else
          tiposegnale="Nessun segnale!";
      }
    }else{
      if(calcoladistanzaInizio(position, segnale)<10 && !attivi.contains(segnale) && !disattivi.contains(segnale)){
        attivi.add(segnale); 
        mostraSegnale(segnale);
      }
    }
  }

  

  creaPunto(DocumentSnapshot dati)
    {
      Segnale nuovo_segnale=
        Segnale(dati.reference.id, dati.get('categoria'), dati.get('specifica'),dati.get('descrizione'), dati.get('nomeSegnale'), dati.get('inizio'), dati.get('fine'));
      print(nuovo_segnale);
      listasegnali?.add(nuovo_segnale);
      print(listasegnali);
    }

                                                
  Future<void> getSegnali() async{
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
    );
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('Segnali').get();
    final List<DocumentSnapshot> documents = result.docs;
    print('STAMPO IL PORCO DI DIOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO');
    documents.forEach((data) => creaPunto(data));
  }
                                                          

 @override void initState() {
   

    listasegnali=[];
    _future=getSegnali();
    Map<String, double> distanze={};
     
     _positionStream =
            geolocation1.Geolocator.getPositionStream(locationSettings: locationsettings)
            .listen((position){
              listasegnali?.forEach((segnale) =>checkAggiunta(position, segnale));
        
            });
            super.initState();
  }

  @override
Widget build(BuildContext context) {
 return FutureBuilder(
   future: _future,
   builder: (context, snapshot) {
     if (snapshot.connectionState != ConnectionState.done) {
       return Padding(
      padding: EdgeInsets.all(16.0),
      
      child: Align(
        
        alignment: Alignment.topCenter,
        
        child: DecoratedBox(decoration: BoxDecoration(
          border: Border.all(color:  Color.fromARGB(255, 255, 182, 54), width: 5),
          color: Color.fromARGB(255, 144, 120, 79),
          borderRadius: BorderRadius.all(Radius.circular(17)),
          
        ) ,
        
        child:  ListTile( 

          title: Text('Caricamento...'),
          leading: 
          Image.asset("lib/images/limite_prova.png", width: 70, height: 40,),
          trailing: Icon(Icons.speed_outlined),
          
        ),
        
        ),  
      ),
      );
  }
     
     return Padding(
      padding: EdgeInsets.all(16.0),
      
      child: Align(
        
        alignment: Alignment.topCenter,
        
        child: DecoratedBox(decoration: BoxDecoration(
          border: Border.all(color:  Color.fromARGB(255, 255, 182, 54), width: 5),
          color: Color.fromARGB(255, 144, 120, 79),
          borderRadius: BorderRadius.all(Radius.circular(17)),
          
        ) ,
        child:  ListTile( 

          title: Text('$tiposegnale'),
          leading: 
          Image.asset("lib/images/limite_prova.png", width: 70, height: 40,),
          trailing: Icon(Icons.speed_outlined),
          
        ),
        
        ),  
      ),
      );
    }
 );
}

  
}


SEGNALIIIIIIII

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class segnali extends StatelessWidget {
   segnali({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: 
      Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          height: 100,
          width: 40,
          child: DecoratedBox(
             decoration: BoxDecoration(
               
               color: Colors.grey[400],
               borderRadius: BorderRadius.all(Radius.circular(15.0)),
               
             ),
             child: Column(
               children: <Widget>[
                 Icon(Icons.abc)
               ],
             ),
             
             
            
            
            ),
        ),
        ),
      );
  }
}

            ),*/