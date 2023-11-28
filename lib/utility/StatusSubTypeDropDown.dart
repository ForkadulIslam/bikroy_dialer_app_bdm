import 'package:flutter/material.dart';
class StatusSubTypeDropDown extends StatefulWidget {
  const StatusSubTypeDropDown({super.key});

  @override
  State<StatusSubTypeDropDown> createState() => _StatusSubTypeDropDownState();
}

class _StatusSubTypeDropDownState extends State<StatusSubTypeDropDown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<Map<String, dynamic>>(
      onChanged: (Map<String, dynamic>? value) {
        print(value);
      },
      items: [
        DropdownMenuItem<Map<String, dynamic>>(
          value: null,
          child: Text('Status sub type'),
        )
      ],
    );
  }
}
