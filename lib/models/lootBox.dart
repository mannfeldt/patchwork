import 'package:patchwork/models/lootPrice.dart';

class LootBox {
  List<LootPrice> prices;
  int winningLootId;
  LootPrice win;
  int valueFactor;

  LootBox(int winningLootId, List<LootPrice> prices, LootPrice win,
      int valueFactor) {
    this.winningLootId = winningLootId;
    this.prices = prices;
    this.win = win;
    this.valueFactor = valueFactor;
  }
  String getName() {
    if (valueFactor > 1) {
      return "Lootbox x" + valueFactor.toString();
    }
    return "Lootbox";
  }
}
