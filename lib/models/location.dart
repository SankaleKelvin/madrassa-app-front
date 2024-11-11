//Locations model
class Location{
  int id;
  String name;
  String areaCode;


Location({ required this.id, required this.name, required this.areaCode });

factory Location.fromJson(Map<String, dynamic> json){
  return Location(
    id: json['id'],
    name: json['name'],
    areaCode: json['areaCode']
  );
  }
}