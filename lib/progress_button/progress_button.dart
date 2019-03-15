import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProgressButton extends StatefulWidget {
  final double percentProgress;
  final Size size;
  final Color primaryColor;
  final Color progressColor;
  final Color backgroundColor;
  final Color contrastColor;
  final VoidCallback onPressed;

  bool get started => percentProgress > 0;

  const ProgressButton(
      {Key key,
      this.percentProgress,
      this.size: const Size(64.0, 64.0),
      this.primaryColor: Colors.cyan,
      this.backgroundColor: Colors.cyan,
      this.contrastColor: Colors.white,
      this.progressColor: Colors.lime,
      this.onPressed})
      : super(key: key);

  @override
  _ProgressButtonState createState() {
    return new _ProgressButtonState();
  }
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  AnimationController _controller;

  RectTween innerRectTween;

  ColorTween primaryColorTween;
  ColorTween endColorTween;

  _ProgressButtonState();

  final padding = Offset(10.0, 10.0);

  Rect innerRect;
  Rect maxInnerRect;

  @override
  void initState() {
    super.initState();

    innerRect = Offset.zero & widget.size;
    maxInnerRect =
        (Offset.zero + padding) & (widget.size - (padding + padding));

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 166),
      value: 0.0,
    )..addListener(() {
        setState(() => innerRect = innerRectTween.evaluate(_controller));
      });

    initTweens();
  }

  @override
  void didUpdateWidget(ProgressButton oldWidget) {
    if (widget.percentProgress > 0 && _controller.isDismissed)
      _controller.forward();

    if (widget.percentProgress >= 100) _controller.reverse();

    super.didUpdateWidget(oldWidget);
  }

  void initTweens() {
    innerRectTween =
        new RectTween(begin: Offset.zero & widget.size, end: maxInnerRect);

    primaryColorTween =
        new ColorTween(begin: widget.primaryColor, end: widget.contrastColor);

    endColorTween =
        new ColorTween(begin: widget.progressColor, end: widget.contrastColor);
  }

  @override
  Widget build(BuildContext context) {
    final currentFillColor = widget.percentProgress < 100
        ? primaryColorTween.evaluate(_controller)
        : endColorTween.evaluate(_controller);

    return InkWell(
        onTap: widget.onPressed,
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          child: Stack(children: [
            CustomPaint(
              painter: _ProgressButtonPainter(
                progress: widget.percentProgress,
                innerRect: innerRect,
                fillColor: currentFillColor,
                progressColor: widget.progressColor,
                backgroundColor: widget.backgroundColor,
              ),
              size: widget.size,
            ),
            Center(
                child: widget.percentProgress < 100
                    ? _buildLabel(widget.percentProgress)
                    : Icon(Icons.check, color: Colors.white))
          ]),
        ));
  }

  Widget _buildLabel(double percent) => widget.started
      ? Text("${percent.toInt()} %",
          style: TextStyle(color: widget.primaryColor))
      : Text(
          "Start",
          style: TextStyle(color: widget.contrastColor),
        );
}

class _ProgressButtonPainter extends CustomPainter {
  final double progress;
  final Color fillColor;
  final Color progressColor;
  final Color backgroundColor;
  final Rect innerRect;

  _ProgressButtonPainter({
    this.progress,
    this.fillColor: Colors.cyan,
    this.backgroundColor: Colors.cyan,
    this.progressColor: Colors.lime,
    this.innerRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillRect = Offset.zero & size;

    if (progress == 0.0 || progress == 100.0)
      canvas.drawShadow(Path()..addRect(fillRect), Colors.black, 2.0, true);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    canvas.drawRect(fillRect, fill);

    final progressFill = Paint()
      ..style = PaintingStyle.fill
      ..color = progressColor;
    canvas.drawRect(
        new Rect.fromPoints(
            Offset.zero, Offset(size.width * progress / 100, size.height)),
        progressFill);

    if (progress > 0.0 && progress < 100.0)
      canvas.drawShadow(Path()..addRect(innerRect), Colors.black, 2.0, true);

    final innerFill = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    canvas.drawRect(innerRect, innerFill);
  }

  @override
  bool shouldRepaint(_ProgressButtonPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.innerRect != innerRect ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
