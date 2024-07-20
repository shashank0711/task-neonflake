import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/openWeatherAPIService.dart';
import '../Utilities/utils.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  final cityController = TextEditingController();
  String selectedCity = 'Ghaziabad';
  late Future<Map<String, dynamic>> weatherData;
  bool isConnectedToInternet = false;
  StreamSubscription? internetConnection;

  @override
  void initState() {
    super.initState();
    getCityName();
    weatherData = getCurrentWeather(selectedCity);
    internetConnection = InternetConnection().onStatusChange.listen((event) {
      print(event);
      switch (event) {
        case InternetStatus.connected:
          setState(() {
            isConnectedToInternet = true;
          });
          break;
        case InternetStatus.disconnected:
          setState(() {
            isConnectedToInternet = false;
          });
          break;
        default:
          setState(() {
            isConnectedToInternet = false;
          });
      }
    });
  }

  void getCityName() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? getName = pref.getString("cityName");
    setState(() {
      selectedCity = getName ?? "Ghaziabad";
      weatherData = getCurrentWeather(selectedCity);
    });
  }

  void updateWeather(String enteredCity) async {
    var pref = await SharedPreferences.getInstance();
    pref.setString("cityName", enteredCity);
    setState(() {
      selectedCity = enteredCity;
      weatherData = getCurrentWeather(selectedCity);
    });
  }

  @override
  void dispose() {
    internetConnection?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Weather App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    weatherData = getCurrentWeather(selectedCity);
                  });
                },
                icon: Icon(Icons.refresh)),
          ],
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              //textformfield to enter the city name
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: size.width * 0.4,
                    child: Row(
                      children: [
                        const Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.location_on,
                            size: 30,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            selectedCity,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: size.width * .47,
                    child: TextField(
                      controller: cityController,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.search,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white70,
                        ),
                        contentPadding: EdgeInsets.all(15),
                        hintText: 'Enter City...',
                        filled: true,
                        fillColor: Colors.black38,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.black54,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && isConnectedToInternet == true) {
                          updateWeather(value);
                        } else if (isConnectedToInternet == false) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'No Internet Connection\nConnect to internet ')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * .02,
              ),

              FutureBuilder(
                future: weatherData,
                builder: (context, snapshot) {
                  // print('SnapShot is $snapshot');
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  final data = snapshot.data!;
                  final currentWeatherData = data['list'][0];

                  final currentTemp = (currentWeatherData['main']['temp'] - 273)
                      .toStringAsFixed(1);
                  final currentSky = currentWeatherData['weather'][0]['main'];
                  final humidityValue = currentWeatherData['main']['humidity'];
                  final windSpeed = currentWeatherData['wind']['speed'];
                  final pressureValue = currentWeatherData['main']['pressure'];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //main card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currentTemp °C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * .02,
                                    ),
                                    Icon(
                                      currentSky == 'Clouds' ||
                                              currentSky == 'Rain'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 65,
                                    ),
                                    SizedBox(
                                      height: size.height * .02,
                                    ),
                                    Text(
                                      '$currentSky',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      //weather forecast card
                      SizedBox(
                        height: size.height * .03,
                      ),
                      const Text(
                        '5-Day Forecast',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.height * .015,
                      ),

                      SizedBox(
                        height: size.height * .16,
                        child: ListView.builder(
                            itemCount: 5,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final dayWiseForecast =
                                  data['list'][index * 8]['dt_txt'];
                              final dayWiseSky =
                                  data['list'][index * 8]['weather'][0]['main'];
                              final dayWiseTemp = (data['list'][index * 8]
                                          ['main']['temp'] -
                                      273)
                                  .toStringAsFixed(1);
                              final hourlyTime =
                                  DateTime.parse(dayWiseForecast);
                              return ForecastBlock(
                                  DateFormat('dd MMMM').format(hourlyTime),
                                  dayWiseSky == 'Clouds' || dayWiseSky == 'Rain'
                                      ? Icons.cloud
                                      : Icons.sunny,
                                  dayWiseTemp);
                            }),
                      ),

                      //additional information
                      SizedBox(
                        height: size.height * .06,
                      ),
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.height * .015,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Additional_info_block(
                              Icons.water_drop, 'Humidity', '$humidityValue'),
                          Additional_info_block(
                              Icons.air, 'Wind Speed', '$windSpeed'),
                          Additional_info_block(
                              Icons.beach_access, 'Pressure', '$pressureValue'),
                        ],
                      )
                    ],
                  );
                },
              ),
            ],
          ),
        )));
  }
}
