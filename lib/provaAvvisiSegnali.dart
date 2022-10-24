import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import'Segnale.dart';
import 'package:geolocator/geolocator.dart' as geolocation1;
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class provaAvvisiSegnali extends StatefulWidget{
  
  provaAvvisiSegnali({Key? key, this.segnali}): super(key: key);
  List<Segnale>? segnali;

    @override
  State<provaAvvisiSegnali> createState() => provaAvvisiSegnaliState();

}
class provaAvvisiSegnaliState extends State<provaAvvisiSegnali>{


  StreamSubscription<geolocation1.Position>? _positionStream;

  

final geolocation1.LocationSettings locationsettings = geolocation1.LocationSettings(
  accuracy: geolocation1.LocationAccuracy.bestForNavigation,
  distanceFilter: 1,
);
  List<Segnale> attivi=[];
  List<Segnale> disattivi=[];
  String tiposegnale="";
  List<Segnale>? listasegnali;
  static final sfondo_rosso= Color.fromARGB(255, 238, 132, 132);
  static final bordo_rosso= Color.fromARGB(255, 255, 87, 87);
  static final sfondo_verde=Color.fromARGB(213, 86, 143, 95);
  static final bordo_verde=Color.fromARGB(185, 27, 105, 40);
  static final sfondo_nero=Color.fromARGB(205, 95, 84, 84);
  static final bordo_nero=Color.fromARGB(179, 166, 155, 155);
  static final color_widget=Color.fromARGB(205, 95, 84, 84);
  Color sfondo= sfondo_verde;
  Color bordo= bordo_verde;
  Segnale segnaleVuoto=new Segnale("noDoc", "mock", "nessunSegnale","descr","Nessun segnale", new GeoPoint(0, 0), new GeoPoint(0,0));
  Segnale segn1 = new Segnale("noDoc", "mock", "nessunSegnale","descr","Nessun segnale", new GeoPoint(0, 0), new GeoPoint(0,0));
  Segnale segn2 = new Segnale("noDoc", "mock", "nessunSegnale","descr","Nessun segnale",  new GeoPoint(0, 0), new GeoPoint(0,0));
  Segnale segn3 = new Segnale("noDoc", "mock", "nessunSegnale","descr","Nessun segnale", new GeoPoint(0, 0), new GeoPoint(0,0));
  Segnale segnaleRimosso= new Segnale("noDoc", "mock", "nessunSegnale","descr","Nessun segnale", new GeoPoint(0, 0), new GeoPoint(0,0));
  Future<void>? _future;
  bool nuovosegnale=false;
  bool fineSegnale=false;
  String nomeSegnale='';
  void mostraSegnale(Segnale segnale)
  {
    this.tiposegnale=segnale.specifica;
    this.nomeSegnale=segnale.nomeSegnale;
    if(segnale.categoria=="pericolo")
    {
      sfondo=sfondo_rosso;
      bordo=bordo_rosso;
    }
    if(attivi.length==0){
      sfondo=sfondo_verde;
      bordo=bordo_verde;
      segn1= segnaleVuoto;
      segn2= segnaleVuoto;
      segn3= segnaleVuoto;
    }else{
      if(attivi.length==1){
        segn1=attivi.elementAt(0);
        segn2= segnaleVuoto;
        segn3= segnaleVuoto;
      }else{
        if(attivi.length==2){
        segn1=attivi.elementAt(1);
        segn2= attivi.elementAt(0);
        segn3= segnaleVuoto;
        }else{
          segn1=attivi.elementAt(attivi.length-1);
          segn2= attivi.elementAt(attivi.length-2);
          segn3= attivi.elementAt(attivi.length-3);
        }
      }
    }
  }
  double calcoladistanzaInizio(Position position, Segnale segnale){
    return(geolocation1.Geolocator.distanceBetween(position.latitude, position.longitude, segnale.inizio.latitude, segnale.inizio.longitude));
  }

  


  void checkAggiunta(Position position, Segnale segnale)
  { 
    if(calcoladistanzaFine(position, segnale)<50){
      if(!disattivi.contains(segnale))
        disattivi.add(segnale);
      if(attivi.remove(segnale)){
        fineSegnale=true;
        FlutterRingtonePlayer.play(  
        fromAsset: "lib/sounds/fine.wav", // will be the sound on Android
        ); 
        segnaleRimosso=segnale;
        const time = const Duration(seconds: 3);
        Timer.periodic(time, (Timer t) => fineSegnale=false);

        if(attivi.length>0)
         {
          mostraSegnale(attivi.elementAt(attivi.length-1));
         }
        else
          mostraSegnale(segnaleVuoto);
      }
    }else{
      if(calcoladistanzaInizio(position, segnale)<50 && !attivi.contains(segnale) && !disattivi.contains(segnale)){
        attivi.add(segnale); 
        FlutterRingtonePlayer.play(  
        fromAsset: "lib/sounds/inizio.wav", 
        ); 
        mostraSegnale(segnale);
        nuovosegnale=true;
        const time = const Duration(seconds: 5);
        Timer.periodic(time, (Timer t) => nuovosegnale=false);
      }
    }
  }

  

