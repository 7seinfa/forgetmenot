import 'dart:convert';
import 'package:forgetMeNot/memories.dart';
import 'package:forgetMeNot/people.dart';
import 'package:forgetMeNot/places.dart';
import 'package:forgetMeNot/theme.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'notes.dart';
import 'theme.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forget Me Not',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      routes: <String, WidgetBuilder>{
        "/people/": (BuildContext context) => new People(),
        "/memories/": (BuildContext context) => new Memories(),
        "/places/": (BuildContext context) => new Places(),
        "/notes/": (BuildContext context) => new Notes(),
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<String> pinned = [];
  List<bool> isDone = [];
  BehaviorSubject<bool> pinnedS;

  @override
  void initState() {
    pinnedS = new BehaviorSubject<bool>();
    loadInfo();
    super.initState();
  }

  Future<void> loadInfo() async {
    String path = await localPath;
    File pinnedFile = File('$path/pinned.json');
    if(await pinnedFile.exists()){
      try{
        print(await pinnedFile.readAsString());
        var pinnedJson = json.decode(await pinnedFile.readAsString());
        for(var x in pinnedJson){
          pinned.add(x);
          isDone.add(false);
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
            title: Padding(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Forget Me Not", style: Theme.of(context).textTheme.headline6.copyWith(fontSize: MediaQuery.of(context).size.width*0.08, color: MyColors.appbarText()), overflow: TextOverflow.visible,),
                ]
              ),
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height*0.016, 0, 0),
            ),
            centerTitle: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))
            ),
            bottom: PreferredSize(                       // Add this code
              preferredSize: Size(double.infinity,MediaQuery.of(context).size.height*0.02),      // Add this code
              child: Text("")
            ) 
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                //Flexible(
                  //child: 
                  Padding(
                    padding: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.05,MediaQuery.of(context).size.width*0.05, MediaQuery.of(context).size.width*0.05, MediaQuery.of(context).size.width*0.01),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()]),
                      ),
                      width: MediaQuery.of(context).size.width*0.97,
                      height: MediaQuery.of(context).size.height*0.35,
                      child: LayoutBuilder(builder: (context, constraint){
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              //mainAxisSize: MainAxisSize.min,
                              //crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(flex: 1, fit: FlexFit.tight,child:Container()),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: Text("Pinned", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.cardText(), fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                                ),
                                Flexible(
                                  flex: 11,
                                  fit: FlexFit.tight,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: MyColors.cardText(),
                                      borderRadius: BorderRadius.circular(20)
                                    ),
                                    width: constraint.biggest.width*0.9,
                                    padding: EdgeInsets.only(left: constraint.biggest.width*0.03, right: constraint.biggest.width*0.03,) ,
                                    child: Stack(
                                      children: [
                                        SingleChildScrollView(
                                          child: StreamBuilder(
                                            stream: pinnedS.stream.asBroadcastStream(),
                                            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                              List<Widget> pinnedText = [Container(width: constraint.biggest.width*0.9,),];
                                              if(snapshot.data){
                                                for(var x = 0; x < pinned.length; x++){
                                                  pinnedText.add(
                                                    InkWell(
                                                      child:Text(pinned[x],  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: !isDone[x]?MyColors.gradientLeft():MyColors.gradientRight(), fontWeight: FontWeight.bold),),
                                                      onTap: (){
                                                        isDone[x] = !isDone[x];
                                                        setState(() {
                                                          
                                                        });
                                                      },
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
                                                                    Text("Would you like to delete the event "+ pinned[x] + "?", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
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
                                                                      pinned.removeAt(x);
                                                                      String path = await localPath;
                                                                      File pinnedFile = File('$path/pinned.json');
                                                                      pinnedFile.writeAsString(json.encode(pinned));
                                                                      pinnedS.add(true);
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
                                                    )
                                                  );
                                                }
                                              }
                                              return Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: pinnedText,
                                              );
                                            },
                                            initialData: false,
                                          )
                                        ),
                                        Align(
                                          alignment: Alignment(0.8,0.6),
                                          child: IconButton(
                                            icon: Icon(Icons.add, size: constraint.biggest.width*0.2, color: MyColors.gradientLeft(),), 
                                            onPressed: (){
                                              TextEditingController desc = new TextEditingController();
                                              int hour = 10;
                                              int minute = 30;
                                              bool pm = false;
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return ButtonBarTheme(
                                                    data: ButtonBarThemeData(alignment: MainAxisAlignment.center), 
                                                    child: AlertDialog(
                                                      backgroundColor: MyColors.gradientRight(),
                                                      content: StatefulBuilder(
                                                        builder: (BuildContext context, StateSetter setState) {
                                                          return Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text("Time", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold),),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 3,
                                                                    fit: FlexFit.tight,
                                                                    child: Container()
                                                                  ),
                                                                  Flexible(
                                                                    flex: 4,
                                                                    fit: FlexFit.tight,
                                                                    child: NumberPicker.integer(initialValue: hour, minValue: 1, maxValue: 12, onChanged: (newHour){
                                                                        hour = newHour;
                                                                        setState((){});
                                                                      },
                                                                      selectedTextStyle: TextStyle(color: MyColors.selected(), fontSize: MediaQuery.of(context).size.width*0.06),
                                                                      textStyle: TextStyle(color: MyColors.cardText(), fontSize: MediaQuery.of(context).size.width*0.04),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 1,
                                                                    fit: FlexFit.tight,
                                                                    child: Text(":", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected()), textAlign: TextAlign.center,),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 4,
                                                                    fit: FlexFit.tight,
                                                                    child: NumberPicker.integer(initialValue: minute, minValue: 0, maxValue: 59, onChanged: (newMinute){
                                                                        minute = newMinute;
                                                                        setState((){});
                                                                      },
                                                                      selectedTextStyle: TextStyle(color: MyColors.selected(), fontSize: MediaQuery.of(context).size.width*0.06),
                                                                      textStyle: TextStyle(color: MyColors.cardText(), fontSize: MediaQuery.of(context).size.width*0.04),
                                                                   ),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 3,
                                                                    fit: FlexFit.tight,
                                                                    child: FlatButton(
                                                                      onPressed: () async {
                                                                        pm = !pm;
                                                                        setState(() {
                                                                          
                                                                        });
                                                                      },
                                                                      disabledColor: MyColors.gradientLeft(),
                                                                      color: MyColors.gradientLeft(),
                                                                      padding: EdgeInsets.all(5),
                                                                      child: Text(pm?"PM":"AM", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.selected(), fontWeight: FontWeight.bold), textAlign: TextAlign.center,)
                                                                    )
                                                                  ),
                                                                ], 
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
                                                            ]
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
                                                              bool done = false;
                                                              String mORa = " AM";
                                                              pm?mORa=" PM":mORa=" AM";
                                                              int tempHour = hour==12?0:hour;
                                                              String tempMinute = minute<10?"0"+minute.toString():minute.toString();
                                                              for(int x = 0; x<pinned.length; x++){
                                                                int pinnedHour = int.parse(pinned[x].split(":")[0])==12?0:int.parse(pinned[x].split(":")[0]);
                                                                if(mORa.substring(1)==pinned[x].split(" ")[1]){
                                                                  if(pinnedHour>=tempHour&&int.parse(pinned[x].split(":")[1].substring(0,2))>=minute&&!done){
                                                                    pinned.insert(x, hour.toString() + ":" + tempMinute + mORa + " - "+ desc.text);
                                                                    done=true;
                                                                  }
                                                                }else if (!pm&&!done){
                                                                  pinned.insert(x, hour.toString() + ":" + tempMinute + mORa + " - "+ desc.text);
                                                                  done=true;
                                                                }
                                                              }
                                                              if(!done){
                                                                pinned.add(hour.toString() + ":" + tempMinute + mORa + " - "+ desc.text);
                                                              }
                                                              isDone.add(false);
                                                              String path = await localPath;
                                                              File pinnedFile = File('$path/pinned.json');
                                                              pinnedFile.writeAsString(json.encode(pinned));
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
                                            }
                                          )
                                        )
                                      ],
                                    )
                                        
                                  )
                                ),
                                Flexible(flex: 1, fit: FlexFit.tight,child:Container()),
                              ],
                            )
                          ],
                        );
                      })
                    )
                  ),
                //),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/people/");
                        },
                        child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.05,MediaQuery.of(context).size.width*0.03,MediaQuery.of(context).size.width*0.015,MediaQuery.of(context).size.width*0.015),
                          //padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                          height: MediaQuery.of(context).size.height*0.22,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 8,
                                child: Icon(Icons.person, color: MyColors.cardText(), size: MediaQuery.of(context).size.height*0.16,),
                              ),
                              Flexible(
                                flex: 2,
                                child: Text("People", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.cardText(), fontWeight: FontWeight.bold)),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(),
                              )
                            ],
                          ),
                        )
                      )
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/memories/");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.015,MediaQuery.of(context).size.width*0.03,MediaQuery.of(context).size.width*0.05,MediaQuery.of(context).size.width*0.015),
                          //padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                          height: MediaQuery.of(context).size.height*0.22,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 8,
                                child: Icon(Icons.chat_bubble, color: MyColors.cardText(), size: MediaQuery.of(context).size.height*0.16,),
                              ),
                              Flexible(
                                flex: 2,
                                child: Text("Memories", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.cardText(), fontWeight: FontWeight.bold), overflow: TextOverflow.visible,),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(),
                              )
                            ],
                          ),
                        )
                      )
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/places/");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.05,MediaQuery.of(context).size.width*0.015,MediaQuery.of(context).size.width*0.015,MediaQuery.of(context).size.width*0.03),
                          //padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                          height: MediaQuery.of(context).size.height*0.22,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 8,
                                child: Icon(Icons.place, color: MyColors.cardText(), size: MediaQuery.of(context).size.height*0.16,),
                              ),
                              Flexible(
                                flex: 2,
                                child: Text("Places", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.cardText(), fontWeight: FontWeight.bold)),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(),
                              )
                            ],
                          ),
                        )
                      )
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: InkWell(
                        onTap: (){
                          Navigator.of(context).pushNamed("/notes/");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [MyColors.gradientLeft(), MyColors.gradientRight()], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20)
                          ),
                          margin: EdgeInsets.fromLTRB(MediaQuery.of(context).size.width*0.015,MediaQuery.of(context).size.width*0.015,MediaQuery.of(context).size.width*0.05,MediaQuery.of(context).size.width*0.03),
                          //padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.03),
                          height: MediaQuery.of(context).size.height*0.22,
                          child:Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 8,
                                child: Icon(Icons.note, color: MyColors.cardText(), size: MediaQuery.of(context).size.height*0.16,),
                              ),
                              Flexible(
                                flex: 2,
                                child: Text("Notes", style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.06, color: MyColors.cardText(), fontWeight: FontWeight.bold)),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(),
                              )
                            ],
                          ),
                        )
                      )
                    ),
                  ],
                )
              ]
            ),
          )
        ]
      )
    );
  }
}
