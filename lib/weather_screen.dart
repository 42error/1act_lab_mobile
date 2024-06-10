import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'weather_model.dart';

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  List<WeatherForecast> _forecast = [];
  String _selectedCity = 'Москва';
  bool _isLoading = false;
  final List<String> _cities = ['Лондон', 'Нью-Йорк', 'Токио', 'Париж', 'Москва', 'Ханты-Мансийск'];

  void _fetchWeather() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String city;
      switch (_selectedCity) {
        case 'Лондон':
          city = 'London';
          break;
        case 'Нью-Йорк':
          city = 'New York';
          break;
        case 'Токио':
          city = 'Tokyo';
          break;
        case 'Париж':
          city = 'Paris';
          break;
        case 'Москва':
          city = 'Moscow';
          break;
        case 'Ханты-Мансийск':
          city = 'Khanty-Mansiysk';
          break;
        default:
          city = 'Moscow';
      }
      final weatherData = await _weatherService.fetchWeather(city);
      final forecastData = await _weatherService.fetchForecast(city);
      setState(() {
        _weather = Weather.fromJson(weatherData);
        _forecast = forecastData;
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getBackgroundImage() {
    if (_weather == null) return 'assets/clear.jpg';

    switch (_weather!.icon) {
      case '01d':
      case '01n':
        return 'assets/clear.jpg';
      case '02d':
      case '02n':
        return 'assets/few_clouds.jpg';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return 'assets/clouds.jpg';
      case '09d':
      case '09n':
        return 'assets/shower_rain.jpeg';
      case '10d':
      case '10n':
        return 'assets/rain.png';
      case '11d':
      case '11n':
        return 'assets/thunderstorm.jpg';
      case '13d':
      case '13n':
        return 'assets/snow.jpeg';
      case '50d':
      case '50n':
        return 'assets/mist.jpg';
      default:
        return 'assets/clear.jpg';
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Text _buildOutlinedText(String text, double fontSize, [FontWeight fontWeight = FontWeight.normal]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.black,
      ),
    );
  }

  Text _buildFilledText(String text, double fontSize, [FontWeight fontWeight = FontWeight.normal]) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Прогноз погоды'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(_getBackgroundImage()),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: DropdownButton<String>(
                    value: _selectedCity,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCity = newValue!;
                      });
                      _fetchWeather();
                    },
                    items: _cities.map<DropdownMenuItem<String>>((String city) {
                      return DropdownMenuItem<String>(
                        value: city,
                        child: Text(city),
                      );
                    }).toList(),
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _weather == null
                    ? Center(child: Text('Не удалось загрузить данные о погоде'))
                    : Center(
                  child: Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildOutlinedText(_weather!.cityName, 32, FontWeight.bold),
                          _buildOutlinedText('${_weather!.temperature.round()}°C', 64),
                          _buildOutlinedText(_weather!.description, 24),
                          Image.network(
                            'http://openweathermap.org/img/wn/${_weather!.icon}@2x.png',
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _fetchWeather,
                            child: Text('Обновить'),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFilledText(_weather!.cityName, 32, FontWeight.bold),
                          _buildFilledText('${_weather!.temperature.round()}°C', 64),
                          _buildFilledText(_weather!.description, 24),
                          SizedBox(height: 150),
                        ],
                      ),
                    ],
                  ),
                ),
                _forecast.isEmpty
                    ? Center(child: Text('Не удалось загрузить прогноз'))
                    : Expanded(
                  child: ListView.builder(
                    itemCount: _forecast.length ~/ 8, // 8 записей в день
                    itemBuilder: (context, index) {
                      List<WeatherForecast> dailyForecast = _forecast.sublist(index * 8, (index + 1) * 8);
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(dailyForecast.first.date.split(' ')[0]), // Показываем только дату
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: dailyForecast.map((forecast) {
                                  return Column(
                                    children: [
                                      Text(forecast.date.split(' ')[1]), // Время
                                      Image.network(
                                        'http://openweathermap.org/img/wn/${forecast.icon}@2x.png',
                                      ),
                                      Text('${forecast.temperature}°C'),
                                      Text(forecast.description),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
