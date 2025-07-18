import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TCustomCurvedEdges extends CustomClipper<Path>{

  @override
  Path getClip(Size size){
    var path = Path();
    path.lineTo(0, size.height);

    final firsCurve = Offset(0, size.height - 20);
    final lastCurve = Offset(30, size.height - 20);
    path.quadraticBezierTo(firsCurve.dx, firsCurve.dy, lastCurve.dx, lastCurve.dy);

    final secondFirstCurve = Offset(0, size.height - 20);
    final secondlastCurve = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(secondFirstCurve.dx, secondFirstCurve.dy, secondlastCurve.dx, secondlastCurve.dy);

    final thirdfirsCurve = Offset(size.width, size.height - 20);
    final thirdlastCurve = Offset(size.width, size.height);
    path.quadraticBezierTo(thirdfirsCurve.dx, thirdfirsCurve.dy, thirdlastCurve.dx, thirdlastCurve.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper){
    return true;
  }
}