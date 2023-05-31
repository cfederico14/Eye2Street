import 'package:cloud_firestore/cloud_firestore.dart';

class LimiteStrada{
  String docid;
  String categoria;
  String specifica;
  String descrizione;
  String nomeSegnale;
  int valore;
  GeoPoint inizio;
  GeoPoint fine;

  LimiteStrada(this.docid, this.categoria, this.specifica, this.descrizione,this.nomeSegnale, this.valore, this.inizio, this.fine);

  static LimiteStrada fromJson(Map<String, dynamic> json){
    String limite = json["properties"]["maxspeed"];
    String cat="Limite";
    String doc = "daJson";
    String spec ="";
    String desc ="";
    String ns ="limite"+ limite;
    int val = int.parse(limite);
    List punti = json["geometry"]["coordinates"];
    List prime_coord = punti.first;
    List ultime_coord = punti.last;
    
    GeoPoint start = new GeoPoint(prime_coord[1], prime_coord[0]);
    GeoPoint finish = new GeoPoint(ultime_coord[1], ultime_coord[0]);
    return new LimiteStrada(doc,cat,spec,desc,ns,val,start,finish);
  }

  @override
  String toString() {
     return '{ ${this.docid}, ${this.categoria}, ${this.specifica}, ${this.descrizione}, ${this.nomeSegnale}, ${this.valore}, "inizio: ( "  ${this.inizio.latitude},   ${this.inizio.longitude}, "fine: ( "  ${this.fine.latitude},   ${this.fine.longitude}} ';
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map={
      'id': this.docid,
      'categoria' : this.categoria,
      'specifica' : this.specifica,
      'descrizione': this.descrizione,
      'nome LimiteStrada': this.nomeSegnale,
      'valore': this.valore,
      'inizio' : this.inizio,
      'fine' : this.fine
    };
    
    return map;
  }
  
}