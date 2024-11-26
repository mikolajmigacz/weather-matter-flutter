class Region {
  final String id;
  final String localizedName;
  final String englishName;

  Region({
    required this.id,
    required this.localizedName,
    required this.englishName,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['ID'],
      localizedName: json['LocalizedName'],
      englishName: json['EnglishName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'LocalizedName': localizedName,
      'EnglishName': englishName,
    };
  }
}

class Country {
  final String id;
  final String localizedName;
  final String englishName;

  Country({
    required this.id,
    required this.localizedName,
    required this.englishName,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['ID'],
      localizedName: json['LocalizedName'],
      englishName: json['EnglishName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'LocalizedName': localizedName,
      'EnglishName': englishName,
    };
  }
}

class CityDetails {
  final String key;
  final String localizedName;
  final String englishName;
  final Region region;
  final Country country;
  final double latitude; // Added
  final double longitude; // Added

  CityDetails({
    required this.key,
    required this.localizedName,
    required this.englishName,
    required this.region,
    required this.country,
    required this.latitude, // Added
    required this.longitude, // Added
  });

  factory CityDetails.fromJson(Map<String, dynamic> json) {
    final geoPosition = json['GeoPosition'] as Map<String, dynamic>;

    return CityDetails(
      key: json['Key'],
      localizedName: json['LocalizedName'],
      englishName: json['EnglishName'],
      region: Region.fromJson(json['Region']),
      country: Country.fromJson(json['Country']),
      latitude: geoPosition['Latitude'].toDouble(), // Added
      longitude: geoPosition['Longitude'].toDouble(), // Added
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'LocalizedName': localizedName,
      'EnglishName': englishName,
      'Region': region.toJson(),
      'Country': country.toJson(),
      'GeoPosition': {
        // Added
        'Latitude': latitude,
        'Longitude': longitude,
      },
    };
  }
}
