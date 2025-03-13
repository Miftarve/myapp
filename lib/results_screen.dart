// results_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';

class RisultatiCampionatoScreen extends StatefulWidget {
  final List teams;
  final Map homeTeam;
  final Map awayTeam;
  final int homeScore;
  final int awayScore;

  RisultatiCampionatoScreen({
    required this.teams,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });

  @override
  _RisultatiCampionatoScreenState createState() =>
      _RisultatiCampionatoScreenState();
}

class _RisultatiCampionatoScreenState extends State<RisultatiCampionatoScreen> {
  late List<MatchResult> results = [];
  late List<TeamStanding> standings = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    generateMatchResults();
    calculateStandings();
  }

  void generateMatchResults() {
    // Aggiungi il risultato della partita che l'utente ha appena giocato
    results.add(
      MatchResult(
        homeTeam: widget.homeTeam,
        awayTeam: widget.awayTeam,
        homeScore: widget.homeScore,
        awayScore: widget.awayScore,
        isUserMatch: true,
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

        results.add(
          MatchResult(
            homeTeam: teamsCopy[i],
            awayTeam: teamsCopy[i + 1],
            homeScore: homeScore,
            awayScore: awayScore,
            isUserMatch: false,
          ),
        );
      }
    }
  }

  void calculateStandings() {
    // Inizializza la classifica con tutte le squadre
    for (var team in widget.teams) {
      standings.add(TeamStanding(team: team));
    }

    // Aggiorna la classifica in base ai risultati
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
      } else if (result.homeScore < result.awayScore) {
        // Vittoria squadra ospite
        awayStanding.points += 3;
        awayStanding.won++;
        homeStanding.lost++;
      } else {
        // Pareggio
        homeStanding.points += 1;
        awayStanding.points += 1;
        homeStanding.drawn++;
        awayStanding.drawn++;
      }
    }

    // Ordina la classifica per punti (decrescente) e differenza reti
    standings.sort((a, b) {
      if (a.points != b.points) {
        return b.points.compareTo(a.points);
      } else {
        int diffA = a.goalsFor - a.goalsAgainst;
        int diffB = b.goalsFor - b.goalsAgainst;
        return diffB.compareTo(diffA);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Risultati della Giornata"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sezione dei risultati
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Risultati della Giornata",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
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
                                    color:
                                        result.isUserMatch
                                            ? Colors.blue.shade800
                                            : null,
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Tabella classifica
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Classifica",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Table(
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
                    },
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
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
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Torna alla selezione squadre"),
            ),
          ),
        ],
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

class MatchResult {
  final Map homeTeam;
  final Map awayTeam;
  final int homeScore;
  final int awayScore;
  final bool isUserMatch;

  MatchResult({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.isUserMatch,
  });
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

  TeamStanding({required this.team});
}
