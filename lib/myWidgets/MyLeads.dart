import 'package:flutter/material.dart';

class MyLeads extends StatelessWidget {
  final List<Map<String, dynamic>> responseList; // Your response_data list

  MyLeads({required this.responseList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: responseList.length,
      itemBuilder: (context, index) {
        final item = responseList[index];
        final lead = item['lead'];

        return ListTile(
          title: Text(lead['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: ${lead['phone']}'),
              Text('Date: ${lead['lead_date']}'),
              Text('Category: ${lead['category']}'),
              Text('Location: ${lead['location']}'),
            ],
          )

        );
      },
    );
  }
}