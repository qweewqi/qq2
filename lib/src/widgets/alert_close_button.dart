import 'package:flutter/material.dart';

class AlertCloseButton extends StatelessWidget {
  AlertCloseButton({@required this.image, this.isPositioned = true});

  final Image image;
  final bool isPositioned;
  Widget closeButton;

  @override
  Widget build(BuildContext context) {
    closeButton = GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(
          child: image,
        ),
      ),
    );
    return isPositioned
        ? Positioned(
            bottom: 60,
            child: closeButton,
          )
        : Center(child: closeButton);
  }
}
