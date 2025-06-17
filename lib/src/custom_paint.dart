import 'package:flutter/material.dart';

class CustomPaintDemo extends StatefulWidget {
  const CustomPaintDemo({super.key});

  @override
  State<CustomPaintDemo> createState() => _CustomPaintDemoState();
}

class _CustomPaintDemoState extends State<CustomPaintDemo>
    with SingleTickerProviderStateMixin {
  bool _showArrow = false;
  late AnimationController _controller;
  late Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _arrowAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleArrow() {
    setState(() {
      _showArrow = !_showArrow;
      if (_showArrow) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const text = 'text text';
    const style = TextStyle(
      fontSize: 48,
      color: Colors.white,
      fontWeight: FontWeight.w400,
    );

    /// дурацкий кусок для расчета высоты текста
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();

    const paddingH = 36.0;
    const paddingTop = 20.0;
    const paddingBottom = 20.0;
    const maxArrowHeight = 32.0;

    final bubbleWidth = textPainter.width + paddingH * 2;
    final bubbleHeight = textPainter.height + paddingTop + paddingBottom + maxArrowHeight;

    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _toggleArrow,
          child: AnimatedBuilder(
            animation: _arrowAnim,
            builder: (context, child) {
              return CustomPaint(
                size: Size(bubbleWidth, bubbleHeight),
                painter: _Pin(
                  arrow: _arrowAnim.value,
                  text: text,
                  textStyle: style,
                  paddingH: paddingH,
                  paddingTop: paddingTop,
                  paddingBottom: paddingBottom,
                  maxArrowHeight: maxArrowHeight,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Pin extends CustomPainter {
  final double arrow;
  final String text;
  final TextStyle textStyle;
  final double paddingH;
  final double paddingTop;
  final double paddingBottom;
  final double maxArrowHeight;

  _Pin({
    required this.arrow,
    required this.text,
    required this.textStyle,
    required this.paddingH,
    required this.paddingTop,
    required this.paddingBottom,
    required this.maxArrowHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = 36.0;
    final arrowHeight = maxArrowHeight * arrow;
    final arrowWidth = 56.0 * arrow;
    final bubbleHeight = size.height - maxArrowHeight;

    final paint = Paint()
      ..color = const Color(0xFF4E91FF)
      ..style = PaintingStyle.fill;

    final border = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, bubbleHeight - r);
    path.quadraticBezierTo(
        size.width, bubbleHeight, size.width - r, bubbleHeight);

    path.lineTo(size.width / 2 + arrowWidth / 2, bubbleHeight);

    if (arrow > 0) {
      path.lineTo(size.width / 2, bubbleHeight + arrowHeight);
      path.lineTo(size.width / 2 - arrowWidth / 2, bubbleHeight);
    }

    path.lineTo(r, bubbleHeight);
    path.quadraticBezierTo(0, bubbleHeight, 0, bubbleHeight - r);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);

    final txtPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      maxLines: 1,
    )..layout();

    final dx = (size.width - txtPainter.width) / 2;
    final dy = (bubbleHeight - txtPainter.height) / 2;

    txtPainter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _Pin oldDelegate) =>
      oldDelegate.arrow != arrow || oldDelegate.text != text;
}