//madrassa model
class Madrassa {
  final int id;
  final String name;
  final int locationId;
  final String locationName;

  Madrassa({required this.id, required this.name, required this.locationId, required this.locationName});

  factory Madrassa.fromJson(Map<String, dynamic> json){
    return Madrassa(
      id: json['id'],
      name: json['name'],
      locationId: json['location_id'],
      locationName: json['location_name']
      );
  }
}