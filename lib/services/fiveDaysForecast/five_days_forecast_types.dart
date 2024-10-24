class DayForecast {
  final DateTime date;
  final Temperature temperature;
  final int icon;
  final String iconPhrase;

  DayForecast({
    required this.date,
    required this.temperature,
    required this.icon,
    required this.iconPhrase,
  });

  factory DayForecast.fromJson(Map<String, dynamic> json) {
    return DayForecast(
      date: DateTime.parse(json['Date']),
      temperature: Temperature.fromJson(json['Temperature']),
      icon: json['Day']['Icon'],
      iconPhrase: json['Day']['IconPhrase'],
    );
  }
}

class Temperature {
  final double minimum;
  final double maximum;
  final String unit;

  Temperature({
    required this.minimum,
    required this.maximum,
    required this.unit,
  });

  factory Temperature.fromJson(Map<String, dynamic> json) {
    return Temperature(
      minimum: json['Minimum']['Value'].toDouble(),
      maximum: json['Maximum']['Value'].toDouble(),
      unit: json['Maximum']['Unit'],
    );
  }
}
