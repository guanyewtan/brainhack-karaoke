import 'dart:async';

import 'package:agora_flutter_quickstart/src/pages/songconsole.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/painting.dart';
import './call.dart';
import './video.dart';
import './animatedText.dart';

class IndexPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IndexState();
}

class IndexState extends State<IndexPage> with TickerProviderStateMixin {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  // AnimationController motionController;
  // Animation motionAnimation;
  // double size = 150;

  // @override
  // void initState() {
  //   super.initState();

  //   motionController = AnimationController(
  //      duration: Duration(milliseconds: 800),
  //      vsync: this,
  //      lowerBound: 0.8,
  //    );
 
  //    motionAnimation = CurvedAnimation(
  //      parent: motionController,
  //      curve: Curves.ease,
  //    );
 
  //    motionController.forward();
  //    motionController.addStatusListener((status) {
  //      setState(() {
  //        if (status == AnimationStatus.completed) {
  //          motionController.reverse();
  //        } else if (status == AnimationStatus.dismissed) {
  //          motionController.forward();
  //        }
  //      });
  //    });
 
  //    motionController.addListener(() {
  //      setState(() {
  //        size = motionController.value * 50;
  //      });
  //    });
  //  }
  
    @override
    void dispose() {
      // dispose input controller
      _channelController.dispose();
      super.dispose();
    }
  
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        // appBar: AppBar(
        //   title: Text('WeOKE!'),
        // ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 400,
            child: Column(
              children: <Widget>[
                Image.asset('assets/mic.png'),
                AnimatedText(),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: TextField(
                      controller: _channelController,
                      decoration: InputDecoration(
                        errorText:
                            _validateError ? 'Channel name is mandatory' : null,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(width: 1),
                        ),
                        hintText: 'Enter a channel name to start partying',
                      ),
                    ))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: RaisedButton(
                          onPressed: onJoin,
                          child: Text('Join'),
                          color: Colors.purple[800],
                          textColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  
    Future<void> onJoin() async {
      // update input validation
      setState(() {
        _channelController.text.isEmpty
            ? _validateError = true
            : _validateError = false;
      });
      if (_channelController.text.isNotEmpty) {
        // await for camera and mic permissions before pushing video page
        await _handleCameraAndMic();
        // push video page with given channel name
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => 
            //Change to callPage to play butterfly video
            SongConsole(
              channelName: _channelController.text,
            ),
          ),
        );
      }
    }
  
    Future<void> _handleCameraAndMic() async {
      await PermissionHandler().requestPermissions(
        [PermissionGroup.camera, PermissionGroup.microphone],
      );
    }
  }
  
  mixin AnimationMotionController {
}
