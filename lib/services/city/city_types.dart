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

  CityDetails({
    required this.key,
    required this.localizedName,
    required this.englishName,
    required this.region,
    required this.country,
  });

  factory CityDetails.fromJson(Map<String, dynamic> json) {
    return CityDetails(
      key: json['Key'],
      localizedName: json['LocalizedName'],
      englishName: json['EnglishName'],
      region: Region.fromJson(json['Region']),
      country: Country.fromJson(json['Country']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Key': key,
      'LocalizedName': localizedName,
      'EnglishName': englishName,
      'Region': region.toJson(),
      'Country': country.toJson(),
    };
  }
}
