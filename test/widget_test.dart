import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
void testApi() async {
  final apiKey = '153fec9ba9f0eacc93bc8bb15551bee8';
  final url = Uri.https(
    'api.openweathermap.org',
    '/data/2.5/weather',
    {
      'q': 'Tunis,TN',
      'appid': apiKey,
      'units': 'metric',
      'lang': 'fr',
    },
  );
  final response = await http.get(url);
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
}
