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
      appBar: AppBar(title: Text("Benvenuto in Football App")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("Visualizza le Rose"),
                onPressed: () {
                  // Modalità visualizzazione: matchMode = false
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampionatiScreen(matchMode: false),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text("Gioca Partita"),
                onPressed: () {
                  // Modalità partita: matchMode = true
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CampionatiScreen(matchMode: true),
                    ),
                  );
                },
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
      appBar: AppBar(title: Text("Campionati")),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 1.2,
                ),
                itemCount: leagues.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.2),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => SquadreScreen(
                                  leagueId: leagues[index]["league"]["id"],
                                  matchMode: widget.matchMode,
                                ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              leagues[index]["league"]["logo"],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            leagues[index]["league"]["name"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

/// Schermata delle squadre: se matchMode è false, tocca la squadra per vederne la rosa; se true, scegli due squadre per giocare.
class SquadreScreen extends StatefulWidget {
  final int leagueId;
  final bool matchMode;
  SquadreScreen({required this.leagueId, this.matchMode = false});

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
              (context) => PartitaScreen(selectedTeams[0], selectedTeams[1]),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matchMode ? "Seleziona due squadre" : "Squadre"),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: widget.matchMode ? 3 : 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: teams.length,
                      itemBuilder: (context, index) {
                        // Se matchMode è attivo, abilita la selezione multipla
                        // Altrimenti, tocca la squadra per visualizzare la rosa
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
                                        teamId: teams[index]["team"]["id"],
                                      ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side:
                                  widget.matchMode &&
                                          selectedTeams.contains(teams[index])
                                      ? BorderSide(
                                        color: Colors.green,
                                        width: 3,
                                      )
                                      : BorderSide.none,
                            ),
                            elevation: 5,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  teams[index]["team"]["logo"],
                                  width: 50,
                                  height: 50,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  teams[index]["team"]["name"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.matchMode)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed:
                            selectedTeams.length == 2 ? startMatch : null,
                        child: Text("Gioca Partita"),
                      ),
                    ),
                  SizedBox(height: 10),
                ],
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
