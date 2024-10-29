class AutocompleteCity {
  final String key;
  final String localizedName;
  final Country country;
  final AdministrativeArea administrativeArea;

  AutocompleteCity({
    required this.key,
    required this.localizedName,
    required this.country,
    required this.administrativeArea,
  });

  factory AutocompleteCity.fromJson(Map<String, dynamic> json) {
    return AutocompleteCity(
      key: json['Key'],
      localizedName: json['LocalizedName'],
      country: Country.fromJson(json['Country']),
      administrativeArea:
          AdministrativeArea.fromJson(json['AdministrativeArea']),
    );
  }
}

class Country {
  final String id;
  final String name;

  Country({
    required this.id,
    required this.name,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['ID'],
      name: json['LocalizedName'],
    );
  }
}

class AdministrativeArea {
  final String id;
  final String name;

  AdministrativeArea({
    required this.id,
    required this.name,
  });

  factory AdministrativeArea.fromJson(Map<String, dynamic> json) {
    return AdministrativeArea(
      id: json['ID'],
      name: json['LocalizedName'],
    );
  }
}
