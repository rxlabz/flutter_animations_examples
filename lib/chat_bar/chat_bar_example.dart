import 'dart:math';

import 'package:flutter/material.dart';
import 'package:quiver/time.dart';

void main() => runApp(MaterialApp(
      home: ChatScreen(),
    ));

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            children: <Widget>[Expanded(child: Container()), ChatBar()],
          ),
        ),
      ),
    );
  }
}

class ChatBarItem {
  final IconData icon;
  final VoidCallback onPressed;

  ChatBarItem(this.icon, this.onPressed);
}

class ChatBar extends StatefulWidget {
  @override
  _ChatBarState createState() => _ChatBarState();
}

class _ChatBarState extends State<ChatBar> with TickerProviderStateMixin {
  List<ChatBarItem> _chatBarItems = [
    ChatBarItem(Icons.mic, () => print('record')),
    ChatBarItem(Icons.camera_alt, () => print('picture')),
    ChatBarItem(Icons.videocam, () => print('video')),
  ];

  AnimationController _elasticAnimationController;
  AnimationController _bounceAnimationController;
  CurvedAnimation _elasticAnimation;
  CurvedAnimation _bounceAnimation;

  bool on = false;

  @override
  void initState() {
    super.initState();

    _elasticAnimationController =
        AnimationController(vsync: this, duration: aSecond)
          ..addListener(_update);

    _bounceAnimationController =
        AnimationController(vsync: this, duration: aSecond * .1)
          ..addListener(_update);

    _elasticAnimation = CurvedAnimation(
        parent: _elasticAnimationController, curve: Curves.elasticInOut);

    _bounceAnimation = CurvedAnimation(
        parent: _bounceAnimationController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.elasticInOut);
  }

  @override
  void dispose() {
    super.dispose();
    _elasticAnimationController.removeListener(_update);
    _bounceAnimationController.removeListener(_update);
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Transform.rotate(
          angle: _bounceAnimation.value * (pi / (on ? -52 : 52)),
          alignment: Alignment.centerLeft,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: <Widget>[
                _buildBarBackground(),
                _buildMainButton(),
                _buildMessageField(),
                _buildMediaButtons()
              ],
            ),
          )),
    );
  }

  Opacity _buildMediaButtons() {
    return Opacity(
      opacity: min(max(0, _elasticAnimation.value), 1),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 78.0,
          top: 8,
          bottom: 8,
          right: 20,
        ),
        child: Transform.rotate(
          angle: (pi / 2) * (1 - _elasticAnimation.value),
          child: Row(
            children:
                _chatBarItems.map((item) => _buildCircleButton(item)).toList(),
          ),
          alignment: Alignment.centerLeft,
          origin: Offset(-10, 10),
        ),
      ),
    );
  }

  Opacity _buildMessageField() {
    return Opacity(
      opacity: min(max(0, 1 - _elasticAnimation.value), 1),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 78.0,
          top: 10,
          bottom: 8,
          right: 20,
        ),
        child: Transform.rotate(
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Message...',
              labelStyle: TextStyle(color: Colors.white),
              hasFloatingPlaceholder: false,
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.white30,
            ),
          ),
          alignment: Alignment.centerLeft,
          angle: (-pi / 2) * _elasticAnimation.value,
        ),
      ),
    );
  }

  Positioned _buildMainButton() {
    return Positioned(
      left: 12,
      top: 8,
      child: Transform.rotate(
        angle: -pi / 4 * _elasticAnimation.value,
        child: _buildCircleButton(ChatBarItem(Icons.add, _chooseMedia)),
      ),
    );
  }

  Positioned _buildBarBackground() {
    return Positioned.fill(
        left: 12,
        right: 12,
        child: Transform.rotate(
          angle: _bounceAnimation.value * (pi / (on ? -52 : 52)),
          alignment: Alignment.centerLeft,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.cyan.shade600),
          ),
        ));
  }

  Widget _buildCircleButton(ChatBarItem item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: Colors.white30),
        child: IconButton(
            highlightColor: Colors.yellowAccent,
            splashColor: Colors.yellowAccent,
            icon: Icon(item.icon, color: Colors.white),
            onPressed: item.onPressed),
      ),
    );
  }

  void _chooseMedia() {
    if (_elasticAnimationController.status == AnimationStatus.dismissed)
      _elasticAnimationController.forward();
    else if (_elasticAnimationController.status == AnimationStatus.completed)
      _elasticAnimationController.reverse();

    Future.delayed(aSecond * .4, () {
      _bounceAnimationController
        ..forward()
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed)
            _bounceAnimationController.reverse();
        });
      setState(() {
        on = !on;
      });
    });
  }
}
