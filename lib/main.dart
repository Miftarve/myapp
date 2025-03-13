// main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/partita_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Football App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: HomeScreen(),
    );
  }
}

/// Schermata iniziale con scelta delle modalità
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20.0),
                child: Text(
                  "FOOTBALL APP",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/1006/1006657.png',
                          height: 150,
                          color: Colors.white,
                        ),
                        SizedBox(height: 50),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade800,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline),
                                SizedBox(width: 10),
                                Text(
                                  "Visualizza le Rose",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              // Modalità visualizzazione: matchMode = false
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          CampionatiScreen(matchMode: false),
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.blue.shade800,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.sports_soccer),
                                SizedBox(width: 10),
                                Text(
                                  "Gioca Partita",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              // Modalità partita: matchMode = true
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          CampionatiScreen(matchMode: true),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  "Tutte le statistiche del calcio mondiale",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Schermata dei campionati (leagues)
class CampionatiScreen extends StatefulWidget {
  final bool
  matchMode; // true per selezionare squadre e giocare, false per vedere le rose

  CampionatiScreen({this.matchMode = false});

  @override
  _CampionatiScreenState createState() => _CampionatiScreenState();
}

class _CampionatiScreenState extends State<CampionatiScreen> {
  final String apiKey = "2ba03287673f02bbc8ae7911d70b14a3";
  final List<int> topLeagues = [39, 140, 61, 78, 135, 88];
  List leagues = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeagues();
  }

  Future<void> fetchLeagues() async {
    final response = await http.get(
      Uri.parse("https://v3.football.api-sports.io/leagues"),
      headers: {"x-apisports-key": apiKey},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        leagues =
            data["response"]
                .where((league) => topLeagues.contains(league["league"]["id"]))
                .toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Campionati",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          widget.matchMode
                              ? "Seleziona un campionato per la partita"
                              : "Esplora i principali campionati",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16.0,
                                  mainAxisSpacing: 16.0,
                                  childAspectRatio: 0.85,
                                ),
                            itemCount: leagues.length,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => SquadreScreen(
                                              leagueId:
                                                  leagues[index]["league"]["id"],
                                              matchMode: widget.matchMode,
                                              leagueName:
                                                  leagues[index]["league"]["name"],
                                              leagueLogo:
                                                  leagues[index]["league"]["logo"],
                                            ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            leagues[index]["league"]["logo"],
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          leagues[index]["league"]["name"],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.blue.shade900,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        leagues[index]["country"]["name"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

/// Schermata delle squadre: se matchMode è false, tocca la squadra per vederne la rosa; se true, scegli due squadre per giocare.
class SquadreScreen extends StatefulWidget {
  final int leagueId;
  final bool matchMode;
  final String leagueName;
  final String leagueLogo;

  SquadreScreen({
    required this.leagueId,
    this.matchMode = false,
    this.leagueName = "",
    this.leagueLogo = "",
  });

  @override
  _SquadreScreenState createState() => _SquadreScreenState();
}

class _SquadreScreenState extends State<SquadreScreen> {
  final String apiKey = "2ba03287673f02bbc8ae7911d70b14a3";
  List teams = [];
  bool isLoading = true;
  List selectedTeams = [];

  @override
  void initState() {
    super.initState();
    fetchSquadre();
  }

  Future<void> fetchSquadre() async {
    final response = await http.get(
      Uri.parse(
        "https://v3.football.api-sports.io/teams?league=${widget.leagueId}&season=2023",
      ),
      headers: {"x-apisports-key": apiKey},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        teams = data["response"];
        isLoading = false;
      });
    }
  }

  void selectTeam(Map team) {
    setState(() {
      if (selectedTeams.contains(team)) {
        selectedTeams.remove(team);
      } else if (selectedTeams.length < 2) {
        selectedTeams.add(team);
      }
    });
  }

  void startMatch() {
    if (selectedTeams.length == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PartitaScreen(
                selectedTeams[0],
                selectedTeams[1],
                allTeams: teams, // Passa tutte le squadre della lega
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          widget.matchMode ? "Seleziona due squadre" : widget.leagueName,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF134E5E), Color(0xFF71B280)],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Column(
                    children: [
                      // League header
                      if (widget.leagueLogo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            bottom: 16.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.network(
                                  widget.leagueLogo,
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              if (widget.matchMode)
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Text(
                                    "Seleziona due squadre per giocare",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Selected teams display for match mode
                      if (widget.matchMode && selectedTeams.isNotEmpty)
                        Container(
                          margin: EdgeInsets.all(12),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (int i = 0; i < selectedTeams.length; i++)
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Image.network(
                                          selectedTeams[i]["team"]["logo"],
                                          width: 40,
                                          height: 40,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        selectedTeams[i]["team"]["name"],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (selectedTeams.length == 1)
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white70,
                                          size: 30,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Seleziona",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Teams grid
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: widget.matchMode ? 3 : 2,
                                  crossAxisSpacing: 12.0,
                                  mainAxisSpacing: 12.0,
                                  childAspectRatio:
                                      widget.matchMode ? 0.8 : 0.9,
                                ),
                            itemCount: teams.length,
                            itemBuilder: (context, index) {
                              bool isSelected =
                                  widget.matchMode &&
                                  selectedTeams.contains(teams[index]);

                              return GestureDetector(
                                onTap: () {
                                  if (widget.matchMode) {
                                    selectTeam(teams[index]);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => GiocatoriScreen(
                                              teamId:
                                                  teams[index]["team"]["id"],
                                            ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isSelected
                                            ? Colors.green.shade100
                                            : Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: Colors.green,
                                              width: 3,
                                            )
                                            : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isSelected)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                        ),
                                      Image.network(
                                        teams[index]["team"]["logo"],
                                        width: 60,
                                        height: 60,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          teams[index]["team"]["name"],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color:
                                                isSelected
                                                    ? Colors.green.shade800
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Play match button
                      if (widget.matchMode)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed:
                                  selectedTeams.length == 2 ? startMatch : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey.shade400,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.sports_soccer),
                                  SizedBox(width: 12),
                                  Text(
                                    "Gioca Partita",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
        ),
      ),
    );
  }
}

/// Schermata per visualizzare la rosa (giocatori) di una squadra
class GiocatoriScreen extends StatefulWidget {
  final int teamId;

  GiocatoriScreen({required this.teamId});

  @override
  _GiocatoriScreenState createState() => _GiocatoriScreenState();
}

class _GiocatoriScreenState extends State<GiocatoriScreen> {
  final String apiKey = "2ba03287673f02bbc8ae7911d70b14a3";
  List players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGiocatori();
  }

  Future<void> fetchGiocatori() async {
    final response = await http.get(
      Uri.parse(
        "https://v3.football.api-sports.io/players?team=${widget.teamId}&season=2023",
      ),
      headers: {"x-apisports-key": apiKey},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        players = data["response"];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Giocatori")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(players[index]["player"]["name"]),
                    leading: Image.network(
                      players[index]["player"]["photo"],
                      width: 50,
                    ),
                    subtitle: Text("Età: ${players[index]["player"]["age"]}"),
                    onTap: () {
                      // Visualizza dettagli del giocatore
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(players[index]["player"]["name"]),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  players[index]["player"]["photo"],
                                  width: 100,
                                ),
                                Text("Età: ${players[index]["player"]["age"]}"),
                                Text(
                                  "Nazionalità: ${players[index]["player"]["nationality"]}",
                                ),
                                Text(
                                  "Posizione: ${players[index]["player"]["position"]}",
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Chiudi"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
