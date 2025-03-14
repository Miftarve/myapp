import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

class RisultatiCampionatoScreen extends StatefulWidget {
  final List teams;
  final Map homeTeam;
  final Map awayTeam;
  final int homeScore;
  final int awayScore;
  final int currentMatchday;

  const RisultatiCampionatoScreen({
    required this.teams,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.currentMatchday,
  });

  @override
  _RisultatiCampionatoScreenState createState() =>
      _RisultatiCampionatoScreenState();
}

class _RisultatiCampionatoScreenState extends State<RisultatiCampionatoScreen>
    with SingleTickerProviderStateMixin {
  late List<MatchResult> currentMatchdayResults = [];
  late Map<int, List<MatchResult>> allMatchdayResults = {};
  late Map<int, List<TeamStanding>> historicalStandings = {};
  late List<TeamStanding> currentStandings = [];
  final Random random = Random();
  bool isLoading = true;
  late TabController _tabController;
  int selectedMatchday = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadCampionatoData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadCampionatoData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Tenta di caricare dati salvati
      String? savedDataString = prefs.getString('campionato_data');

      if (savedDataString != null) {
        Map<String, dynamic> savedData = json.decode(savedDataString);

        // Carica risultati delle giornate passate
        if (savedData.containsKey('matchdayResults')) {
          Map<String, dynamic> matchdaysMap = savedData['matchdayResults'];
          matchdaysMap.forEach((key, value) {
            int matchday = int.parse(key);
            if (matchday < widget.currentMatchday) {
              List<dynamic> resultsList = value;
              allMatchdayResults[matchday] =
                  resultsList.map((result) {
                    return MatchResult.fromJson(result);
                  }).toList();
            }
          });
        }

        // Carica classifiche storiche
        if (savedData.containsKey('historicalStandings')) {
          Map<String, dynamic> standingsMap = savedData['historicalStandings'];
          standingsMap.forEach((key, value) {
            int matchday = int.parse(key);
            if (matchday < widget.currentMatchday) {
              List<dynamic> standingsList = value;
              historicalStandings[matchday] =
                  standingsList.map((standing) {
                    return TeamStanding.fromJson(standing);
                  }).toList();
            }
          });
        }
      }

      // Genera risultati per giornata corrente
      generateCurrentMatchdayResults();

      // Calcola classifiche
      calculateAllStandings();

      // Salva dati aggiornati
      saveCampionatoData();

      setState(() {
        selectedMatchday = widget.currentMatchday;
        isLoading = false;
      });
    } catch (e) {
      print('Errore nel caricamento dei dati: $e');
      // Fallback: genera nuovi dati
      generateCurrentMatchdayResults();
      calculateAllStandings();
      setState(() {
        selectedMatchday = widget.currentMatchday;
        isLoading = false;
      });
    }
  }

  Future<void> saveCampionatoData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Prepara i risultati di tutte le giornate per il salvataggio
      Map<String, List<Map<String, dynamic>>> matchdayResultsJson = {};
      allMatchdayResults.forEach((matchday, results) {
        matchdayResultsJson[matchday.toString()] =
            results.map((result) => result.toJson()).toList();
      });

      // Prepara le classifiche storiche per il salvataggio
      Map<String, List<Map<String, dynamic>>> historicalStandingsJson = {};
      historicalStandings.forEach((matchday, standings) {
        historicalStandingsJson[matchday.toString()] =
            standings.map((standing) => standing.toJson()).toList();
      });

      Map<String, dynamic> dataToSave = {
        'matchdayResults': matchdayResultsJson,
        'historicalStandings': historicalStandingsJson,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await prefs.setString('campionato_data', json.encode(dataToSave));
    } catch (e) {
      print('Errore nel salvataggio dei dati: $e');
    }
  }

  void generateCurrentMatchdayResults() {
    // Aggiungi il risultato della partita che l'utente ha appena giocato
    currentMatchdayResults.add(
      MatchResult(
        homeTeam: widget.homeTeam,
        awayTeam: widget.awayTeam,
        homeScore: widget.homeScore,
        awayScore: widget.awayScore,
        isUserMatch: true,
        matchday: widget.currentMatchday,
      ),
    );

    // Genera risultati per le altre partite del turno di campionato
    List teamsCopy = List.from(widget.teams);

    // Rimuovi le squadre già utilizzate nella partita dell'utente
    teamsCopy.removeWhere(
      (team) =>
          team["team"]["id"] == widget.homeTeam["team"]["id"] ||
          team["team"]["id"] == widget.awayTeam["team"]["id"],
    );

    // Shuffle per accoppiare casualmente le squadre rimanenti
    teamsCopy.shuffle();

    // Genera partite con le squadre rimanenti
    for (int i = 0; i < teamsCopy.length - 1; i += 2) {
      if (i + 1 < teamsCopy.length) {
        int homeScore = random.nextInt(4); // 0-3 gol
        int awayScore = random.nextInt(4); // 0-3 gol

        currentMatchdayResults.add(
          MatchResult(
            homeTeam: teamsCopy[i],
            awayTeam: teamsCopy[i + 1],
            homeScore: homeScore,
            awayScore: awayScore,
            isUserMatch: false,
            matchday: widget.currentMatchday,
          ),
        );
      }
    }

    // Aggiungi i risultati della giornata corrente alla mappa completa
    allMatchdayResults[widget.currentMatchday] = currentMatchdayResults;
  }

  void calculateAllStandings() {
    // Inizializza per ogni giornata
    for (int matchday = 1; matchday <= widget.currentMatchday; matchday++) {
      // Se non abbiamo risultati per questa giornata, genera risultati casuali
      if (!allMatchdayResults.containsKey(matchday)) {
        generateRandomMatchdayResults(matchday);
      }

      // Calcola la classifica fino a questa giornata
      List<TeamStanding> standings = initializeStandings();

      // Aggiorna con i risultati di tutte le giornate fino a quella attuale
      for (int day = 1; day <= matchday; day++) {
        if (allMatchdayResults.containsKey(day)) {
          updateStandingsWithResults(standings, allMatchdayResults[day]!);
        }
      }

      // Ordina la classifica
      sortStandings(standings);

      // Salva la classifica storica per questa giornata
      historicalStandings[matchday] = standings;
    }

    // La classifica corrente è quella dell'ultima giornata
    currentStandings = historicalStandings[widget.currentMatchday]!;
  }

  void generateRandomMatchdayResults(int matchday) {
    List<MatchResult> matchdayResults = [];
    List teamsCopy = List.from(widget.teams);
    teamsCopy.shuffle();

    for (int i = 0; i < teamsCopy.length - 1; i += 2) {
      if (i + 1 < teamsCopy.length) {
        int homeScore = random.nextInt(4); // 0-3 gol
        int awayScore = random.nextInt(4); // 0-3 gol

        matchdayResults.add(
          MatchResult(
            homeTeam: teamsCopy[i],
            awayTeam: teamsCopy[i + 1],
            homeScore: homeScore,
            awayScore: awayScore,
            isUserMatch: false,
            matchday: matchday,
          ),
        );
      }
    }

    allMatchdayResults[matchday] = matchdayResults;
  }

  List<TeamStanding> initializeStandings() {
    List<TeamStanding> standings = [];
    for (var team in widget.teams) {
      standings.add(TeamStanding(team: team));
    }
    return standings;
  }

  void updateStandingsWithResults(
    List<TeamStanding> standings,
    List<MatchResult> results,
  ) {
    for (var result in results) {
      // Trova la squadra di casa nella classifica
      TeamStanding homeStanding = standings.firstWhere(
        (standing) =>
            standing.team["team"]["id"] == result.homeTeam["team"]["id"],
      );

      // Trova la squadra ospite nella classifica
      TeamStanding awayStanding = standings.firstWhere(
        (standing) =>
            standing.team["team"]["id"] == result.awayTeam["team"]["id"],
      );

      // Aggiorna statistiche per entrambe le squadre
      homeStanding.played++;
      homeStanding.goalsFor += result.homeScore;
      homeStanding.goalsAgainst += result.awayScore;

      awayStanding.played++;
      awayStanding.goalsFor += result.awayScore;
      awayStanding.goalsAgainst += result.homeScore;

      if (result.homeScore > result.awayScore) {
        // Vittoria squadra di casa
        homeStanding.points += 3;
        homeStanding.won++;
        awayStanding.lost++;
        homeStanding.form.add('W');
        awayStanding.form.add('L');
      } else if (result.homeScore < result.awayScore) {
        // Vittoria squadra ospite
        awayStanding.points += 3;
        awayStanding.won++;
        homeStanding.lost++;
        homeStanding.form.add('L');
        awayStanding.form.add('W');
      } else {
        // Pareggio
        homeStanding.points += 1;
        awayStanding.points += 1;
        homeStanding.drawn++;
        awayStanding.drawn++;
        homeStanding.form.add('D');
        awayStanding.form.add('D');
      }
    }
  }

  void sortStandings(List<TeamStanding> standings) {
    standings.sort((a, b) {
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      } else {
        int diffA = a.goalsFor - a.goalsAgainst;
        int diffB = b.goalsFor - b.goalsAgainst;
        if (diffA != diffB) {
          return diffB.compareTo(diffA);
        } else {
          return b.goalsFor.compareTo(a.goalsFor);
        }
      }
    });
  }

  void changeMatchday(int matchday) {
    if (matchday >= 1 && matchday <= widget.currentMatchday) {
      setState(() {
        selectedMatchday = matchday;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Caricamento dati campionato..."),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Riepilogo Campionato"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Risultati"),
            Tab(text: "Classifica"),
            Tab(text: "Storico"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Risultati della giornata
          buildResultsTab(),

          // Tab 2: Classifica attuale
          buildStandingsTab(currentStandings),

          // Tab 3: Storico
          buildHistoryTab(),
        ],
      ),
    );
  }

  Widget buildResultsTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Risultati Giornata ${widget.currentMatchday}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${currentMatchdayResults.length} partite",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: currentMatchdayResults.length,
              itemBuilder: (context, index) {
                final result = currentMatchdayResults[index];
                return buildMatchResultCard(result);
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Torna alla selezione squadre"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStandingsTab(List<TeamStanding> standings) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Classifica Giornata $selectedMatchday",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${standings.length} squadre",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(0.5), // Posizione
                  1: FlexColumnWidth(3), // Squadra
                  2: FlexColumnWidth(0.8), // Pt
                  3: FlexColumnWidth(0.8), // G
                  4: FlexColumnWidth(0.8), // V
                  5: FlexColumnWidth(0.8), // N
                  6: FlexColumnWidth(0.8), // P
                  7: FlexColumnWidth(0.8), // GF
                  8: FlexColumnWidth(0.8), // GS
                  9: FlexColumnWidth(0.8), // DR
                  10: FlexColumnWidth(1.5), // Forma
                },
                border: TableBorder.all(color: Colors.grey.shade300, width: 1),
                children: [
                  // Header della tabella
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade200),
                    children: [
                      paddedText("#", isBold: true),
                      paddedText("Squadra", isBold: true),
                      paddedText("Pt", isBold: true),
                      paddedText("G", isBold: true),
                      paddedText("V", isBold: true),
                      paddedText("N", isBold: true),
                      paddedText("P", isBold: true),
                      paddedText("GF", isBold: true),
                      paddedText("GS", isBold: true),
                      paddedText("DR", isBold: true),
                      paddedText("Forma", isBold: true),
                    ],
                  ),
                  // Righe della tabella
                  ...standings.asMap().entries.map((entry) {
                    int idx = entry.key;
                    TeamStanding team = entry.value;
                    bool isHighlighted =
                        team.team["team"]["id"] ==
                            widget.homeTeam["team"]["id"] ||
                        team.team["team"]["id"] ==
                            widget.awayTeam["team"]["id"];

                    return TableRow(
                      decoration: BoxDecoration(
                        color: isHighlighted ? Colors.blue.shade50 : null,
                      ),
                      children: [
                        paddedText("${idx + 1}"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 4.0,
                          ),
                          child: Row(
                            children: [
                              Image.network(
                                team.team["team"]["logo"],
                                width: 20,
                                height: 20,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.sports_soccer, size: 20),
                              ),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  team.team["team"]["name"],
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight:
                                        isHighlighted
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        paddedText("${team.points}", isBold: true),
                        paddedText("${team.played}"),
                        paddedText("${team.won}"),
                        paddedText("${team.drawn}"),
                        paddedText("${team.lost}"),
                        paddedText("${team.goalsFor}"),
                        paddedText("${team.goalsAgainst}"),
                        paddedText("${team.goalsFor - team.goalsAgainst}"),
                        buildFormWidget(team.form),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHistoryTab() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Storico Campionato",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            // Selettore giornata
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.currentMatchday,
                itemBuilder: (context, index) {
                  int matchday = index + 1;
                  bool isSelected = matchday == selectedMatchday;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => changeMatchday(matchday),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            "$matchday",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 16),

            // Risultati della giornata selezionata
            if (allMatchdayResults.containsKey(selectedMatchday))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Risultati Giornata $selectedMatchday",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: allMatchdayResults[selectedMatchday]!.length,
                    itemBuilder: (context, index) {
                      final result =
                          allMatchdayResults[selectedMatchday]![index];
                      return buildMatchResultCard(result);
                    },
                  ),
                ],
              ),

            SizedBox(height: 16),

            // Classifica della giornata selezionata
            if (historicalStandings.containsKey(selectedMatchday))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Classifica dopo Giornata $selectedMatchday",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  buildStandingsTab(historicalStandings[selectedMatchday]!),
                ],
              ),

            // Andamento grafico squadre top
            SizedBox(height: 16),
            Text(
              "Andamento prime 5 squadre",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(height: 200, child: buildTeamProgressChart()),
          ],
        ),
      ),
    );
  }

  Widget buildTeamProgressChart() {
    // Prendi solo le prime 5 squadre dalla classifica attuale
    List<TeamStanding> topTeams = currentStandings.take(5).toList();

    // Crea un mapping per i colori delle squadre
    Map<String, Color> teamColors = {
      topTeams[0].team["team"]["id"].toString(): Colors.red,
      topTeams[1].team["team"]["id"].toString(): Colors.blue,
      topTeams[2].team["team"]["id"].toString(): Colors.green,
      topTeams[3].team["team"]["id"].toString(): Colors.purple,
      topTeams[4].team["team"]["id"].toString(): Colors.orange,
    };

    return CustomPaint(
      painter: TeamProgressPainter(
        historicalStandings: historicalStandings,
        teamColors: teamColors,
        topTeams: topTeams,
        maxMatchday: widget.currentMatchday,
      ),
      child: Container(),
    );
  }

  Widget buildMatchResultCard(MatchResult result) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      color: result.isUserMatch ? Colors.blue.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Image.network(
                    result.homeTeam["team"]["logo"],
                    width: 30,
                    height: 30,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Icon(Icons.sports_soccer, size: 30),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      result.homeTeam["team"]["name"],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "${result.homeScore} - ${result.awayScore}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: result.isUserMatch ? Colors.blue.shade800 : null,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      result.awayTeam["team"]["name"],
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 8),
                  Image.network(
                    result.awayTeam["team"]["logo"],
                    width: 30,
                    height: 30,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Icon(Icons.sports_soccer, size: 30),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFormWidget(List<String> form) {
    List<String> recentForm =
        form.length > 5 ? form.sublist(form.length - 5) : form;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            recentForm.map((result) {
              Color color;
              if (result == 'W') {
                color = Colors.green;
              } else if (result == 'D') {
                color = Colors.amber;
              } else {
                color = Colors.red;
              }

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 1),
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    result,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget paddedText(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}

class SharedPreferences {
  static getInstance() {}
}

class TeamProgressPainter extends CustomPainter {
  final Map<int, List<TeamStanding>> historicalStandings;
  final Map<String, Color> teamColors;
  final List<TeamStanding> topTeams;
  final int maxMatchday;

  TeamProgressPainter({
    required this.historicalStandings,
    required this.teamColors,
    required this.topTeams,
    required this.maxMatchday,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Disegna gli assi
    final axisPaint =
        Paint()
          ..color = Colors.grey
          ..strokeWidth = 1;

    // Asse Y (posizioni 1-20)
    canvas.drawLine(Offset(40, 10), Offset(40, size.height - 20), axisPaint);

    // Asse X (giornate)
    canvas.drawLine(
      Offset(40, size.height - 20),
      Offset(size.width - 10, size.height - 20),
      axisPaint,
    );

    // Disegna le linee di griglia orizzontali
    for (int i = 0; i < 5; i++) {
      double y = 10 + (i * ((size.height - 30) / 4));
      canvas.drawLine(
        Offset(38, y),
        Offset(size.width - 10, y),
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..strokeWidth = 0.5,
      );

      // Etichette posizioni
      TextPainter(
          text: TextSpan(
            text: "${i * 5 + 1}",
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(20, y - 5));
    }

    // Disegna le etichette delle giornate
    for (int i = 0; i < maxMatchday; i += 5) {
      if (i == 0) continue;
      double x = 40 + (i * ((size.width - 50) / maxMatchday));
      canvas.drawLine(
        Offset(x, size.height - 18),
        Offset(x, size.height - 22),
        axisPaint,
      );

      TextPainter(
          text: TextSpan(
            text: "${i + 1}",
            style: TextStyle(color: Colors.black, fontSize: 10),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(x - 5, size.height - 15));
    }

    // Disegna le linee di andamento per ogni squadra
    for (var team in topTeams) {
      String teamId = team.team["team"]["id"].toString();
      Color teamColor = teamColors[teamId] ?? Colors.grey;

      final linePaint =
          Paint()
            ..color = teamColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

      final path = Path();
      bool first = true;

      // Trova la posizione in classifica della squadra per ogni giornata
      for (int matchday = 1; matchday <= maxMatchday; matchday++) {
        if (historicalStandings.containsKey(matchday)) {
          List<TeamStanding> standings = historicalStandings[matchday]!;
          int position =
              standings.indexWhere(
                (standing) =>
                    standing.team["team"]["id"] == team.team["team"]["id"],
              ) +
              1;

          double x = 40 + (matchday * ((size.width - 50) / maxMatchday));
          double y = 10 + ((position - 1) * ((size.height - 30) / 20));

          if (first) {
            path.moveTo(x, y);
            first = false;
          } else {
            path.lineTo(x, y);
          }
        }
      }

      canvas.drawPath(path, linePaint);

      // Disegna il nome della squadra all'ultima posizione
      if (historicalStandings.containsKey(maxMatchday)) {
        List<TeamStanding> standings = historicalStandings[maxMatchday]!;
        int position =
            standings.indexWhere(
              (standing) =>
                  standing.team["team"]["id"] == team.team["team"]["id"],
            ) +
            1;

        double x = size.width - 5;
        double y = 10 + ((position - 1) * ((size.height - 30) / 20));

        TextPainter(
            text: TextSpan(
              text: team.team["team"]["name"],
              style: TextStyle(
                color: teamColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          )
          ..layout(maxWidth: 100)
          ..paint(canvas, Offset(x - 100, y - 5));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class MatchResult {
  final Map homeTeam;
  final Map awayTeam;
  final int homeScore;
  final int awayScore;
  final bool isUserMatch;
  final int matchday;

  MatchResult({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.isUserMatch,
    required this.matchday,
  });

  // Converte il risultato in formato JSON per il salvataggio
  Map<String, dynamic> toJson() {
    return {
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'isUserMatch': isUserMatch,
      'matchday': matchday,
    };
  }

  // Crea un MatchResult da un JSON
  factory MatchResult.fromJson(Map<String, dynamic> json) {
    return MatchResult(
      homeTeam: json['homeTeam'],
      awayTeam: json['awayTeam'],
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      isUserMatch: json['isUserMatch'],
      matchday: json['matchday'],
    );
  }
}

class TeamStanding {
  final Map team;
  int points = 0;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  List<String> form = []; // 'W', 'D', 'L'

  TeamStanding({required this.team});

  // Converte lo standing in formato JSON per il salvataggio
  Map<String, dynamic> toJson() {
    return {
      'team': team,
      'points': points,
      'played': played,
      'won': won,
      'drawn': drawn,
      'lost': lost,
      'goalsFor': goalsFor,
      'goalsAgainst': goalsAgainst,
      'form': form,
    };
  }

  // Crea un TeamStanding da un JSON
  factory TeamStanding.fromJson(Map<String, dynamic> json) {
    return TeamStanding(team: json['team'])
      ..points = json['points']
      ..played = json['played']
      ..won = json['won']
      ..drawn = json['drawn']
      ..lost = json['lost']
      ..goalsFor = json['goalsFor']
      ..goalsAgainst = json['goalsAgainst']
      ..form = List<String>.from(json['form']);
  }
}
