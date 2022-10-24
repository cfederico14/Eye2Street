import 'package:cloud_firestore/cloud_firestore.dart';

class Segnale{
  String docid;
  String categoria;
  String specifica;
  String descrizione;
  String nomeSegnale;
  GeoPoint inizio;
  GeoPoint fine;

  Segnale(this.docid, this.categoria, this.specifica, this.descrizione,this.nomeSegnale, this.inizio, this.fine);

  @override
  String toString() {
     return '{ ${this.docid}, ${this.categoria}, ${this.specifica}, ${this.descrizione}, ${this.nomeSegnale} "inizio: ( "  ${this.inizio.latitude},   ${this.inizio.longitude}, "fine: ( "  ${this.fine.latitude},   ${this.fine.longitude}} ';
  }

  Map<String, dynamic> toMap(){
    Map<String, dynamic> map={
      'id': this.docid,
      'categoria' : this.categoria,
      'specifica' : this.specifica,
      'descrizione': this.descrizione,
      'nome segnale': this.nomeSegnale,
      'inizio' : this.inizio,
      'fine' : this.fine
    };
    
    return map;
  }
  
}