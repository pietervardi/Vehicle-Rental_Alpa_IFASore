import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    Color baseColor;
    Color highlightColor;

    if (brightness == Brightness.dark) {
      baseColor = Colors.white.withOpacity(0.1);
      highlightColor = Colors.white.withOpacity(0.05);
    } else {
      baseColor = Colors.grey.shade300;
      highlightColor = Colors.grey.shade100;
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}