// current_conditions_types.dart

class Temperature {
  final String value;
  final String unit;

  Temperature({
    required this.value,
    required this.unit,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) {
    final metric = json['Metric'];
    return Temperature(
      value: metric['Value'].toString(),
      unit: "${metric['Unit']}°",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'unit': unit,
    };
  }
}

class CurrentConditions {
  final String weatherText;
  final int weatherIcon;
  final Temperature temperature;
  final Temperature realFeelTemperature;
  final double windSpeed;
  final int uvIndex;
  final String uvIndexText;

  CurrentConditions({
    required this.weatherText,
    required this.weatherIcon,
    required this.temperature,
    required this.realFeelTemperature,
    required this.windSpeed,
    required this.uvIndex,
    required this.uvIndexText,
  });

  factory CurrentConditions.fromJson(Map<String, dynamic> json) {
    return CurrentConditions(
      weatherText: json['WeatherText'],
      weatherIcon: json['WeatherIcon'],
      temperature: Temperature.fromJson(json['Temperature']),
      windSpeed: json['Wind']['Speed']['Metric']['Value'].toDouble(),
      uvIndex: json['UVIndex'],
      uvIndexText: json['UVIndexText'],
      realFeelTemperature: Temperature.fromJson(json['RealFeelTemperature']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weatherText': weatherText,
      'weatherIcon': weatherIcon,
      'temperature': temperature.toJson(),
      'windSpeed': windSpeed,
      'uvIndex': uvIndex,
      'uvIndexText': uvIndexText,
    };
  }

  CurrentConditions copyWith({
    String? weatherText,
    int? weatherIcon,
    Temperature? temperature,
    double? windSpeed,
    int? uvIndex,
    String? uvIndexText,
    Temperature? realFeelTemperature,
  }) {
    return CurrentConditions(
      weatherText: weatherText ?? this.weatherText,
      weatherIcon: weatherIcon ?? this.weatherIcon,
      temperature: temperature ?? this.temperature,
      windSpeed: windSpeed ?? this.windSpeed,
      uvIndex: uvIndex ?? this.uvIndex,
      uvIndexText: uvIndexText ?? this.uvIndexText,
      realFeelTemperature: realFeelTemperature ?? this.realFeelTemperature,
    );
  }
}
