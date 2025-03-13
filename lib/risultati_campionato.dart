import 'dart:math';
import 'package:flutter/material.dart';

class RisultatiCampionato extends StatelessWidget {
  final Map homeTeam;
  final Map awayTeam;
  final int homeScore;
  final int awayScore;
  final int leagueId;
  final List<Map> allTeams;

  RisultatiCampionato({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.leagueId,
    required this.allTeams,
  });

  @override
  Widget build(BuildContext context) {
    final Random random = Random();
    final List<MatchResult> results = _generateRealisticResults();

    // Calcola la classifica basata sui risultati generati
    List<TeamStanding> standings = _calculateStandings(results);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Risultati e Classifica"),
          bottom: TabBar(
            tabs: [Tab(text: "Risultati Giornata"), Tab(text: "Classifica")],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab dei risultati della giornata
            ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade100,
                  child: Center(
                    child: Text(
                      "Giornata ${random.nextInt(38) + 1}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    // Evidenzia la partita del giocatore
                    bool isPlayerMatch =
                        result.homeTeam['team']['id'] ==
                            homeTeam['team']['id'] &&
                        result.awayTeam['team']['id'] == awayTeam['team']['id'];

                    return Card(
                      elevation: isPlayerMatch ? 8 : 2,
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: isPlayerMatch ? Colors.amber.shade50 : null,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    result.homeTeam['team']['name'],
                                    style: TextStyle(
                                      fontWeight:
                                          isPlayerMatch
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Image.network(
                                    result.homeTeam['team']['logo'],
                                    width: 30,
                                    height: 30,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isPlayerMatch
                                            ? Colors.amber.shade100
                                            : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "${result.homeScore} - ${result.awayScore}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Image.network(
                                    result.awayTeam['team']['logo'],
                                    width: 30,
                                    height: 30,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    result.awayTeam['team']['name'],
                                    style: TextStyle(
                                      fontWeight:
                                          isPlayerMatch
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                    ),
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

            // Tab della classifica
            ListView(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.blue.shade100,
                  child: Center(
                    child: Text(
                      _getLeagueName(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    columnWidths: {
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(3),
                      2: FixedColumnWidth(40),
                      3: FixedColumnWidth(40),
                      4: FixedColumnWidth(40),
                      5: FixedColumnWidth(40),
                      6: FixedColumnWidth(40),
                      7: FixedColumnWidth(40),
                    },
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    children: [
                      // Intestazione tabella
                      TableRow(
                        decoration: BoxDecoration(color: Colors.grey.shade200),
                        children: [
                          Center(
                            child: Text(
                              '#',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 4.0,
                            ),
                            child: Text(
                              'Squadra',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'PG',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'V',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'P',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'S',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'DR',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Pt',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      // Righe squadre
                      ...standings.asMap().entries.map((entry) {
                        int index = entry.key;
                        TeamStanding team = entry.value;
                        bool isUserTeam =
                            team.teamId == homeTeam['team']['id'] ||
                            team.teamId == awayTeam['team']['id'];

                        Color? rowColor;
                        if (isUserTeam) {
                          rowColor = Colors.amber.shade50;
                        } else if (index < 4) {
                          rowColor = Colors.blue.shade50;
                        } else if (index >= standings.length - 3) {
                          rowColor = Colors.red.shade50;
                        }

                        return TableRow(
                          decoration: BoxDecoration(color: rowColor),
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight:
                                        isUserTeam
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Row(
                                children: [
                                  Image.network(
                                    team.logo,
                                    width: 20,
                                    height: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      team.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight:
                                            isUserTeam
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(child: Text('${team.played}')),
                            Center(child: Text('${team.won}')),
                            Center(child: Text('${team.drawn}')),
                            Center(child: Text('${team.lost}')),
                            Center(child: Text('${team.goalDifference}')),
                            Center(
                              child: Text(
                                '${team.points}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        color: Colors.blue.shade50,
                      ),
                      SizedBox(width: 8),
                      Text("Zona Champions League"),
                      SizedBox(width: 16),
                      Container(
                        width: 16,
                        height: 16,
                        color: Colors.red.shade50,
                      ),
                      SizedBox(width: 8),
                      Text("Zona Retrocessione"),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Genera risultati realistici per tutte le partite della giornata
  List<MatchResult> _generateRealisticResults() {
    final Random random = Random();
    final List<Map> otherTeams =
        allTeams
            .where(
              (team) =>
                  team['team']['id'] != homeTeam['team']['id'] &&
                  team['team']['id'] != awayTeam['team']['id'],
            )
            .toList();

    // Mescola le squadre per creare accoppiamenti casuali
    otherTeams.shuffle(random);

    // Crea la lista di risultati
    List<MatchResult> results = [];

    // Aggiungi la partita del giocatore
    results.add(
      MatchResult(
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        homeScore: homeScore,
        awayScore: awayScore,
      ),
    );

    // Genera il resto delle partite della giornata
    for (int i = 0; i < otherTeams.length - 1; i += 2) {
      if (i + 1 < otherTeams.length) {
        // Assegna forza relativa alle squadre basata su un ranking simulato
        double homeStrength = _getTeamStrength(otherTeams[i]['team']['id']);
        double awayStrength = _getTeamStrength(otherTeams[i + 1]['team']['id']);

        // La forza relativa influenza il punteggio, ma c'è comunque casualità
        double homeScoreProbability = 1.0 + (homeStrength - awayStrength) / 3.0;
        if (homeScoreProbability < 0.5) homeScoreProbability = 0.5;

        double awayScoreProbability = 1.0 + (awayStrength - homeStrength) / 3.0;
        if (awayScoreProbability < 0.5) awayScoreProbability = 0.5;

        // Genera punteggi più realistici (i gol seguono una distribuzione più realistica)
        int homeScoreResult = _generateRealisticScore(homeScoreProbability);
        int awayScoreResult = _generateRealisticScore(awayScoreProbability);

        results.add(
          MatchResult(
            homeTeam: otherTeams[i],
            awayTeam: otherTeams[i + 1],
            homeScore: homeScoreResult,
            awayScore: awayScoreResult,
          ),
        );
      }
    }

    return results;
  }

  // Genera un punteggio realistico basato sulla forza della squadra
  int _generateRealisticScore(double strength) {
    final Random random = Random();
    double baseChance = random.nextDouble() * strength;

    // Distribuzione più realistica dei gol
    if (baseChance < 1.0) return 0;
    if (baseChance < 2.3) return 1;
    if (baseChance < 3.3) return 2;
    if (baseChance < 3.9) return 3;
    if (baseChance < 4.3) return 4;
    return random.nextInt(3) + 3; // Raramente 3-5 gol
  }

  // Simula la forza di una squadra basata sul suo ID (in realtà si potrebbe usare un ranking reale)
  double _getTeamStrength(int teamId) {
    // Usa l'ID come seme per generare un valore di forza pseudo-casuale ma consistente
    final Random random = Random(teamId);
    return 0.5 + random.nextDouble() * 2.0; // Valore tra 0.5 e 2.5
  }

  // Calcola la classifica basata sui risultati generati
  List<TeamStanding> _calculateStandings(List<MatchResult> results) {
    Map<int, TeamStanding> standingsMap = {};

    // Inizializza le classifiche con tutte le squadre
    for (var team in allTeams) {
      int teamId = team['team']['id'];
      standingsMap[teamId] = TeamStanding(
        teamId: teamId,
        name: team['team']['name'],
        logo: team['team']['logo'],
      );
    }

    // Simula 10-20 giornate passate per avere una classifica più realistica
    final Random random = Random();
    int pastMatchdays = random.nextInt(11) + 10; // 10-20 giornate

    for (int matchday = 0; matchday < pastMatchdays; matchday++) {
      List<MatchResult> pastResults = [];
      List<Map> shuffledTeams = List.from(allTeams);
      shuffledTeams.shuffle(random);

      for (int i = 0; i < shuffledTeams.length - 1; i += 2) {
        if (i + 1 < shuffledTeams.length) {
          double homeStrength = _getTeamStrength(
            shuffledTeams[i]['team']['id'],
          );
          double awayStrength = _getTeamStrength(
            shuffledTeams[i + 1]['team']['id'],
          );

          int homeScoreResult = _generateRealisticScore(homeStrength);
          int awayScoreResult = _generateRealisticScore(awayStrength);

          pastResults.add(
            MatchResult(
              homeTeam: shuffledTeams[i],
              awayTeam: shuffledTeams[i + 1],
              homeScore: homeScoreResult,
              awayScore: awayScoreResult,
            ),
          );
        }
      }

      // Aggiorna la classifica con i risultati passati
      for (var result in pastResults) {
        _updateStandings(standingsMap, result);
      }
    }

    // Aggiorna la classifica con i risultati della giornata attuale
    for (var result in results) {
      _updateStandings(standingsMap, result);
    }

    // Converti mappa in lista e ordina
    List<TeamStanding> standings = standingsMap.values.toList();
    standings.sort((a, b) {
      // Ordine per punti
      if (a.points != b.points) return b.points.compareTo(a.points);
      // Se pari punti, ordina per differenza reti
      if (a.goalDifference != b.goalDifference)
        return b.goalDifference.compareTo(a.goalDifference);
      // Se pari differenza reti, ordina per gol fatti
      return b.goalsFor.compareTo(a.goalsFor);
    });

    return standings;
  }

  // Aggiorna la classifica con un risultato
  void _updateStandings(Map<int, TeamStanding> standings, MatchResult result) {
    int homeTeamId = result.homeTeam['team']['id'];
    int awayTeamId = result.awayTeam['team']['id'];

    // Aggiorna statistiche squadra di casa
    standings[homeTeamId]!.played++;
    standings[homeTeamId]!.goalsFor += result.homeScore;
    standings[homeTeamId]!.goalsAgainst += result.awayScore;

    // Aggiorna statistiche squadra ospite
    standings[awayTeamId]!.played++;
    standings[awayTeamId]!.goalsFor += result.awayScore;
    standings[awayTeamId]!.goalsAgainst += result.homeScore;

    // Determina il risultato
    if (result.homeScore > result.awayScore) {
      // Vittoria casa
      standings[homeTeamId]!.won++;
      standings[homeTeamId]!.points += 3;
      standings[awayTeamId]!.lost++;
    } else if (result.homeScore < result.awayScore) {
      // Vittoria ospiti
      standings[awayTeamId]!.won++;
      standings[awayTeamId]!.points += 3;
      standings[homeTeamId]!.lost++;
    } else {
      // Pareggio
      standings[homeTeamId]!.drawn++;
      standings[homeTeamId]!.points += 1;
      standings[awayTeamId]!.drawn++;
      standings[awayTeamId]!.points += 1;
    }

    // Aggiorna differenza reti
    standings[homeTeamId]!.goalDifference =
        standings[homeTeamId]!.goalsFor - standings[homeTeamId]!.goalsAgainst;
    standings[awayTeamId]!.goalDifference =
        standings[awayTeamId]!.goalsFor - standings[awayTeamId]!.goalsAgainst;
  }

  // Ottieni il nome del campionato in base all'ID
  String _getLeagueName() {
    switch (leagueId) {
      case 39:
        return "Premier League";
      case 140:
        return "La Liga";
      case 61:
        return "Ligue 1";
      case 78:
        return "Bundesliga";
      case 135:
        return "Serie A";
      case 88:
        return "Eredivisie";
      default:
        return "Campionato";
    }
  }
}

// Classe per rappresentare un risultato di partita
class MatchResult {
  final Map homeTeam;
  final Map awayTeam;
  final int homeScore;
  final int awayScore;

  MatchResult({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
  });
}

// Classe per rappresentare la classifica di una squadra
class TeamStanding {
  final int teamId;
  final String name;
  final String logo;
  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int goalDifference = 0;
  int points = 0;

  TeamStanding({required this.teamId, required this.name, required this.logo});
}
