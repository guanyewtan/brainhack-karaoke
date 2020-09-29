import 'dart:async';

import 'package:agora_flutter_quickstart/src/services/database.dart';
import 'package:agora_flutter_quickstart/src/utils/parser.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
void main() => runApp(VideoApp());

class VideoApp extends StatefulWidget {
  final String channelName;// = '123';
  const VideoApp({Key key, this.channelName}) : super(key: key);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;
  Stream ktvRoomStream;
  DatabaseMethods databaseMethods = DatabaseMethods();
  Future<void> _initializeVideoPlayerFuture;
  
  void getKTVRoomList() async {
    await databaseMethods.getKtvRoom(widget.channelName).then((value){
      setState(() {
        ktvRoomStream = value;
      });
    });
  }

  // Future<void> _initializePlay(String videoPath) async {
    
  //   setState(() {
  //     _initializeVideoPlayerFuture = null;
  //   });
  //   await _clearPrevious().then((_) {
  //     _controller = VideoPlayerController.network(videoPath);
  //     _initializeVideoPlayerFuture = _controller.initialize().then((_) {
  //       print('happens');
  //     });
  //   });
  // }

  void _initializePlay(String videoPath) {
      // databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'pause');
      if (_controller != null) {
        _controller.dispose();
      }
      _controller = VideoPlayerController.network(videoPath);
      _initializeVideoPlayerFuture =  _controller.initialize();
  }

  Future<bool> _clearPrevious() async {
    await _controller?.pause();
    return true;
  }

  Future<void> _startPlay(String videoPath) async {
    setState(() {
      _initializeVideoPlayerFuture = null;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _clearPrevious().then((_) {
        _initializePlay(videoPath);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getKTVRoomList();
    // final file = File();
    databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'pause');
    _controller = VideoPlayerController.network('https://tzw0.github.io/videos/perfect.mp4');
    // Initialize the controller and store the Future for later use.
    _initializeVideoPlayerFuture = _controller.initialize();

    // Use the controller to loop the video.
    _controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Demo',
      home: StreamBuilder(
        stream: ktvRoomStream,
              builder: (context, snapshot) {
                var currentSong = (snapshot.hasData && snapshot != null && snapshot.data['songlist'] != null && snapshot.data['songlist'].length > 0) ? snapshot.data['songlist'][0] : 'https://tzw0.github.io/videos/perfect.mp4';
                _initializePlay(currentSong);
                print('stream');
                var state;
                try {
                  state = snapshot.data['videostate'];
                } catch (e) {
                  state = 'pause';
                }
                print(state);
                if (snapshot.hasData && state == 'play') {
                  _controller.play();
                } else if (snapshot.hasData && state == 'pause') {
                  _controller.pause();
                }
          return Scaffold(
            body: FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context0, snapshot0) {
                    print('future' + snapshot0.toString());
                    if (snapshot0.connectionState == ConnectionState.done) {
                      return Center(
                        child: _controller.value.initialized
                            ? AspectRatio(
                                aspectRatio: _controller.value.aspectRatio,
                                child: VideoPlayer(_controller),
                              )
                            : Container(),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    } 
                  }
            ),
            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: Colors.purple[800].withAlpha(100),
              onPressed: () {
                setState(() {
                  if (_controller.value.isPlaying) {
                    state = 'pause';
                    databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'pause'); //when these 2 commented somehow ok
                    _controller.pause();
                  } else {
                    state = 'play';
                    databaseMethods.createOrUpdateKtvRoomVideoState(widget.channelName, 'play'); //when these 2 commented somehow ok
                    _controller.play();
                  }
                });
              },
              label: Text(SongNameParser.getSongName(currentSong, songNameLengthLimit: 30)),
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _initializeVideoPlayerFuture = null;
    _controller.dispose();
  }
}