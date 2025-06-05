class Person  {
  const Person({required this.name, required this.profilepicurl});
  final String name;
  final String profilepicurl;
  // @override
  // State<CommentWidget> createState() => CommentWidgetState();
}

class Family {
  final mum = Person(name: "mum", profilepicurl: "asset/lib/dummy_data/pictures/mumprofile.jpeg");
  final dad = Person(name: "dad", profilepicurl: "asset/lib/dummy_data/pictures/dadprofile.png");
  final bro = Person(name: "bro", profilepicurl: "asset/lib/dummy_data/pictures/broprofile.jpg");
  final me  = Person(name: "me", profilepicurl:  "meprofile");
  
}

class DummyFamilyState {

}