import 'package:flutter/material.dart';

class FamilyMemberCard extends StatefulWidget {
  final String name, number, desc;
  final LinearGradient gradient;
  final Image image;

  FamilyMemberCard({Key key, this.name, this.number, this.desc, this.gradient, this.image}) : super (key: key);
  @override 
  _FamilyMemberCardState createState() => new _FamilyMemberCardState();
}

class _FamilyMemberCardState extends State<FamilyMemberCard> {
  

  @override
  Widget build (BuildContext context){
    return Padding(
          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,MediaQuery.of(context).size.width*0.01, MediaQuery.of(context).size.width*0.03, MediaQuery.of(context).size.width*0.01),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: widget.gradient,
            ),
            width: MediaQuery.of(context).size.width*0.97,
            height: MediaQuery.of(context).size.height*0.15,
            padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.03, top: MediaQuery.of(context).size.height*0.01, bottom: MediaQuery.of(context).size.height*0.01),
            child: Row(
              children: [
                widget.image==null?Icon(Icons.account_box, size: MediaQuery.of(context).size.width*0.3, color: MyColors.cardText(),):
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      image: DecorationImage(
                        image: widget.image.image,
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.center
                      ),
                    ),
                  ),
                ),
                
                
                Padding(padding: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.04)),
                Expanded(
                  child:SingleChildScrollView(
                    child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.07, color: MyColors.cardText()), textAlign: TextAlign.left,),
                      Text(widget.number, style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: MyColors.cardText()), textAlign: TextAlign.left,),
                      Text(widget.desc, style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.04, color: MyColors.cardText()), textAlign: TextAlign.left, softWrap: true,),
                    ],
                  )
                  ) 
                )
              ],
            )
          )
    );
  }
}


extension MyColors on Color {
  
  static Color background(){
    return Color(0xff23193e);
  }

  static Color appbarBackground(){
    return Color(0xff815AC0);
  }

  static Color appbarText(){
    return Color(0xffDEC9E9);
  } 

  static Color gradientLeft(){
    return Color(0xff6247AA);
  }

  static Color gradientRight(){
    return Color(0xff815AC0);
  }

  static Color cardText(){
    return Color(0xffDEC9E9);
  }

  static Color selected(){
    return Colors.white;
  }

}