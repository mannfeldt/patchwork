import 'package:flutter/material.dart';
import 'package:patchwork/mainMenu.dart';
import 'package:patchwork/gameplay.dart';
import 'package:patchwork/setup.dart';
import 'package:provider/provider.dart';
import 'package:patchwork/models/piece.dart';
import 'package:patchwork/gamestate.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());
// TODO Animations. coola animeringar övergångar osv. snyggt vore om när man gör put piece så läggs den ner.
// och knapparna räknas bort i en animation, sen flippas det automatiskt till timeboard-vyn där spelarens piece rör sig steg framåt
//när den stannat och antingen fått en extra piece eller är nästa spelares tur så swapar den tillbaka till game-vyn
//pieceSelectorn ska också animeras så att den snyggt plockar bort pieces och glider till vänster

// TODO Rotering och spegling kanske man kan göra medan man drar biten? typ om man spelar med två fingrar och så har vi större knappar nere under boarden medan man drar i en bit
// kanvara bra om det är jobbigt att behöva släppa biten hela tiden.
//


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<GameState>(
        builder: (_) => GameState("test123"),
        child: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  String _previousPhase;
  //skapa en koppling till game.dart som state?
  //använd funktionerna i game.fetchgame/joingame till en knapp här
  //sen ska ju denna widget bara visas om golfgame är null.
  //annars ska widget lobby eller gameplay visas beroende på vad phase är.
  //denna wdiget är parent som håller state, lobby och gameplay är childs som jag kan passa state till och renderare rätt child beroende på state i parent här.
  @override
  Widget build(BuildContext context) {
    final gameState = Provider.of<GameState>(context);
    final view = gameState.getView();
    Widget child;
    bool showAppBar = true;
    if (view == null) {
      child = MainMenu();
    }else if(view == "setup"){
      child = Setup();
    }else if(view == "gameplay"){
      child = Gameplay();
      showAppBar=false;
    }else if(view == "finished"){
      child = Text("finished view");
      showAppBar=false;
    }
   
// börja med det grafiska nu. när man klickarp å new game så ska en vy visas som är settings. här väljer man antal spelare och om det ska vara randombitar eller default
// när man godkänt inställningar kommer man vidare till gameplay där man får se timeboard och alla spelbitar runt denna. (alla kan inte visas så får bli någon form av scroll/zoom/portal de kommer ut genom)
//  därifrån ska man kunna swipea över till en annan vy som visar currentplayers spelbräde, tre nästkommande bitar att välja på, en passknapp, HuD för spelarens knappar (kanske senare också hur många ofyllda shape spelaren har )
//  seplaren ska kunna scrolla i listan av nästa bitar för att se efterkommande också. bitarna ska visas snyggt. sale/over, pris, buttons, color, disabled om man inte har råd eller inte kan placera den (rulengine.canSelectPiece)
//     swipea mellan vyer kan uppnås med att se det som en lista med två objekt som ligger horizontellt och tar upp 100%?
//     drag and drop ska vara med sikte på leftTopMost har jag sagt. då måste det också vara där man håller tummen på för att det ksa bli korrekt?
//     alt. så blir det inte leftTopMost utan vi har en dragSquare som är den man har fingret på och det är den som styr hur placeringen blir beroende på var man släpper den
    var scaffold = Scaffold(
        
      appBar: showAppBar ? AppBar(
        title: Text("Patchwork"),
      ):null,
      body: child,
    );
    return scaffold;
  }
}
//https://github.com/CACppuccino/PatchworkGame
//smart sätt att spara information om boardplacements? kräver dock att vi gett idn till alla pieces
//här har vi även alla bitar som bilder. kan användas rakt av? modifieras. jag kanske vill använda mnstret från bitarna? skapa 1x1 bitar av varaje mönster
//som jag kan se använda för att bygga ihop mina bitar. sen lägga knappar ovanpå och kostnaden ovanpå? x2 bilder där varje mönster 1x1 också har en knapp på
//kostanden är egentligen irrelvant när biten ligger på boardet. så kan ta bort den? bara skriva kostanden under biten eller vad som när man väljer?
//
//https://github.com/adrianosmond/patchwork/blob/master/src/constants/utils.js
//bra javascript functioner för regler osv.
