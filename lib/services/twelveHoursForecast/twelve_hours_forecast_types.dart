class HourForecastTemperature {
  final String value;
  final String unit;

  HourForecastTemperature({
    required this.value,
    required this.unit,
  });

  factory HourForecastTemperature.fromJson(Map<String, dynamic> json) {
    return HourForecastTemperature(
      value: json['Value'].toString(),
      unit: "${json['Unit']}°",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}

class HourForecast {
  final DateTime dateTime;
  final int weatherIcon;
  final HourForecastTemperature temperature;

  HourForecast({
    required this.dateTime,
    required this.weatherIcon,
    required this.temperature,
  });

  factory HourForecast.fromJson(Map<String, dynamic> json) {
    return HourForecast(
      dateTime: DateTime.parse(json['DateTime']),
      weatherIcon: json['WeatherIcon'],
      temperature: HourForecastTemperature.fromJson(json['Temperature']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dateTime': dateTime.toIso8601String(),
      'weatherIcon': weatherIcon,
      'temperature': temperature.toJson(),
    };
  }
}
