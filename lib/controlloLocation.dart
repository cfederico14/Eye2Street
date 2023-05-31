import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class controlloLocation extends StatefulWidget {    
  bool? steady;
  

  controlloLocation({Key? key, required steady}): super(key: key);
   @override
  State<controlloLocation> createState() => controlloLocationState();

}
class controlloLocationState extends State<controlloLocation>{

  bool steady=false;
  @override
  Widget build(BuildContext context) {
    if(!steady){
      return Center();
    }
    else
    {
      return Container(
        child: Center(
          child: TextButton(onPressed: () => {}, child: Text("PROVA"),)
          ),
      );
    }
  }

}