class Square {
  int id;
  int x;
  int y;
  bool hasButton;
  String
      state; //dead, cloth, wool, cotton, silk. kan användas till vad som. om man dödar någons bräde eller om man startar med ett bräde med hål i så kan en square läggas där
  String color;

  Square(int x, int y) {
    this.x = x;
    this.y = y;
    this.hasButton = false;
  }
}