  creaPunto(DocumentSnapshot dati)
    {
      Segnale nuovo_segnale=
        Segnale(dati.reference.id, dati.get('categoria'), dati.get('specifica'), dati.get('descrizione'), dati.get('nomeSegnale'), dati.get('inizio'), dati.get('fine'));
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
        return Column(
            children: [
            Padding(
            padding: EdgeInsets.all(16.0),
      
            child: Align(
            
              alignment: Alignment.topCenter,
            
                child: DecoratedBox(decoration: BoxDecoration(
                border: Border.all(color:  Color.fromARGB(255, 164, 164, 164), width: 5),
                color: Color.fromARGB(255, 247, 247, 247),
                borderRadius: BorderRadius.all(Radius.circular(17)),
              
              
              ),
            
              child:  ListTile( 

                title: Text('Caricamento...'),
              
              
              
            ),
            
            ),  
      ),
      ),
      Padding(
        padding: EdgeInsets.all(16),
        child: 
        Align(
          alignment: Alignment.centerRight,
        
          child: SizedBox(
            height: 120,
            width: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(
               
                color: color_widget,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
               
              ),
              child: Column(
               children: <Widget>[
                
               ],
             ),
             
             
            
            
            ),
        ),
        ),
      ),
         ],
       );
  }else{
    if(fineSegnale){
      return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              
              child: Align(
                
                alignment: Alignment.topCenter,
                
                child: DecoratedBox(decoration: BoxDecoration(
                  border: Border.all(color:  bordo_verde, width: 5),
                  color: sfondo_verde,
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  
                ) ,
                child:  ListTile( 
                  
                  title: Text('Fine ' +segnaleRimosso.nomeSegnale,
                              style: GoogleFonts.lato(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                

                              ),
                              ),
                  leading:  Image.asset("lib/images/"+ segnaleRimosso.specifica+'.png', width: 70, height: 40,),
                  
                  
                ),
                
                ),  
              ),
              ),
              
          
          ]
        );
    }
    else{
      if(attivi.isEmpty)
      {
        return Column();
      }
      else{
        if(nuovosegnale){
          return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              
              child: Align(
                
                alignment: Alignment.topCenter,
                
              
                child:  ListTile( 
                                  title: AnimatedContainer(
                                                        height:500,
                                                        width:290,
                                                        
                                                        duration: Duration(seconds: 1),
                                                        curve: Curves.bounceInOut,
                                                        
                                                        decoration: BoxDecoration(
                                                                                      border: Border.all(color:  bordo, width: 5),
                                                                                      color: sfondo,
                                                                                      borderRadius: BorderRadius.all(Radius.circular(17)),
                                                                                      
                                                        ),
                                                        padding: const EdgeInsets.fromLTRB(10, 150, 10, 0),

                                                  child: Column(children: [
                                                    Align(
                                                      alignment: Alignment.center,
                                                      child: Image.asset("lib/images/"+ segn1.specifica+'.png', width: 100, height: 70,),
                                                              
                                                      ),
                                                      Align(
                                                        alignment: Alignment.center,
                                                        child: Text(  
                                                                      attivi.elementAt(attivi.length-1).descrizione,
                                                                      style: GoogleFonts.lato(
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontSize: 18,
                                                                                              ),
                                                                      textAlign: TextAlign.center,
                                                                    ),

                                                      ),
                                                  ],)
                                                  
                                                  )
                                                        

                                                ),
                            
                  
                  
                  
                ),
                
                ),  
          ],
        );
        }else{

          return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              
              child: Align(
                
                alignment: Alignment.topCenter,
                
                child: DecoratedBox(decoration: BoxDecoration(
                  border: Border.all(color:  bordo, width: 5),
                  color: sfondo,
                  borderRadius: BorderRadius.all(Radius.circular(17)),
                  
                ) ,
                child:  ListTile( 
                  
                  title: Text('$nomeSegnale',
                              style: GoogleFonts.lato(
                                                                                            color: Colors.white,
                                                                                            fontWeight: FontWeight.bold,
                                                                                            fontSize: 24,
                                                                                              ),
                              ),
                  leading: 
                  Image.asset("lib/images/"+ segn1.specifica+'.png', width: 70, height: 40,),
                  
                  
                ),
                
                ),  
              ),
              ),
              Padding(
          padding: EdgeInsets.all(16),
          child: 
          Align(
            alignment: Alignment.centerRight,
            
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: SizedBox(
                
                height: 120,
                width: 60,

                child: DecoratedBox(
                  decoration: BoxDecoration(
                    
                    color: color_widget,
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    
                  ),
                  child: Column(
                    children: <Widget>[
                        
                        Image.asset("lib/images/"+segn1.specifica+'.png', width: 50, height: 40,),
                        Image.asset("lib/images/"+segn2.specifica+'.png',width: 50, height: 40,),
                        Image.asset("lib/images/"+segn3.specifica+'.png',width: 50, height: 40,),
                    ],
                  ),
                  
                  
                  
                  
                  ),
              ),
            ),
            ),
          )
          ],
        );
        }
      }
      }
        
        }
      }
    );
 
}

 double calcoladistanzaFine(Position position, Segnale segnale){
    return(geolocation1.Geolocator.distanceBetween(position.latitude, position.longitude, segnale.fine.latitude, segnale.fine.longitude));
  }





  

}