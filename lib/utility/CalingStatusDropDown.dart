import 'package:flutter/material.dart';
class CallingStatusDropDown extends StatefulWidget {
  const CallingStatusDropDown({super.key});

  @override
  State<CallingStatusDropDown> createState() => _CallingStatusDropDownState();
}

class _CallingStatusDropDownState extends State<CallingStatusDropDown> {
  // Define the list of options from the response data
  final List<Map<String, dynamic>> options = [
    {'id': 1, 'title': 'Interested'},
    {'id': 2, 'title': 'Not interested'},
  ];

  // Define a variable to hold the selected option
  Map<String, dynamic>? selectedOption;
  @override
  Widget build(BuildContext context) {
    @override
    initState(){
      setState(() {
        selectedOption = {'id': 1, 'title': 'Interested'};
      });
    }
    return DropdownButton<Map<String, dynamic>>(
      value: selectedOption, // Currently selected option
      onChanged: (Map<String, dynamic>? newValue) {
        setState(() {
          selectedOption = newValue;
        });
        print(selectedOption);
      },
      items: [
        DropdownMenuItem<Map<String, dynamic>>(
          //value: null,
          child: Text('Calling Status')
        ),
        // Map the actual options
        ...options.map((option) {
          return DropdownMenuItem<Map<String, dynamic>>(
            value: option,
            child: Text(option['title'] as String),
          );
        }).toList(),
      ],
    );
  }
}
