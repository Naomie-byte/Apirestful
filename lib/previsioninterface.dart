import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'donnees_meteo_widget.dart';

class PrevisionInterface extends StatefulWidget {
  @override
  _PrevisionInterfaceState createState() => _PrevisionInterfaceState();
}

class _PrevisionInterfaceState extends State<PrevisionInterface> {
  final TextEditingController _villeController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _donneesMeteo;

  // clé Api
  final String _apiKey = '153fec9ba9f0eacc93bc8bb15551bee8';

  Future<void> _recupererDonnees() async {
    final String ville = _villeController.text.trim();
    if (ville.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Veuillez entrer le nom d'une ville.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _donneesMeteo = null;
    });

    //  Encode la ville et paramètres
    try {
      final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$ville&appid=$_apiKey&units=metric&lang=fr',
      );
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _donneesMeteo = data;
          _isLoading = false;
        });
      } else if(response.statusCode == 400) {
        setState(() => _isLoading = false);
        String message = 'Requete invalide : vérifiez le nom de la ville.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else if(response.statusCode == 401) {
        setState(() => _isLoading = false);
        String message = 'Clé API invalide ou expirée.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else  {
        setState(() => _isLoading = false);
        String message = "Erreur inconnue (${response.statusCode}).";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur inconnue.")),
        );
        try {
          final Map<String, dynamic> err = jsonDecode(response.body);
          if (err.containsKey('message')) message = err['message'];
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Impossible de récupérer la météo : $message')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau ou inconnue : $e')),
      );
    }
  }
  Widget _buildMeteoCard() {
    if (_donneesMeteo == null) return SizedBox.shrink();
    final String ville = _donneesMeteo!['name'] ?? '-';
    final dynamic main = _donneesMeteo!['main'];
    final dynamic weatherList = _donneesMeteo!['weather'];
    final dynamic wind = _donneesMeteo!['wind'];
    final String description = (weatherList != null && weatherList is List && weatherList.isNotEmpty)
    ? (weatherList[0]['description'] ?? '_')
        : '_';
    final double? temp = main != null && main['temp'] != null ? (main['temp'] as num).toDouble() : null;
    final int? humidity = main != null && main['humidity'] != null ? (main['humidity'] as num).toInt() : null;
    final double? windSpeed = wind != null && wind['speed'] != null ? (wind['speed'] as num).toDouble() : null;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Padding(
          padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ville, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
                if (temp != null)
                  Text('Température : ${temp.toStringAsFixed(1)} °C', style: TextStyle(fontSize: 18)),
            Text('Description : ${description[0].toUpperCase()}${description.substring(1)}', style: TextStyle(fontSize: 16)),
            if (humidity != null) Text('Humidité : $humidity %', style: TextStyle(fontSize: 16)),
            if (windSpeed != null) Text('Vent : ${windSpeed.toStringAsFixed(1)} m/s', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    _villeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Prévisions Météo'), centerTitle: true),
      body: Center(
        child: Padding(
        padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: _villeController,
            decoration: InputDecoration(
                    labelText: 'Entrer le nom d’une ville',
                    hintText: 'Ex: Tunis, Paris, Kinshasa',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                        onPressed: () {
                          _villeController.clear();
                        },
                    ),
                  ),
                   textInputAction: TextInputAction.done,
                   onSubmitted: (_) => _recupererDonnees(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _recupererDonnees,
                      icon: Icon(Icons.cloud_download),
                      label: Text('Obtenir la météo'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                      ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  Column(
                    children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Chargement des données...', style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
    if (!_isLoading) _buildMeteoCard(),
    if (kDebugMode && _donneesMeteo != null) ...[
      SizedBox(height: 12),
    ExpansionTile(
    title: Text(''),
    children: [
      Container(
    width: double.infinity,
    color: Colors.grey[100],
    padding: EdgeInsets.all(12),
    child: SingleChildScrollView(
       scrollDirection: Axis.horizontal,
       child: SelectableText(
           JsonEncoder.withIndent(' ').convert(_donneesMeteo),
          style: TextStyle(fontFamily: 'monospace', fontSize: 12),
    ),
    ),
    ),
    ],
    ),
    ],
    ],
        ),
      ),
    ),
    );
  }
}
