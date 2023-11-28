import 'package:flutter/material.dart';
class ConditioningLoader extends StatefulWidget {
  const ConditioningLoader({super.key});

  @override
  State<ConditioningLoader> createState() => _ConditioningLoaderState();
}

class _ConditioningLoaderState extends State<ConditioningLoader> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 10,),
        Align(
          child: CircularProgressIndicator(
            color: Color(0xff009877),
          ),
          alignment: Alignment.center,
        ),
      ],
    );
  }
}
