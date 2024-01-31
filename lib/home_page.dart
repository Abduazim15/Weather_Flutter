import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:weather/weather.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selected = 0;
  String cityName = 'Tashkent';
  bool isDarkMode = false;
  Position? position;
  Weather? weather;
  WeatherFactory wf = WeatherFactory(
    "0cec2a74add655ada491e8c95a7199cf",
    language: Language.ENGLISH,
  );

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> getWeather() async {
    Weather? currentWeather = await wf.currentWeatherByLocation(
        position?.latitude != null ? position!.latitude : 41.322293,
        position?.longitude != null ? position!.longitude : 69.242475);
    setState(() {
      weather = currentWeather;
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() async {
        position = await Geolocator.getLastKnownPosition(
            forceAndroidLocationManager: true);
      });

      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _determinePosition();
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _determinePosition();
      return;
      // Permissions are denied forever, handle appropriately.
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position p = await Geolocator.getCurrentPosition();
    setState(() {
      position = p;
      getWeather();
    });
  }

  String getWeatherConditionString() {
    if (weather != null && weather!.weatherConditionCode != null) {
      if (weather!.weatherConditionCode! >= 200 &&
          weather!.weatherConditionCode! <= 299) {
        return 'assets/rainy_thunder.json';
      } else if (weather!.weatherConditionCode! >= 300 &&
          weather!.weatherConditionCode! <= 399) {
        return 'assets/rainy_thunder.json';
      } else if (weather!.weatherConditionCode! >= 500 &&
          weather!.weatherConditionCode! <= 599) {
        return 'assets/rainy.json';
      } else if (weather!.weatherConditionCode! >= 600 &&
          weather!.weatherConditionCode! <= 699) {
        return 'assets/snowy.json';
      } else if (weather!.weatherConditionCode! >= 700 &&
          weather!.weatherConditionCode! <= 799) {
        return 'assets/rainy_thunder.json';
      } else if (weather!.weatherConditionCode! == 800) {
        return 'assets/sunny.json';
      } else if (weather!.weatherConditionCode! == 801) {
        return 'assets/few_cloudy.json';
      } else if (weather!.weatherConditionCode! >= 802 &&
          weather!.weatherConditionCode! <= 899) {
        return 'assets/cloudy.json';
      }else {return 'assets/sunny.json';}
    }
    return 'assets/sunny.json';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      // Apply theme based on the mode
      duration: const Duration(milliseconds: 300),
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          items: const [
            Icon(Icons.light_mode, color: Colors.white),
            Icon(Icons.dark_mode, color: Colors.white),
          ],
          backgroundColor: Colors.transparent,
          color: Colors.indigo,
          onTap: (index) {
            setState(() {
              selected = index;
              isDarkMode = index ==
                  1; // Update the dark mode based on the selected index
            });
          },
          animationDuration: const Duration(milliseconds: 300),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: Colors.red,
                  ),
                  Text(
                    weather != null ? weather!.areaName.toString() : '',
                    style:
                        const TextStyle(decoration: TextDecoration.underline),
                  ),
                ],
              ),
              Lottie.asset(getWeatherConditionString()),
              Text(
                "${weather != null ? weather!.temperature!.celsius!.toInt() : ''} C",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
