import 'dart:async';

import 'package:app_prova_tirocinio/LimiteStrada.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geolocator/geolocator.dart' as geolocation1;
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';





class limite extends StatefulWidget {
  const limite({Key? key}) : super(key: key);

  


  @override
  State<limite> createState() => limiteState();
}

class limiteState extends State<limite> {



    StreamSubscription<geolocation1.Position>? _positionStream;

    int _speed = 0;
    List<LimiteStrada>? listalimiti=[];
    LimiteStrada limite50= new LimiteStrada("", "limite", "limite di velocità", "Il limite di velocità su questa tratta è di 50 Km/h", "limite50", 50, new GeoPoint(0, 0), new GeoPoint(0,0));
    LimiteStrada limiteAttivo= new LimiteStrada("", "limite", "limite di velocità", "Il limite di velocità su questa tratta è di 50 Km/h", "limite50", 50, new GeoPoint(0, 0), new GeoPoint(0,0));
    bool finelimite=false;
    LimiteStrada limiteRimosso=new LimiteStrada("", "limite", "limite di velocità", "Il limite di velocità su questa tratta è di 50 Km/h", "limite50", 50, new GeoPoint(0, 0), new GeoPoint(0,0));
    List<LimiteStrada> attivi=[];
    Future<void>? _future;
    static final Color rosso=Color.fromARGB(255, 239, 44, 44);
    static final Color bianco=Color.fromARGB(255, 255, 255, 255);
    Color colore = Color.fromARGB(255, 255, 255, 255);
    static final color_widget=Color.fromARGB(205, 95, 84, 84);
  void _onSpeedChange(int newSpeed) {
    setState(() {
      _speed = newSpeed;
    });
  }



  double calcoladistanzaInizio(Position position, LimiteStrada segnale){
    return(geolocation1.Geolocator.distanceBetween(position.latitude, position.longitude, segnale.inizio.latitude, segnale.inizio.longitude));
  }

  
 double calcoladistanzaFine(Position position, LimiteStrada segnale){
    return(geolocation1.Geolocator.distanceBetween(position.latitude, position.longitude, segnale.fine.latitude, segnale.fine.longitude));
  }

  void checkLimite(Position position, LimiteStrada limite)
  { 
    
    if(calcoladistanzaFine(position, limite)<50){
      
      if(attivi.remove(limite)){
        finelimite=true;
        limiteRimosso=limite;
        const time = const Duration(seconds: 3);
        Timer.periodic(time, (Timer t) => finelimite=false);

        if(attivi.length>0)
         {
          limiteAttivo=attivi.elementAt(attivi.length-1);
         }
        else
          limiteAttivo=limite50;
      }
    }else{
      if(calcoladistanzaInizio(position, limite)<50 && !attivi.contains(limite)){
        attivi.add(limite); 
        limiteAttivo=limite;
      }
    }
  }

  creaPunto(DocumentSnapshot dati)
    {
      LimiteStrada nuovo_limite=
        LimiteStrada(dati.reference.id, dati.get('categoria'), dati.get('specifica'), dati.get('descrizione'), dati.get('nomeSegnale'), dati.get('valore'), dati.get('inizio'), dati.get('fine'));
      print(nuovo_limite);
      listalimiti?.add(nuovo_limite);
      print(listalimiti);
    }

                                                
  Future<void> getLimiti() async{
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    
    );
    final QuerySnapshot result = await FirebaseFirestore.instance.collection('Limiti').get();
    final List<DocumentSnapshot> documents = result.docs;
    documents.forEach((data) => creaPunto(data));
  }


  final geolocation1.LocationSettings locationsettings = geolocation1.LocationSettings(
  accuracy: geolocation1.LocationAccuracy.bestForNavigation,
  distanceFilter: 20,
);
  double velocita=0;

  void _visualizzaVelocita(double velocita)
  {
    this.velocita=velocita;
  }

 @override void initState() {

     listalimiti=[];
    _future=getLimiti();
     _positionStream =
            geolocation1.Geolocator.getPositionStream(locationSettings: locationsettings)
            .listen((position){
              _onSpeedChange(position == null ? 0 : ((position.speed * 18) / 5).round());
              listalimiti!.forEach((limite) {checkLimite(position, limite);});
              if(position!=null){
                int velocita=((position.speed * 18) / 5).round();
                if(colore==bianco && velocita > limiteAttivo.valore)
                  {
                    FlutterRingtonePlayer.play(  
                              fromAsset: "lib/sounds/inizio.wav", 
                           ); 
                    colore=rosso;
                  }
                else if(colore==rosso && velocita <= limiteAttivo.valore)
                  {
                    colore=bianco;
                    FlutterRingtonePlayer.play(  
                      fromAsset: "lib/sounds/fine.wav",
                    ); 
                  } 
              }
              });
            super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done){
              return     Padding(
    
            padding: EdgeInsets.all(16),
    
            child: 
    
            Align(
    
              alignment: Alignment.bottomRight,
    
              child: SizedBox(
    
                height:40,
    
                width: 110,
    
                child: DecoratedBox(
    
                   decoration: BoxDecoration(
    
                     
    
                     color: color_widget,
                     borderRadius: BorderRadius.all(Radius.circular(60.0)),
    
                     
    
                   ),
    
                   child: Row(
    
                     children: <Widget>[
                      
                      Text('Carimento. . .')
                       
                       
    
                     ],
    
                   ),
    
                   
    
                   
    
                  
    
                  
    
                  ),
    
              ),
    
              ),
    
            );
        }else{
             return     Padding(
    
            padding: EdgeInsets.all(16),
    
            child: 
    
            Align(
    
              alignment: Alignment.bottomRight,
    
              child: SizedBox(
    
                height:40,
    
                width: 110,
    
                child: DecoratedBox(
    
                   decoration: BoxDecoration(
    
                     
    
                     color: color_widget,
    
                     borderRadius: BorderRadius.all(Radius.circular(60.0)),
    
                     
    
                   ),
    
                   child: Row(
    
                     children: <Widget>[
                      Image.asset("lib/images/"+ limiteAttivo.nomeSegnale+'.png', width: 40, height: 30,),
                      Text('$_speed KM/H',
                                      style: GoogleFonts.lato(
                                                        color: colore,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                        ),
                                      )
                       
                       
    
                     ],
    
                   ),
    
                   
    
                   
    
                  
    
                  
    
                  ),
    
              ),
    
              ),
    
            );
        }
       
      }
    );
  }
}
