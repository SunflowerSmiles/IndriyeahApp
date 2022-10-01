// import 'package:flutter/material.dart';

// typedef void OnWidgetSizeChange(Size size);

// class MeasureSize extends StatefulWidget {
//   final Widget child;
//   final OnWidgetSizeChange onChange;

//   const MeasureSize({
//     required Key key,
//     required this.onChange,
//     required this.child,
//   }) : super(key: key);

//   @override
//   _MeasureSizeState createState() => _MeasureSizeState();
// }

// class _MeasureSizeState extends State<MeasureSize> {
//   var widgetKey = GlobalKey();

//   @override
//   Widget build(BuildContext context) {
//     WidgetsBinding.instance.addPostFrameCallback(
//         (_) => widget.onChange(widgetKey.currentContext.size));

//     return Container(
//       key: widgetKey,
//       child: widget.child,
//     );
//   }
// }
