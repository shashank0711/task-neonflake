import 'dart:convert';
import 'package:hive/hive.dart';

import '../Secrets/secrets.dart';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getCurrentWeather(String cityName) async {
  try {
    cityName = cityName.trim();
    final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey'));

    final data = jsonDecode(res.body);
    if (data['cod'] != '200') {
      throw data['message'];
    }

    await _saveToHive('weatherData', data);
    return data;

    print(data['list'][0]['main']['temp']);
  } catch (e) {
    // Try to load from Hive on failure
    final cachedData = await _readFromHive('weatherData');
    if (cachedData != null) {
      return cachedData;
    }
    throw e.toString();
  }
}


//Hive to store weather data locally when the user is not having internet connection
Future<void> _saveToHive(String key, Map<String, dynamic> data) async {
  var box = await Hive.openBox('weatherBox');
  await box.put(key, jsonEncode(data));
  await box.close();
}

Future<Map<String, dynamic>?> _readFromHive(String key) async {
  var box = await Hive.openBox('weatherBox');
  var jsonString = box.get(key);
  await box.close();
  if (jsonString != null) {
    return jsonDecode(jsonString);
  }
  return null;
}
