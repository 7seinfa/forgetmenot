import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'theme.dart';

class Places extends StatefulWidget {
  Places({Key key}) : super(key: key);

  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends State<Places> {

  List<String> names = [];
  List<String> addresses = [];
  List<String> descriptions = [];
  List<String> imagePaths = [];
  BehaviorSubject<bool> pinnedS;
  final picker = ImagePicker();
  String path;

  @override
  void initState() {
    pinnedS = new BehaviorSubject<bool>();
    loadInfo();
    super.initState();
  }

  Future<void> loadInfo() async {
    path = await localPath;
    File pinnedFile = File('$path/places.json');
    if(await pinnedFile.exists()){
      try{
        print(await pinnedFile.readAsString());
        var pinnedJson = json.decode(await pinnedFile.readAsString());
        for(var x in pinnedJson){
          names.add(x[0]);
          addresses.add(x[1]);
          descriptions.add(x[2]);
          imagePaths.add(x[3]);
        }
      }catch (exception){
        print(exception.toString());
      }
      
    }
    pinnedS.add(true);
    setState(() {
      
    });
  }

  Future<String> get localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background(),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: MyColors.appbarBackground(),
            leading: Padding(
              child: IconButton(icon: Icon(Icons.home, color: MyColors.appbarText(),), onPressed: (){Navigator.of(context).pop();}, iconSize: MediaQuery.of(context).size.width*0.08,),
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.01, left: MediaQuery.of(context).size.width*0.05),
            ),
            title: Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Places", style: Theme.of(context).textTheme.headline6.copyWith(fontSize: MediaQuery.of(context).size.width*0.08, color: MyColors.appbarText()), overflow: TextOverflow.visible,),
                ]
              ),
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height*0.016, 0, 0),
            ),
            actions: [Container(width: 56,)],
            centerTitle: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
            ),
            bottom: PreferredSize(                       // Add this code
              preferredSize: Size(double.infinity,MediaQuery.of(context).size.height*0.02),      // Add this code
              child: Text("")
            ) 
          ),
          StreamBuilder(
              stream: pinnedS.stream.asBroadcastStream(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                List<Widget> people = [];
                if(snapshot.data){
                  for (var x = 0; x<names.length; x++){
                    Image img;
                    if(imagePaths[x]!=null&&imagePaths[x]!=''){
                      File imageFile = File('$path/'+names[x]+'.png');
                      img = Image.file(imageFile, height: MediaQuery.of(context).size.height*0.13,);
                    }
                    people.add(
                      InkWell(
                        onLongPress: (){
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ButtonBarTheme(
                                data: ButtonBarThemeData(alignment: MainAxisAlignment.center), 
                                child: AlertDialog(
                                  backgroundColor: MyColors.gradientRight(),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("Would you like to delete "+ names[x] + "?", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
                                    ]
                                  ),
                                  actions: [
                                    FlatButton(
                                      disabledColor: MyColors.gradientLeft(),
                                      color: MyColors.gradientLeft(),
                                      padding: EdgeInsets.all(10),
                                      child: Text("No", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }
                                    ),
                                    FlatButton(
                                      disabledColor: MyColors.gradientLeft(),
                                      color: MyColors.gradientLeft(),
                                      padding: EdgeInsets.all(10),
                                      child: Text("Yes", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                      onPressed: () async {
                                        addresses.removeAt(x);
                                        descriptions.removeAt(x);
                                        File img = File('$path/'+names[x]+'.png');
                                        if(await img.exists()){
                                          img.delete();
                                        }
                                        names.removeAt(x);
                                        imagePaths.removeAt(x);
                                        List<List<String>> newPeople = [];
                                        for(var x = 0; x<names.length; x++){
                                          newPeople.add([names[x], addresses[x], descriptions[x]]);
                                        }
                                        File pinnedFile = File('$path/places.json');
                                        pinnedFile.writeAsString(json.encode(newPeople));
                                        setState(() {
                                          
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    )
                                  ],
                                )
                              );
                            }
                          );
                        },
                        child: FamilyMemberCard(
                          name: names[x],
                          number: addresses[x],
                          desc: descriptions[x],
                          gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight(),], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          image: img
                        )
                      )
                    );
                  }
                }
                people.add(
                  InkWell(
                    onTap: (){
                      TextEditingController name = new TextEditingController();
                      TextEditingController address = new TextEditingController();
                      TextEditingController desc = new TextEditingController();
                      File _image;
                      String imageChosen = "Pick Image";
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ButtonBarTheme(
                            data: ButtonBarThemeData(alignment: MainAxisAlignment.center), 
                            child: AlertDialog(
                              backgroundColor: MyColors.gradientRight(),
                              content: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return StatefulBuilder(
                                      builder: (BuildContext context, StateSetter setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("Location Name", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
                                            TextField(
                                              controller: name,
                                              style: TextStyle(color: MyColors.cardText()),
                                              cursorColor: MyColors.gradientLeft(),
                                              decoration: InputDecoration(        
                                                enabledBorder: UnderlineInputBorder(      
                                                  borderSide: BorderSide(color: MyColors.gradientLeft()),   
                                                ),  
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: MyColors.gradientLeft()),
                                                ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: MyColors.cardText()),
                                                ),
                                              )
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                            ),
                                            Text("Address", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
                                            TextField(
                                              controller: address,
                                              style: TextStyle(color: MyColors.cardText()),
                                              cursorColor: MyColors.gradientLeft(),
                                              decoration: InputDecoration(        
                                                enabledBorder: UnderlineInputBorder(      
                                                  borderSide: BorderSide(color: MyColors.gradientLeft()),   
                                                ),  
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: MyColors.gradientLeft()),
                                                ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: MyColors.cardText()),
                                                ),
                                              )
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                            ),
                                            Text("Description", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
                                            TextField(
                                              controller: desc,
                                              style: TextStyle(color: MyColors.cardText()),
                                              cursorColor: MyColors.gradientLeft(),
                                              decoration: InputDecoration(        
                                                enabledBorder: UnderlineInputBorder(      
                                                  borderSide: BorderSide(color: MyColors.gradientLeft()),   
                                                ),  
                                                focusedBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: MyColors.gradientLeft()),
                                                ),
                                                border: UnderlineInputBorder(
                                                  borderSide: BorderSide(color: MyColors.cardText()),
                                                ),
                                              )
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.03),
                                            ),
                                            FlatButton(
                                              disabledColor: MyColors.gradientLeft(),
                                              color: MyColors.gradientLeft(),
                                              padding: EdgeInsets.all(10),
                                              child: Text(imageChosen, style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
                                              onPressed: () async {
                                                final pickedFile = await picker.getImage(source: ImageSource.gallery);
                                                
                                                if (pickedFile != null) {
                                                  _image = File(pickedFile.path);
                                                  imageChosen = "Image Chosen!";
                                                  setState(() {
                                                    
                                                  });
                                                }else {
                                                  print('No image selected.');
                                                }
                                              },
                                            )
                                          ]
                                        );
                                      }
                                  );
                                }
                              ),
                              actions: [
                                FlatButton(
                                  disabledColor: MyColors.gradientLeft(),
                                  color: MyColors.gradientLeft(),
                                  padding: EdgeInsets.all(10),
                                  child: Text("Add", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                  onPressed: () async {
                                    try{
                                      String path = await localPath;
                                      names.add(name.text);
                                      addresses.add(address.text);
                                      descriptions.add(desc.text);
                                      if(_image!=null){
                                        File newImage = await _image.copy('$path/'+name.text+'.png');
                                        imagePaths.add('$path/'+name.text+'.png');
                                      }else{
                                        imagePaths.add('');
                                      }
                                      List<List<String>> newPeople = [];
                                      for(var x = 0; x<names.length; x++){
                                        newPeople.add([names[x], addresses[x], descriptions[x], imagePaths[x]]);
                                      }
                                      File pinnedFile = File('$path/places.json');
                                      pinnedFile.writeAsString(json.encode(newPeople));
                                      setState(() {
                                        
                                      });
                                      Navigator.of(context).pop();
                                    }catch(e){
                                      //print(e.toString());
                                    }
                                    
                                  },
                                )
                              ],
                            )
                          );
                        },
                      );
                    },
                    //child: Flexible(
                      child: Padding(
                          padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.03,MediaQuery.of(context).size.width*0.01, MediaQuery.of(context).size.width*0.03, MediaQuery.of(context).size.width*0.01),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight(),], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            ),
                            width: MediaQuery.of(context).size.width*0.97,
                            child: Row(
                              children: [
                                Icon(Icons.add, size: MediaQuery.of(context).size.width*0.3, color: MyColors.cardText(),),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Add a New Place", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.05, color: MyColors.cardText()), textAlign: TextAlign.left,),
                                  ],
                                )
                              ],
                            )
                          )
                        )
                    )
                  //)
                  
                );
                return SliverList(
                  delegate: SliverChildListDelegate(
                    people,
                  ),
                );
              },
              initialData: false,
            )
          /*SliverList(
            delegate: SliverChildListDelegate(
              [
                FamilyMemberCard(name: "firstname lastname", relationship: "Son", birthday: "Nov. 21, 2020", hobbies: "hobby, hobby, hobby", facts: "random facts here", gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),),
                FamilyMemberCard(name: "firstname lastname", relationship: "Son", birthday: "Nov. 21, 2020", hobbies: "hobby, hobby, hobby", facts: "random facts here", gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),),
                FamilyMemberCard(name: "firstname lastname", relationship: "Son", birthday: "Nov. 21, 2020", hobbies: "hobby, hobby, hobby", facts: "random facts here", gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),),
                FamilyMemberCard(name: "firstname lastname", relationship: "Son", birthday: "Nov. 21, 2020", hobbies: "hobby, hobby, hobby", facts: "random facts here", gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),),
              ]
            ),
          )*/
        ]
      )
    );
  }
}
