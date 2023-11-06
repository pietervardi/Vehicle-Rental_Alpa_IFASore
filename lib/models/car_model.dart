class Car {
  int id;
  String name;
  String brand;
  String image;
  int price;
  String color;
  String gearbox;
  String seat;
  String fuel;
  String power;
  bool book;
  String? date;

  Car({
    required this.id,
    required this.name, 
    required this.brand, 
    required this.image, 
    required this.price,
    required this.color,
    required this.gearbox,
    required this.seat,
    required this.fuel,
    required this.power,
    required this.book,
    required this.date,
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    id: json['id'],
    name: json['name'],
    brand: json['brand'],
    image: json['image'],
    price: json['price'],
    color: json['color'],
    gearbox: json['gearbox'],
    seat: json['seat'],
    fuel: json['fuel'],
    power: json['power'],
    book: json['book'],
    date: json['date'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brand': brand,
    'image': image,
    'price': price,
    'color': color,
    'gearbox': gearbox,
    'seat': seat,
    'fuel': fuel,
    'power': power,
    'book': book,
    'date': date,
  };
}
