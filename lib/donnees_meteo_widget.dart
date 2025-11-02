import 'package:flutter/material.dart';

class DonneesMeteoWidget extends StatelessWidget {
  final Map<String, dynamic> donneesMeteo;

  const DonneesMeteoWidget({required this.donneesMeteo, super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic main = donneesMeteo['main'];
    final dynamic weatherList = donneesMeteo['weather'];
    final String ville = donneesMeteo['name'] ?? '_';

    final String description = (weatherList != null && weatherList is List && weatherList.isNotEmpty)
        ? (weatherList[0]['description'] ?? '_')
        : '_';
    final double? temp = main != null && main['temp'] != null
        ? (main['temp'] as num).toDouble()
        : null;
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ville,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (temp !=  null)
              Text(
               'Temperature : ${temp.toStringAsFixed(1)}°C',
              style: TextStyle(fontSize: 40, color: Colors.blue),
            ),
            Text(
              'Description : ${description[0].toUpperCase()}${description.substring(1)}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
