// ignore_for_file: prefer_const_constructors
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smart_music_player/utils/ai_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:alan_voice/alan_voice.dart';


class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  double flexwidth(){
    return MediaQuery.of(context).size.width;
  }

  double flexHeight(){
    return MediaQuery.of(context).size.height;
  }

  List <Map<String, String>> musicsQueue = [
    {
      "id": "1",
      "name": "Heavenly Sword",
      "mandarin": "何為永恆",
      "imgUrl": "assets/images/heavenly_sword.jpg",
      "author": "ken's",
      "musicUrl": "assets/musics/hewei.mp3"
    },
    {
      "id": "2",
      "name": "you okay",
      "mandarin": "你，好不好？",
      "imgUrl": "assets/images/ni_haobuhao.jpg",
      "author": "ken's zhou",
      "musicUrl": "assets/musics/nihaobuhao.mp3"
    },
    {
      "id": "3",
      "name": "those year",
      "mandarin": "那些年",
      "imgUrl": "assets/images/naxienian.jpg",
      "author": "kenzwin",
      "musicUrl": "assets/musics/naxienian.mp3"
    },
    {
      "id": "4",
      "name": "promise",
      "mandarin": "約定",
      "imgUrl": "assets/images/yueding.jpeg",
      "author": "kenhuang",
      "musicUrl": "assets/musics/yueding.mp3"
    },
    {
      "id": "5",
      "name": "Fairy Taile",
      "mandarin": "童話",
      "imgUrl": "assets/images/tonghua.jpg",
      "author": "kenny",
      "musicUrl": "assets/musics/tonghua.mp3"
    },
  ];


  var isPlay = false;
  var isPause = false;
  int seek = 0;
  int maxduration = 0;
  int maxplayDurSec = 0;
  int maxplayDurMin = 0;
  int currentpos = 0;
  int sec = 0;
  bool next = false;
  String currentpostlabel = "00:00";
  String musicAsset = "assets/musics/hewei.mp3";
  late Uint8List audiobytes;
  AudioPlayer player = AudioPlayer();


  @override
  void initState() {
    if (_currentIndex ==0){
      convertMusic();
    }
    setupAlan();
    super.initState();
  }

  setupAlan() {
    AlanVoice.addButton(
        "91fd1edaed5ed8acf60f16d26a72dede2e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);

    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) async {
    switch (response["command"]) {
      case "play":
        await convertMusic();
        await player.playBytes(audiobytes);
        setState(() {
          isPlay = true;
          next = false;
        });
        break;
      case "stop":
        await player.stop();
        setState(() {
          isPlay = false;
          isPause = false;
          sec = 0;
          currentpostlabel = "0:0";
          next = false;
        });
        break;
      case "next":
        setState(() {
          next = true;
          isPlay = true;
        });
        break;
      case "pause":
        await player.pause();
        setState(() {
          isPause = true;
          next = false;
        });
        break;
      case "resume":
        await player.resume();
        setState(() {
          isPause = false;
          next = false;
        });
        break;
      default:
    }

  }
  
  Future convertMusic(){
    return Future.delayed(Duration.zero, () async {
      musicAsset = musicsQueue[_currentIndex]["musicUrl"]!;
      print("url music ketika di konvert : $musicAsset");
      ByteData bytes = await rootBundle.load(musicAsset); //load music dari assets/
      audiobytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

      //convert ByteData to Uint8List
      player.onDurationChanged.listen((Duration d) { //ambil durasi music
          maxplayDurSec = (d.inSeconds%60).floor();
          maxplayDurMin = d.inMinutes;
          maxduration = d.inSeconds;
          print("maxDuration = $maxduration");

          setState(() {
            
          });
      });

      player.onAudioPositionChanged.listen((Duration  p){
        currentpos = p.inMilliseconds; //tampung posisi waktu sekarang ketika music sedang berjalan
        sec = p.inSeconds;
          //durasi waktu yang berjalan dalam jam:menit:detik
          int shours = Duration(milliseconds:currentpos).inHours;
          int sminutes = Duration(milliseconds:currentpos).inMinutes;
          int sseconds = Duration(milliseconds:currentpos).inSeconds;

          // int rhours = shours;
          int rminutes = sminutes - (shours * 60);
          int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

          currentpostlabel = "$rminutes:$rseconds";
          print("sec = $sec");
          setState(() {
            //refresh the UI
          });
      });
      
    });
  }


  @override
  Widget build(BuildContext context) {

    Widget playButton({
      required Function() onPressed
    }){
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: const Icon(
            Icons.play_circle_outline_rounded, 
            size: 50, 
            color: Colors.purple,
          ),
        )
      );
    }

    Widget pauseStopButton({
      required Function() onPausePressed,
      required Function() onStopPressed,
    }){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle
            ),
            child: IconButton(
              onPressed: onPausePressed,
              icon: Icon(
                isPause?Icons.play_circle_outline_rounded : Icons.pause_circle_outline_rounded, size: 50, color: Colors.purple,),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle
            ),
            child: IconButton(
              onPressed: onStopPressed,
              icon: Icon(Icons.stop_circle_outlined, size: 50, color: Colors.purple,),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: Duration(milliseconds: 600),
        width: flexwidth(),
        height: flexHeight(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AIColors.primaryColor2!,
              AIColors.primaryColor1!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight
          )
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 25),
              child: Shimmer.fromColors(
                child: const Text("AI Music",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                  )
                ), 
                baseColor: Colors.white, 
                highlightColor: Colors.cyan.withOpacity(0.5),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                // top: flexHeight()-650,
                top: flexHeight()-700,
                bottom: 50
                // bottom: flexHeight()-800
              ),
              width: double.infinity,
              child: CarouselSlider(
                items: musicsQueue.map((data) => 
                  Container(
                    clipBehavior: Clip.hardEdge,
                    width: flexwidth()-90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        width: 5,
                        color: Colors.black
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(data["imgUrl"]!)
                      )
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            padding: EdgeInsets.only(top: 8, bottom: 8,right: 20, left: 5),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Text(data["mandarin"]!, 
                              style: TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.w600,
                                fontSize: 18
                              ),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(60),
                              topRight: Radius.circular(60),
                            )
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(data["name"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(data["author"]!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                  )
                ).toList(),
                options: CarouselOptions(
                  height: 350,
                  viewportFraction: 0.75,
                  enlargeCenterPage: true,
                  initialPage: 0,
                  autoPlay: (double.parse(currentpostlabel.split(":")[0]) == maxplayDurMin 
                            && 
                            double.parse(currentpostlabel.split(":")[1]) == maxplayDurSec 
                            && 
                            double.parse(currentpostlabel.split(":")[1]) != 0 
                            && sec == maxduration)
                            ? true : next? true : false,
                  autoPlayInterval: const Duration(seconds: 1),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.easeInOut,
                  onPageChanged: (index, reason) async {
                    await player.stop();
                    setState(() {
                      _currentIndex = index;
                      print(_currentIndex);
                      print("url music ketika diubah $musicAsset");
                      next = false;
                      isPause = false;
                    });
                      await convertMusic();
                      isPlay == false ? player.stop(): player.playBytes(audiobytes);
                      // isPlay = true;
                  }
                ),
              ),
            ),
            Container(
              child: Text(musicsQueue[_currentIndex]["name"]!.toUpperCase()),
            ),
            Container(
              width: flexwidth(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 35,
                          offset: Offset(2,2)
                        )
                      ]
                    ),
                    child: Slider(
                      divisions: 1000,
                      onChanged: (val){
                        seek = val.toInt();
                        player.seek(Duration(seconds: seek));
                      },
                      value:  sec.toDouble() > maxduration.toDouble()?
                              sec.toDouble()-(sec.toDouble()-maxduration.toDouble()) : 
                              sec.toDouble(),
                      min: 0,
                      max: maxduration.toDouble(),
                      activeColor: Colors.purple,
                      inactiveColor: Colors.white,
                    )
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(sec!=maxduration? currentpostlabel:currentpostlabel="0:0", 
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white
                          ),
                        ),
                        Text("$maxplayDurMin:$maxplayDurSec", 
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: isPlay && sec != maxduration? pauseStopButton(
                      onPausePressed: () async {
                        await player.pause();
                        setState(() {
                          isPause = !isPause;
                          isPause? player.pause(): player.resume();
                        });
                      },
                      onStopPressed: ()async{
                        await player.stop();
                        setState(() {
                          isPlay = false;
                          isPause = false;
                          sec = 0;
                          currentpostlabel = "0:0";
                        });
                      }
                    ) : 
                    playButton(
                      onPressed: () async {
                        await player.playBytes(audiobytes);
                        setState(() {
                          isPlay = true;
                        });
                      }
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}